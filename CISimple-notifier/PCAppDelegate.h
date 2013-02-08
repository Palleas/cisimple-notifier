//
//  PCAppDelegate.h
//  CISimple-notifier
//
//  Created by Romain Pouclet on 06/02/13.
//  Copyright (c) 2013 Perfectly Cooked. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import <Bully/Bully.h>

@interface PCAppDelegate : NSObject <NSWindowDelegate, NSApplicationDelegate, BLYClientDelegate>
{
    // @move ?
    BLYClient *client;
    BLYChannel *buildChannel;
    NSStatusItem *statusItem;
    NSURL *buildsURL;
}


@property (nonatomic, strong) IBOutlet NSCollectionView *buildCollectionView;
@property (nonatomic, strong) IBOutlet NSMenu *menu;

@property (assign) IBOutlet NSWindow *window;
@property (nonatomic, strong) NSMutableArray *builds;

- (void)notifyBuildResult;
- (IBAction)didPressShowLatestBuilds:(id)sender;
- (IBAction)didPressQuit:(id)sender;

- (NSURL *)applicationSupportDirectory;

@end
