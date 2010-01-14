// NSURL+WOConvenience.h
// WOCommon
//
// Copyright 2006-2009 Wincent Colaiuta. All rights reserved.

#import <Foundation/Foundation.h>

// WOPublic headers
#import "WOPublic/WOConvenienceMacros.h"

WO_DECLARE_CATEGORY_MARKER(NSURL, WOConvenience);

//! Required frameworks:
//!     - AppKit (for NSWorkspace)
//!     - Foundation
//!
@interface NSURL (WOConvenience)

- (BOOL)open;

//! Objective-C wrapper for CFURLCreateFromFSRef API.
//! \warn Note that this method differs from the original WOBase implementation
//! (which expected \p ref to be a pointer to an FSRef, not an FSRef)
+ (NSURL *)URLWithFSRef:(FSRef)ref;

@end
