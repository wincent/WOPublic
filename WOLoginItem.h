//
//  WOLoginItem.h
//  WOCommon
//
//  Created by Wincent Colaiuta on 9 December 2007.
//  Copyright 2007-2008 Wincent Colaiuta.

#import "WOObject.h"

//! Required classes:
//!
//!     - WOObject (superclass)
//!     - WOLogManager
//!
@interface WOLoginItem : WOObject {

    NSString                *name;
    NSString                *path;
    BOOL                    hidden;
    BOOL                    global;
    LSSharedFileListItemRef itemRef;
}

//! aName may be nil.
+ (WOLoginItem *)loginItemWithName:(NSString *)aName path:(NSString *)aPath hidden:(BOOL)isHidden global:(BOOL)isGlobal;

//! aName may be nil.
- (id)initWithName:(NSString *)aName path:(NSString *)aPath hidden:(BOOL)isHidden global:(BOOL)isGlobal;

+ (WOLoginItem *)sessionLoginItemWithRef:(LSSharedFileListItemRef)aRef;

+ (WOLoginItem *)globalLoginItemWithRef:(LSSharedFileListItemRef)aRef;

- (id)initWithRef:(LSSharedFileListItemRef)aRef global:(BOOL)isGlobal;

- (BOOL)addToList:(LSSharedFileListRef)listRef;

#pragma mark -
#pragma mark Properties

@property(readonly, copy)   NSString                *name;
@property(copy)             NSString                *path;
@property(getter=isHidden)  BOOL                    hidden;
@property(getter=isGlobal)  BOOL                    global;
@property(readonly)         LSSharedFileListItemRef itemRef;

@end
