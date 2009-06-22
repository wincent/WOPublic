//
//  WOLoginItemList.h
//  WOCommon
//
//  Created by Wincent Colaiuta on 9 December 2007.
//  Copyright 2007-2008 Wincent Colaiuta.

#import "WOObject.h"

@class WOLoginItem;

//! Required classes:
//!     - WOObject (parent class)
//!     - WOLoginItem
//!
@interface WOLoginItemList : WOObject <NSFastEnumeration> {

    LSSharedFileListRef listRef;
    NSMutableArray      *items;
    BOOL                global;

}

+ (WOLoginItemList *)globalLoginItems;

+ (WOLoginItemList *)sessionLoginItems;

- (id)initWithOptions:(CFTypeRef)options;

- (NSArray *)itemsWithName:(NSString *)aName;

- (WOLoginItem *)itemWithPath:(NSString *)aPath;

- (BOOL)removeItemsWithName:(NSString *)aName;

- (BOOL)removeItemWithPath:(NSString *)aPath;

- (BOOL)removeItem:(WOLoginItem *)anItem;

- (BOOL)addItem:(WOLoginItem *)anItem;

#pragma mark -
#pragma mark Properties

@property(copy, readonly)               NSArray *items;
@property(getter=isGlobal, readonly)    BOOL    global;

@end
