// WOKernelQueue.m
// WODebug (formerly part of WOBase)
//
// Copyright 2005-2009 Wincent Colaiuta.

// class header
#import "WOKernelQueue.h"

// system headers
#import <sys/types.h>   /* getpid() */
#import <sys/event.h>
#import <sys/time.h>
#import <unistd.h>      /* close(), getpid() */
#import <fcntl.h>       /* O_RDONLY */

// WOPublic headers
#import "WOPublic/WOConvenienceMacros.h"
#import "WOPublic/WODebugMacros.h"

// WOCommon headers
#import "WOCommon/WOEnumerate.h"

#pragma mark -
#pragma mark Dictionary key macros

#define WO_PATH_KEY         @"WOPath"
#define WO_DESCRIPTOR_KEY   @"WODescriptor"

#pragma mark -
#pragma mark Global strings

WO_EXPORT NSString *WOKernelQueueDeleteNotification = @"WOKernelQueueDeleteNotification";
WO_EXPORT NSString *WOKernelQueueWriteNotification  = @"WOKernelQueueWriteNotification";
WO_EXPORT NSString *WOKernelQueueExtendNotification = @"WOKernelQueueExtendNotification";
WO_EXPORT NSString *WOKernelQueueAttribNotification = @"WOKernelQueueAttribNotification";
WO_EXPORT NSString *WOKernelQueueLinkNotification   = @"WOKernelQueueLinkNotification";
WO_EXPORT NSString *WOKernelQueueRenameNotification = @"WOKernelQueueRenameNotification";
WO_EXPORT NSString *WOKernelQueueRevokeNotification = @"WOKernelQueueRevokeNotification";

@implementation WOKernelQueue

- (id)init
{
    return [self initWithPaths:[NSArray array] notify:WO_DEFAULT_KQUEUE_FLAGS];
}

- (id)initWithPath:(NSString *)aPath
{
    WOParameterCheck(aPath != nil);
    return [self initWithPaths:[NSArray arrayWithObject:aPath] notify:WO_DEFAULT_KQUEUE_FLAGS];
}

- (id)initWithPath:(NSString *)aPath notify:(u_int)fflags
{
    WOParameterCheck(aPath != nil);
    return [self initWithPaths:[NSArray arrayWithObject:aPath] notify:fflags];
}

- (id)initWithPaths:(NSArray *)paths
{
    WOParameterCheck(paths != nil);
    return [self initWithPaths:paths notify:WO_DEFAULT_KQUEUE_FLAGS];
}

- (id)initWithPaths:(NSArray *)paths notify:(u_int)fflags
{
    // designated initializer
    WOParameterCheck(paths != nil);

    if ((self = [super init]))
    {
        if ((kernelQueue = kqueue()) == -1) // fatal error, must bail
        {
            NSLog(@"error: kqueue() (errno = %d)", errno);
            return nil;
        }

        // ensure that SIGIO is ignored by the usual handler (if any)
        signal(SIGIO, SIG_IGN);

        // and add it to the queue; where it will be is used to terminate thread
        struct kevent event;
        struct timespec timeout = {0, 0};
        EV_SET(&event, SIGIO, EVFILT_SIGNAL, EV_ADD, 0, 0, NULL);
        if (kevent(kernelQueue, &event, 1, NULL, 0, &timeout) == -1)
            NSLog(@"error: kevent() (errno = %d)", errno);

        monitoredPaths = [[NSMutableArray alloc] initWithCapacity:[paths count]];
        [NSThread detachNewThreadSelector:@selector(watchKernelQueueInDetachedThread:) toTarget:self withObject:nil];
        [self addPaths:paths notify:fflags];
    }
    return self;
}

- (void)finalize
{
    kernelQueue = -1;       // signal to thread to exit while loop
    kill(getpid(), SIGIO);
    [self removeAllPaths];  // closes open file descriptors
    [super finalize];
}

- (void)addPath:(NSString *)aPath
{
    if (!aPath) return;
    [self addPath:aPath notify:WO_DEFAULT_KQUEUE_FLAGS];
}

- (void)addPaths:(NSArray *)paths
{
    if (!paths) return;
    for (id path in paths)
        [self addPath:path notify:WO_DEFAULT_KQUEUE_FLAGS];
}

// TODO: find out what happens if i add the same path twice

- (void)addPath:(NSString *)aPath notify:(u_int)fflags
{
    struct kevent       event;
    struct timespec     timeout     = {0, 0};
    int                 descriptor  = open([aPath fileSystemRepresentation], O_RDONLY, 0);
    if (descriptor >= 0)
    {
        EV_SET(&event, descriptor, EVFILT_VNODE, EV_ADD|EV_CLEAR, fflags, 0, (void *)aPath);

        NSDictionary *pathInfo = [NSDictionary dictionaryWithObjectsAndKeys:
            aPath,                                  WO_PATH_KEY,
            [NSNumber numberWithInt:descriptor],    WO_DESCRIPTOR_KEY,
            nil];

        [monitoredPaths addObject:pathInfo];

        int event_count = kevent(kernelQueue, &event, 1, NULL, 0, &timeout);
        if (event_count == -1)
        {
            NSLog(@"error: kevent() (errno = %d) adding path \"%@\"", errno, aPath);
            [monitoredPaths removeObject:pathInfo];
            if (close(descriptor) == -1)
                NSLog(@"error: close() (errno = %d) closing path \"%@\"", errno, aPath);
        }
    }
    else
        NSLog(@"warning: Couldn't open path \"%@\" for reading", aPath);
}

- (void)addPaths:(NSArray *)paths notify:(u_int)fflags
{
    if (!paths)return;
    for (id path in paths)
        [self addPath:path notify:fflags];
}

- (void)removePath:(NSString *)aPath
{
    if (!aPath) return;

    for (NSDictionary *dictionary in monitoredPaths)
    {
        NSString *path = [dictionary objectForKey:WO_PATH_KEY];
        if (path && [path isEqualToString:aPath]) // match found
        {
            NSNumber *descriptor = [dictionary objectForKey:WO_DESCRIPTOR_KEY];
            if (descriptor)
            {
                // closing descriptor removes path from kqueue
                if (close([descriptor intValue]) == -1)
                    NSLog(@"error: close() (errno = %d) closing path \"%@\"", errno, path);
            }
            [monitoredPaths removeObject:dictionary];
            break;
        }
    }
}

- (void)removePaths:(NSArray *)paths
{
    for(id path in paths)
        [self removePath:path];
}

- (void)removeAllPaths
{
    while ([monitoredPaths count] > 0)
    {
        NSString *path = [[monitoredPaths objectAtIndex:0] objectForKey:WO_PATH_KEY];
        [self removePath:path];
    }
}

- (void)watchKernelQueueInDetachedThread:(id)sender
{
    while (kernelQueue != -1)
    {
        __attribute__((unused)) NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];

        struct kevent event;
        int eventCount = kevent(kernelQueue, NULL, 0, &event, 1, NULL);
        if (eventCount > 0)
        {
            if (event.filter == EVFILT_SIGNAL)
            {
                // no op, this is just to get us back to the top of the while
            }
            if ((event.filter == EVFILT_VNODE) && event.flags)
            {
                NSString *path = (NSString *)event.udata;
                NSNotificationCenter *center = [[NSWorkspace sharedWorkspace] notificationCenter];

                // TODO: document that notifications are posted from the detached thread and will therefore be received on the detached thread!
                // alternatively, always post them on the main thread?
                if (event.flags & NOTE_DELETE)
                    [center postNotificationName:WOKernelQueueDeleteNotification    object:path];
                if (event.flags & NOTE_WRITE)
                    [center postNotificationName:WOKernelQueueWriteNotification     object:path];
                if (event.flags & NOTE_EXTEND)
                    [center postNotificationName:WOKernelQueueExtendNotification    object:path];
                if (event.flags & NOTE_ATTRIB)
                    [center postNotificationName:WOKernelQueueAttribNotification    object:path];
                if (event.flags & NOTE_LINK)
                    [center postNotificationName:WOKernelQueueLinkNotification      object:path];
                if (event.flags & NOTE_RENAME)
                    [center postNotificationName:WOKernelQueueRenameNotification    object:path];
                if (event.flags & NOTE_REVOKE)
                    [center postNotificationName:WOKernelQueueRevokeNotification    object:path];
            }
        }
        else if (eventCount == -1)
            NSLog(@"error: kevent() (errno = %d)", errno);
    }
}

@end
