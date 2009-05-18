// NSMutableString+WOPathUtilities.m
// WOCommon
//
// Copyright 2006-2009 Wincent Colaiuta. All rights reserved.

// category header
#import "NSMutableString+WOPathUtilities.h"

WO_CATEGORY_MARKER(NSMutableString, WOPathUtilities);
@implementation NSMutableString (WOPathUtilities)

- (void)appendPathComponent:(NSString *)component
{
    if (!component) return;
    [self setString:[self stringByAppendingPathComponent:component]];
}

- (void)appendPathComponents:(NSArray *)components
{
    for (NSString *component in components)
        [self appendPathComponent:component];
}

@end
