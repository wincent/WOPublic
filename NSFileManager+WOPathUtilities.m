// NSFileManager+WOPathUtilities.m
// WOPublic
//
// Copyright 2006-2009 Wincent Colaiuta. All rights reserved.
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
#import "NSFileManager+WOPathUtilities.h"

// system headers
#import <CoreServices/CoreServices.h>
#import <sys/param.h>                       /* MAXPATHLEN */
#import <sys/time.h>                        /* utimes() */
#import <unistd.h>                          /* mkdtemp() */

// class headers
#import "WOConvenienceMacros.h"
#import "WOLogManager.h"

// macro headers
#import "WODebugMacros.h"
#import "WOMemory.h"

WO_CATEGORY_MARKER(NSFileManager, WOPathUtilities);
@implementation NSFileManager (WOPathUtilities)

- (NSString *)pathForFolder:(OSType)type domain:(short)domain
{
    return [self pathForFolder:type domain:domain create:NO];
}

- (NSString *)pathForFolder:(OSType)type domain:(short)domain create:(BOOL)create
{
    NSString *path = nil;
    FSRef folderRef;
    OSErr err = FSFindFolder(domain, type, (Boolean)create, &folderRef);
    if (err == noErr)
        path = [NSMakeCollectable(CFURLCreateFromFSRef(NULL, &folderRef)) path];
    else
        [WOLog err:@"FSFindFolder returned %d for type %d, domain %d, create %@", type, domain, WO_STRING_FROM_BOOL(create)];
    return path;
}

// TODO: consider splitting off these methods into separate category/categories (WODirectoryAdditions, WOFileAdditions etc)

- (NSString *)temporaryDirectory
{
    NSString *temp      = [self pathForFolder:kTemporaryFolderType domain:kSystemDomain];
    NSString *template  = [temp stringByAppendingPathComponent:@"WOCommon.XXXXXXXXXXXXXXXX"];
    return [self temporaryDirectoryUsingTemplate:template];
}

- (NSString *)temporaryDirectoryUsingTemplate:(NSString *)aString
{
    WOParameterCheck(aString != nil);
    const char  *readOnlyTemplate   = [self fileSystemRepresentationWithPath:aString];
    size_t      templateLength      = strlen(readOnlyTemplate);
    WOCheck(templateLength <= MAXPATHLEN);
    char        *writeableTemplate  = emalloc((templateLength + 1) * sizeof(char));
    strncpy(writeableTemplate, readOnlyTemplate, templateLength + 1);
    if (!mkdtemp(writeableTemplate))
    {
        perror("mkdtemp");
        return nil;
    }
    return [self stringWithFileSystemRepresentation:writeableTemplate length:strlen(writeableTemplate)];
}

- (BOOL)touchFileAtPath:(NSString *)path
{
    if (!path) return NO;
    int err = utimes([path fileSystemRepresentation], NULL);
    if (err == 0) return YES;
    if (errno == ENOENT)    // file does not exist attempt to create it
        return [self createFileAtPath:path contents:[NSData data] attributes:nil];
    else                    // all other errors except "file does not exist"
        perror("utimes");
    return NO;
}

- (BOOL)createDirectoryAtPath:(NSString *)path attributes:(NSDictionary *)attributes createParents:(BOOL)flag
{
    if (!flag) return [self createDirectoryAtPath:path attributes:attributes];
    if (!path) return NO;
    NSArray     *components = [path pathComponents];
    unsigned    count       = [components count];
    if (count > 1)
    {
        NSString *parent = [path stringByDeletingLastPathComponent];
        BOOL isDirectory;
        if ([self fileExistsAtPath:parent isDirectory:&isDirectory])
        {
            if (isDirectory)    // parent exists and is a directory
                return [self createDirectoryAtPath:path attributes:attributes];
            else                // parent exists and is not a directory!
            {
                [WOLog err:@"failed to create directory at path \"%@\" (parent \"%@\" exists and is not a directory)", path, parent];
                return NO;
            }
        }
        else                    // parent does not exist, create it recursively
        {
            if ([self createDirectoryAtPath:parent attributes:attributes createParents:flag])
                return [self createDirectoryAtPath:path attributes:attributes];
            else
            {
                [WOLog err:@"failed to create directory at path \"%@\" (couldn't create parent \"%@\")", path, parent];
                return NO;      // couldn't create parent
            }
        }
    }
    else if (count == 1)
        return [self createDirectoryAtPath:path attributes:attributes];
    return NO;                  // count is 0, can't create a directory with zero components
}

@end
