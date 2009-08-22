// WOProcessLifetime.h
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

// superclass header
#import "WOObject.h"

/*!
 * @defined     WO_PROCESS_LIFETIME_DEFAULT_POLL_INTERVAL
 * @abstract    Default interval for polling when in fallback mode
 * @discussion  Defines the default interval (in seconds) for use in the
 *              fallback mode when polling must be used (when Mach "dead name"
 *              notifications cannot be set up).
 */
#define WO_PROCESS_LIFETIME_DEFAULT_POLL_INTERVAL   ((NSTimeInterval)1.0)

/*!
 * @protocol    WOProcessLifetimeObserver
 * @abstract    Methods that should be implemented by any class that wishes to
 *              to observe process lifetimes using the WOProcessLifetime class.
 */
@protocol WOProcessLifetimeObserver

- (void)observedProcessDidTerminate:(pid_t)aPid;

@end

//! Class for monitoring process lifetimes without polling
//!
//! Provides an Objective-C wrapper for Mach Port "dead name" notifications. Unlike Cocoa NSWorkspace notifications which only monitor some applications with connections to the window server (as of Mac OS X 10.2.6, this excludes applicatons with LSUIElement, and perhaps other flags, set in their Info.plist), Mach notifications are issued for all processes, even those without connections to the window server.
//!
//! The only limitation is that only processes running under the same UID as the monitoring application can be observed in this way (except for when the monitoring application is running as root). As such, the class provides a fallback method (which uses polling) for these cases.
//!
//! Required classes:
//!     - WOObject (superclass)
//!     - WOProcessManager
//!     - WOProcessSerialNumber
//!
@interface WOProcessLifetime : WOObject <WOProcessLifetimeObserver> {

    pid_t           pid;

    id              callback;

    NSTimeInterval  pollInterval;

@private

    // port which will receive notification of process termination
    NSMachPort      *_notifyPort;

    // port on target process (the process to monitor for termination)
    NSMachPort      *_targetPort;
}

/*!
 * @method      initWithCallback:observe:
 * @abstract    Designated initializer
 * @discussion  Initializes a new WOProcessLifetime object to monitor a process
 *              with process identification number, aPid. The callback object,
 *              anObject, will be called when the monitored process terminates.
 *              Returns nil if the required Mach Port callbacks and the fall-
 *              back (polling-based) method could not be put in place.
 *
 *              The notfication apparatus will be inserted into the current
 *              run loop, and so an NSRunLoop must exist in order
 *              for this method to work.
 *
 * @param       anObject    The object which will be notified on termination
 * @param       aPid        The unix process id that will be monitored for
 *                          termination
 *
 * @result      Returns the newly initialized WOProcessLifetime object or nil on
 *              error.
 */
- (id)initWithCallback:(id <WOProcessLifetimeObserver, NSObject>)anObject observe:(pid_t)aPid;

/*!
 * @method      observedProcessDidTerminate:
 * @abstract
 * @discussion  Implemented here to conform to the WOProcessLifetimeObserver
 *              protocol.
 */
- (void)observedProcessDidTerminate:(pid_t)aPid;

#pragma mark -
#pragma mark Accessors (not thread-safe)

/*!
 * @method      pid
 * @abstract    Gets the pid (process identificaton number) currently being
 *              monitored
 * @discussion  If this method is called before proper initialization has taken
 *              place, it will return 0.
 */
- (pid_t)pid;

/*!
 * @method      setPid
 * @abstract    Sets the pid (process identification number) that should be
 *              monitored for termination
 * @discussion  Generally the pid is set during initialization using the
 *              initWithCallback:observe: method. If this setPid method is then
 *              used to later set another pid, then the previous monitoring
 *              arrangements are canceled and replaced. Use of this method is
 *              not recommended however, because as a simple accessor, it
 *              provides no return value to indicate the success or failure of
 *              the attempt to establish new monitoring arrangements.
 */
- (void)setPid:(pid_t)aPid;

/*!
 * @method      callback
 * @abstract    Returns the callback object that will be notified on process
 *              termination
 */
- (id)callback;

/*!
 * @method      setCallback
 * @abstract    Sets the callback object that will be notified on process
 *              termination
 */
- (void)setCallback:(id <WOProcessLifetimeObserver, NSObject>)anObject;

- (NSTimeInterval)pollInterval;

/*!
 * @method      setPollInterval
 * @discussion  Sets the polling interval for use when in fallback (polling)
 *              mode. If polling is already under way, then setting a new value
 *              will take effect for subsequent polls (but not for the current
 *              interval).
 */
- (void)setPollInterval:(NSTimeInterval)anInterval;

@end
