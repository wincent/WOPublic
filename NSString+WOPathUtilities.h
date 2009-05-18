// NSString+WOPathUtilities.h
// WOCommon
//
// Copyright 2006-2009 Wincent Colaiuta. All rights reserved.

#import <Foundation/Foundation.h>

// WOPublic headers
#import "WOPublic/WOConvenienceMacros.h"

WO_DECLARE_CATEGORY_MARKER(NSString, WOPathUtilities);

//! Required classes:
//!     - WOLogManager
//!
//! Required categories:
//!     - NSMutableString (WOPathUtilities)
//!     - NSMutableString (WOCreation)
//!     - NSFileManager (WOPathUtilities)
//!
@interface NSString (WOPathUtilities)

#pragma mark -
#pragma mark Custom methods

//! Objective-C wrapper around the FSFindFolder API.
//!
//! \param type     One of the values defined in Apple's FSFindFolder documentation, such as kApplicationSupportFolderType, kDesktopFolderType or kTrashFolderType. See the Apple documentation for a full list.
//! \param domain   One of the values defined in Apple's FSFindFolder documentation, such as kOnAppropriateDisk, kSystemDomain, kLocalDomain, kNetworkDomain or kUserDomain.
+ (NSString *)stringWithFolder:(OSType)type domain:(short)domain creating:(BOOL)creating;

//! Invokes stringWithFolder:domain:creating: passing \p type kApplicationSupportFolderType, \p domain kUserDomain and \p creating YES. Returns nil on failure. Note that the path returned is not for the application-specific subfolder within the Application Support folder, but for the Application Support folder itself. If you want the application specific subfolder then you should call stringWithApplicationSupportSubfolder.
+ (NSString *)stringWithApplicationSupportFolder;

//! Invokes stringWithApplicationSupportFolder and appends subfolder as an additional path component before returning the result. subfolder may not be nil. If subfolder does not exist it this method will attempt to create it. You may pass a single subfolder (such as @"Application Name") or multiple-levels of subfolders (such as "Application Name/Scripts").
+ (NSString *)stringWithApplicationSupportSubfolder:(NSString *)subfolder;

// Convenience wrapper for NSFileManager method of same name
// \param representation A NULL-terminate C string file system representation
+ (NSString *)stringWithFileSystemRepresentation:(const char *)representation;

- (NSString *)stringByAppendingPathComponents:(NSArray *)pathComponents;

@end
