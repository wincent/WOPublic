// NSArray+WOConvenience.h
// WOPublic
//
// Copyright 2006-2009 Wincent Colaiuta. All rights reserved.

// system header
#import <Foundation/Foundation.h>

// macro headers
#import "WOConvenienceMacros.h"

WO_DECLARE_CATEGORY_MARKER(NSArray, WOConvenience);

@interface NSArray (WOConvenience)

//! Companion to the lastObject method. Returns nil if the receiver is empty.
- (id)firstObject;

//! Convenience method that allows the creation of more robust, readable tests
//! as shown in this example:
//!
//! \code
//! // easy to make mistakes when coding like this:
//! lastObject = [array objectAtIndex:[array count] - 1];
//!
//! // more robust:
//! if (index == [array lastIndex]) return [array lastObject];
//! \endcode
//!
//! \returns The index of the last item in the receiver, or NSNotFound if the
//! receiver is empty.
- (unsigned)lastIndex;

@end
