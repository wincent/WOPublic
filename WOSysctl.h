//
//  WOSysctl.h
//  WOCommon
//
//  Created by Wincent Colaiuta on 10 July 2005.
//  Copyright 2005-2008 Wincent Colaiuta.

#import "WOObject.h"    /* imports WOObfuscation.h */

//! pid_t value returned when no matching process is found.
#define WO_NO_PROCESS -1

//! The WOSysctl class is a singleton class that provides an Objective-C wrapper for selected aspects of the sysctl(3) functions in the Standard C Library.
//!
//! Required classes:
//!     - WOLogManager
//!     - WOProcessSerialNumber
//!
//! \note The singleton pattern implemented by WOSysctl is not designed with subclassing in mind; unpredictable results may occur if subclassed.
//!
@interface WOSysctl : WOObject {

}

//! The shared singleton instance of the WOSysctl class.
+ (WOSysctl *)sharedInstance;

#pragma mark -
#pragma mark Determining whether processes are running

//! \name Determining whether processes are running
//! Methods for determining whether a specified process is running.
//! \startgroup

//! Determines whether a process matching name \p aProcess and user \p uid is currently running. This method is suitable for use with background processes and those which have no connection to the window server and which therfore cannot be detected using Cocoa's NSWorkspace or the Carbon Process Manager. If the user is not important for the comparison the isRunningProcess: method instead. Raises an exception if \p aProcess is nil.
- (BOOL)isRunningProcess:(NSString *)aProcess user:(uid_t)uid;

//! Like isRunningProcess:user: but does not limit the comparison to a single user.
- (BOOL)isRunningProcess:(NSString *)aProcess;

//! Invokes isRunningProcess:user: passing the uid of the current user (as determined by the getuid() function) as the \p uid parameter.
- (BOOL)currentUserIsRunningProcess:(NSString *)aProcess;

//! \endgroup

#pragma mark -
#pragma mark Retrieving process identifiers

//! \name Retrieving process identifiers
//! Methods for retreiving process identifiers (pid_t).
//! \startgroup

//! Returns the first matching process id that matches process name \p aProcess and user \p uid. If the user is not important for the comparison use the PIDForProcessName: method instead. If no matching process is found returns WO_NO_PROCESS. Raises an exception if \p aProcess is nil.
- (pid_t)PIDForProcessName:(NSString *)aProcess user:(uid_t)uid;

//! Like PIDForProcessName:user: but does not limit the comparison to a single user.
- (pid_t)PIDForProcessName:(NSString *)aProcess;

//! Invokes PIDForProcessName:user: passing the uid of the current user (as determined by the getuid() function) as the \p uid parameter.
- (pid_t)PIDForCurrentUserProcessName:(NSString *)aProcess;

//! \endgroup

#pragma mark -
#pragma mark Retrieving Process Serial Numbers

//! \name Retrieving Process Serial Numbers
//! Methods for retreiving process serial numbers (ProcessSerialNumber type).
//! \startgroup

//! Returns the first matching process serial number that matches process name \p aProcess and user \p uid. If the user is not important use the PSNForProcessName: method instead. If no matching process is found returns a Process Serial Number of kNoProcess. Raises an exception if \p aProcess is nil.
- (ProcessSerialNumber)PSNForProcessName:(NSString *)aProcess user:(uid_t)uid;

//! Like PSNForProcessName:user: but does not limit the comparison to a single user.
- (ProcessSerialNumber)PSNForProcessName:(NSString *)aProcess;

//! Invokes PSNForProcessName:user: passing the uid of the current user (as determined by the getuid() function) as the \p uid parameter.
- (ProcessSerialNumber)PSNForCurrentUserProcessName:(NSString *)aProcess;

//! \endgroup

@end
