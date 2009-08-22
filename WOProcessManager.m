//
//  WOProcessManager.m
//  WOCommon
//
//  Created by Wincent Colaiuta on 20 January 2003.
//  Copyright 2003-2008 Wincent Colaiuta.

// class header
#import "WOProcessManager.h"

// WOCommon headers
#import "WOConvenienceMacros.h"
#import "WOLogManager.h"
#import "WOProcessSerialNumber.h"
#import "WOMemoryBarrier.h"

// WOPublic headers
#import "WOPublic/WODebugMacros.h"
#import "WOPublic/WOMemory.h"

#pragma mark -
#pragma mark Global variables

static WOProcessManager *WOSharedProcessManager = nil;

#pragma mark -

@implementation WOProcessManager
WO_CLASS_EXPORT(WOProcessManager);

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
        WOMakeCollectable(processName);

        if ([name isEqualToString:(NSString *)processName])
            found = YES;
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
