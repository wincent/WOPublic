//
//  NSString+WOPathUtilitiesTests.m
//  WOCommon
//
//  Created by Wincent Colaiuta on 10 August 2006.
//  Copyright 2006-2008 Wincent Colaiuta.

#import "NSString+WOPathUtilitiesTests.h"
#import "NSString+WOPathUtilities.h"
#import "WOConvenienceMacros.h"

@implementation NSString_WOPathUtilitiesTests

- (void)testStringByAppendingPathComponents
{
    NSString *path = [NSString stringWithString:@"/usr/etc"];
    NSArray *components = WO_ARRAY(@"foo", @"bar");
    NSString *newPath = [path stringByAppendingPathComponents:components];
    WO_TEST_EQ(newPath, @"/usr/etc/foo/bar");
}

@end
