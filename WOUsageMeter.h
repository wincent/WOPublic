// WOUsageMeter.h
// WOPublic
//
// Copyright 2006-present Greg Hurrell. All rights reserved.
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
