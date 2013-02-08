//
//  PCBuild.h
//  CISimple-notifier
//
//  Created by Romain Pouclet on 06/02/13.
//  Copyright (c) 2013 Perfectly Cooked. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface PCBuild : NSObject <NSCoding>

@property (nonatomic, assign) NSNumber *buildNumber;
@property (nonatomic, strong) NSString *projectName;
@property (nonatomic, assign) BOOL passing;

+ (PCBuild *)buildWithDictionnary:(NSDictionary *)dict;
- (PCBuild *)initWithDictionnary:(NSDictionary *)dict;

@end
