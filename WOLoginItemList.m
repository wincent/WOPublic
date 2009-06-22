//
//  WOLoginItemList.m
//  WOCommon
//
//  Created by Wincent Colaiuta on 9 December 2007.
//  Copyright 2007-2008 Wincent Colaiuta.

// class header
#import "WOLoginItemList.h"

// other class headers
#import "WOLoginItem.h"

// WOPublic headers
#import "WOPublic/WODebugMacros.h"
#import "WOPublic/WOMemory.h"

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

- (NSUInteger)countByEnumeratingWithState:(NSFastEnumerationState *)state objects:(id *)stackbuf count:(NSUInteger)len
{
    return [self.items countByEnumeratingWithState:state objects:stackbuf count:len];
}

#pragma mark -
#pragma mark Properties

@synthesize items;
@synthesize global;

@end
