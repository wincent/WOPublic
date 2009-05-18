// NSString+WOFileUtilities.h
// WOCommon
//
// Copyright 2004-2009 Wincent Colaiuta. All rights reserved.

// category header
#import "NSString+WOFileUtilities.h"

// system headers
#import <sys/types.h>   /* write() */
#import <sys/uio.h>     /* write() */
#import <unistd.h>      /* write(), close() */
#import <fcntl.h>       /* open() */

// WOCommon class headers
#import "WOLogManager.h"

// WOPublic headers
#import "WOPublic/WODebugMacros.h"

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
