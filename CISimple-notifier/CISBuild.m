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
static NSString *kProjectNameKeyPath = @"build.build_number";

@implementation CISBuild

+ (CISBuild *)buildWithDictionnary:(NSDictionary *)dict
{
    return [[CISBuild alloc] initWithDictionnary: dict];
}

- (CISBuild *)initWithDictionnary:(NSDictionary *)dict
{
    self = [super init];
    if (self) {
        self.success = (BOOL)[dict valueForKeyPath: kBuildSuccessKeyPath];
        self.buildNumber = [dict valueForKeyPath: kBuildNumberKeyPath];
        self.projectName = [dict valueForKeyPath: kProjectNameKeyPath];
    }
    
    return self;
}

@end
