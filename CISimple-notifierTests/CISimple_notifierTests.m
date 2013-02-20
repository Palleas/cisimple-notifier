//
//  CISimple_notifierTests.m
//  CISimple-notifierTests
//
//  Created by Romain Pouclet on 06/02/13.
//  Copyright (c) 2013 Perfectly Cooked. All rights reserved.
//

#import "CISimple_notifierTests.h"
#import "CISBuild.h"

@implementation CISimple_notifierTests

- (NSDictionary *)loadPayload:(NSString *)name
{
    NSString *path = [[NSBundle mainBundle] pathForResource: name
                                                     ofType: @"json"];
    NSAssert(path != nil, @"Unable to retrieve payload file");
    
    NSData *d = [NSData dataWithContentsOfFile: path];
    NSError *error;
    NSDictionary *payload = [NSJSONSerialization JSONObjectWithData: d
                                                  options: 0
                                                    error: &error];
    NSAssert(error == nil, @"Woops, payload file wasn't parsed properly");
    
    return payload;
}

- (void)testQueuedBuildNotificationPayloadParsing
{
    CISBuild *build = [CISBuild buildWithDictionnary: [self loadPayload: @"build-payload-queued"]];
    STAssertTrue(build.phase == CISBuildPhaseQueued, @"Build phase must be 'queued'");
    STAssertTrue([build.buildNumber intValue] == 22, @"Build number must be 22");
    STAssertTrue([build.projectName isEqualToString: @"Knit-that-shit"], @"Project name must be Knit-that-shit");
}

- (void)testStartedBuildNotificationPayloadParsing
{
    CISBuild *build = [CISBuild buildWithDictionnary: [self loadPayload: @"build-payload-started"]];
    STAssertTrue(build.phase == CISBuildPhaseStarted, @"Build phase must be 'started'");
    STAssertTrue([build.buildNumber intValue] == 22, @"Build number must be 22");
    STAssertTrue([build.projectName isEqualToString: @"Knit-that-shit"], @"Project name must be Knit-that-shit");
}

- (void)testCompletedBuildNotificationPayloadParsing
{
    CISBuild *build = [CISBuild buildWithDictionnary: [self loadPayload: @"build-payload-completed"]];

    STAssertTrue(build.phase == CISBuildPhaseCompleted, @"Build phase must be 'completed'");
    STAssertTrue([build.buildNumber intValue] == 22, @"Build number must be 22");
    STAssertTrue([build.projectName isEqualToString: @"Knit-that-shit"], @"Project name must be Knit-that-shit");
}

- (void)testFinishedBuildNotificationPayloadParsing
{
    CISBuild *build = [CISBuild buildWithDictionnary: [self loadPayload: @"build-payload-finished"]];
    
    STAssertTrue(build.phase == CISBuildPhaseFinished, @"Build phase must be 'finished'");
    STAssertTrue([build.buildNumber intValue] == 22, @"Build number must be 22");
    STAssertTrue([build.projectName isEqualToString: @"Knit-that-shit"], @"Project name must be Knit-that-shit");
    STAssertTrue(build.success, @"Build must be successful");
}

@end
