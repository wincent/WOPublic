// WOSysctl.m
// WOPublic
//
// Copyright 2005-2009 Wincent Colaiuta. All rights reserved.
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
#import "WOSysctl.h"

// system headers
#import <sys/sysctl.h>                  /* CTL_KERN, KERN_PROC, KERN_PROC_ALL */
#import <sys/types.h>                   /* getuid() */
#import <unistd.h>                      /* getuid() */

// class headers
#import "WOLogManager.h"
#import "WOProcessSerialNumber.h"

// macro headers
#import "WOMemoryBarrier.h"
#import "WODebugMacros.h"
#import "WOMemory.h"

#pragma mark -
#pragma mark Global variables

static WOSysctl *WOSharedSysctl = nil;

#pragma mark -

@interface WOSysctl ()

- (pid_t)PIDForProcessName:(NSString *)aProcess uid:(uid_t *)uid;

@end

@implementation WOSysctl

+ (WOSysctl *)sharedInstance
{
    WOSysctl *instance = WOSharedSysctl;
    WO_READ_MEMORY_BARRIER();
    if (!instance)
    {
        @synchronized (self)
        {
            instance = WOSharedSysctl;
            if (!instance)
            {
                instance = [[self alloc] init];
                WO_WRITE_MEMORY_BARRIER();
                WOSharedSysctl = instance;
            }
        }
    }
    return instance;
}

#pragma mark -
#pragma mark Determining whether processes are running

- (BOOL)isRunningProcess:(NSString *)aProcess user:(uid_t)uid
{
    NSParameterAssert(aProcess != nil);
    return (WO_NO_PROCESS != [self PIDForProcessName:aProcess uid:&uid]);
}

- (BOOL)isRunningProcess:(NSString *)aProcess
{
    NSParameterAssert(aProcess != nil);
    return (WO_NO_PROCESS != [self PIDForProcessName:aProcess uid:NULL]);
}

- (BOOL)currentUserIsRunningProcess:(NSString *)aProcess
{
    NSParameterAssert(aProcess != nil);
    return [self isRunningProcess:aProcess user:getuid()];
}

#pragma mark -
#pragma mark Retrieving process identifiers (private)

- (pid_t)PIDForProcessName:(NSString *)aProcess uid:(uid_t *)uid;
{
    NSParameterAssert(aProcess != nil);
    pid_t       pid             = WO_NO_PROCESS;
    const char  *processName    = [aProcess UTF8String];
    int         mib[4]          = { CTL_KERN, KERN_PROC, KERN_PROC_ALL, 0 };
    size_t      length          = 0;

    // see: http://developer.apple.com/qa/qa2001/qa1123.html
    if (sysctl(mib, 4, NULL, &length, NULL, 0) == -1)   // get size of buffer
        [WOLog err:@"sysctl (%d: %s)", errno, strerror(errno)];
    else
    {
        struct kinfo_proc *processes = wmalloc(length);
        if (sysctl(mib, 4, processes, &length, NULL, 0) == -1)
            [WOLog err:@"sysctl (%d: %s)", errno, strerror(errno)];
        else
        {
            int procCount = length / sizeof(struct kinfo_proc);
            for (int i = 0; i < procCount; i++)
            {
                if ((processes[i].kp_proc.p_comm) && (strcmp(processes[i].kp_proc.p_comm, processName) == 0))
                {
                    // a NULL uid pointer means "any user"; otherwise search for a specific user id
                    if (!uid || (*uid == processes[i].kp_eproc.e_ucred.cr_uid))
                    {
                        pid = processes[i].kp_proc.p_pid; // found pid
                        break;
                    }
                }
            }
        }
        free(processes);
    }
    return pid; // WO_NO_PROCESS returned if no matching process found
}

#pragma mark -
#pragma mark Retrieving process identifiers

- (pid_t)PIDForProcessName:(NSString *)aProcess user:(uid_t)uid
{
    NSParameterAssert(aProcess != nil);
    return [self PIDForProcessName:aProcess uid:&uid];
}

- (pid_t)PIDForProcessName:(NSString *)aProcess
{
    NSParameterAssert(aProcess != nil);
    return [self PIDForProcessName:aProcess uid:NULL];
}

- (pid_t)PIDForCurrentUserProcessName:(NSString *)aProcess
{
    NSParameterAssert(aProcess != nil);
    uid_t uid = getuid();
    return [self PIDForProcessName:aProcess uid:&uid];
}

#pragma mark -
#pragma mark Retrieving Process Serial Numbers

- (ProcessSerialNumber)PSNForProcessName:(NSString *)aProcess user:(uid_t)uid
{
    NSParameterAssert(aProcess != nil);
    pid_t pid = [self PIDForProcessName:aProcess uid:&uid];
    if (pid != WO_NO_PROCESS)
        return [WOProcessSerialNumber PSNForPID:pid];
    else
        return [[WOProcessSerialNumber noProcess] PSN];
}

- (ProcessSerialNumber)PSNForProcessName:(NSString *)aProcess
{
    NSParameterAssert(aProcess != nil);
    pid_t pid = [self PIDForProcessName:aProcess uid:NULL];
    if (pid != WO_NO_PROCESS)
        return [WOProcessSerialNumber PSNForPID:pid];
    else
        return [[WOProcessSerialNumber noProcess] PSN];
}

- (ProcessSerialNumber)PSNForCurrentUserProcessName:(NSString *)aProcess
{
    NSParameterAssert(aProcess != nil);
    return [self PSNForProcessName:aProcess user:getuid()];
}

@end
