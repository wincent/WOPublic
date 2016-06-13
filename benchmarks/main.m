// main.m
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

// system header
#import <Foundation/Foundation.h>

// macro headers
#import "WOConvenienceMacros.h"

// class headers
#import "WOUsageMeter.h"

// category headers
#import "NSArray+WORubyBlocks.h"

static WOUsageMeter *meter = nil;

void group(const char *description)
{
    printf("%s\n", description);
}

void start(const char *description)
{
    NSString *labelPadding = @"                              "; // 30 spaces
    int paddingWidth = 30 - strlen(description);
    if (paddingWidth > 0)
        printf("%s", [[labelPadding substringToIndex:paddingWidth] UTF8String]);
    printf("%s: ", description);
    meter = [WOUsageMeter usageMeter];
}

void stop(void)
{
    [meter pause];
    const char *usage = [[meter usageString] UTF8String];
    printf("%s\n", usage);
}

#define WO_ONE_MILLION 1000000
#define WO_ONE_THOUSAND 1000

int main(int argc, char *argv[])
{
#pragma mark -
#pragma mark NSArray (WORubyBlocks) benchmarks

#pragma mark 1,000,000-element array, 1 iteration
    group("1,000,000-element array, 1 iteration");
    NSMutableArray *array = [NSMutableArray arrayWithCapacity:WO_ONE_MILLION];
    for (unsigned i = 0, max = WO_ONE_MILLION; i < max; i++)
        [array addObject:WO_STRING(@"object %d", i)];

    start("-[NSArray map:]");
    [array map:^(id string) {
        return (id)[string stringByAppendingString:@"!"];
    }];
    stop();

    start("manual enumeration");
    NSMutableArray *result = [NSMutableArray arrayWithCapacity:[array count]];
    for (unsigned i = 0, max = WO_ONE_MILLION; i < max; i++)
    {
        NSString *string = [array objectAtIndex:i];
        [result addObject:[string stringByAppendingString:@"!"]];
    }
    (void)[result copy];
    stop();

    start("fast enumeration");
    result = [NSMutableArray arrayWithCapacity:[array count]];
    for (NSString *string in array)
        [result addObject:[string stringByAppendingString:@"!"]];
    (void)[result copy];
    stop();

#pragma mark 1000-element array, 1000 iterations
    group("1000-element array, 1000 iterations");
    array = [NSMutableArray arrayWithCapacity:WO_ONE_THOUSAND];
    for (unsigned i = 0, max = WO_ONE_THOUSAND; i < max; i++)
        [array addObject:WO_STRING(@"object %d", i)];

    start("-[NSArray map:]");
    for (unsigned i = 0, max = WO_ONE_THOUSAND; i < max; i++)
    {
        (void)[array map:^(id string) {
            return (id)[string stringByAppendingString:@"!"];
        }];
    }
    stop();

    start("manual enumeration");
    for (unsigned i = 0, max = WO_ONE_THOUSAND; i < max; i++)
    {
        NSMutableArray *result = [NSMutableArray arrayWithCapacity:[array count]];
        for (unsigned i = 0, max = WO_ONE_THOUSAND; i < max; i++)
        {
            NSString *string = [array objectAtIndex:i];
            [result addObject:[string stringByAppendingString:@"!"]];
        }
        (void)[result copy];
    }
    stop();

    start("fast enumeration");
    for (unsigned i = 0, max = WO_ONE_THOUSAND; i < max; i++)
    {
        result = [NSMutableArray arrayWithCapacity:[array count]];
        for (NSString *string in array)
            [result addObject:[string stringByAppendingString:@"!"]];
        (void)[result copy];
    }
    stop();

    return EXIT_SUCCESS;
}
