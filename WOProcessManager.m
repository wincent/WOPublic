// WOProcessManager.m
// WOPublic
//
// Copyright 2003-present Greg Hurrell. All rights reserved.
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
#import "WOProcessManager.h"

// macro headers
#import "WODebugMacros.h"
#import "WOMemory.h"
#import "WOMemoryBarrier.h"

// other class headers
#import "WOLogManager.h"
#import "WOProcessSerialNumber.h"

#pragma mark -
#pragma mark Global variables

static WOProcessManager *WOSharedProcessManager = nil;

#pragma mark -

@implementation WOProcessManager

#pragma mark -
#pragma mark Singleton shared instance

+ (WOProcessManager *)sharedManager;
{
    WOProcessManager *manager = WOSharedProcessManager;
    WO_READ_MEMORY_BARRIER();
    if (!manager)
    {
        @synchronized (self)
        {
            manager = WOSharedProcessManager;
            if (!manager)
            {
                manager = [[self alloc] init];
                WO_WRITE_MEMORY_BARRIER();
                WOSharedProcessManager = manager;
            }
        }
    }
    return manager;
}

#pragma mark -
#pragma mark NSObject overrides

- (id)init
{
    if ((self = [super init]))
        self->noProcess = [WOProcessSerialNumber noProcess];
    return self;
}

#pragma mark -
#pragma mark Methods for determining if a process is running

- (BOOL)processRunningWithPSN:(ProcessSerialNumber)PSN
{
    // wrapping these PSNs in objects is probably overkill but at least it makes for nicer looking code
    WOProcessSerialNumber   *desired    = [WOProcessSerialNumber processSerialNumberWithPSN:PSN];
    ProcessSerialNumber     psn         = [noProcess PSN];  // start with "no process" to start from beginning of list
    OSErr                   err;

    if ([desired isNoProcess])          // special case, caller asked if "no process" was running
        return NO;

    while ((err = GetNextProcess(&psn)) == noErr)
    {
        if ([desired isEqualToPSN:psn])
            return YES;
    }
    if (!((err == procNotFound) || (err == noErr)))
        [WOLog err:@"GetNextProcess returned %d", err];
    return NO;
}

- (BOOL)processRunningWithProcessName:(NSString *)name
{
    return [noProcess isEqualToPSN:[self PSNForProcessName:name]] ? NO : YES;
}

- (BOOL)processRunningWithIdentifier:(NSString *)identifier
{
    return [noProcess isEqualToPSN:[self PSNForIdentifier:identifier]] ? NO : YES;
}

- (BOOL)processRunningWithSignature:(UInt32)signature
{
    return [noProcess isEqualToPSN:[self PSNForSignature:signature]] ? NO : YES;
}

#pragma mark -
#pragma mark Methods for determining if a process is hidden

- (BOOL)processHiddenWithSignature:(UInt32)signature
{
    if ([self processRunningWithSignature:signature])
    {
        ProcessSerialNumber PSN = [self PSNForSignature:signature];
        return !IsProcessVisible(&PSN);
    }
    return YES; // if not running, consider it to be hidden
}

#pragma mark -
#pragma mark Methods for controlling process visibility

- (void)hideProcess:(ProcessSerialNumber)PSN
{
    [self setVisibility:NO ofProcess:PSN];
}

- (void)showProcess:(ProcessSerialNumber)PSN
{
    [self setVisibility:YES ofProcess:PSN];
}

- (void)setVisibility:(BOOL)visible ofProcess:(ProcessSerialNumber)PSN
{
    if ([self processRunningWithPSN:PSN])
    {
        OSErr err = ShowHideProcess(&PSN, visible);
        if (err != noErr)
            [WOLog err:@"ShowHideProcess" no:err];
    }
}

#pragma mark -
#pragma mark Methods for determining if a process is frontmost

- (BOOL)processFrontmostWithSignature:(UInt32)signature
{
    ProcessSerialNumber PSN = [self PSNForSignature:signature];
    if ([self processRunningWithPSN:PSN])
    {
        ProcessSerialNumber frontProcess;
        OSErr err = GetFrontProcess(&frontProcess);
        if (err != noErr)
            [WOLog err:@"GetFrontProcess" no:err];
        else
        {
            Boolean result;
            err = SameProcess(&frontProcess, &PSN, &result);
            if (err != noErr)
                [WOLog err:@"SameProcess" no:err];
            else
                return (BOOL)result;
        }
    }
    return NO;  // fallback case: process not running, or other error
}

#pragma mark -
#pragma mark Methods for controlling which process is frontmost

- (void)bringProcessToFront:(ProcessSerialNumber)PSN
{
    if ([self processRunningWithPSN:PSN])
    {
        OSErr err = SetFrontProcess(&PSN);
        if (err != noErr)
            [WOLog err:@"SetFrontProcess" no:err];
    }
}

#pragma mark -
#pragma mark Methods for obtaining a Process Serial Number (PSN) for a process

- (ProcessSerialNumber)PSNForProcessName:(NSString *)name
{
    WOParameterCheck(name != nil);
    BOOL                found   = NO;
    ProcessSerialNumber psn     = [noProcess PSN];  // start with "no process" to start from beginning of list
    OSErr               err;
    while ((found == NO) && ((err = GetNextProcess(&psn)) == noErr))
    {
        CFStringRef processName;
        OSStatus status = CopyProcessName(&psn, &processName);
        if (status != noErr)
        {
            [WOLog err:@"CopyProcessName returned %d", status];
            break;
        }

        if ([name isEqualToString:(NSString *)processName])
            found = YES;
        CFRelease(processName);
    }
    if (!(err == procNotFound || err == noErr))
        [WOLog err:@"GetNextProcess returned %d", err];
    return found ? psn : [noProcess PSN];
}

- (ProcessSerialNumber)PSNForIdentifier:(NSString *)identifier
{
    WOParameterCheck(identifier != nil);
    ProcessSerialNumber     psn             = [noProcess PSN]; // start with "no process" to start from beginning of list
    ProcessInfoRec          info;
    info.processInfoLength                  = sizeof(ProcessInfoRec);
    info.processName                        = NULL;
    info.processAppSpec                     = NULL;
    static OSType           applicationType = 'APPL';
    BOOL                    found           = NO;
    OSErr                   err;
    while ((found == NO) && ((err = GetNextProcess(&psn)) == noErr))
    {
        if ((err = GetProcessInformation(&psn, &info)) == noErr)
        {
            if (info.processType == applicationType)
            {
                FSRef theRef;
                OSStatus status = GetProcessBundleLocation(&psn, &theRef);
                if (status == noErr)
                {
                    NSURL *path = NSMakeCollectable(CFURLCreateFromFSRef(kCFAllocatorDefault, &theRef));
                    if (path)
                    {
                        NSBundle *bundle = [NSBundle bundleWithPath:[path path]];
                        if ([identifier isEqualToString:[bundle bundleIdentifier]])
                            found = YES;
                    }
                }
                else
                    [WOLog err:@"GetProcessBundleLocation returned %d", status];
            }
        }
        else
            [WOLog err:@"GetProcessInformation returned %d", err];
    }
    if (!(err == procNotFound || err == noErr))
        [WOLog err:@"GetNextProcess returned %d", err];
    return found ? psn : [noProcess PSN];
}

- (ProcessSerialNumber)PSNForSignature:(UInt32)signature
{
    ProcessSerialNumber     psn             = [noProcess PSN];  // start with "no process" to start from beginning of list
    ProcessInfoRec          info;
    info.processInfoLength                  = sizeof(ProcessInfoRec);
    info.processName                        = NULL;
    info.processAppSpec                     = NULL;
    static OSType           applicationType = 'APPL';           // will scan for processes with of type "APPL" (application)
    OSErr                   err;
    while ((err = GetNextProcess(&psn)) == noErr)
    {
        if ((err = GetProcessInformation(&psn, &info)) == noErr)
        {
            if ((info.processType == applicationType) && (info.processSignature == signature))
                return info.processNumber;                      // found a match -- process is running -- return the PSN
        }
        else
            [WOLog err:@"GetProcessInformation returned %d", err];
    }
    if (!((err == procNotFound) || (err == noErr)))
        [WOLog err:@"GetNextProcess returned %d", err];
    return [noProcess PSN];                                     // did not find process in list of running processes
}

@end
