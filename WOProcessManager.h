// WOProcessManager.h
// WOCommon
//
// Copyright 2003-2009 Wincent Colaiuta. All rights reserved.

#import "WOObject.h"

@class WOProcessSerialNumber;

//! Simple singleton wrapper class for Carbon Process Manager functions
//!
//! Required classes:
//!     - WOObject
//!     - WOProcessSerialNumber
//!
//! \note The singleton pattern implemented by WOProcessManager is not designed with subclassing in mind; unpredictable results may occur if subclassed.
//!
@interface WOProcessManager : WOObject {

    WOProcessSerialNumber *noProcess;

}

#pragma mark -
#pragma mark Singleton shared instance

+ (WOProcessManager *)sharedManager;

#pragma mark -
#pragma mark Methods for determining if a process is running

//! Returns YES if a process is running matching the submitted PSN. Does this by scanning the list of running processes for a match.
- (BOOL)processRunningWithPSN:(ProcessSerialNumber)PSN;

//! Raises an exception if \p name is nil
- (BOOL)processRunningWithProcessName:(NSString *)name;

- (BOOL)processRunningWithIdentifier:(NSString *)identifier;

- (BOOL)processRunningWithSignature:(UInt32)signature;

#pragma mark -
#pragma mark Methods for determining if a process is hidden

//! Returns YES if the process identified by \p signature is running and hidden, YES if it is not running, NO if it is running and visible.
- (BOOL)processHiddenWithSignature:(UInt32)signature;

#pragma mark -
#pragma mark Methods for controlling process visibility

- (void)hideProcess:(ProcessSerialNumber)PSN;
- (void)showProcess:(ProcessSerialNumber)PSN;
- (void)setVisibility:(BOOL)visible ofProcess:(ProcessSerialNumber)PSN;

#pragma mark -
#pragma mark Methods for determining if a process is frontmost

- (BOOL)processFrontmostWithSignature:(UInt32)signature;

#pragma mark -
#pragma mark Methods for controlling which process is frontmost

- (void)bringProcessToFront:(ProcessSerialNumber)PSN;

#pragma mark -
#pragma mark Methods for obtaining a Process Serial Number (PSN) for a process

//! Tries to obtain the PSN for the process with name \p name. Uses the Carbon Process Manager.
//! \sa See the WOsysctl class for an alternative process-finding methods based on the BSD sysctl API.
- (ProcessSerialNumber)PSNForProcessName:(NSString *)name;

//! Raises an exception if \p identifier is nil
//! Returns PSN based on bundle identifier (eg. com.apple.Safari)
- (ProcessSerialNumber)PSNForIdentifier:(NSString *)identifier;

//! Returns PSN based on application signature (eg. hook = iTunes)
- (ProcessSerialNumber)PSNForSignature:(UInt32)signature;

@end
