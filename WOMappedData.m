// WOMappedData.m
// WODebug
//
// Copyright 2006-2009 Wincent Colaiuta.

// class header
#import "WOMappedData.h"

// system headers
#import <fcntl.h>           /* O_RDONLY */
#import <unistd.h>          /* lseek() */
#import <mach/vm_map.h>     /* vm_allocate(), vm_deallocate() */

// WOPublic headers
#import "WOPublic/WODebugMacros.h"

// WOCommon headers
#import "WOCommon/WOConvenienceMacros.h"

@implementation WOMappedData

+ (id)dataWithContentsOfFile:(NSString *)path
{
    WOParameterCheck(path != nil);
    return [[self alloc] initWithContentsOfFile:path];
}

- (id)initWithContentsOfFile:(NSString *)path
{
    if ((self = [super init]))
    {
        WOParameterCheck(path != nil);
        int     err     = 0;
        BOOL    success = NO;

        // open the file
        int file = open([path fileSystemRepresentation], O_RDONLY);
        if (file < 0)
        {
            err = errno;
            NSLog(@"error: open() %d: %s", err, strerror(err));
        }

        // check length of file
        off_t fileSize;
        if (err == 0)
        {
            fileSize = lseek(file, 0, SEEK_END);
            if (fileSize < 0)
            {
                err = errno;
                NSLog(@"error: lseek() %d: %s", err, strerror(err));
            }
        }

        // check length of file is not too large for address space
        if (err == 0)
        {
            bufferSize = (size_t)fileSize;                                                  // perform cast
            if ((off_t)bufferSize != fileSize)                                              // was any information lost in cast?
            {
                err = errno = EFBIG;                                                        // "File too large"
                NSLog(@"error: lseek() %d: %s", err, strerror(err));
            }
        }

        // allocate the buffer
        if (err == 0)
        {
            err = vm_allocate(mach_task_self(), (vm_address_t *)&buffer, bufferSize, VM_FLAGS_ANYWHERE);
            if (err != KERN_SUCCESS)
            {
                err = errno = ENOMEM;                                                       // "Cannot allocate memory"
                NSLog(@"error: vm_allocate() %d: %s", err, strerror(err));
            }
            else
                err = 0;
        }

        // read the file
        ssize_t bytesRead;
        if (err == 0)
        {
            bytesRead = pread(file, (void *)buffer, bufferSize, 0);
            if (bytesRead < 0)
            {
                NSLog(@"error: pread() %d: %s", err, strerror(err));
                err = vm_deallocate(mach_task_self(), (vm_address_t)buffer, bufferSize);
                if (err != KERN_SUCCESS)
                    NSLog(@"error: vm_deallocate() %d", err);
            }
            else if (bytesRead != bufferSize)
            {
                errno = EPIPE;                                                              // "Broken pipe"
                NSLog(@"error: pread() %d: %s", err, strerror(err));
                err = vm_deallocate(mach_task_self(), (vm_address_t)buffer, bufferSize);
                if (err != KERN_SUCCESS)
                    NSLog(@"error: vm_deallocate() %d", err);
            }
            else                                                                            // file was successfully read
            {
                if ((embeddedData = [[NSData alloc] initWithBytesNoCopy:(void *)buffer length:bufferSize freeWhenDone:NO]))
                    success = YES;
            }
        }

        if (file >= 0)
        {
            if (close(file) != 0)
                NSLog(@"error: close() %d: %s", err, strerror(err));
        }

        if (!success)
            self = nil;
    }
    return self;
}

- (void)finalize
{
    if (buffer)
    {
        kern_return_t err = vm_deallocate(mach_task_self(), (vm_address_t)buffer, bufferSize);
        if (err != KERN_SUCCESS)
            NSLog(@"error: vm_deallocate() %d", err);
    }
    [super finalize];
}

- (ssize_t)size
{
    return bufferSize;
}

- (const void *)bytes
{
    return buffer;
}

- (NSData *)embeddedData
{
    return embeddedData;
}

@end
