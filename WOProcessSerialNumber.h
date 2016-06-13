// WOProcessSerialNumber.h
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

#import "WOObject.h"

//! Objective-C wrapper for the Carbon ProcessSerialNumber struct (as defined in
//! processes.h) useful for cases where one wishes to pass a ProcessSerialNumber
//! encapsulated inside an object. Also contains some convenience methods for
//! working with PSNs, converting them to and from PIDs and so forth.
//!
//! Required classes:
//!     - WOLogManager
//!
@interface WOProcessSerialNumber : WOObject {

    ProcessSerialNumber PSN;

}

//! Designated initialiser
- (id)initWithPSN:(ProcessSerialNumber)newPSN;

// Returns a WOProcessSerialNumber object representing "no process".
+ (WOProcessSerialNumber *)noProcess;

//! Convenience constructor
+ (WOProcessSerialNumber *)processSerialNumberWithPSN:(ProcessSerialNumber)newPSN;

//! Convenience constructor
+ (WOProcessSerialNumber *)processSerialNumberWithPID:(pid_t)aPid;

- (BOOL)isNoProcess;

- (BOOL)isEqualToPSN:(ProcessSerialNumber)aPSN;

- (unsigned long)highLongOfPSN;
- (unsigned long)lowLongOfPSN;

- (void)setHighLongOfPSN:(unsigned long)newHighLongOfPSN;
- (void)setLowLongOfPSN:(unsigned long)newLowLongOfPSN;

//! class method for returning a PSN given a Unix PID
+ (ProcessSerialNumber)PSNForPID:(pid_t)aPid;

//! Class method for returning Unix PID for a given PSN
+ (pid_t)PIDForPSN:(ProcessSerialNumber)aPSN;

//! Return a Unix PID for the receiver
- (pid_t)PID;

#pragma mark -
#pragma mark Accessors

- (ProcessSerialNumber)PSN;
- (void)setPSN:(ProcessSerialNumber)newPSN;

@end
