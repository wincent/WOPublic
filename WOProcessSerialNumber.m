//
//  WOProcessSerialNumber.m
//  WOCommon
//
//  Created by Wincent Colaiuta on 21 May 2003.
//  Copyright 2003-2008 Wincent Colaiuta.

// class header
#import "WOProcessSerialNumber.h"

// WOCommon class headers
#import "WOLogManager.h"

// WOCommon other headers
#import "WODebugMacros.h"

@implementation WOProcessSerialNumber

// Used for comparisons with "NoProcess" value
static ProcessSerialNumber WONoProcess;

#pragma mark -
#pragma mark NSObject overrides

+ (void)initialize
{
    // set up "WONoProcess" constant
    WONoProcess.highLongOfPSN   = 0;
    WONoProcess.lowLongOfPSN    = kNoProcess;
}

+ (WOProcessSerialNumber *)noProcess
{
    return [[self alloc] initWithPSN:WONoProcess];
}

// designated initialiser
- (id)initWithPSN:(ProcessSerialNumber)newPSN
{
    if ((self = [super init]))
        self->PSN = newPSN;
    return self;
}

// convenience constructor
+ (WOProcessSerialNumber *)processSerialNumberWithPSN:(ProcessSerialNumber)newPSN
{
    return [[self alloc] initWithPSN:newPSN];
}

// convenience constructor
+ (WOProcessSerialNumber *)processSerialNumberWithPID:(pid_t)aPid
{
    // psn will be "noProcess" if no match found for that pid
    return [[self alloc] initWithPSN:[self PSNForPID:aPid]];
}

// other convenience methods
- (BOOL)isNoProcess
{
    return [self isEqualToPSN:WONoProcess];
}

- (BOOL)isEqualToPSN:(ProcessSerialNumber)aPSN
{
    Boolean result;
    OSErr err = SameProcess(&PSN, &aPSN, &result);
    if (err == noErr)
        return (BOOL)result;
    [WOLog err:@"SameProcess" no:err];
    return NO;
}

- (unsigned long)highLongOfPSN
{
    return PSN.highLongOfPSN;
}

- (unsigned long)lowLongOfPSN
{
    return PSN.lowLongOfPSN;
}

- (void)setHighLongOfPSN:(unsigned long)newHighLongOfPSN
{
    PSN.highLongOfPSN = newHighLongOfPSN;
}

- (void)setLowLongOfPSN:(unsigned long)newLowLongOfPSN
{
    PSN.lowLongOfPSN = newLowLongOfPSN;
}

// class method for returning a PSN given a Unix PID
+ (ProcessSerialNumber)PSNForPID:(pid_t)aPid
{
    ProcessSerialNumber returnValue;
    OSStatus err = GetProcessForPID(aPid, &returnValue);
    if (err == noErr)
        return returnValue;
    if (err != procNotFound)
        [WOLog err:@"GetProcessForPID" no:err]; // procNotFound is a "harmless" error; log all others
    return WONoProcess;
}

// class method for returning Unix PID for a given PSN
+ (pid_t)PIDForPSN:(ProcessSerialNumber)aPSN
{
    pid_t returnValue;
    OSStatus err = GetProcessPID(&aPSN, &returnValue);
    if (err == noErr)
        return returnValue;
    if (err != procNotFound)
        [WOLog err:@"GetProcessPID" no:err];    // procNotFound is a "harmless" error; log all others
    return 0;
}

// return a Unix pid for a given PSN
- (pid_t)PID
{
    return [[self class] PIDForPSN:[self PSN]];
}

#pragma mark -
#pragma mark Accessors

- (ProcessSerialNumber)PSN
{
    return PSN;
}

- (void)setPSN:(ProcessSerialNumber)newPSN
{
    PSN = newPSN;
}

@end
