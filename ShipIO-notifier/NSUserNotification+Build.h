//
//  NSUserNotification+Build.h
//  ShipIO-notifier
//
//  Created by Romain Pouclet on 12/02/13.
//  Copyright (c) 2013 Perfectly Cooked. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "CISBuild.h"

@interface NSUserNotification (Build)

+ (NSUserNotification *)notificationForBuild:(CISBuild *)build;

@end
