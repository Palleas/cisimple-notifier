//
//  PCAppDelegate.h
//  CISimple-notifier
//
//  Created by Romain Pouclet on 06/02/13.
//  Copyright (c) 2013 Perfectly Cooked. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import <Bully/Bully.h>
#import "CISBuild.h"

@interface PCAppDelegate : NSObject <NSWindowDelegate, NSApplicationDelegate, BLYClientDelegate>
{
    BLYClient *bullyClient;
    BLYChannel *buildChannel;
    NSStatusItem *statusItem;
    NSURL *buildsURL;
}

@property (nonatomic, strong) IBOutlet NSMenu *menu;

- (IBAction)didPressQuit:(id)sender;
- (NSUserNotification *)userNotificationForBuild:(CISBuild *)build;

@end
