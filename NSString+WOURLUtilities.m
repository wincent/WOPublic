//
//  NSString+WOURLUtilities.h
//  WOCommon (imported from WODebug)
//
//  Created by Wincent Colaiuta on 2 December 2004.
//  Copyright 2004-2008 Wincent Colaiuta.

// category header
#import "NSString+WOURLUtilities.h"

// other headers
#import "NSURL+WOConvenience.h"

WO_CATEGORY_MARKER(NSString, WOURLUtilities);
@implementation NSString (WOURLUtilities)

#pragma mark -
#pragma mark Instance methods

- (BOOL)openAsURL
{
    NSURL *URL = [NSURL URLWithString:self];
    return (URL && [URL open]);
}

@end
