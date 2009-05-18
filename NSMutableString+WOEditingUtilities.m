// NSMutableString+WOEditingUtilities.m
// WOCommon
//
// Copyright 2006-2009 Wincent Colaiuta. All rights reserved.

// category header
#import "NSMutableString+WOEditingUtilities.h"

WO_CATEGORY_MARKER(NSMutableString, WOEditingUtilities);
@implementation NSMutableString (WOEditingUtilities)

- (void)removeCharactersInSet:(NSCharacterSet *)aSet
{
    if (!aSet)
        return;
    unsigned length = self.length;
    if (length == 0)
        return;
    for (unsigned i = length; i > 0; i--) // loop backwards through string for safe deletion
    {
        if ([aSet characterIsMember:[self characterAtIndex:i - 1]])
            [self deleteCharactersInRange:NSMakeRange(i - 1, 1)];
    }
}

@end
