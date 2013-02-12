//
//  PCCiSimple.h
//  CISimple-notifier
//
//  Created by Romain Pouclet on 10/02/13.
//  Copyright (c) 2013 Perfectly Cooked. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef void (^CISCompletionHandler)(id response, NSError *error);

@interface PCCiSimple : NSObject

@property (nonatomic, copy, readonly) NSString *key;

- (id)initWithKey:(NSString *)key;

- (void)retrieveChannelInfo:(CISCompletionHandler)completion;

@end
