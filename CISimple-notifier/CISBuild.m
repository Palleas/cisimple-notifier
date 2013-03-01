//
//  PCBuild.m
//  CISimple-notifier
//
//  Created by Romain Pouclet on 06/02/13.
//  Copyright (c) 2013 Perfectly Cooked. All rights reserved.
//

#import "CISBuild.h"

static NSString *kBuildSuccessKeyPath = @"build.successful";
static NSString *kBuildNumberKeyPath = @"build.build_number";
static NSString *kBuildStateKeyPath = @"build.state";
static NSString *kProjectNameKeyPath = @"job.name";

@implementation CISBuild

+ (CISBuild *)buildWithDictionnary:(NSDictionary *)dict
{
    return [[CISBuild alloc] initWithDictionnary: dict];
}

- (CISBuild *)initWithDictionnary:(NSDictionary *)dict
{
    self = [super init];
    if (self) {
        self.buildNumber = [dict valueForKeyPath: kBuildNumberKeyPath];
        self.projectName = [dict valueForKeyPath: kProjectNameKeyPath];
        self.success = (BOOL) [dict valueForKeyPath: kBuildSuccessKeyPath];
        
        NSString *stateCode = [dict valueForKeyPath: kBuildStateKeyPath];
        if ([stateCode isEqualToString: @"RUNNING"]) {
            self.state = CISBuildStateRunning;
        } else if ([stateCode isEqualToString: @"FINISHED"]) {
            self.state = CISBuildStateFinished;
        } else if ([stateCode isEqualToString: @"QUEUED"]) {
            self.state = CISBuildStateQueued;
        }
    }
    
    return self;
}

@end
