// NSArray+WORubyBlocksTests.m
// WOPublic
//
// Copyright 2010 Wincent Colaiuta. All rights reserved.
//
// Redistribution and use in source and binary forms, with or without
// modification, are permitted provided that the following conditions are met:
//
// 1. Redistributions of source code must retain the above copyright notice,
//    this list of conditions and the following disclaimer.
// 2. Redistributions in binary form must reproduce the above copyright notice,
//    this list of conditions and the following disclaimer in the documentation
//    and/or other materials provided with the distribution.
//
// THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS"
// AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE
// IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE
// ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT HOLDERS OR CONTRIBUTORS BE
// LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR
// CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF
// SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS
// INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN
// CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE)
// ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE
// POSSIBILITY OF SUCH DAMAGE.

// class header
#import "NSArray+WORubyBlocksTest.h"

// tested category header
#import "NSArray+WORubyBlocks.h"

@implementation NSArray_WORubyBlocksTests

- (void)testEmptyArray
{
    // empty array should remain empty
    NSArray *array = [NSArray array];
    WO_TEST_EQ([array map:^(id obj) { return (id)nil; }], [NSArray array]);

    // original array should not be modified
    WO_TEST_EQ(array, [NSArray array]);

    // alternate syntax (explicit return type)
    WO_TEST_EQ([array map:(id)^(id obj) { return nil; }], [NSArray array]);

    // alernate syntax (predeclared block variable)
    id (^block1)(id) = ^(id obj) {
        return (id)nil;
    };
    WO_TEST_EQ([array map:block1], [NSArray array]);

    // alernate syntax (predeclared block variable with explicit return type)
    id (^block2)(id) = (id)^(id obj) {
        return nil;
    };
    WO_TEST_EQ([array map:block2], [NSArray array]);
}

- (void)testOneElementArray
{
    // basic operation
    NSArray *array = WO_ARRAY(@"hello");
    NSArray *expected = WO_ARRAY(@"hello world");
    NSArray *actual = [array map:^(id obj) {
        return (id)[obj stringByAppendingString:@" world"];
    }];
    WO_TEST_EQ(actual, expected);

    // original array should not be modified
    WO_TEST_EQ(array, WO_ARRAY(@"hello"));

    // NSNull singleton should be substituted for nil returned from block
    expected = WO_ARRAY([NSNull null]);
    actual = [array map:^(id obj) { return (id)nil; }];
    WO_TEST_EQ(actual, expected);
}

- (void)testTwoElementArray
{
    // basic operation
    NSArray *array = WO_ARRAY(@"foo", @"bar");
    NSArray *expected = WO_ARRAY(@"foobaz", @"barbaz");
    NSArray *actual = [array map:^(id obj) {
        return (id)[obj stringByAppendingString:@"baz"];
    }];
    WO_TEST_EQ(actual, expected);

    // original array should not be modified
    WO_TEST_EQ(array, WO_ARRAY(@"foo", @"bar"));

    // NSNull singleton should be substituted for nil returned from block
    expected = WO_ARRAY([NSNull null], @"bar");
    actual = [array map:^(id obj) {
        return (id)([obj isEqualToString:@"bar"] ? obj : nil);
    }];
}

@end
