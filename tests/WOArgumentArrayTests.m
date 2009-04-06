// WOArgumentArrayTests
// WODebug
//
// Copyright 2006-2009 Wincent Colaiuta.

#import "WOArgumentArrayTests.h"

@implementation WOArgumentArrayTests

- (void)preflight
{
    NSArray *array = [NSArray arrayWithObjects:

        // non-boolean options
        @"--alpha=",                    // non-boolean option, empty argument
        @"--beta",                      // non-boolean, malformed
        @"--no-delta=foo",              // non-boolean, malformed
        @"--gamma=bar",                 // non-boolean, valid, returns @"bar"
        @"iota=foo",                    // non-boolean, malformed
        @"-aa",             @"alice",   // non-boolean, malformed
        @"-b",              @"bob",     // non-boolean, valid, returns @"bob"
        @"-c",              @"-d",      // non-boolean, returns nil (missing)
        @"e",               @"derek",   // non-boolean, malformed

        // boolean options
        @"-f",                          // boolean, returns YES
        @"--g",                         // boolean, malformed, returns NO
        @"h",                           // boolean, malformed, returns NO
        @"--no-tango=abc",              // boolean, malformed, returns NO
        @"--lima=def",                  // boolean, malformed, returns NO
        @"--foxtrot",                   // boolean, returns YES
        @"--no-zebra",                  // boolean, returns NO
        @"omega",                       // boolean, malformed, returns NO
        nil];

    args    = [[WOArgumentArray alloc] initWithArray:array];
    count   = [array count];
}

- (void)testCount
{
    WO_TEST_EQ([args count], count);
    WO_TEST_EQ([[[WOArgumentArray alloc] init] count], (unsigned)0);
}

- (void)testArgumentForOption
{
    WO_TEST_EQ([args argumentForOption:nil],        nil);
    WO_TEST_EQ([args argumentForOption:@"alpha"],   @"");       // empty
    WO_TEST_EQ([args argumentForOption:@"beta"],    nil);       // malformed
    WO_TEST_EQ([args argumentForOption:@"delta"],   nil);       // malformed
    WO_TEST_EQ([args argumentForOption:@"gamma"],   @"bar");    // valid
    WO_TEST_EQ([args argumentForOption:@"iota"],    nil);       // malformed
    WO_TEST_EQ([args argumentForOption:@"aa"],      nil);       // malformed
    WO_TEST_EQ([args argumentForOption:@"b"],       @"bob");    // valid
    WO_TEST_EQ([args argumentForOption:@"c"],       nil);       // missing
    WO_TEST_EQ([args argumentForOption:@"e"],       nil);       // malformed
    WO_TEST_EQ([args argumentForOption:@"other"],   nil);       // not present
}

- (void)testBoolForOption
{
    WO_TEST_EQ([args boolForOption:nil],            NO);
    WO_TEST_EQ([args boolForOption:@"f"],           YES);       // valid
    WO_TEST_EQ([args boolForOption:@"g"],           NO);        // malformed
    WO_TEST_EQ([args boolForOption:@"h"],           NO);        // malformed
    WO_TEST_EQ([args boolForOption:@"tango"],       NO);        // malformed
    WO_TEST_EQ([args boolForOption:@"lima"],        NO);        // malformed
    WO_TEST_EQ([args boolForOption:@"foxtrot"],     YES);       // valid
    WO_TEST_EQ([args boolForOption:@"zebra"],       NO);        // valid
    WO_TEST_EQ([args boolForOption:@"omega"],       NO);        // malformed
    WO_TEST_EQ([args boolForOption:@"other"],       NO);        // not present
}

- (void)testArgumentAtIndex
{
    WO_TEST_EQ([args argumentAtIndex:0],            @"--alpha=");   // first
    WO_TEST_EQ([args argumentAtIndex:1],            @"--beta");     // second
    WO_TEST_EQ([args argumentAtIndex:(count - 1)],  @"omega");      // last
    WO_TEST_THROWS([args argumentAtIndex:1000000]);
    WO_TEST_THROWS_EXCEPTION_NAMED([args argumentAtIndex:1000000],
                                   NSRangeException);
    [args setArguments:nil];
    WO_TEST_THROWS([args argumentAtIndex:0]);
}

- (void)testArgumentsFromIndex
{
    WO_TEST_EQ([args argumentsFromIndex:0], [args arguments]);      // all
    WO_TEST_EQ([args argumentsFromIndex:(count - 1)],
               [NSArray arrayWithObject:@"omega"]);                 // last
    WO_TEST_THROWS([args argumentsFromIndex:1000000]);
    WO_TEST_THROWS_EXCEPTION_NAMED([args argumentsFromIndex:1000000],
                                   NSRangeException);
    [args setArguments:nil];
    WO_TEST_THROWS([args argumentsFromIndex:0]);
}

- (void)testArgumentIsOptionAtIndex
{
    WO_TEST([args argumentIsOptionAtIndex:0]);          // --alpha= : passes
    WO_TEST_FALSE([args argumentIsOptionAtIndex:4]);    // iota=foo : fails
    WO_TEST([args argumentIsOptionAtIndex:5]);          // -aa      : passes
    WO_TEST_FALSE([args argumentIsOptionAtIndex:8]);    // d        : fails

    WO_TEST_THROWS([args argumentIsOptionAtIndex:1000000]);
    WO_TEST_THROWS_EXCEPTION_NAMED([args argumentIsOptionAtIndex:1000000],
                                   NSRangeException);
}

@end
