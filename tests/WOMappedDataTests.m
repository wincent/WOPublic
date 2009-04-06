// WOMappedDataTests.m
// WODebug
//
// Copyright 2006-2009 Wincent Colaiuta.

// class header
#import "WOMappedDataTests.h"

// tested class header
#import "WOMappedData.h"

@implementation WOMappedDataTests

- (void)testInitialization
{
    WO_TEST_THROWS([WOMappedData dataWithContentsOfFile:nil]);
    WO_TEST_THROWS([[WOMappedData alloc] initWithContentsOfFile:nil]);
}

@end
