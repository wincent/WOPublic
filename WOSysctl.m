//
//  WOSysctl.m
//  WOCommon
//
//  Created by Wincent Colaiuta on 10 July 2005.
//  Copyright 2005-2008 Wincent Colaiuta.

// class header
#import "WOSysctl.h"

// system headers
#import <sys/sysctl.h>                  /* CTL_KERN, KERN_PROC, KERN_PROC_ALL */
#import <sys/types.h>                   /* getuid() */
#import <unistd.h>                      /* getuid() */

// class headers
#import "WOLogManager.h"
#import "WOProcessSerialNumber.h"

// other headers
#import "WOMemoryBarrier.h"

// WOPublic headers
#import "WOPublic/WODebugMacros.h"
#import "WOPublic/WOMemory.h"

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
