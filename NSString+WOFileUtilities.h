// NSString+WOFileUtilities.h
// WOCommon
//
// Copyright 2004-2009 Wincent Colaiuta. All rights reserved.

#import <Foundation/Foundation.h>

// WOPublic headers
#import "WOPublic/WOConvenienceMacros.h"

WO_DECLARE_CATEGORY_MARKER(NSString, WOFileUtilities);

//! Required classes:
//!     - WOLogManager
//!
@interface NSString (WOFileUtilities)

#pragma mark -
#pragma mark Instance methods

//! The file is created if it does not exist.
//! \note Appending a zero-length string always succeeds so this method will retun YES if the receiver is an empty string
//! \return YES on success, NO on failure
//! \throw NSInternalInconsistencyException thrown if \p path is nil
- (BOOL)appendToFile:(NSString *)path;

@end
