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

@property (nonatomic, strong) IBOutlet NSWindow *preferencesWindow;
@property (nonatomic, strong) IBOutlet NSMenu *statusBarMenu;

- (IBAction)didEnterAPIKey:(id)sender;
- (IBAction)didPressShowPreferencesWindow:(id)sender;
- (IBAction)didPressQuit:(id)sender;

@end
