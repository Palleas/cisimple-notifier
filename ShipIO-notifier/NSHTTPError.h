//
//  NSHTTPError.h
//  ShipIO-notifier
//
//  Created by Romain Pouclet on 15/02/13.
//  Copyright (c) 2013 Perfectly Cooked. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSHTTPError : NSError

+ (NSHTTPError *)errorWithCode:(NSInteger)code;

@end
