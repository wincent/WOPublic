// NSString+WOPathUtilities.m
// WOCommon
//
// Copyright 2006-2009 Wincent Colaiuta. All rights reserved.

// category header
#import "NSString+WOPathUtilities.h"

// other headers
#import "NSFileManager+WOPathUtilities.h"
#import "NSMutableString+WOPathUtilities.h"
#import "WOLogManager.h"

// WOPublic headers
#import "WOPublic/WODebugMacros.h"

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
