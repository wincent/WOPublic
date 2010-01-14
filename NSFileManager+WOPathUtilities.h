// NSFileManager+WOPathUtilities.h
// WOPublic
//
// Copyright 2006-2010 Wincent Colaiuta. All rights reserved.
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

// system header
#import <Foundation/Foundation.h>

// macro headers
#import "WOConvenienceMacros.h"

WO_DECLARE_CATEGORY_MARKER(NSFileManager, WOPathUtilities);

//! Required classes:
//!     - WOLogManager
//!
@interface NSFileManager (WOPathUtilities)

//! Objective-C wrapper for the FSFindFolder function. Returns nil on failure to find the requested path. Invokes pathForFolder:domain:create: with a \p create paramater of NO.
- (NSString *)pathForFolder:(OSType)type domain:(short)domain;

//! Objective-C wrapper for the FSFindFolder function. Returns nil on failure to find the requested path.
//! \param type A type constant (as defined in <Folders.h>) such as kApplicationSupportFolderType or kContextualMenuItemsFolderType
//! \param domain A domain constant (as defined in <Folders.h>) such as kUserDomain, kLocalDomain, kSystemDomain or kNetworkDomain
//! \param create Whether the folder should be created if it does not already exist
- (NSString *)pathForFolder:(OSType)type domain:(short)domain create:(BOOL)create;

//! Objective-C wrapper for the mkdtemp function. Invokes temporaryDirectoryUsingTemplate: with an \p aString parameter obtained by calling pathForFolder:domain: with a \p type of kTemporaryFolderType and kSystemDomain \p domain and appending the path component "WOPublic.XXXXXXXXXXXXXXXX"
- (NSString *)temporaryDirectory;

//! \param aString A path template of the form "/tmp/templateXXXX" with any number of Xs
//! \return The path to the created directory, or nil on failure
//! \throws NSInternalInconsistencyException thrown if \p aString is nil
//! \throws NSInternalInconsistencyException thrown if the template length exceeds MAXPATHLEN (defined in <param.h>)
//! \throws NSMallocException thrown if memory allocation fails while trying to copy the path template
- (NSString *)temporaryDirectoryUsingTemplate:(NSString *)aString;

//! Touches (updates the modification date) of the item at \p path. If no such item exists an empty file is created at \p path (intervening directories are not created).
//! \return YES on success and NO on failure
- (BOOL)touchFileAtPath:(NSString *)path;


//! \deprecated This method was made obsolete by the
//! createDirectoryAtPath:withIntermediateDirectories:attributes:error: method
//! which was added to NSFileManager in Leopard.
- (BOOL)createDirectoryAtPath:(NSString *)path
                   attributes:(NSDictionary *)attributes
                createParents:(BOOL)flag WO_DEPRECATED;

@end
