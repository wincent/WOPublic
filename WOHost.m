// WOHost.m
// WOPublic
//
// Copyright 2004-2009 Wincent Colaiuta. All rights reserved.
//
// Redistribution and use in source and binary forms, with or without
// modification, are permitted provided that the following conditions are met:
//
// 1. Redistributions of source code must retain the above copyright notice,
//    this list of conditions and the following disclaimer.
// 2. Redistributions in binary form must reproduce the above copyright notice,
//    this list of conditions and the following disclaimer in the documentation
//    and/or other materials provided with the distribution.
//
// THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS"
// AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE
// IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE
// ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT HOLDERS OR CONTRIBUTORS BE
// LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR
// CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF
// SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS
// INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN
// CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE)
// ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE
// POSSIBILITY OF SUCH DAMAGE.

// class header
#import "WOHost.h"

// system headers
#import <libkern/OSAtomic.h>        /* OSAtomicIncrement32Barrier() */

// macro headers
#import "WOConvenienceMacros.h"
#import "WODebugMacros.h"

// other class headers
#import "WOLogManager.h"


#pragma mark -
#pragma mark Class variables

/*! An auto-maintained list of registered hosts. */
static NSMutableDictionary *WOHostRegisteredHosts = nil;

/*! A separate registry for explicitly managed hosts. */
static NSMutableDictionary *WOHostRegistry = nil;

@interface WOHost ()

- (void)registerForCallbacks;
- (void)unregisterForCallbacks;

#pragma mark -
#pragma mark Private Accessors

- (SCNetworkReachabilityRef)ref;

#pragma mark -
#pragma mark Private properties

@property(readwrite) BOOL reachable;

@end

#pragma mark -
#pragma mark Functions

// once-off initialization called prior to hitting main()
WO_LOAD WOHostLoad()
{
    // this may be paranoid, but ensure that initialization only happens once even in a multi-threaded context
    static int32_t initialized = 0;
    if (OSAtomicIncrement32Barrier(&initialized) == 1)
    {
        WOHostRegisteredHosts   = [NSMutableDictionary dictionary];
        WOHostRegistry          = [NSMutableDictionary dictionary];
    }
}

void WOHostReachabilityCallback(SCNetworkReachabilityRef aRef, SCNetworkConnectionFlags flags, void *info)
{
    if (aRef == NULL || info == NULL) return;

    WOHost *host = (WOHost *)info;

    if ([host ref] != aRef) return;

    if (!(flags & kSCNetworkFlagsConnectionRequired) && (flags & kSCNetworkFlagsReachable))
    {
        if (!host.isReachable)  // reachability has changed
        {
            host.reachable = YES;
            [[NSNotificationCenter defaultCenter] postNotificationName:WOHostDidBecomeReachableNotification object:host];
        }
    }
    else    // host is not reachable
    {
        if (host.isReachable)   // reachability has changed
        {
            host.reachable = NO;
            [[NSNotificationCenter defaultCenter] postNotificationName:WOHostDidBecomeUnreachableNotification object:host];
        }
    }
}

@implementation WOHost
WO_CLASS_EXPORT(WOHost);

#pragma mark -
#pragma mark Shared host registry

+ (WOHost *)hostForHostName:(NSString *)aHostName
{
    WOParameterCheck(aHostName != nil);
    return [WOHostRegistry objectForKey:aHostName];
}

+ (void)setHost:(WOHost *)aHost forHostName:(NSString *)aHostName
{
    WOParameterCheck(aHostName != nil);
    if (aHost)
        WOCheck([aHostName isEqualToString:[aHost hostName]]);

    @synchronized (WOHostRegistry)
    {
        WOHost *host = [WOHostRegistry objectForKey:aHostName];

        if ((aHost == nil) && host)     // remove entry from registry
            [WOHostRegistry removeObjectForKey:aHostName];
        else if (aHost)                 // insert or replace entry in registry
            [WOHostRegistry setObject:aHost forKey:aHostName];
    }
}

#pragma mark -
#pragma mark Creating/obtaining WOHost instances

+ (id)hostWithHostName:(NSString *)aHostName
{
    WOParameterCheck(aHostName != nil);
    WOHost *host = nil;                                         // return value
    @synchronized (WOHostRegisteredHosts)
    {
        host = [WOHostRegisteredHosts objectForKey:aHostName];
        if (!host)
            host = [[self alloc] initWithHostName:aHostName];   // fallback case: create brand new object
    }
    return host;
}

- (id)initWithHostName:(NSString *)aHostName
{
    WOParameterCheck(aHostName != nil);
    @synchronized (WOHostRegisteredHosts)
    {
        // look for pre-existing object for this host
        WOHost *host = [WOHostRegisteredHosts objectForKey:aHostName];
        if (host)
            return host;

        // no pre-existing object found for this host, create a new one
        if ((self = [super init]))
            [self setHostName:aHostName];   // self gets added to WOHostRegisteredHosts dictionary here
    }
    return self;
}

- (void)finalize
{
    @synchronized (WOHostRegisteredHosts)
    {
        NSString *name = [self hostName];
        if (name)
            [WOHostRegisteredHosts removeObjectForKey:name];
        [self setHostName:nil]; // unregisters for callbacks
        [super finalize];
    }
}

- (void)registerForCallbacks
{
    if (![self hostName])
        return;

    SCNetworkConnectionFlags flags;
    context.version         = 0;
    context.info            = self;
    context.retain          = NULL;
    context.release         = NULL;
    context.copyDescription = NULL;

    if (((ref = SCNetworkReachabilityCreateWithName(NULL, [[self hostName] UTF8String])) != NULL) &&
        (SCNetworkReachabilitySetCallback(ref, WOHostReachabilityCallback, &context)) &&
        (SCNetworkReachabilityScheduleWithRunLoop(ref, CFRunLoopGetCurrent(), kCFRunLoopDefaultMode)) &&
        (SCNetworkReachabilityGetFlags(ref, &flags)))
    {
        // successfully registered for callbacks; flags is always zero at this point, but we can expect a callback very soon now
        self.reachable = !(flags & kSCNetworkFlagsConnectionRequired) && (flags & kSCNetworkFlagsReachable);
    }
    else
        [WOLog logError:@"SCNetworkReachability: %s", SCErrorString(SCError())];
}

- (void)unregisterForCallbacks
{
    if (ref)
    {
        (void)SCNetworkReachabilityUnscheduleFromRunLoop(ref, [[NSRunLoop currentRunLoop] getCFRunLoop], kCFRunLoopDefaultMode);
        (void)SCNetworkReachabilitySetCallback(ref, NULL, &context);
        CFMakeCollectable(ref);
    }
}

#pragma mark -
#pragma mark Accessors

- (void)setHostName:(NSString *)aHostName
{
    if (hostName != aHostName)
    {
        @synchronized (WOHostRegisteredHosts)
        {
            if (hostName)
                [WOHostRegisteredHosts removeObjectForKey:hostName];
            [self unregisterForCallbacks];
            hostName = aHostName;
            if (hostName)
            {
                WOHost *host = [WOHostRegisteredHosts objectForKey:hostName];
                if (host)
                    [NSException raise:NSInternalInconsistencyException
                                format:@"pre-existing host name (%@) passed to WOHost setHostName:", hostName];
                else
                    [WOHostRegisteredHosts setObject:self forKey:hostName];
                [self registerForCallbacks];
            }
        }
    }
}

#pragma mark -
#pragma mark Properties

@synthesize hostName;
@synthesize reachable;

- (SCNetworkReachabilityRef)ref
{
    return ref;
}

@end

#pragma mark -
#pragma mark Notifications

WO_EXPORT NSString *WOHostDidBecomeReachableNotification      = @"WOHostDidBecomeReachableNotification";
WO_EXPORT NSString *WOHostDidBecomeUnreachableNotification    = @"WOHostDidBecomeUnreachableNotification";
