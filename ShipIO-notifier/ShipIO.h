//
//  ShipIO.h
//  ShipIO-notifier
//
//  Created by Romain Pouclet on 10/02/13.
//  Copyright (c) 2013 Perfectly Cooked. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "CISShipioDelegate.h"

extern NSString * const kBuildUpdatedEventName;

typedef void (^CISCompletionHandler)(id response, NSError *error);

@interface ShipIO : NSObject

@property (nonatomic, copy, readonly) NSString *token;
@property (nonatomic, weak, readonly) id<CISShipioDelegate> delegate;

- (id)initWithToken:(NSString *)token delegate:(id<CISShipioDelegate>)delegate;

- (void)retrieveChannelInfo:(CISCompletionHandler)completion;
- (void)retrieveAuthentificationForParameters:(NSDictionary *)parameters completionBlock:(CISCompletionHandler)completion;

@end
