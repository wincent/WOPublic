// NSMutableString+WOPathUtilitiesTests.m
// WOPublic
//
// Copyright 2006-present Greg Hurrell. All rights reserved.
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
#import "NSMutableString+WOPathUtilitiesTests.h"

// tested category header
#import "NSMutableString+WOPathUtilities.h"

// macro headers
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
