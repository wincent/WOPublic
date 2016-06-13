// NSDictionary+WOCreation.m
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

// category header
#import "NSDictionary+WOCreation.h"

WO_CATEGORY_MARKER(NSDictionary, WOCreation);
@implementation NSDictionary (WOCreation)

#pragma mark -
#pragma mark Class methods

+ (id)dictionaryWithKeysAndObjects:(id)firstKey, ...
{
    if (!firstKey) return [NSDictionary dictionary];

    // preliminaries
    NSMutableArray  *objects    = [NSMutableArray arrayWithCapacity:1];
    NSMutableArray  *keys       = [NSMutableArray arrayWithCapacity:1];
    id              object      = nil;
    id              key         = nil;
    id              exception   = nil;
    va_list         arguments;
    va_start(arguments, firstKey);
    [keys addObject:firstKey];
    if ((object = va_arg(arguments, id)))           // get first object to go with first key
    {
        [objects addObject:object];
        while ((key = va_arg(arguments, id)))       // get next key
        {
            if ((object = va_arg(arguments, id)))   // get next object
            {
                [keys       addObject:key];
                [objects    addObject:object];
            }
            else
            {
                exception = [NSException exceptionWithName:NSInvalidArgumentException
                                                    reason:WO_STRING(@"no object for key, %@", key)
                                                  userInfo:nil];
                break;
            }
        }
    }
    else
        exception = [NSException exceptionWithName:NSInvalidArgumentException
                                            reason:WO_STRING(@"no object for key, %@", firstKey)
                                          userInfo:nil];

    va_end(arguments);
    if (exception) @throw exception;
    return [self dictionaryWithObjects:objects forKeys:keys];
}

@end
