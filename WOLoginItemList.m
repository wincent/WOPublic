// WOLoginItemList.m
// WOPublic
//
// Copyright 2007-2009 Wincent Colaiuta. All rights reserved.
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
#import "WOLoginItemList.h"

// macro headers
#import "WODebugMacros.h"
#import "WOMemory.h"

// other class headers
#import "WOLoginItem.h"

@interface WOLoginItemList ()

- (void)refreshList;
- (BOOL)removeItem:(WOLoginItem *)anItem andRefresh:(BOOL)refresh;

#pragma mark Property redeclarations

@property(copy) NSArray *items;

@end

// TODO: unit tests

@implementation WOLoginItemList

- (id)initWithOptions:(CFTypeRef)options
{
    if ((self = [super init]))
    {
        items = [NSMutableArray array];
        listRef = LSSharedFileListCreate(NULL, options, NULL);
        if (!listRef)
            return items;
        CFMakeCollectable(listRef);
        global = (options == kLSSharedFileListGlobalLoginItems);
        [self refreshList];
    }
    return self;
}

+ (WOLoginItemList *)loginItems:(CFTypeRef)options
{
    // cast needed here or compiler thinks alloc returns an NSPointerFunctions or NSPointerArray instance
    return [(WOLoginItemList *)[self alloc] initWithOptions:options];
}

+ (WOLoginItemList *)globalLoginItems
{
    return [self loginItems:kLSSharedFileListGlobalLoginItems];
}

+ (WOLoginItemList *)sessionLoginItems
{
    return [self loginItems:kLSSharedFileListSessionLoginItems];
}

- (void)refreshList
{
    WOAssert(listRef != NULL);
    if (items.count > 0)
        [items removeAllObjects];
    UInt32 seed;
    CFArrayRef array = WOMakeCollectable(LSSharedFileListCopySnapshot(listRef, &seed));
    for (CFIndex i = 0, max = CFArrayGetCount(array); i < max; i++)
    {
        LSSharedFileListItemRef item = (LSSharedFileListItemRef)CFArrayGetValueAtIndex(array, i);
        WOLoginItem *login = self.global ?
            [WOLoginItem globalLoginItemWithRef:item] :
            [WOLoginItem sessionLoginItemWithRef:item];

        // login item could be nil, so avoid throwing an exception here
        // see: <http://wincent.com/a/support/bugs/show_bug.cgi?id=636>
        if (login)
            [items addObject:login];
    }
}

- (NSArray *)itemsWithName:(NSString *)aName
{
    NSParameterAssert(aName != nil);
    NSMutableArray *matches = [NSMutableArray array];
    for (WOLoginItem *item in items)
    {
        // item.name may be localized, so try matching against last path component as well
        if ([aName isEqualToString:item.name] ||
            [aName isEqualToString:[item.path lastPathComponent]])
            [matches addObject:item];
    }
    return matches;
}

- (WOLoginItem *)itemWithPath:(NSString *)aPath
{
    NSParameterAssert(aPath != nil);
    for (WOLoginItem *item in items)
    {
        if ([aPath isEqualToString:item.path])
            return item;

    }
    return nil;
}

- (BOOL)removeItemsWithName:(NSString *)aName
{
    NSParameterAssert(aName != nil);
    BOOL success = YES;
    for (WOLoginItem *item in [self itemsWithName:aName])
    {
        if (![self removeItem:item andRefresh:NO])
            success = NO;
    }
    [self refreshList];
    return success;
}

- (BOOL)removeItemWithPath:(NSString *)aPath
{
    NSParameterAssert(aPath != nil);
    WOLoginItem *item = [self itemWithPath:aPath];
    if (item)
        return [self removeItem:item];
    return YES;
}

// TODO: support for removing global login items (not done because not needed yet)
- (BOOL)removeItem:(WOLoginItem *)anItem
{
    return [self removeItem:anItem andRefresh:YES];
}

// TODO: support for removing global login items (not done because not needed yet)
- (BOOL)removeItem:(WOLoginItem *)anItem andRefresh:(BOOL)refresh
{
    NSParameterAssert(anItem != nil);
    OSStatus err = LSSharedFileListItemRemove(listRef, anItem.itemRef);
    if (refresh)
        [self refreshList];
    return (err == noErr);
}

// TODO: support for adding global login items (not done because not needed yet)
- (BOOL)addItem:(WOLoginItem *)anItem
{
    NSParameterAssert(anItem != nil);
    BOOL success = [anItem addToList:listRef];
    [self refreshList];
    return success;
}

#pragma mark -
#pragma mark NSFastEnumeration protocol

- (NSUInteger)countByEnumeratingWithState:(NSFastEnumerationState *)state
                                  objects:(id *)stackbuf
                                    count:(NSUInteger)len
{
    return [self.items countByEnumeratingWithState:state
                                           objects:stackbuf
                                             count:len];
}

#pragma mark -
#pragma mark Properties

@synthesize items;
@synthesize global;

@end
