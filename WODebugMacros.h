// WODebugMacros.h
// WOPublic
//
// Copyright 2004-2009 Wincent Colaiuta. All rights reserved.
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

//! \file
//! Assertion and check macros.
//!
//! There are two main types of macros declared in this file:
//!
//! - assertion macros: compiled into Debug builds only
//! - check macros: compiled into Debug <em>and</em> Release builds
//!
//! Within each type there are two subtypes:
//!
//! - macros for use within Objective-C methods
//! - macros for use within C functions
//!
//! \par Assertion macros
//!
//! Assertion macros are a debugging and development aid that are used to
//! confirm the validity of programmer assumptions <em>in Debug builds
//! only</em>. Given that programs should be well-tested prior to release, the
//! assertion macros are <em>preprocessed away to nothing in Release
//! builds</em>. Specifically, assertion macros are preprocessed to nothing
//! whenever the NS_BLOCK_ASSERTIONS macro is defined (which is the case in
//! Release builds but not in Debug builds).
//!
//! In a nutshell, assertion macros should be used to detect programmer errors.
//! This detection is performed by confirming that programmer assumptions hold
//! true. Untested assumptions are dangerous because when they are not met they
//! can cause unpredictable behaviour. Testing assumptions ensures that programs
//! "fail early" (as close to the site where a problem originates), thus making
//! bugs easier to find and eliminate. Because assertions incur zero cost in
//! release builds, it is acceptable to use them abundantly.
//!
//! A failed assumption is an indication of a programming error (either it was
//! incorrect to make the assumption in the first place or a separate error in
//! the codebase causes what should be a valid assumption to fail). Programmers
//! can make assumptions about <em>things directly within their control</em> and
//! whenever they make such an assumption they should test (confirm) it using
//! one of the assertion macros. Using an assertion macro is equivalent to a
//! programmer stating, "I expect this to be true at this point in the program's
//! execution, and if it is not true then it is because either my expectation is
//! incorrect or I've made a mistake elsewhere that causes my expectation not to
//! be met".
//!
//! Things that are <em>not</em> suitable for assertions are things
//! <em>outside</em> of programmer control; these are things which although they
//! <em>should</em> or <em>can</em> be true, they <em>might</em> not and there
//! is nothing that can be done to control them. You should not make assertions
//! about things like user input or data received from external sources,
//! although you should still be testing for these possibilities and handling
//! them adequately at runtime (with error messages, for instance); but the
//! assertion macros are not the right tool for that job (partly because they
//! are only compiled in Debug builds and partly because they are exclusively
//! intended for detecting programmer errors).
//!
//! \par Check macros
//!
//! Check macros are a special class of macros designed to catch programming
//! (and possibly other types of) errors. They are closely related to assertion
//! macros but with one key difference: they are compiled into <em>both Debug
//! and Release</em> builds.
//!
//! Use check macros when you require action to be taken upon failure in both
//! Debug and Release builds. A good example of this need is when fulfilling
//! your API contract; for example, if you design an API that says that an
//! exception is thrown if an invalid parameter is passed then you cannot use
//! assertion macros like NSParameterAssert because you would only be meeting
//! your API contract in Debug builds (where the assertion macros are compiled
//! in) and not in Release builds.
//!
//! Note that while assertion macros are used to detect programmer errors
//! (that is, <em>your own</em> errors), check macros can be used to detect the
//! programming errors of others (for example, when you write a framework API
//! and you use the checks to enforce your API contract).
//!
//! Another good use for check macros is in unit tests (if using a testing
//! framework like WOTest which is designed to work in both Debug and Release
//! builds); in these cases as well you want to be alerted about unexpected
//! conditions in both Debug and Release builds.

#pragma mark Low-level macros

//! Evaluates \p condition and if false calls the assertion handler for the
//! current thread.
//!
//! Note that it passes the source file name only rather than the entire
//! absolute path of the source file, but this is intended as a convenience for
//! users rather than an information-hiding measure against attackers. Be aware
//! that this does <em>not</em> hide the full path from an attacker inspecting
//! the executable itself as the __FILE__ macro embeds the absolute path anyway.
//! It is merely a cosmetic measure in the event that users should see an
//! assertion printed to the log. Likewise, the failing condition itself is
//! printed to the console so care should be taken about exactly what internal
//! details get "leaked" in this way if they are at all sensitive.
//!
//! This macro is intended for use within Objective-C methods.
#define WOAssertionBody(condition)                                                                                              \
do                                                                                                                              \
{                                                                                                                               \
    if (!(condition))                                                                                                           \
        [[NSAssertionHandler currentHandler] handleFailureInMethod:_cmd                                                         \
                                                            object:self                                                         \
                                                              file:[[NSString stringWithUTF8String:__FILE__] lastPathComponent] \
                                                        lineNumber:__LINE__                                                     \
                                                       description:[NSString stringWithUTF8String:#condition]];                 \
} while (0)

//! Evaluates \p condition and if false calls the assertion handler for the
//! current thread.
//!
//! Note that it passes the source file name only rather than the entire
//! absolute path of the source file. For information on the security
//! considerations of this approach see the documentation for the
//! WOAssertionBody macro.
//!
//! This macro is intended for use within C functions.
#define WOCAssertionBody(condition)                                                                                               \
do                                                                                                                                \
{                                                                                                                                 \
    if (!(condition))                                                                                                             \
        [[NSAssertionHandler currentHandler] handleFailureInFunction:[NSString stringWithUTF8String:__PRETTY_FUNCTION__]          \
                                                                file:[[NSString stringWithUTF8String:__FILE__] lastPathComponent] \
                                                          lineNumber:__LINE__                                                     \
                                                         description:[NSString stringWithUTF8String:#condition]];                 \
} while (0)

#pragma mark -
#pragma mark Assertion macros

#ifdef NS_BLOCK_ASSERTIONS
//! In Release builds the WOAssert macro is preprocessed away.
#define WOAssert(condition)
#else
//! Replacement for the NSAssert macro which, for brevity, does not require a
//! description string.
//!
//! Breaks with the all-uppercase macro naming convention and instead is named
//! using camel case for consistency with the NSAssert macro.
//!
//! See the description of WOAssertionBody for more information on the
//! differences between this and NSAssert.
#define WOAssert(condition) WOAssertionBody(condition)
#endif /* NS_BLOCK_ASSERTIONS */

#ifdef NS_BLOCK_ASSERTIONS
//! In Release builds the WOCAssert macro is preprocessed away.
#define WOCAssert(condition)
#else
//! Replacement for the NSCAssert macro which, for brevity, does not require a
//! description string.
//!
//! Breaks with the all-uppercase macro naming convention and instead is named
//! using camel case for consistency with the NSCAssert macro.
//!
//! See the description of WOCAssertionBody for more information on the
//! differences between this and NSCAssert.
#define WOCAssert(condition) WOCAssertionBody(condition)
#endif /* NS_BLOCK_ASSERTIONS */

#pragma mark -
#pragma mark Check macros

//! Replacement for the NSParameterAssert macro which is compiled into both
//! Release and Debug builds.
//!
//! Breaks with the all-uppercase macro naming convention and instead is named
//! using camel case for consistency with the NSParameterAssert macro.
//!
//! See the description of WOAssertionBody for more information on the
//! differences between this and NSParameterAssert.
#define WOParameterCheck(condition) WOAssertionBody(condition)

//! Replacement for the NSCParameterAssert macro which is compiled into both
//! Release and Debug builds.
//!
//! Breaks with the all-uppercase macro naming convention and instead is named
//! using camel case for consistency with the NSCParameterAssert macro.
//!
//! See the description of WOCAssertionBody for more information on the
//! differences between this and NSCParameterAssert.
#define WOCParameterCheck(condition) WOCAssertionBody(condition)

//! Replacement for the NSAssert macro which is compiled into both Release and
//! Debug builds.
//!
//! Breaks with the all-uppercase macro naming convention and instead is named
//! using camel case for consistency with the NSAssert macro.
//!
//! See the description of WOAssertionBody for more information on the
//! differences between this and NSParameterAssert.
#define WOCheck(condition) WOAssertionBody(condition)

//! Replacement for the NSCAssert macro which is compiled into both Release and
//! Debug builds.
//!
//! Breaks with the all-uppercase macro naming convention and instead is named
//! using camel case for consistency with the NSCAssert macro.
//!
//! See the description of WOCAssertionBody for more information on the
//! differences between this and NSParameterAssert.
#define WOCCheck(condition) WOCAssertionBody(condition)
