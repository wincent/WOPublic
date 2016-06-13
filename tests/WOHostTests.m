// WOHostTests.m
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
#import "WOHostTests.h"

// other headers
#import "WOHost.h"

@implementation WOHostTests

- (void)testHostForHostName
{
    // should raise exception if passed nil
    WO_TEST_THROWS([WOHost hostForHostName:nil]);
    WO_TEST_THROWS_EXCEPTION_NAMED([WOHost hostForHostName:nil], NSInternalInconsistencyException);

    // should return nil for unregistered host
    WOHost *host = [WOHost hostWithHostName:@"wincent.com"];
    [WOHost setHost:host forHostName:@"wincent.com"];
    WO_TEST_NIL([WOHost hostForHostName:@"secure.wincent.com"]);
    WO_TEST_NOT_NIL([WOHost hostForHostName:@"wincent.com"]);
    WO_TEST_EQ([WOHost hostForHostName:@"wincent.com"], host);
}

- (void)testSetHostForHostName
{
    WOHost *host = [WOHost hostWithHostName:@"secure.wincent.com"];

    // should raise exception if passed nil host name
    WO_TEST_THROWS([WOHost setHost:nil forHostName:nil]);
    WO_TEST_THROWS_EXCEPTION_NAMED([WOHost setHost:nil forHostName:nil], NSInternalInconsistencyException);
    WO_TEST_THROWS([WOHost setHost:host forHostName:nil]);
    WO_TEST_THROWS_EXCEPTION_NAMED([WOHost setHost:host forHostName:nil], NSInternalInconsistencyException);

    // should raise of host name doesn't match passed host object
    WO_TEST_THROWS([WOHost setHost:host forHostName:@"wincent.com"]);
    WO_TEST_THROWS_EXCEPTION_NAMED([WOHost setHost:host forHostName:@"wincent.com"], NSInternalInconsistencyException);

    // passing nil should remove host from registry
    [WOHost setHost:host forHostName:@"secure.wincent.com"];
    WO_TEST_NOT_NIL([WOHost hostForHostName:@"secure.wincent.com"]);
    [WOHost setHost:nil forHostName:@"secure.wincent.com"];
    WO_TEST_NIL([WOHost hostForHostName:@"secure.wincent.com"]);
}

- (void)testHostWithHostName
{
    // should raise exception if passed nil
    WO_TEST_THROWS([WOHost hostWithHostName:nil]);
    WO_TEST_THROWS_EXCEPTION_NAMED([WOHost hostWithHostName:nil], NSInternalInconsistencyException);

    // should return the same WOHost object if passed the same name
    WOHost *aHost           = [WOHost hostWithHostName:@"wincent.com"];
    WOHost *differentHost   = [WOHost hostWithHostName:@"secure.wincent.com"];
    WOHost *sameHost        = [WOHost hostWithHostName:@"wincent.com"];
    WO_TEST_EQ(aHost, sameHost);
    WO_TEST_NE(aHost, differentHost);

    // same should be true if using init to initialize one of the objects
    WOHost *otherHost       = [[WOHost alloc] initWithHostName:@"secure.wincent.com"];
    WO_TEST_EQ(differentHost, otherHost);
    WO_TEST_NE(otherHost, sameHost);
}

- (void)testInitWithHostName
{
    // should raise exception if passed nil
    WO_TEST_THROWS([[WOHost alloc] initWithHostName:nil]);
    WO_TEST_THROWS_EXCEPTION_NAMED([[WOHost alloc] initWithHostName:nil], NSInternalInconsistencyException);
}

- (void)testSetHostName
{
    // should raise if pass already-existing host name
    WOHost *host1 = [WOHost hostWithHostName:@"wincent.com"];
    (void)[WOHost hostWithHostName:@"secure.wincent.com"];
    WO_TEST_THROWS([host1 setHostName:@"secure.wincent.com"]);
}

@end
