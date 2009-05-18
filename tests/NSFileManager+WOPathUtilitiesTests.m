// NSFileManager+WOPathUtilitiesTests.m
// WOPublic
//
// Copyright 2006-2009 Wincent Colaiuta. All rights reserved.
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
#import "NSFileManager+WOPathUtilitiesTests.h"

// tested category header
#import "NSFileManager+WOPathUtilities.h"

// other category headers
#import "NSDictionary+WOCreation.h"
#import "NSString+WOPathUtilities.h"

// macro headers
#import "WOConvenienceMacros.h"
#import "WODebugMacros.h"

@implementation NSFileManager_WOPathUtilitiesTests

- (void)testPathForFolder
{
    // unfortunately have to hardcode these expected results
    NSString *expected = @"/Library/Contextual Menu Items";
    NSString *actual = [[NSFileManager defaultManager] pathForFolder:kContextualMenuItemsFolderType domain:kLocalDomain];
    WO_TEST_EQ(expected, actual);

    expected = @"/System/Library/Contextual Menu Items";
    actual = [[NSFileManager defaultManager] pathForFolder:kContextualMenuItemsFolderType domain:kSystemDomain];
    WO_TEST_EQ(expected, actual);

    // can't use this test (may return nil if path doesn't exist)
    //expected = @"/Network/Library/Contextual Menu Items";
    //actual = [[NSFileManager defaultManager] pathForFolder:kContextualMenuItemsFolderType domain:kNetworkDomain];
    //WO_TEST_EQ(expected, actual);

    // can't use this test either for exactly the same reason
    //expected = [NSHomeDirectory() stringByAppendingPathComponents:WO_ARRAY(@"Library", @"Contextual Menu Items")];
    //actual = [[NSFileManager defaultManager] pathForFolder:kContextualMenuItemsFolderType domain:kUserDomain];
    //WO_TEST_EQ(expected, actual);
}

- (void)testPathForFolderCreate
{
    // TODO: figure out how to test this... to test creation I need a folder that doesn't exist yet...
}

- (void)testTemporaryDirectory
{
}

- (void)testTemporaryDirectoryUsingTemplate
{
}

- (void)testTouchFileAtPath
{
    // should create file if it doesn't already exist
    NSFileManager   *manager            = [NSFileManager defaultManager];
    NSString        *temp               = [manager temporaryDirectory];
    WOCheck(temp != nil);
    NSString        *target             = [temp stringByAppendingPathComponent:@"testfile"];
    WO_TEST_NOT([manager fileExistsAtPath:target]);
    WO_TEST([manager touchFileAtPath:target]);
    WO_TEST([manager fileExistsAtPath:target]);

    // should update file if it does exist
    [manager changeFileAttributes:WO_DICTIONARY(NSFileModificationDate, [NSDate dateWithTimeIntervalSinceNow:-60],
                                                NSFileCreationDate,     [NSDate dateWithTimeIntervalSinceNow:-60]) atPath:target];
    NSDate          *previousModDate    = [[manager fileAttributesAtPath:target traverseLink:YES] fileModificationDate];
    WOCheck([[NSDate date] timeIntervalSinceDate:previousModDate] > 50);
    WOCheck(previousModDate != nil);
    [manager touchFileAtPath:target];
    NSDate          *newModDate         = [[manager fileAttributesAtPath:target traverseLink:YES] fileModificationDate];
    WOCheck(newModDate != nil);
    WO_TEST([newModDate timeIntervalSinceDate:previousModDate] > 50);
}

- (void)testCreateDirectoryAtPathCreateParent
{
    NSFileManager   *manager        = [NSFileManager defaultManager];
    NSString        *temp           = [manager temporaryDirectory];
    WOCheck(temp != nil);

    // single level test
    NSString        *singleDir      = [temp stringByAppendingPathComponent:@"single"];
    WO_TEST([manager createDirectoryAtPath:singleDir attributes:nil createParents:NO]);
    BOOL            isDirectory;
    WO_TEST([manager fileExistsAtPath:singleDir isDirectory:&isDirectory]);
    WO_TEST(isDirectory);

    // multi-level test
    NSString        *deepDir        = [temp stringByAppendingPathComponents:WO_ARRAY(@"level1", @"level2", @"level3")];
    WO_TEST_NOT([manager createDirectoryAtPath:deepDir attributes:nil createParents:NO]);
    WO_TEST([manager createDirectoryAtPath:deepDir attributes:nil createParents:YES]);
    WO_TEST([manager fileExistsAtPath:deepDir isDirectory:&isDirectory]);
    WO_TEST(isDirectory);

    // failed test because parent is a file and not a directory
    NSString        *file           = [temp stringByAppendingPathComponent:@"clash"];
    WOCheck([manager touchFileAtPath:file]);
    NSString        *willFail       = [temp stringByAppendingPathComponents:WO_ARRAY(@"clash", @"doomed")];
    WO_TEST_NOT([manager createDirectoryAtPath:willFail attributes:nil createParents:YES]);
}

@end
