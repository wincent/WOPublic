//
//  NSFileManager+WOPathUtilitiesTests.m
//  WOCommon
//
//  Created by Wincent Colaiuta on 11 August 2006.
//  Copyright 2006-2008 Wincent Colaiuta.

// class header
#import "NSFileManager+WOPathUtilitiesTests.h"

// other headers
#import "NSDictionary+WOCreation.h"
#import "NSFileManager+WOPathUtilities.h"
#import "NSString+WOPathUtilities.h"
#import "WOConvenienceMacros.h"

// WOPublic headers
#import "WOPublic/WODebugMacros.h"

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
