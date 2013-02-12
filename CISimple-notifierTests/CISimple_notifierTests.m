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
{
    NSDictionary *payload;
}

- (void)setUp
{
    [super setUp];
    NSString *path = [[NSBundle mainBundle] pathForResource:@"build-payload" ofType:@"json"];
    NSData *d = [NSData dataWithContentsOfFile: path];
    NSError *error;
    payload = [NSJSONSerialization JSONObjectWithData: d
                                              options: 0
                                                error: &error];
    NSAssert(error == nil, @"Woops, payload file wasn't parsed properly");
}

- (void)tearDown
{
    [super tearDown];
    
    payload = nil;
}

- (void)testNotificationPayloadParsing
{
    CISBuild *build = [CISBuild buildWithDictionnary: payload];
    
    STAssertTrue(build.success, @"Build is passing");
    STAssertTrue([build.buildNumber intValue] == 7, @"Build number must be 7");
    STAssertTrue([build.projectName isEqualToString: @"Super Social Photo Sharing App"], @"Project name must be Super Social Photo Sharing App");
}

@end
