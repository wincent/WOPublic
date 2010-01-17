//
//  WOUsageMeterTests.m
//  WOCommon
//
//  Created by Wincent Colaiuta on 25 November 2006.
//  Copyright 2006-2008 Wincent Colaiuta.

// class header
#import "WOUsageMeterTests.h"

// tested class header
#import "WOUsageMeter.h"

@implementation WOUsageMeterTests

- (void)testNormalizeTimeval
{
    // preliminaries
    struct timeval time;

    // test microseconds positive overflow: 3 seconds, 1.5 million microseconds -> normalizes to 4 seconds, 0.5 million microseonds
    time.tv_sec     = 3;
    time.tv_usec    = 1500000;
    time = WONormalizeTimeval(time);
    WO_TEST_EQ(time.tv_sec, 4);
    WO_TEST_EQ(time.tv_usec, 500000);

    // test negative microseconds: 2 seconds, -0.5 million microseconds -> normalizes to 1 second, 0.5 million microseconds
    time.tv_sec     = 2;
    time.tv_usec    = -500000;
    time = WONormalizeTimeval(time);
    WO_TEST_EQ(time.tv_sec, 1);
    WO_TEST_EQ(time.tv_usec, 500000);

    // test negative seconds, positive microseconds: -1 seconds, 0.5 million microseconds -> normalizes to 0 seconds, -0.5 million
    time.tv_sec     = -1;
    time.tv_usec    = 500000;
    time = WONormalizeTimeval(time);
    WO_TEST_EQ(time.tv_sec, 0);
    WO_TEST_EQ(time.tv_usec, -500000);

    // test positive, no overflow: 2 seconds, 0.5 million microseconds -> no change
    time.tv_sec     = 2;
    time.tv_usec    = 500000;
    time = WONormalizeTimeval(time);
    WO_TEST_EQ(time.tv_sec, 2);
    WO_TEST_EQ(time.tv_usec, 500000);

    // test negative, no overflow: -2 seconds, -0.5 million microseconds -> no change
    time.tv_sec     = -2;
    time.tv_usec    = -500000;
    time = WONormalizeTimeval(time);
    WO_TEST_EQ(time.tv_sec, -2);
    WO_TEST_EQ(time.tv_usec, -500000);

    // test tricky overflow quantity: 2 seconds, 1,202,409 microseconds -> 3 seconds, 202,409 microseconds
    time.tv_sec     = 2;
    time.tv_usec    = 1202409;
    time = WONormalizeTimeval(time);
    WO_TEST_EQ(time.tv_sec, 3);
    WO_TEST_EQ(time.tv_usec, 202409);

    // test massive overflow quantity: 10 seconds, 60,202,409 microseconds -> 70 seconds, 202,409 microseconds
    time.tv_sec     = 10;
    time.tv_usec    = 60202409;
    time = WONormalizeTimeval(time);
    WO_TEST_EQ(time.tv_sec, 70);
    WO_TEST_EQ(time.tv_usec, 202409);

    // test massive negative overflow quantity: 10 seconds, -60,202,409 microseconds -> -50 seconds, -202,409 microseconds
    time.tv_sec     = 10;
    time.tv_usec    = -60202409;
    time = WONormalizeTimeval(time);
    WO_TEST_EQ(time.tv_sec, -50);
    WO_TEST_EQ(time.tv_usec, -202409);

    // test positive seconds, 0 microseconds: 10 seconds, 0 microseconds -> no change
    time.tv_sec     = 10;
    time.tv_usec    = 0;
    time = WONormalizeTimeval(time);
    WO_TEST_EQ(time.tv_sec, 10);
    WO_TEST_EQ(time.tv_usec, 0);

    // test negative seconds, 0 microseconds: -10 seconds, 0 microseconds -> no change
    time.tv_sec     = -10;
    time.tv_usec    = 0;
    time = WONormalizeTimeval(time);
    WO_TEST_EQ(time.tv_sec, -10);
    WO_TEST_EQ(time.tv_usec, 0);

    // test 0 seconds, positive microseconds: 0 seconds, 100,000 microseconds -> no change
    time.tv_sec     = 0;
    time.tv_usec    = 100000;
    time = WONormalizeTimeval(time);
    WO_TEST_EQ(time.tv_sec, 0);
    WO_TEST_EQ(time.tv_usec, 100000);

    // test 0 seconds, negative microseconds: 0 seconds, -100,000 microseconds -> no change
    time.tv_sec     = 0;
    time.tv_usec    = -100000;
    time = WONormalizeTimeval(time);
    WO_TEST_EQ(time.tv_sec, 0);
    WO_TEST_EQ(time.tv_usec, -100000);
}

- (void)testAddTimeval
{
    // preliminaries
    struct timeval a;
    struct timeval b;
    struct timeval c;   // c = a + b

    // test positive, no overflow: 10;200,000 + 2;400,000 -> 12;600,000
    a.tv_sec    = 10;
    a.tv_usec   = 200000;
    b.tv_sec    = 2;
    b.tv_usec   = 400000;
    c = WOAddTimeval(a, b);
    WO_TEST_EQ(c.tv_sec, 12);
    WO_TEST_EQ(c.tv_usec, 600000);

    // test positive, microseconds overflow: 10;600,000 + 2;500,000 -> 13;100,000
    a.tv_sec    = 10;
    a.tv_usec   = 600000;
    b.tv_sec    = 2;
    b.tv_usec   = 500000;
    c = WOAddTimeval(a, b);
    WO_TEST_EQ(c.tv_sec, 13);
    WO_TEST_EQ(c.tv_usec, 100000);

    // test positive, 0 microseconds: 10;0 + 2;0 -> 12;0
    a.tv_sec    = 10;
    a.tv_usec   = 0;
    b.tv_sec    = 2;
    b.tv_usec   = 0;
    c = WOAddTimeval(a, b);
    WO_TEST_EQ(c.tv_sec, 12);
    WO_TEST_EQ(c.tv_usec, 0);

    // test positive, microseconds overflow to 0: 10;400,000 + 2;600,000 -> 13;0
    a.tv_sec    = 10;
    a.tv_usec   = 400000;
    b.tv_sec    = 2;
    b.tv_usec   = 600000;
    c = WOAddTimeval(a, b);
    WO_TEST_EQ(c.tv_sec, 13);
    WO_TEST_EQ(c.tv_usec, 0);

    // test non-normalized input values: -10;1,200,000 + 2;-1,400,000 -> -8;-800,000 + 0;600,000 -> -8;-200,000
    a.tv_sec    = -10;
    a.tv_usec   = 1200000;
    b.tv_sec    = 2;
    b.tv_usec   = -1400000;
    c = WOAddTimeval(a, b);
    WO_TEST_EQ(c.tv_sec, -8);
    WO_TEST_EQ(c.tv_usec, -200000);
}

- (void)testSubtractTimeval
{
    // preliminaries
    struct timeval a;
    struct timeval b;
    struct timeval c;   // c = a - b

    // test positive, no overflow: 10;500,000 - 5;100,000 -> 5;400,000
    a.tv_sec    = 10;
    a.tv_usec   = 500000;
    b.tv_sec    = 5;
    b.tv_usec   = 100000;
    c = WOSubtractTimeval(b, a);
    WO_TEST_EQ(c.tv_sec, 5);
    WO_TEST_EQ(c.tv_usec, 400000);

    // test positive, microseconds underflow: 10;200,000 - 2;400,000 -> 7;800,000
    a.tv_sec    = 10;
    a.tv_usec   = 200000;
    b.tv_sec    = 2;
    b.tv_usec   = 400000;
    c = WOSubtractTimeval(b, a);
    WO_TEST_EQ(c.tv_sec, 7);
    WO_TEST_EQ(c.tv_usec, 800000);
}

@end
