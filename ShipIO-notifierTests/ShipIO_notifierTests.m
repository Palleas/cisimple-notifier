//
//  ShipIO_notifierTests.m
//  ShipIO-notifierTests
//
//  Created by Romain Pouclet on 06/02/13.
//  Copyright (c) 2013 Perfectly Cooked. All rights reserved.
//

#import "ShipIO_notifierTests.h"
#import "CISBuild.h"

@implementation ShipIO_notifierTests

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
    STAssertTrue(build.state == CISBuildStateQueued, @"Build phase must be 'queued'");
    STAssertTrue([build.buildNumber intValue] == 22, @"Build number must be 22");
    STAssertTrue([build.projectName isEqualToString: @"Knit-that-shit"], @"Project name must be Knit-that-shit");
}

- (void)testStartedBuildNotificationPayloadParsing
{
    CISBuild *build = [CISBuild buildWithDictionnary: [self loadPayload: @"build-payload-started"]];
    STAssertTrue(build.state == CISBuildStateRunning, @"Build phase must be 'started'");
    STAssertTrue([build.buildNumber intValue] == 22, @"Build number must be 22");
    STAssertTrue([build.projectName isEqualToString: @"Knit-that-shit"], @"Project name must be Knit-that-shit");
}

- (void)testCompletedBuildNotificationPayloadParsing
{
    CISBuild *build = [CISBuild buildWithDictionnary: [self loadPayload: @"build-payload-completed"]];

    STAssertTrue(build.state == CISBuildStateFinished, @"Build phase must be 'completed'");
    STAssertTrue([build.buildNumber intValue] == 22, @"Build number must be 22");
    STAssertTrue([build.projectName isEqualToString: @"Knit-that-shit"], @"Project name must be Knit-that-shit");
}

- (void)testFinishedBuildNotificationPayloadParsing
{
    CISBuild *build = [CISBuild buildWithDictionnary: [self loadPayload: @"build-payload-finished"]];
    
    STAssertTrue(build.state == CISBuildStateFinished, @"Build phase must be 'finished'");
    STAssertTrue([build.buildNumber intValue] == 22, @"Build number must be 22");
    STAssertTrue([build.projectName isEqualToString: @"Knit-that-shit"], @"Project name must be Knit-that-shit");
    STAssertTrue(build.success, @"Build must be successful");
}

@end
