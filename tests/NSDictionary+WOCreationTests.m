// NSDictionary+WOCreationTests.m
// WOPublic
//
// Copyright 2006-2009 Wincent Colaiuta. All rights reserved.
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
#import "NSDictionary+WOCreationTests.h"

// tested category header
#import "NSDictionary+WOCreation.h"

@implementation NSDictionary_WOCreationTests

- (void)testDictionaryWithKeysAndObjects
{
    // passing nil should return an empty dictionary
    WO_TEST_EQ([NSDictionary dictionaryWithKeysAndObjects:nil], [NSDictionary dictionary]);

    // must be an object for every key
    WO_TEST_THROWS(([NSDictionary dictionaryWithKeysAndObjects:@"key", nil]));
    WO_TEST_THROWS(([NSDictionary dictionaryWithKeysAndObjects:@"key1", @"object1", @"key2", nil]));

    NSDictionary *expected  = [NSDictionary dictionaryWithObjectsAndKeys:@"object1", @"key1", @"object2", @"key2", nil];
    NSDictionary *actual    = [NSDictionary dictionaryWithKeysAndObjects:@"key1", @"object1", @"key2", @"object2", nil];
    WO_TEST_EQ(actual, expected);
}

@end
