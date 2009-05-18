//
//  NSMutableString+WOPathUtilitiesTests.m
//  WOCommon
//
//  Created by Wincent Colaiuta on 10 August 2006.
//  Copyright 2006-2008 Wincent Colaiuta.

#import "NSMutableString+WOPathUtilitiesTests.h"
#import "NSMutableString+WOPathUtilities.h"
#import "WOConvenienceMacros.h"

@implementation NSMutableString_WOPathUtilitiesTests

- (void)testAppendPathComponent
{
    NSMutableString *path = [NSMutableString stringWithString:@"/usr/etc"];
    [path appendPathComponent:@"foo"];
    WO_TEST_EQ(path, @"/usr/etc/foo");
}

- (void)testAppendPathComponents
{
    NSMutableString *path = [NSMutableString stringWithString:@"/usr/etc"];
    NSArray *components = WO_ARRAY(@"foo", @"bar");
    [path appendPathComponents:components];
    WO_TEST_EQ(path, @"/usr/etc/foo/bar");
}

@end
