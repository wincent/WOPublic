//
//  NSMutableString+WOEditingUtilitiesTests.m
//  WOCommon
//
//  Created by Wincent Colaiuta on 10 August 2006.
//  Copyright 2006-2008 Wincent Colaiuta.

// class header
#import "NSMutableString+WOEditingUtilitiesTests.h"

// other headers
#import "NSMutableString+WOEditingUtilities.h"
#import "WOConvenienceMacros.h"

@implementation NSMutableString_WOEditingUtilitiesTests

- (void)testRemoveCharactersInSet
{
    // nil set
    NSMutableString *string = WO_MUTABLE_STRING(@"foobar");
    [string removeCharactersInSet:nil];
    WO_TEST_EQ(string, @"foobar");

    // empty set
    [string removeCharactersInSet:[NSCharacterSet characterSetWithCharactersInString:@""]];
    WO_TEST_EQ(string, @"foobar");

    // another set
    [string removeCharactersInSet:[NSCharacterSet characterSetWithCharactersInString:@"fa"]];
    WO_TEST_EQ(string, @"oobr");

    // test with zero-length string
    string = WO_MUTABLE_STRING(@"");
    [string removeCharactersInSet:nil];
    WO_TEST_EQ(string, @"");
    [string removeCharactersInSet:[NSCharacterSet characterSetWithCharactersInString:@""]];
    WO_TEST_EQ(string, @"");
    [string removeCharactersInSet:[NSCharacterSet characterSetWithCharactersInString:@"fa"]];
    WO_TEST_EQ(string, @"");
}

@end
