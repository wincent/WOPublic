// NSMutableString+WOEditingUtilities.h
// WOCommon
//
// Copyright 2006-2009 Wincent Colaiuta. All rights reserved.

#import <Foundation/Foundation.h>

// WOPublic headers
#import "WOPublic/WOConvenienceMacros.h"

WO_DECLARE_CATEGORY_MARKER(NSMutableString, WOEditingUtilities);

//! Methods for modifying mutable strings in place
@interface NSMutableString (WOEditingUtilities)

- (void)removeCharactersInSet:(NSCharacterSet *)aSet;

@end
