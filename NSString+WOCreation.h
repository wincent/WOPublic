// NSString+WOCreation.m
// WOCommon
//
// Copyright 2004-2009 Wincent Colaiuta. All rights reserved.

#import <Foundation/Foundation.h>

// WOPublic headers
#import "WOPublic/WOConvenienceMacros.h"

WO_DECLARE_CATEGORY_MARKER(NSString, WOCreation);

//! Methods for creating strings
//!
//! Required categories:
//!     - NSMutableString (WOEditingUtilities)
//!
@interface NSString (WOCreation)

#pragma mark -
#pragma mark Class methods

//! Returns an immutable string based on the contents of the receiver.
//! \deprecated Under Garbage Collection this is effectively equivalent to performing a copy; callers are advised to use the copy method directly instead.
- (NSString *)string WO_DEPRECATED;

+ (NSString *)stringWithFormat:(NSString *)aString arguments:(va_list)args;

#pragma mark -
#pragma mark Instance methods

- (NSString *)stringByPrependingString:(NSString *)aString;

- (NSString *)stringByRemovingCharactersInSet:(NSCharacterSet *)aSet;

@end
