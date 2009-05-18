// NSString+WOFileUtilities.h
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

// category header
#import "NSString+WOFileUtilities.h"

// system headers
#import <sys/types.h>   /* write() */
#import <sys/uio.h>     /* write() */
#import <unistd.h>      /* write(), close() */
#import <fcntl.h>       /* open() */

// class headers
#import "WOLogManager.h"

// macro headers
#import "WODebugMacros.h"

WO_CATEGORY_MARKER(NSString, WOFileUtilities);
@implementation NSString (WOFileUtilities)

#pragma mark -
#pragma mark Instance methods

// TODO: add better error logging here (potentially use NSError)
- (BOOL)appendToFile:(NSString *)path
{
    WOParameterCheck(path != nil);
    if ([self length] == 0) // appending nothing always succeeds
        return YES;

    BOOL returnValue = NO;

    // open file, creating if necessary, write-only, appending, exclusive lock
    int descriptor = open([path fileSystemRepresentation], O_CREAT | O_WRONLY | O_APPEND | O_EXLOCK, 0644);

    if (descriptor > 0) // successfully opened file
    {
        const char *string = [self UTF8String];
        ssize_t written = write(descriptor, string, strlen(string));
        if (written == -1)
            perror("write");
        else if (written >= 0)
        {
            if ((unsigned)written == strlen(string))    // cast is safe because written is non-negative
            returnValue = YES;
        }
        else                                            // this is totally unexpected
            [WOLog err:@"write returned a negative length other than -1: %d", written];
        if (close(descriptor) != 0)                     // error while closing file
        {
            perror("close");
            returnValue = NO;
        }
    }
    return returnValue;
}

@end
