// NSMutableString+WOPathUtilities.h
// WOCommon
//
// Copyright 2006-2009 Wincent Colaiuta. All rights reserved.

#import <Foundation/Foundation.h>

// WOPublic headers
#import "WOPublic/WOConvenienceMacros.h"

WO_DECLARE_CATEGORY_MARKER(NSMutableString, WOPathUtilities);

@interface NSMutableString (WOPathUtilities)

- (void)appendPathComponent:(NSString *)component;

- (void)appendPathComponents:(NSArray *)components;

@end
