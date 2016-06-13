// WOLoginItem.h
// WOPublic
//
// Copyright 2007-present Greg Hurrell. All rights reserved.
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
//! raises if aPath is nil.
+ (WOLoginItem *)loginItemWithName:(NSString *)aName
                              path:(NSString *)aPath
                            hidden:(BOOL)isHidden
                            global:(BOOL)isGlobal;

//! aName may be nil.
//! raises if aPath is nil.
- (id)initWithName:(NSString *)aName
              path:(NSString *)aPath
            hidden:(BOOL)isHidden
            global:(BOOL)isGlobal;

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
