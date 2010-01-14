// NSString+WOURLUtilities.h
// WOCommon
//
// Copyright 2004-2009 Wincent Colaiuta. All rights reserved.

#import <Foundation/Foundation.h>

// WOPublic headers
#import "WOPublic/WOConvenienceMacros.h"

WO_DECLARE_CATEGORY_MARKER(NSString, WOURLUtilities);

@interface NSString (WOURLUtilities)

#pragma mark -
#pragma mark Instance methods

//! Convenience method that creates a new NSURL object based on the contents of
//! the receiver and then tries to open the URL using the openURL: method of
//! NSWorkspace.
//!
//! Returns the result returned by the openURL: method (YES or NO).
- (BOOL)openAsURL;

@end
