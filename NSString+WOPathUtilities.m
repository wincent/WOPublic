// NSString+WOPathUtilities.m
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
#import "NSString+WOPathUtilities.h"

// other category headers
#import "NSFileManager+WOPathUtilities.h"
#import "NSMutableString+WOPathUtilities.h"

// class headers
#import "WOLogManager.h"

// macro headers
#import "WODebugMacros.h"

WO_CATEGORY_MARKER(NSString, WOPathUtilities);
@implementation NSString (WOPathUtilities)

#pragma mark -
#pragma mark Custom methods

+ (NSString *)stringWithFolder:(OSType)type domain:(short)domain creating:(BOOL)creating
{
    FSRef   folderRef;
    Boolean flag    = creating ? kCreateFolder : kDontCreateFolder;
    OSErr   err     = FSFindFolder(domain, type, flag, &folderRef);
    return (err == noErr) ? [NSMakeCollectable(CFURLCreateFromFSRef(NULL, &folderRef)) path] : nil;
}

+ (NSString *)stringWithApplicationSupportFolder
{
    return [self stringWithFolder:kApplicationSupportFolderType domain:kUserDomain creating:YES];
}

+ (NSString *)stringWithApplicationSupportSubfolder:(NSString *)subfolder
{
    NSParameterAssert(subfolder != nil);
    NSString *folder = [self stringWithApplicationSupportFolder];
    if (!folder) return nil;

    // if subfolders already exist at desired path, make sure final path component is a folder and not a regular file
    NSString        *path           = [folder stringByAppendingPathComponents:[subfolder pathComponents]];
    NSFileManager   *manager        = [NSFileManager defaultManager];
    BOOL            isDirectory;
    if ([manager fileExistsAtPath:path isDirectory:&isDirectory])
    {
        if (isDirectory)
            return path;
        else
        {
            [WOLog err:@"file exists at path \"%@\" but is not a directory", path];
            return nil;
        }
    }

    // try to create subfolders
    return [manager createDirectoryAtPath:path attributes:nil createParents:YES] ? path : nil;
}

+ (NSString *)stringWithFileSystemRepresentation:(const char *)representation
{
    return [[NSFileManager defaultManager] stringWithFileSystemRepresentation:representation length:strlen(representation)];
}

- (NSString *)stringByAppendingPathComponents:(NSArray *)pathComponents
{
    if (!pathComponents || [pathComponents count] == 0) return [self copy];
    NSMutableString *path = [self mutableCopy];
    [path appendPathComponents:pathComponents];
    return path;
}

@end
