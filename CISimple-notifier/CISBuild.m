//
//  PCBuild.m
//  CISimple-notifier
//
//  Created by Romain Pouclet on 06/02/13.
//  Copyright (c) 2013 Perfectly Cooked. All rights reserved.
//

#import "CISBuild.h"

static NSString *kBuildSuccessKeyPath = @"build.success";
static NSString *kBuildNumberKeyPath = @"build.build_number";
static NSString *kBuildPhaseKeyPath = @"build.phase.code";
static NSString *kProjectNameKeyPath = @"job.friendly_name";

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
        
        NSString *phaseCode = [dict valueForKeyPath: kBuildPhaseKeyPath];
        if ([phaseCode isEqualToString: @"STARTED"]) {
            self.phase = CISBuildPhaseStarted;
        } else if ([phaseCode isEqualToString: @"COMPLETED"]) {
            self.phase = CISBuildPhaseCompleted;
        } else if ([phaseCode isEqualToString: @"FINISHED"]) {
            self.phase = CISBuildPhaseFinished;
            self.success = [[dict valueForKeyPath: kBuildSuccessKeyPath] intValue] == 1;
        } else {
            [NSException exceptionWithName: @"invalid-build-phase"
                                    reason: [NSString stringWithFormat: @"Invalid phase code %@", phaseCode]
                                  userInfo: nil];
        }
    }
    
    return self;
}

@end
