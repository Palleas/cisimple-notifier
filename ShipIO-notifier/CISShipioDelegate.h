//
//  CISShipioDelegate.h
//  ShipIO-notifier
//
//  Created by Romain Pouclet on 18/02/13.
//  Copyright (c) 2013 Perfectly Cooked. All rights reserved.
//

#import <Foundation/Foundation.h>

@class ShipIO;

@protocol CISShipioDelegate <NSObject>

- (void)shipioClientStartedFetchingChannel:(ShipIO *)client;
- (void)shipioClientFetchedChannel:(ShipIO *)client channel:(NSString *)channel;
- (void)shipioClient:(ShipIO *)client didReceiveError:(NSError *)error;

@end
