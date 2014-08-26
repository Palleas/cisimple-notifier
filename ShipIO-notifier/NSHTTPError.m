//
//  NSHTTPError.m
//  ShipIO-notifier
//
//  Created by Romain Pouclet on 15/02/13.
//  Copyright (c) 2013 Perfectly Cooked. All rights reserved.
//

#import "NSHTTPError.h"

static NSString *kHTTPErrorDomain = @"HTTP";

@implementation NSHTTPError

+ (NSHTTPError *)errorWithCode:(NSInteger)code
{
    return [NSHTTPError errorWithDomain: kHTTPErrorDomain
                                   code: code
                               userInfo: nil];
}

@end
