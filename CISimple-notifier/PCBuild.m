//
//  PCBuild.m
//  CISimple-notifier
//
//  Created by Romain Pouclet on 06/02/13.
//  Copyright (c) 2013 Perfectly Cooked. All rights reserved.
//

#import "PCBuild.h"

static NSString *BuildNumberArchiveKey = @"buildNumber";
static NSString *BuildPassingArchiveKey = @"buildPassing";
static NSString *ProjectNameArchiveKey = @"projectName";

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
        self.projectName = (NSString *)dict[@"job"][@"friendly_name"];
    }
    
    return self;
}

- (id)initWithCoder:(NSCoder *)aDecoder
{
    NSLog(@"Init build with coder");
    self = [super init];
    if (self) {
        self.buildNumber = [aDecoder decodeObjectForKey: BuildNumberArchiveKey];
        self.projectName = [aDecoder decodeObjectForKey: ProjectNameArchiveKey];
        self.passing = [aDecoder decodeBoolForKey: BuildPassingArchiveKey];
    }
    
    return self;
}

- (void)encodeWithCoder:(NSCoder *)aCoder
{
    NSLog(@"Encoding build %@ 🙊", self.buildNumber);

    [aCoder encodeObject: self.buildNumber forKey: BuildNumberArchiveKey];
    [aCoder encodeObject: self.projectName forKey: ProjectNameArchiveKey];
    [aCoder encodeBool: self.passing forKey: BuildPassingArchiveKey];
}

@end
