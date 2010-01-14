//
//  NSURL+WOConvenience.m
//  WOCommon
//
//  Created by Wincent Colaiuta on 30 May 2006.
//  Copyright 2006-2008 Wincent Colaiuta.

// category header
#import "NSURL+WOConvenience.h"

// system headers
#import <AppKit/AppKit.h>

// WOPublic headers
#import "WOPublic/WOMemory.h"

WO_CATEGORY_MARKER(NSURL, WOConvenience);
@implementation NSURL (WOConvenience)

- (BOOL)open
{
    return [[NSWorkspace sharedWorkspace] openURL:self];
}

+ (NSURL *)URLWithFSRef:(FSRef)ref
{
    return NSMakeCollectable(CFURLCreateFromFSRef(NULL, &ref));
}

@end
