//
//  WOProcessSerialNumber.h
//  WOCommon
//
//  Created by Wincent Colaiuta on 21 May 2003.
//  Copyright 2003-2008 Wincent Colaiuta.

#import "WOObject.h"            /* imports WOObfuscation.h */

//! Objective-C wrapper for the Carbon ProcessSerialNumber struct (as defined in processes.h) useful for cases where one wishes to pass a ProcessSerialNumber encapsulated inside an object. Also contains some convenience methods for working with PSNs, converting them to and from PIDs and so forth.
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
