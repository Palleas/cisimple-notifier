//
//  CISCisimpleDelegate.h
//  CISimple-notifier
//
//  Created by Romain Pouclet on 18/02/13.
//  Copyright (c) 2013 Perfectly Cooked. All rights reserved.
//

#import <Foundation/Foundation.h>

@class CISimple;

@protocol CISCisimpleDelegate <NSObject>

- (void)cisimpleClientStartedFetchingChannel:(CISimple *)client;
- (void)cisimpleClientFetchedChannel:(CISimple *)client channel:(NSString *)channel;

@end
