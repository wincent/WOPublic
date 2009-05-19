// WOLogManager.h
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

// superclass header
#import "WOObject.h"

#pragma mark -
#pragma mark Macros

#ifdef WO_DEBUG

//! Convenience macro that invokes the #WOLogManager::log: method to log
//! information about class name, method name, file name and line number
//! (useful for debugging). In debug builds the filename and line number is
//! included.
#define WO_LOG_METHOD_DETAILS                                               \
do                                                                          \
{                                                                           \
    [WOLog logDebug:@"%@[%@ %@] (%s:%d)",                                   \
        ((void *)[self class] == (void *)self ? @"+" : @"-"),               \
        [self class], NSStringFromSelector(_cmd), __FILE__, __LINE__];      \
} while (0)

#else /* Release configuration: no file and line information included */

//! Convenience macro that invokes the #WOLogManager::log: method to log
//! information about class name, method name, file name and line number
//! (useful for debugging). In non-debug builds the filename and line number is
//! omitted.
#define WO_LOG_METHOD_DETAILS                                               \
do                                                                          \
{                                                                           \
    [WOLog logDebug:@"%@[%@ %@]",                                           \
        ((void *)[self class] == (void *)self ? @"+" : @"-"),               \
        [self class], NSStringFromSelector(_cmd)];                          \
} while (0)

#endif

//! Required classes:
//!
//!     - WOObject (superclass)
//!
//! Required categories:
//!
//!     - NSMutableString (WOEditingUtilities)
//!     - NSString (WOCreation)
//!     - NSString (WOFileUtilities)
//!
//! \note The singleton pattern implemented by WOLogManager is not designed
//! with subclassing in mind; unpredictable results may occur if subclassed.
@interface WOLogManager : WOObject {

    NSString    *processName;
    int         processIdentifier;
    unsigned    logLevel;
    NSString    *logFilePath;
    NSString    *defaultLogFilePath;
    BOOL        logsToFileByDefault;

}

#pragma mark -
#pragma mark Class methods

//! Returns the application-wide shared instance of the WOLogManager class.
//! The WOLog global variable is initialized at load time (prior to entering
//! main()) to point to this shared instance.
+ (WOLogManager *)sharedManager;

#pragma mark -
#pragma mark Primitive logging methods

//! This is a primitive logging method which logs to the log file. Rather than
//! calling this method you should call one of the methods in the "Logging
//! methods" group.
//!
//! \param level The minimum log level required for the message to be logged
//! \param format A non-nil NSString format string
//! \param args An optional variable arguments list of type va_list
//! \throws NSInternalInconsistencyException Throws an exception if a nil or
//! non-NSString format string is passed.
- (void)vLogToFileLevel:(unsigned)level message:(NSString *)format args:(va_list)args;

//! This is a primitive logging method which unconditionally logs to standard
//! error (in other words, it ignores the logsToFileByDefault setting). Rather
//! than calling this method you should call one of the methods in the "Logging
//! methods" group.
//!
//! \param level The minimum log level required for the message to be logged
//! \param format A non-nil NSString format string
//! \param args An optional variable arguments list of type va_list
//! \throws NSInternalInconsistencyException Throws an exception if a nil or
//! non-NSString format string is passed.
- (void)vLogToStdErrLevel:(unsigned)level message:(NSString *)format args:(va_list)args;

#pragma mark -
#pragma mark Logging methods

//! \name Logging methods
//!
//! Like NSLog all of the logging methods behave as no-ops if passed a nil
//! format string.

 //@{

//! Convenience method equivalent to #logMessage:.
- (void)log:(NSString *)format, ...;

- (void)logMessage:(NSString *)format, ...;

//! Convenience method equivalent to #logWarning:.
- (void)logWarn:(NSString *)format, ...;

//! Convenience method equivalent to #logWarning:.
- (void)warn:(NSString *)format, ...;

//! Convenience method equivalent to #logError:.
- (void)logErr:(NSString *)format, ...;

//! Convenience method equivalent to #logError:.
- (void)error:(NSString *)format, ...;

//! Convenience method equivalent to #logError:.
- (void)err:(NSString *)format, ...;

//! Convenience method for logging error numbers returned by functions or
//! methods. Given \p functionOrMethodName "WOFunction" and \p errorNumber -1,
//! calls #logError: so as to produce output that looks like this:
//!
//! <tt>2005-03-24 15:29:32.915 ProcessName[17016] Error: WOFunction returned
//! error -1</tt>
- (void)err:(NSString *)functionOrMethodName no:(int)errorNumber;

- (void)logToFileMessage:(NSString *)format, ...;
- (void)logToFileWarning:(NSString *)format, ...;
- (void)logToFileError:(NSString *)format, ...;

- (void)logLevel:(unsigned)level message:(NSString *)format, ...;
- (void)logLevel:(unsigned)level warning:(NSString *)format, ...;
- (void)logLevel:(unsigned)level error:(NSString *)format, ...;

//! Convenience method, equivalent to invoking logLevel:error: passing \p level
//! ASL_LEVEL_EMERG (0)
- (void)logEmergency:(NSString *)format, ...;

//! Convenience method, equivalent to invoking logLevel:error: passing \p level
//! ASL_LEVEL_ALERT (1)
- (void)logAlert:(NSString *)format, ...;

//! Convenience method, equivalent to invoking logLevel:error: passing \p level
//! ASL_LEVEL_CRIT (2)
- (void)logCritical:(NSString *)format, ...;

//! Convenience method, equivalent to invoking logLevel:error: passing \p level
//! ASL_LEVEL_ERR (3)
- (void)logError:(NSString *)format, ...;

//! Convenience method, equivalent to invoking logLevel:warning: passing
//! \p level ASL_LEVEL_WARNING (4)
- (void)logWarning:(NSString *)format, ...;

//! Convenience method, equivalent to invoking logLevel:message: passing
//! \p level ASL_LEVEL_NOTICE (5)
- (void)logNotice:(NSString *)format, ...;

//! Convenience method, equivalent to invoking logLevel:message: passing
//! \p level ASL_LEVEL_INFO (6)
- (void)logInfo:(NSString *)format, ...;

//! Convenience method, equivalent to invoking logLevel:message: passing
//! \p level ASL_LEVEL_DEBUG (7)
- (void)logDebug:(NSString *)format, ...;

- (void)logToFileLevel:(unsigned)level message:(NSString *)format, ...;
- (void)logToFileLevel:(unsigned)level warning:(NSString *)format, ...;
- (void)logToFileLevel:(unsigned)level error:(NSString *)format, ...;

//@}

#pragma mark -
#pragma mark Utility methods

- (NSString *)stringForObject:(NSObject *)object;

#pragma mark -
#pragma mark Convenience methods

//! Returns the full path to the "Logs" folder (should be /Library/Logs/ or
//! ~/Library/Logs depending on the domain) creating if necessary. Domain
//! should be kUserDomain, kLocalDomain or any other domain defined in
//! <Folders.h>. 
- (NSString *)logsFolderPath:(short)domain;

#pragma mark -
#pragma mark Properties

@property(copy)     NSString    *processName;
@property           int         processIdentifier;

//! Setting aLogLevel to 0 suppresses all logging performed with the
//! #logMessage:, #logWarning:, #logError:, #logToFileMessage:,
//! #logToFileWarning: and #logToFileError: methods. When set to 0 the
//! #logLevel:message:, #logLevel:warning:, #logLevel:error:,
//! #logToFileLevel:message:, #logToFileLevel:warning: and
//! #logToFileLevel:error: methods will only produce log output if passed 0 in
//! the level parameter.
@property           unsigned    logLevel;

//! When logging to a file the logfile path is automatically determined
//! based on the application bundle identifier following this pattern:
//! "~/Library/Logs/bundleidentifier.log". This behaviour can be overridden by
//! setting the #logFilePath property; to revert back to the standard behaviour
//! set #logFilePath to nil.
@property(copy)             NSString    *logFilePath;

@property(readonly, copy)   NSString    *defaultLogFilePath;
@property                   BOOL        logsToFileByDefault;

@end

#pragma mark -
#pragma mark Macros

//! Convenience macro for quickly accessing the shared WOLogManager singleton
//! instance.
//!
//! Together with convenience methods like WOLogManager#err:, provides a
//! convenient shorthand such as:
//!
//! \code
//! [WOLog err:@"aborting!"];
//! \endcode
//!
//! instead of:
//!
//! \code
//! [[WOLogManager sharedManager] logError:@"aborting!"];
//! \endcode
#define WOLog [WOLogManager sharedManager]

//! Normally the default log file name is determined by appending a "log"
//! extension to the application bundle identifier. In cases where the bundle
//! identifier cannot be determined, the default log file name will be
//! WO_DEFAULT_LOG_FILE_NAME with the extension WO_LOG_FILE_EXTENSION.
#define WO_DEFAULT_LOG_FILE_NAME @"WOCommon"

#define WO_LOG_FILE_EXTENSION @"log"

//! A last resort hard-coded log file folder path to be used when all attempts
//! to determine one dynamically fail.
#define WO_FALLBACK_LOG_FOLDER_PATH @"~/Library/Logs"

//! String prepened to messages logged using the WOLogManager::logWarning: and
//! related methods.
#define WO_LOG_WARNING_PREFIX @"Warning: "

//! String prepended to messages logged using the WOLogManager::logError: and
//! related methods.
#define WO_LOG_ERROR_PREFIX @"Error: "

//! Default log level.
#define WO_DEFAULT_LOG_LEVEL 5
