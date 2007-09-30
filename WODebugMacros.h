//
//  WODebugMacros.h
//  WOPublic
//
//  Created by Wincent Colaiuta on 30 November 2004.
//  Copyright 2004-2007 Wincent Colaiuta.

//! \file
//! A collection of convenience and logging/debugging macros
//!
//! There are alternate definitions of the logging macros depending on whether the WO_DEBUG flag is passed to the preprocessor and compiler (either on the command line using the -D switch, or by specifying "-DDEBUG" in the "Other C Flags" field in the target build settings or style settings of Xcode). In general, Debug       builds should set the WO_DEBUG flag, and the logging macros will produce more verbose output. In Release or installation builds the WO_DEBUG glad should not be set, and the logging macros will produce less verbose (or no) output.

#pragma mark -
#pragma mark Assertion macros

/*! Modelled on Apple's require macros from AssertMacros.h, this macro is designed to handle error conditions in C code in a compact fashion. Unlike the Apple macros, this macro produces output even when not running in debug mode. It is intended for situations where error messages should be made available to the end user (for example, in a command line tool). Output is printed directly to the standard error with no timestamp or other information (output is not funnelled through NSLog). If \p condition evaluates to true no action is taken, otherwise control jumps to \p label and the third parameter is printed to the standard error, prepended by "Error: ". The third parameter should be a NSString format string (no terminating newline is required), optionally followed by parameters. */
#define WORequire(condition, label, ...)                                                            \
do                                                                                                  \
{                                                                                                   \
    if (!(condition))                                                                               \
    {                                                                                               \
        fprintf(stderr, "%s\n", [[NSString stringWithFormat:@"Error: " __VA_ARGS__] UTF8String]);   \
        goto label;                                                                                 \
    }                                                                                               \
} while (0)

#ifdef NS_BLOCK_ASSERTIONS
#define WOAssert(condition)
#else
/*! Replacement for the NSAssert macro. Named using UperCamelCase for consistency with the NSAssert macro. Unlike NSAssert, WOAssert does not log the entire absolute path of the source file. Note that this does <em>not</em> hide the full path from an attacker inspecting the executable itself as the __FILE__ macro does embed the absolute path anyway; it is merely a cosmetic measure in the event that users should see an assertion printed to the log. Likewise, the failing condition itself is printed to the console so care should be taken about exactly what internal details get "leaked" in this way. */
#define WOAssert(condition)                                                                                                     \
do                                                                                                                              \
{                                                                                                                               \
    if (!(condition))                                                                                                           \
        [[NSAssertionHandler currentHandler] handleFailureInMethod:_cmd                                                         \
                                                            object:self                                                         \
                                                              file:[[NSString stringWithUTF8String:__FILE__] lastPathComponent] \
                                                        lineNumber:__LINE__                                                     \
                                                       description:[NSString stringWithUTF8String:#condition]];                 \
} while (0)
#endif

#ifdef NS_BLOCK_ASSERTIONS
#define WOCAssert(condition)
#else
/*! Replacement for the NSCAssert macro. Named using UpperCamelCase for consistency with the NSCAssert macro. See the description of WOAssert for more information no the differences between this and the original macro. */
#define WOCAssert(condition)                                                                                                      \
do                                                                                                                                \
{                                                                                                                                 \
    if (!(condition))                                                                                                             \
        [[NSAssertionHandler currentHandler] handleFailureInFunction:[NSString stringWithUTF8String:__PRETTY_FUNCTION__]          \
                                                                file:[[NSString stringWithUTF8String:__FILE__] lastPathComponent] \
                                                          lineNumber:__LINE__                                                     \
                                                         description:[NSString stringWithUTF8String:#condition]];                 \
} while (0)
#endif

/*! Shorthand for including code only in debug builds. Useful for short statements. */
#define WO_DEBUG_ONLY(block)    \
do {                            \
    block;                      \
} while(0)                      \

