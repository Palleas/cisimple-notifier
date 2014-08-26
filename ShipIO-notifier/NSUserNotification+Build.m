//
//  NSUserNotification+Build.m
//  ShipIO-notifier
//
//  Created by Romain Pouclet on 12/02/13.
//  Copyright (c) 2013 Perfectly Cooked. All rights reserved.
//

#import "NSUserNotification+Build.h"

@implementation NSUserNotification (Build)

+ (NSUserNotification *)notificationForBuild:(CISBuild *)build
{
    NSUserNotification *n = [[NSUserNotification alloc] init];
    n.title = build.projectName;
    
    // CISBuildPhaseCompleted is not handled (too confusing for the user)
    switch (build.state) {
        case CISBuildStateQueued:
            n.informativeText = [NSString stringWithFormat: @"Build #%@ was queued", build.buildNumber];
            break;
            
        case CISBuildStateRunning:
            n.informativeText = [NSString stringWithFormat: @"Build #%@ has started", build.buildNumber];
            break;
            
        case CISBuildStateFinished:
            if (build.success) {
                n.informativeText = [NSString stringWithFormat: @"Build #%@ succeeded", build.buildNumber];
            } else {
                n.informativeText = [NSString stringWithFormat: @"Build #%@ failed", build.buildNumber];
            }
            break;
    }
    
    return n;
}

@end
