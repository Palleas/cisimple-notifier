//
//  PCAppDelegate.h
//  ShipIO-notifier
//
//  Created by Romain Pouclet on 06/02/13.
//  Copyright (c) 2013 Perfectly Cooked. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import <Bully/Bully.h>
#import "CISBuild.h"
#import "CISShipioDelegate.h"

@interface CISAppDelegate : NSObject <NSWindowDelegate, NSApplicationDelegate, BLYClientDelegate, CISShipioDelegate>

@property (nonatomic, strong) IBOutlet NSWindow *preferencesWindow;
@property (nonatomic, strong) IBOutlet NSMenu *statusBarMenu;
@property (nonatomic, strong) IBOutlet NSTextField *apiTokenField;

- (IBAction)didEnterAPIToken:(id)sender;
- (IBAction)didPressShowPreferencesWindow:(id)sender;
- (IBAction)didPressQuit:(id)sender;
- (IBAction)didPressGetAPIToken:(id)sender;

@end
