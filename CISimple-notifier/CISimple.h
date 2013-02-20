//
//  PCCiSimple.h
//  CISimple-notifier
//
//  Created by Romain Pouclet on 10/02/13.
//  Copyright (c) 2013 Perfectly Cooked. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "CISCisimpleDelegate.h"

extern NSString * const kBuildUpdatedEventName;

typedef void (^CISCompletionHandler)(id response, NSError *error);

@interface CISimple : NSObject

@property (nonatomic, copy, readonly) NSString *token;
@property (nonatomic, weak, readonly) id<CISCisimpleDelegate> delegate;

- (id)initWithToken:(NSString *)token delegate:(id<CISCisimpleDelegate>)delegate;

- (void)retrieveChannelInfo:(CISCompletionHandler)completion;
- (void)retrieveAuthentificationForParameters:(NSDictionary *)parameters completionBlock:(CISCompletionHandler)completion;

@end
