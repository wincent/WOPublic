// NSString+WOCreation.m
// WOCommon
//
// Copyright 2004-2009 Wincent Colaiuta. All rights reserved.

// class header
#import "NSString+WOCreation.h"

// other headers
#import "NSMutableString+WOEditingUtilities.h"

// WOPublic headers
#import "WOPublic/WODebugMacros.h"

WO_CATEGORY_MARKER(NSString, WOCreation);
@implementation NSString (WOCreation)

#pragma mark -
#pragma mark Class methods

- (NSString *)string
{
    return [self copy];
}

+ (NSString *)stringWithFormat:(NSString *)aString arguments:(va_list)args
{
    NSParameterAssert(aString != nil);
    if (args)
        return [[NSString alloc] initWithFormat:aString arguments:args];
    else
        return [NSString stringWithString:aString];
}

#pragma mark -
#pragma mark Instance methods

- (NSString *)stringByPrependingString:(NSString *)aString
{
    NSParameterAssert(aString != nil);
    return WO_STRING(@"%@%@", aString, self);
}

- (NSString *)stringByRemovingCharactersInSet:(NSCharacterSet *)aSet
{
    if (aSet == nil) return [NSString stringWithString:self];
    NSMutableString *workString = [NSMutableString stringWithString:self];
    [workString removeCharactersInSet:aSet];
    return workString;
}

@end
