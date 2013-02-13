//
//  CISKeychainManager.h
//  CISimple-notifier
//
//  Created by Romain Pouclet on 12/02/13.
//  Copyright (c) 2013 Perfectly Cooked. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "CISimple.h"

typedef void (^CISKeychainCompletionHandler)(id response, NSError *error);


@interface CISKeychainManager : NSObject

- (void)storeApiKey:(NSString *)key;
- (SecKeychainItemRef)retrieveApiKey:(CISKeychainCompletionHandler)completion;

@end
