// WOProcessSerialNumber.m
// WOPublic
//
// Copyright 2003-2009 Wincent Colaiuta. All rights reserved.
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
#import "WOProcessSerialNumber.h"

// WOPublic class headers
#import "WOLogManager.h"

// WOPublic other headers
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
        // procNotFound is a "harmless" error; log all others
        [WOLog err:@"GetProcessForPID" no:err];
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
        // procNotFound is a "harmless" error; log all others
        [WOLog err:@"GetProcessPID" no:err];
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