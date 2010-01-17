//
// WOUsageMeter.m
// WOCommon
//
// Created by Wincent Colaiuta on 25 November 2006.
// Copyright 2006-2008 Wincent Colaiuta.

// class header
#import "WOUsageMeter.h"

// system headers
#import <libkern/OSAtomic.h>    /* OSAtomicIncrement32Barrier, OSAtomicDecrement32Barrier */

// WOCommon other headers
#import "WOConvenienceMacros.h"

#pragma mark -
#pragma mark Macro definitions

// Minimize the risk of undetected typing errors by using a macro instead of a literal constant
#define WO_ONE_MILLION  1000000

@implementation WOUsageMeter

#pragma mark -
#pragma mark NSObject overrides

- (id)init
{
    if ((self = [super init]))
    {
        getrusage(RUSAGE_SELF, &(self->_last));
        OSAtomicIncrement32Barrier(&(self->_pauseCount));
    }
    return self;
}

#pragma mark -
#pragma mark Custom methods

+ (WOUsageMeter *)usageMeter
{
    return [[self alloc] init];
}

- (void)pause
{
    if (OSAtomicDecrement32Barrier(&(_pauseCount)) == 0)    // pause when pause count hits 0
    {
        struct rusage now;
        getrusage(RUSAGE_SELF, &now);
        @synchronized (self)
        {
            _cumulative.ru_utime = WOAddTimeval(_cumulative.ru_utime, WOSubtractTimeval(_last.ru_utime, now.ru_utime));
            _cumulative.ru_stime = WOAddTimeval(_cumulative.ru_stime, WOSubtractTimeval(_last.ru_stime, now.ru_stime));
        }
    }
}

- (void)resume
{
    if (OSAtomicIncrement32Barrier(&(_pauseCount)) == 1)    // resume when pause count moves from 0 to 1
    {
        struct rusage now;
        getrusage(RUSAGE_SELF, &now);
        @synchronized (self)
        {
            _last = now;
        }
    }
}

- (struct timeval)usage
{
    struct timeval user;
    struct timeval system;
    struct rusage now;
    getrusage(RUSAGE_SELF, &now);
    @synchronized (self)
    {
        if (_pauseCount > 0)    // currently running
        {
            user     = WOAddTimeval(_cumulative.ru_utime, WOSubtractTimeval(_last.ru_utime, now.ru_utime));
            system   = WOAddTimeval(_cumulative.ru_stime, WOSubtractTimeval(_last.ru_stime, now.ru_stime));
        }
        else                    // paused
        {
            user    = _cumulative.ru_utime;
            system  = _cumulative.ru_stime;
        }
    }
    return WOAddTimeval(user, system);
}

- (struct timeval)systemUsage
{
    struct timeval system;
    struct rusage now;
    getrusage(RUSAGE_SELF, &now);
    @synchronized (self)
    {
        if (_pauseCount > 0)    // currently running
            system   = WOAddTimeval(_cumulative.ru_stime, WOSubtractTimeval(_last.ru_stime, now.ru_stime));
        else                    // paused
            system  = _cumulative.ru_stime;
    }
    return system;
}

- (struct timeval)userUsage
{
    struct timeval user;
    struct rusage now;
    getrusage(RUSAGE_SELF, &now);
    @synchronized (self)
    {
        if (_pauseCount > 0)    // currently running
            user    = WOAddTimeval(_cumulative.ru_utime, WOSubtractTimeval(_last.ru_utime, now.ru_utime));
        else                    // paused
            user    = _cumulative.ru_utime;
    }
    return user;
}

- (NSString *)usageString
{
    // get usage
    struct timeval user     = [self userUsage];
    struct timeval system   = [self systemUsage];

#ifdef WO_COCOA_SUPPORTS_LONG_DOUBLE
    // convert to microseconds
    unsigned long long u = (user.tv_sec * WO_ONE_MILLION) + user.tv_usec;
    unsigned long long s = (system.tv_sec * WO_ONE_MILLION) + system.tv_usec;

    // format output
    return WO_STRING(@"%.6Lf/%.6Lf/%.6Lf (user/system/total)",
                     ((long double)u) / WO_ONE_MILLION,
                     ((long double)s) / WO_ONE_MILLION,
                     ((long double)(u + s)) / WO_ONE_MILLION);
#else
    // convert to microseconds
    unsigned long u = (user.tv_sec * WO_ONE_MILLION) + user.tv_usec;
    unsigned long s = (system.tv_sec * WO_ONE_MILLION) + system.tv_usec;

    // format output
    return WO_STRING(@"%f/%f/%f (user/system/total)",
                     ((double)u) / WO_ONE_MILLION,
                     ((double)s) / WO_ONE_MILLION,
                     ((double)(u + s)) / WO_ONE_MILLION);
#endif
}

@end

#pragma mark -
#pragma mark Functions

struct timeval WOSubtractTimeval(struct timeval a, struct timeval b)
{
    volatile struct timeval difference;
    difference.tv_sec   = b.tv_sec - a.tv_sec;
    difference.tv_usec  = b.tv_usec - a.tv_usec;
    return WONormalizeTimeval(difference);
}

struct timeval WOAddTimeval(struct timeval a, struct timeval b)
{
    volatile struct timeval total;
    total.tv_sec    = a.tv_sec + b.tv_sec;
    total.tv_usec   = a.tv_usec + b.tv_usec;
    return WONormalizeTimeval(total);
}

struct timeval WONormalizeTimeval(struct timeval time)
{
    if ((time.tv_usec >= WO_ONE_MILLION) || (time.tv_usec <= WO_ONE_MILLION))       // microseconds overflowed
    {
        __darwin_time_t overflow    = time.tv_usec / WO_ONE_MILLION;
        time.tv_sec                 += overflow;
        time.tv_usec                -= (overflow * WO_ONE_MILLION);
    }

    if ((time.tv_sec > 0) && (time.tv_usec < 0))        // signedness mismatch
    {
        time.tv_sec--;
        time.tv_usec += WO_ONE_MILLION;
    }
    else if ((time.tv_sec < 0) && (time.tv_usec > 0))   // signedness mismatch
    {
        time.tv_sec++;
        time.tv_usec -= WO_ONE_MILLION;
    }

    return time;
}