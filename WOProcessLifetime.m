// WOProcessLifetime.m
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

// classs header
#import "WOProcessLifetime.h"

// system headers
#import <mach/mach.h>

// WOPublic headers
#import "WOConvenienceMacros.h"
#import "WODebugMacros.h"
#import "WOProcessManager.h"
#import "WOProcessSerialNumber.h"

// TODO: not happy with name of this class "WOProcessLifetime"; perhaps should be built in to WOProcessManager or a category on NSWorkspace
// TODO: also, we are lacking the other side of the equation: observing when processes *start*
// if Leopard fixes the kqueue fork monitoring bug, can watch for windowserver forks and observe even LSUIElement/LSBackgroundOnly launches

@interface WOProcessLifetime ()

// sets up monitoring of a given pid, returning YES on successful setup and NO on failure
- (BOOL)_setupMonitoringWithNewPid:(pid_t)aPid;

// attempts to monitor a given Pid using Mach "Dead-Name" notifications
// returns YES on successful setup, NO on failure
- (BOOL)_monitorPid:(pid_t)aPid;

// cancel any existing dead name notification arrangements
- (void)_cancelNotifications;

// a future revision of this class could provide an additional alternative
// method for when Mach notifications are not possible: the use of the posix
// "wait" command, which will block waiting for a given unix pid to exit (this
// method would require a shift to a multi-threaded model).

@end

@implementation WOProcessLifetime

- (id)initWithCallback:(id <WOProcessLifetimeObserver, NSObject>)anObject observe:(pid_t)aPid
{
    if ((self = [super init]))
    {
        pollInterval = WO_PROCESS_LIFETIME_DEFAULT_POLL_INTERVAL;
        [self setCallback:anObject];
        if (![self _setupMonitoringWithNewPid:aPid])
            // failed to setup monitoring! deallocate self and return nil
            self = nil;
    }
    return self;
}

// init override for callers who do not use designated initializer
- (id)init
{
    return [self initWithCallback:nil observe:(pid_t)0];
}

- (void)finalize
{
    // setting the pid to 0 cancels any mach port notifications in place
    // (by the time dealloc is entered, polling, if any, will already be cancelled)
    [self setPid:0];
    [self setCallback:nil];
    [super finalize];
}

#pragma mark **** WOProcessLifetimeObserver Protocol method ****

- (void)observedProcessDidTerminate:(pid_t)aPid
{
    // this method implemented here to conform to the WOProcessLifetimeObserver
    // protocol.

    // typically, this method should deallocate the WOProcessLifetime object
    // and do any other necessary cleanup
}

#pragma mark **** Private methods ****

// sets up monitoring of a given pid, returning YES on successful setup and NO on failure
- (BOOL)_setupMonitoringWithNewPid:(pid_t)aPid
{
    // check to ensure that aPid has not already been set
    if (aPid == pid)
        return NO;
    pid = aPid;

    // make sure that any previous Mach dead name notifications are cancelled
    [self _cancelNotifications];

    // check for pid of zero
    if (aPid == 0)
        return NO;

    // check to ensure that aPid is associated with a running process
    WOProcessSerialNumber *WOPsn = [WOProcessSerialNumber processSerialNumberWithPID:aPid];

    if ([WOPsn isNoProcess])
    {
        // bad form to get here: caller has requested that we monitor a process
        // that is not running

        // fire callback, and return
        [callback observedProcessDidTerminate:aPid];

        return YES;
    }

    // attempt to set up monitoring of aPid
    if ([self _monitorPid:aPid])
        return YES;

    return NO;
}

// attempts to monitor a given Pid using Mach "Dead-Name" notifications
// returns YES on successful setup, NO on failure
- (BOOL)_monitorPid:(pid_t)aPid
{
    // Useful documentation can be found in: /usr/include/mach/

    kern_return_t   kernResult;             // return status on Mach functions
    mach_port_t     taskOfOurProcess;       // Mach port of the current process
    mach_port_t     taskForTargetProcess;   // Mach port on the target process

    // check for a legal pid
    if (aPid < 1)
        return NO;

    // make sure callback is non-nil
    if (!callback)
        return NO;

    taskOfOurProcess = mach_task_self();

    if (taskOfOurProcess == MACH_PORT_NULL)
        return NO;

    // get task for target process (must deallocate this later)
    //
    // from mach_traps.h:
    //  kern_return_t task_for_pid(mach_port_t target_tport,
    //      int pid, mach_port_t *t);

    // if we try to get the task of a process owned by another user, the call
    // will fail with a return value of 5 (KERN_FAILURE)

    kernResult = task_for_pid(taskOfOurProcess, (int)aPid, &taskForTargetProcess);

    if (kernResult != KERN_SUCCESS)
        return NO;

    if (taskForTargetProcess == MACH_PORT_NULL)
        return NO;

    // store a copy of the port in an instance variable for later deallocation
    _targetPort = [[NSMachPort alloc] initWithMachPort:(int)taskForTargetProcess];

    // set up the notification port on which to receive dead name notifications
    mach_port_name_t    notifyPort;

    // from mach_port.h:
    // kern_return_t mach_port_allocate(ipc_space_t task,
    //      mach_port_right_t right, mach_port_name_t *name);
    //
    // see mach_port.defs for possible values for right:
    //      MACH_PORT_RIGHT_RECEIVE, MACH_PORT_RIGHT_PORT_SET and
    //      MACH_PORT_RIGHT_DEAD_NAME

    kernResult = mach_port_allocate(taskOfOurProcess, MACH_PORT_RIGHT_RECEIVE, &notifyPort);


    if (kernResult != KERN_SUCCESS)
        return NO;

    // store it in instance variable

    _notifyPort = [[NSMachPort alloc] initWithMachPort:(int)notifyPort];

    // request notifications
    mach_port_t     old_port = MACH_PORT_NULL;

    // from mach_port.h:
    // kern_return_t mach_port_request_notification(ipc_space_t task,
    //      mach_port_name_t name, mach_msg_id_t msgid,
    //      mach_port_mscount_t sync, mach_port_t notify,
    //      mach_msg_type_name_t notifyPoly, mach_port_t *previous);

    kernResult = mach_port_request_notification(taskOfOurProcess,
                                                taskForTargetProcess,
                                                MACH_NOTIFY_DEAD_NAME,
                                                0,
                                                notifyPort,
                                                MACH_MSG_TYPE_MAKE_SEND_ONCE,
                                                &old_port);

    if (kernResult != KERN_SUCCESS)
        return NO;

    if (old_port != MACH_PORT_NULL)
        mach_port_deallocate(taskOfOurProcess, old_port);

    // now add the notification port to our run loop
    [_notifyPort setDelegate:self];

    [_notifyPort scheduleInRunLoop:[NSRunLoop currentRunLoop] forMode:NSDefaultRunLoopMode];

    // successful setup
    return YES;
}

- (void)_cancelNotifications
{
    if (_notifyPort)
    {
        // remove from run loop
        [_notifyPort removeFromRunLoop:[NSRunLoop currentRunLoop] forMode:NSDefaultRunLoopMode];

        // deallocate mach port for notifications
        mach_port_t notifyPort = (mach_port_t)[_notifyPort machPort];

        // don't check for error on return here: my reading of the documentation
        // implies that dead names will cause this to always return
        // KERN_INVALID_RIGHT:
        //      http://web.mit.edu/darwin/src/modules/xnu/osfmk/man/mach_port_deallocate.html
        if (notifyPort != MACH_PORT_NULL)
            mach_port_deallocate(mach_task_self(), notifyPort);

        // set pointers to nil to provide a reliable indication of whether notification arrangements exist
        _notifyPort = nil;
    }

    if (_targetPort)
    {
        // deallocate mach port on target process
        mach_port_t targetPort = (mach_port_t)[_targetPort machPort];

        if (targetPort != MACH_PORT_NULL)
        {
            kern_return_t kernResult = mach_port_deallocate(mach_task_self(), targetPort);

            if (kernResult != KERN_SUCCESS)
                // TODO: get rid of this ELOG and all others
                NSLog(@"Error (%d) while attempting mach_port_deallocate on target process", kernResult);
        }

        _targetPort = nil;
    }
}

#pragma mark -
#pragma mark NSMachPort delegate methods

- (void)handleMachMessage:(void *)msg
{
    [self _cancelNotifications];                    // cancel notification arrangements (if any)
    [callback observedProcessDidTerminate:pid];     // fire callback
}

#pragma mark -
#pragma mark Accessors (not thread-safe)

- (pid_t)pid
{
    return pid;
}

- (void)setPid:(pid_t)aPid
{
    // return value ignored here
    [self _setupMonitoringWithNewPid:aPid];
}

- (id)callback
{
    return callback;
}

- (void)setCallback:(id <WOProcessLifetimeObserver, NSObject>)anObject
{
    callback = anObject;
}

- (NSTimeInterval)pollInterval
{
    return pollInterval;
}

- (void)setPollInterval:(NSTimeInterval)anInterval
{
    pollInterval = anInterval;
}

@end
