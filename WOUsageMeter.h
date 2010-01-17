// WOUsageMeter.h
// WOCommon
//
// Copyright 2006-2009 Wincent Colaiuta. All rights reserved.

#import "WOObject.h"
#import <sys/time.h>            /* timeval */
#import <sys/resource.h>        /* rusage */

@interface WOUsageMeter : WOObject {

    //! Last known usage statistics (at time receiver was put in motion)
    struct rusage   _last;

    //! Cumulative total of processor usage
    struct rusage   _cumulative;

    //! Thread-safe
    int32_t         _pauseCount;
}

#pragma mark -
#pragma mark Custom methods

//! Returns a usage meter object in "running" state
+ (WOUsageMeter *)usageMeter;

//! Stackable (can send multiple pause messages)
- (void)pause;

//! Stackable (can send multiple resume messages)
- (void)resume;

//! Cumulative total processor usage (equivalent to system plus user processor usage)
- (struct timeval)usage;

//! Cumulative system processor usage
- (struct timeval)systemUsage;

//! Cumulative user processor usage
- (struct timeval)userUsage;

//! Returns string of form: "x.xxxxxx/y.yyyyyy/z.zzzzzz (user/system/total)"
- (NSString *)usageString;

@end

#pragma mark -
#pragma mark Functions

//! Returns difference between two timevals
//!
//! Subtracts time interval \p a from time interval \b
struct timeval WOSubtractTimeval(struct timeval a, struct timeval b);

//! Adds two timevals
struct timeval WOAddTimeval(struct timeval a, struct timeval b);

//! Normalizes a timeval so that the microseconds component does not exceed 1 million. Additionally, adjusts the components and changes the signedness of the microseconds component when necessary to make the signedness of both components match.
//!
//! For example:
//!     - a timeval of 3 seconds, 1.5 million microseconds would be normalized to 4 seconds, 0.5 million microseconds.
//!     - a timeval of 2 seconds, -0.5 million microseconds would be normalized to 1 second, 0.5 million microseconds.
//!     - a timeval of -1 seconds, 0.5 million microseconds would be normalized to 0 seconds, -0.5 million microseconds.
//!     - a timeval of 2 seconds, 0.5 million microseconds would be left unchanged
//!     - a timeval of -2 seconds, -0.5 million microseconds would be left unchanged
//!
struct timeval WONormalizeTimeval(struct timeval time);
