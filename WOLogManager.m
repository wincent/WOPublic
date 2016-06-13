// WOLogManager.m
// WOPublic
//
// Copyright 2004-present Greg Hurrell. All rights reserved.
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
#import "WOLogManager.h"

// system headers
#import <asl.h>

// category headers
#import "NSString+WOCreation.h"
#import "NSString+WOFileUtilities.h"

// macro other headers
#import "WOConvenienceMacros.h"
#import "WODebugMacros.h"
#import "WOMemoryBarrier.h"

#pragma mark -
#pragma mark Global variables

WOLogManager *WOSharedLogManager = nil;

#pragma mark -

@interface WOLogManager ()

@property(copy) NSString    *defaultLogFilePath;

@end

// TODO: (for Leopard only?) integration with Apple System Log API (man asl)
@implementation WOLogManager

#pragma mark -
#pragma mark Class methods

+ (WOLogManager *)sharedManager
{
    WOLogManager *manager = WOSharedLogManager;
    WO_READ_MEMORY_BARRIER();
    if (!manager)
    {
        @synchronized (self)
        {
            manager = WOSharedLogManager;
            if (!manager)
            {
                manager = [[self alloc] init];
                WO_WRITE_MEMORY_BARRIER();
                WOSharedLogManager = manager;
            }
        }
    }
    return manager;
}

- (id)init
{
    if ((self = [super init]))
    {
        NSString *identifier = [[NSBundle mainBundle] bundleIdentifier];
        NSString *logFileName = nil;
        if (identifier)
            logFileName = [identifier stringByAppendingPathExtension:WO_LOG_FILE_EXTENSION];
        else
            logFileName = [WO_DEFAULT_LOG_FILE_NAME stringByAppendingPathExtension:WO_LOG_FILE_EXTENSION];
        NSString *folderPath = [self logsFolderPath:kUserDomain];
        NSString *fullPath = [folderPath stringByAppendingPathComponent:logFileName];
        if (fullPath)
            self.defaultLogFilePath = fullPath;
        else
            self.defaultLogFilePath =
                [[WO_FALLBACK_LOG_FOLDER_PATH stringByExpandingTildeInPath] stringByAppendingPathComponent:logFileName];

        NSProcessInfo *processInfo = [NSProcessInfo processInfo];
        [self setProcessName:[processInfo processName]];
        [self setProcessIdentifier:[processInfo processIdentifier]];
        [self setLogLevel:WO_DEFAULT_LOG_LEVEL];
    }
    return self;
}

#pragma mark -
#pragma mark Primitive logging methods

- (void)vLogToFileLevel:(unsigned)level message:(NSString *)format args:(va_list)args
{
    WOParameterCheck([format isKindOfClass:[NSString class]]);
    WOParameterCheck(format != nil);
    if (level > [self logLevel]) return;

    NSString *message = [NSString stringWithFormat:format arguments:args];
    NSString *path = [self logFilePath];
    if (!path) path = [self defaultLogFilePath];

    NSString *date = [[NSDate date] descriptionWithCalendarFormat:@"%Y-%m-%d %H:%M:%S.%F" timeZone:nil locale:nil];

    // Final string should resemble "2005-03-24 15:29:32.915 Xcode[17016] msg"
    NSString *logString = WO_STRING(@"%@ %@[%d] %@\n", date, [self processName], [self processIdentifier], message);

    if (![logString appendToFile:path])
    {
        NSLog(@"Error: Could not log message to file \"%@\": message follows", path);
        NSLog(@"%@", message);  // pass string as format argument in case it contains format markers
    }
}

- (void)vLogToStdErrLevel:(unsigned)level message:(NSString *)format args:(va_list)args
{
    WOParameterCheck([format isKindOfClass:[NSString class]]);
    WOParameterCheck(format != nil);
    if (level > [self logLevel]) return;

    NSString *string = [NSString stringWithFormat:format arguments:args];
    NSLog(@"%@", string);   // pass string as format argument in case it contains format markers
}

#pragma mark -
#pragma mark Logging methods

- (void)log:(NSString *)format, ...
{
    if (!format) return;
    va_list args;
    va_start(args, format);
    if ([self logsToFileByDefault])
        [self vLogToFileLevel:WO_DEFAULT_LOG_LEVEL message:[self stringForObject:format] args:args];
    else
        [self vLogToStdErrLevel:WO_DEFAULT_LOG_LEVEL message:[self stringForObject:format] args:args];
    va_end(args);
}

- (void)logMessage:(NSString *)format, ...
{
    if (!format) return;
    va_list args;
    va_start(args, format);
    if ([self logsToFileByDefault])
        [self vLogToFileLevel:WO_DEFAULT_LOG_LEVEL message:[self stringForObject:format] args:args];
    else
        [self vLogToStdErrLevel:WO_DEFAULT_LOG_LEVEL message:[self stringForObject:format] args:args];
    va_end(args);
}

- (void)logWarn:(NSString *)format, ...
{
    if (!format) return;
    va_list args;
    va_start(args, format);
    if ([self logsToFileByDefault])
        [self vLogToFileLevel:ASL_LEVEL_WARNING
                      message:[[self stringForObject:format] stringByPrependingString:WO_LOG_WARNING_PREFIX]
                         args:args];
    else
        [self vLogToStdErrLevel:ASL_LEVEL_WARNING
                        message:[[self stringForObject:format] stringByPrependingString:WO_LOG_WARNING_PREFIX]
                           args:args];
    va_end(args);
}

- (void)warn:(NSString *)format, ...
{
    if (!format) return;
    va_list args;
    va_start(args, format);
    if ([self logsToFileByDefault])
        [self vLogToFileLevel:ASL_LEVEL_WARNING
                      message:[[self stringForObject:format] stringByPrependingString:WO_LOG_WARNING_PREFIX]
                         args:args];
    else
        [self vLogToStdErrLevel:ASL_LEVEL_WARNING
                        message:[[self stringForObject:format] stringByPrependingString:WO_LOG_WARNING_PREFIX]
                           args:args];
    va_end(args);
}

- (void)logErr:(NSString *)format, ...
{
    if (!format) return;
    va_list args;
    va_start(args, format);
    if ([self logsToFileByDefault])
        [self vLogToFileLevel:ASL_LEVEL_ERR
                      message:[[self stringForObject:format] stringByPrependingString:WO_LOG_ERROR_PREFIX]
                         args:args];
    else
        [self vLogToStdErrLevel:ASL_LEVEL_ERR
                        message:[[self stringForObject:format] stringByPrependingString:WO_LOG_ERROR_PREFIX]
                           args:args];
    va_end(args);
}

- (void)error:(NSString *)format, ...
{
    if (!format) return;
    va_list args;
    va_start(args, format);
    if ([self logsToFileByDefault])
        [self vLogToFileLevel:ASL_LEVEL_ERR
                      message:[[self stringForObject:format] stringByPrependingString:WO_LOG_ERROR_PREFIX]
                         args:args];
    else
        [self vLogToStdErrLevel:ASL_LEVEL_ERR
                        message:[[self stringForObject:format] stringByPrependingString:WO_LOG_ERROR_PREFIX]
                           args:args];
    va_end(args);
}

- (void)err:(NSString *)format, ...
{
    if (!format) return;
    va_list args;
    va_start(args, format);
    if ([self logsToFileByDefault])
        [self vLogToFileLevel:ASL_LEVEL_ERR
                      message:[[self stringForObject:format] stringByPrependingString:WO_LOG_ERROR_PREFIX]
                         args:args];
    else
        [self vLogToStdErrLevel:ASL_LEVEL_ERR
                        message:[[self stringForObject:format] stringByPrependingString:WO_LOG_ERROR_PREFIX]
                           args:args];
    va_end(args);
}

- (void)err:(NSString *)functionOrMethodName no:(int)errorNumber
{
    NSParameterAssert(functionOrMethodName != nil);
    [self logError:@"%@ returned error %d", functionOrMethodName, errorNumber];
}

- (void)logToFileMessage:(NSString *)format, ...
{
    if (!format) return;
    va_list args;
    va_start(args, format);
    [self vLogToFileLevel:WO_DEFAULT_LOG_LEVEL
                  message:[self stringForObject:format]
                     args:args];
    va_end(args);
}

- (void)logToFileWarning:(NSString *)format, ...
{
    if (!format) return;
    va_list args;
    va_start(args, format);
    [self vLogToFileLevel:ASL_LEVEL_WARNING
                  message:[[self stringForObject:format] stringByPrependingString:WO_LOG_WARNING_PREFIX] args:args];
    va_end(args);
}

- (void)logToFileError:(NSString *)format, ...
{
    if (!format) return;
    va_list args;
    va_start(args, format);
    [self vLogToFileLevel:ASL_LEVEL_ERR
                  message:[[self stringForObject:format] stringByPrependingString:WO_LOG_ERROR_PREFIX] args:args];
    va_end(args);
}

- (void)logLevel:(unsigned)level message:(NSString *)format, ...
{
    if (!format) return;
    va_list args;
    va_start(args, format);
    if ([self logsToFileByDefault])
        [self vLogToFileLevel:level message:[self stringForObject:format] args:args];
    else
        [self vLogToStdErrLevel:level message:[self stringForObject:format] args:args];
    va_end(args);
}

- (void)logLevel:(unsigned)level warning:(NSString *)format, ...
{
    if (!format) return;
    va_list args;
    va_start(args, format);
    if ([self logsToFileByDefault])
        [self vLogToFileLevel:level
                      message:[[self stringForObject:format] stringByPrependingString:WO_LOG_WARNING_PREFIX] args:args];
    else
        [self vLogToStdErrLevel:level
                        message:[[self stringForObject:format] stringByPrependingString:WO_LOG_WARNING_PREFIX] args:args];
    va_end(args);
}


- (void)logLevel:(unsigned)level error:(NSString *)format, ...
{
    if (!format) return;
    va_list args;
    va_start(args, format);
    if ([self logsToFileByDefault])
        [self vLogToFileLevel:level
                      message:[[self stringForObject:format] stringByPrependingString:WO_LOG_ERROR_PREFIX] args:args];
    else
        [self vLogToStdErrLevel:level
                        message:[[self stringForObject:format] stringByPrependingString:WO_LOG_ERROR_PREFIX] args:args];
    va_end(args);
}

- (void)logEmergency:(NSString *)format, ...
{
    if (!format) return;
    va_list args;
    va_start(args, format);
    if ([self logsToFileByDefault])
        [self vLogToFileLevel:ASL_LEVEL_EMERG
                      message:[[self stringForObject:format] stringByPrependingString:WO_LOG_ERROR_PREFIX] args:args];
    else
        [self vLogToStdErrLevel:ASL_LEVEL_EMERG
                        message:[[self stringForObject:format] stringByPrependingString:WO_LOG_ERROR_PREFIX] args:args];
    va_end(args);
}

- (void)logAlert:(NSString *)format, ...
{
    if (!format) return;
    va_list args;
    va_start(args, format);
    if ([self logsToFileByDefault])
        [self vLogToFileLevel:ASL_LEVEL_ALERT
                      message:[[self stringForObject:format] stringByPrependingString:WO_LOG_ERROR_PREFIX] args:args];
    else
        [self vLogToStdErrLevel:ASL_LEVEL_ALERT
                        message:[[self stringForObject:format] stringByPrependingString:WO_LOG_ERROR_PREFIX] args:args];
    va_end(args);
}

- (void)logCritical:(NSString *)format, ...
{
    if (!format) return;
    va_list args;
    va_start(args, format);
    if ([self logsToFileByDefault])
        [self vLogToFileLevel:ASL_LEVEL_CRIT
                      message:[[self stringForObject:format] stringByPrependingString:WO_LOG_ERROR_PREFIX] args:args];
    else
        [self vLogToStdErrLevel:ASL_LEVEL_CRIT
                        message:[[self stringForObject:format] stringByPrependingString:WO_LOG_ERROR_PREFIX] args:args];
    va_end(args);
}

- (void)logError:(NSString *)format, ...
{
    if (!format) return;
    va_list args;
    va_start(args, format);
    if ([self logsToFileByDefault])
        [self vLogToFileLevel:ASL_LEVEL_ERR
                      message:[[self stringForObject:format] stringByPrependingString:WO_LOG_ERROR_PREFIX] args:args];
    else
        [self vLogToStdErrLevel:ASL_LEVEL_ERR
                        message:[[self stringForObject:format] stringByPrependingString:WO_LOG_ERROR_PREFIX] args:args];
    va_end(args);
}

- (void)logWarning:(NSString *)format, ...
{
    if (!format) return;
    va_list args;
    va_start(args, format);
    if ([self logsToFileByDefault])
        [self vLogToFileLevel:ASL_LEVEL_WARNING
                      message:[[self stringForObject:format] stringByPrependingString:WO_LOG_WARNING_PREFIX] args:args];
    else
        [self vLogToStdErrLevel:ASL_LEVEL_WARNING
                        message:[[self stringForObject:format] stringByPrependingString:WO_LOG_WARNING_PREFIX] args:args];
    va_end(args);
}

- (void)logNotice:(NSString *)format, ...
{
    if (!format) return;
    va_list args;
    va_start(args, format);
    if ([self logsToFileByDefault])
        [self vLogToFileLevel:ASL_LEVEL_NOTICE message:[self stringForObject:format] args:args];
    else
        [self vLogToStdErrLevel:ASL_LEVEL_NOTICE message:[self stringForObject:format] args:args];
    va_end(args);
}

- (void)logInfo:(NSString *)format, ...
{
    if (!format) return;
    va_list args;
    va_start(args, format);
    if ([self logsToFileByDefault])
        [self vLogToFileLevel:ASL_LEVEL_INFO message:[self stringForObject:format] args:args];
    else
        [self vLogToStdErrLevel:ASL_LEVEL_INFO message:[self stringForObject:format] args:args];
    va_end(args);
}

- (void)logDebug:(NSString *)format, ...
{
    if (!format) return;
    va_list args;
    va_start(args, format);
    if ([self logsToFileByDefault])
        [self vLogToFileLevel:ASL_LEVEL_DEBUG message:[self stringForObject:format] args:args];
    else
        [self vLogToStdErrLevel:ASL_LEVEL_DEBUG message:[self stringForObject:format] args:args];
    va_end(args);
}

- (void)logToFileLevel:(unsigned)level message:(NSString *)format, ...
{
    if (!format) return;
    va_list args;
    va_start(args, format);
    [self vLogToFileLevel:level message:[self stringForObject:format] args:args];
    va_end(args);
}

- (void)logToFileLevel:(unsigned)level warning:(NSString *)format, ...
{
    if (!format) return;
    va_list args;
    va_start(args, format);
    [self vLogToFileLevel:level
                  message:[[self stringForObject:format] stringByPrependingString:WO_LOG_WARNING_PREFIX] args:args];
    va_end(args);
}

- (void)logToFileLevel:(unsigned)level error:(NSString *)format, ...
{
    if (!format) return;
    va_list args;
    va_start(args, format);
    [self vLogToFileLevel:level
                  message:[[self stringForObject:format] stringByPrependingString:WO_LOG_ERROR_PREFIX] args:args];
    va_end(args);
}

#pragma mark -
#pragma mark Utility methods

- (NSString *)stringForObject:(NSObject *)object
{
    // TODO: make this safe even for objects that don't inherit from NSObject or another Cocoa root class (see WOTest)
    NSString *returnValue = nil;
    @try
    {
        if (!object)
            returnValue = @"(null)";
        else if ([object isKindOfClass:[NSString class]])
            returnValue = (NSString *)object;
        else if ([object respondsToSelector:@selector(stringValue)])
            returnValue = [object performSelector:@selector(stringValue)];
        else if ([object respondsToSelector:@selector(description)])
            returnValue = [object performSelector:@selector(description)];
        else
            returnValue = @"(cannot obtain string value from object)";
    }
    @catch (id exception)
    {
        returnValue = @"(exception caught trying to obtain string value)";
    }
    return returnValue;
}

#pragma mark -
#pragma mark Convenience methods

- (NSString *)logsFolderPath:(short)domain
{
    NSString *logsPath = nil;
    FSRef folderRef;
    OSErr err = FSFindFolder(domain, kLogsFolderType, kCreateFolder, &folderRef);
    if (err == noErr)
        logsPath = [(NSURL *)CFBridgingRelease(CFURLCreateFromFSRef(kCFAllocatorDefault, &folderRef)) path];
    else
        NSLog(@"FSFinderFolder error (%d)", err);
    return logsPath;
}

#pragma mark -
#pragma mark Properties

@synthesize processName;
@synthesize processIdentifier;
@synthesize logLevel;
@synthesize logFilePath;
@synthesize defaultLogFilePath;
@synthesize logsToFileByDefault;

@end
