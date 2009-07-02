// WOLoginItem.m
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
#import "WOLoginItem.h"

// system headers
#import <sys/param.h>                   /* MAXPATHLEN */

// other class headers
#import "WOLogManager.h"

// other headers
#import "WOConvenienceMacros.h"
#import "WOMemory.h"

@interface WOLoginItem ()

#pragma mark Private properties

@property(copy) NSString *name;

@end

// TODO: unit tests

@implementation WOLoginItem

+ (WOLoginItem *)loginItemWithName:(NSString *)aName path:(NSString *)aPath hidden:(BOOL)isHidden global:(BOOL)isGlobal
{
    WOParameterCheck(aPath != nil);
    return [[self alloc] initWithName:aName path:aPath hidden:isHidden global:isGlobal];
}

- (id)initWithName:(NSString *)aName path:(NSString *)aPath hidden:(BOOL)isHidden global:(BOOL)isGlobal
{
    WOParameterCheck(aPath != nil);
    if ((self = [super init]))
    {
        name    = [aName copy];
        path    = [aPath copy];
        hidden  = isHidden;
        global  = isGlobal;
    }
    return self;
}

+ (WOLoginItem *)sessionLoginItemWithRef:(LSSharedFileListItemRef)aRef
{
    return [[self alloc] initWithRef:aRef global:NO];
}

+ (WOLoginItem *)globalLoginItemWithRef:(LSSharedFileListItemRef)aRef
{
    return [[self alloc] initWithRef:aRef global:YES];
}

- (id)initWithRef:(LSSharedFileListItemRef)aRef global:(BOOL)isGlobal
{
    NSParameterAssert(aRef != NULL);
    if ((self = [super init]))
    {
        itemRef = aRef;
        name = [NSMakeCollectable(LSSharedFileListItemCopyDisplayName(aRef)) copy];
        CFBooleanRef isHidden = WOMakeCollectable(LSSharedFileListItemCopyProperty(aRef, kLSSharedFileListItemHidden));
        hidden = (isHidden == kCFBooleanTrue);
        global = isGlobal;
        CFURLRef URL;
        OSStatus err = LSSharedFileListItemResolve(aRef, 0, &URL, NULL);
        if (err == fnfErr)
        {
            // see: <http://wincent.com/a/support/bugs/show_bug.cgi?id=636>
            [WOLog err:@"LSSharedFileListItemResolve returned error %d (stale entry in login items no longer present on disk?)", err];
            return nil;
        }
        else if (err != noErr)
        {
            [WOLog err:@"LSSharedFileListItemResolve" no:err];
            return nil;
        }
        WOCFRelease(URL);
        UInt8 *buff = (UInt8 *)emalloc(MAXPATHLEN);
        if (!CFURLGetFileSystemRepresentation(URL, true, buff, MAXPATHLEN))
            [WOLog err:@"CFURLGetFileSystemRepresentation returned false"];
        else
            path = [NSString stringWithUTF8String:(const char *)buff];
        free(buff);
    }
    return self;
}

- (BOOL)addToList:(LSSharedFileListRef)listRef
{
    NSParameterAssert(listRef != NULL);
    CFStringRef     keys[]      = { kLSSharedFileListItemHidden };
    CFBooleanRef    values[]    = { self.isHidden ? kCFBooleanTrue : kCFBooleanFalse };
    CFDictionaryRef properties  = CFDictionaryCreate(NULL, (void *)keys, (void *)values, 1, NULL, NULL);
    if (!properties)
        return NO;
    CFMakeCollectable(properties);
    CFURLRef URL = CFURLCreateWithFileSystemPath(NULL, (CFStringRef)self.path, kCFURLPOSIXPathStyle, false);
    LSSharedFileListItemRef ref = LSSharedFileListInsertItemURL(listRef, kLSSharedFileListItemLast, NULL, NULL, URL, properties,
                                                                NULL);
    WOMakeCollectable(ref);
    itemRef = ref;
    return (ref != NULL);
}

#pragma mark -
#pragma mark NSObject overrides

- (NSString *)description
{
    return [NSString stringWithFormat:@"<WOLoginItem %#8x: properties => {name: %@, path: %@, hidden: %@, global: %@}>",
            self,
            self.name ? self.name : @"<unset>",
            self.path ? self.path : @"<unset>",
            WO_STRING_FROM_BOOL(self.hidden),
            WO_STRING_FROM_BOOL(self.global)];
}

#pragma mark -
#pragma mark Properties

@synthesize name;
@synthesize path;
@synthesize hidden;
@synthesize global;
@synthesize itemRef;

@end
