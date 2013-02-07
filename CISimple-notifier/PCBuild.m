//
//  PCBuild.m
//  CISimple-notifier
//
//  Created by Romain Pouclet on 06/02/13.
//  Copyright (c) 2013 Perfectly Cooked. All rights reserved.
//

#import "PCBuild.h"

@implementation PCBuild

+ (PCBuild *)buildWithDictionnary:(NSDictionary *)dict
{
    return [[PCBuild alloc] initWithDictionnary: dict];
}

- (PCBuild *)initWithDictionnary:(NSDictionary *)dict
{
    self = [super init];
    if (self) {
        self.buildNumber = (NSNumber *)dict[@"build_number"];
        self.passing = [dict[@"build_status"][@"code"] isEqualToString:@"SUCCESS"];
    }
    
    return self;
}

@end
