// NSArray+WOConvenience.m
// WOPublic
//
// Copyright 2006-2009 Wincent Colaiuta. All rights reserved.

// category header
#import "NSArray+WOConvenience.h"

WO_CATEGORY_MARKER(NSArray, WOConvenience);
@implementation NSArray (WOConvenience)

- (id)firstObject
{
    return ([self count] == 0) ? nil : [self objectAtIndex:0];
}

- (unsigned)lastIndex
{
    return ([self count] == 0) ? NSNotFound : [self count] - 1;
}

@end
