//
//  PCAppDelegate.m
//  CISimple-notifier
//
//  Created by Romain Pouclet on 06/02/13.
//  Copyright (c) 2013 Perfectly Cooked. All rights reserved.
//

#import "PCAppDelegate.h"
#import "PCBuildViewItem.h"
#import "PCBuild.h"

@implementation PCAppDelegate

- (void)applicationDidFinishLaunching:(NSNotification *)aNotification
{
    self.builds = [NSMutableArray array];
    
    client = [[BLYClient alloc] initWithAppKey: @"5a44e74babe5c2550330" delegate:self];

    buildChannel = [client subscribeToChannelWithName:@"builds"];
    [buildChannel bindToEvent:@"ci-build" block:^(id message) {
        NSLog(@"Received build : %@", message);

        PCBuild *build = [PCBuild buildWithDictionnary: message];
        [[self mutableArrayValueForKey:@"builds"] addObject: build];
        [self notifyBuildResult];
    }];
}

- (void)bullyClientDidConnect:(BLYClient *)client
{
    NSLog(@"Connected to pusher");
}

- (void)bullyClient:(BLYClient *)client didReceiveError:(NSError *)error
{
    NSLog(@"Client received error : %@", error.localizedDescription);
}

- (void)bullyClientDidDisconnect:(BLYClient *)client
{
    NSLog(@"Client disconnected");
}

- (void)notifyBuildResult
{
    PCBuild *build = [self.builds lastObject];
    NSString *message;
    
    if (self.builds.count == 1) {
        message = build.passing ? [NSString stringWithFormat: @"Build #%@ passed !", build.buildNumber] : [NSString stringWithFormat: @"Build #%@ failed", build.buildNumber];
    } else {
        NSUInteger index = [self.builds indexOfObject: build];
        PCBuild *previousBuild = [self.builds objectAtIndex: index - 1];
        
        if (!previousBuild.passing && !build.passing) {
            message = @"Build is still failing.";
        } else if (previousBuild.passing && !build.passing) {
            message = @"Somebody broke the build.";
        } else if (!previousBuild.passing && build.passing) {
            message = @"Build was fixed !";
        } else {
            message = @"Build still passing";
        }
    }
    
    NSUserNotification *notification = [[NSUserNotification alloc] init];
    notification.title = @"cisimple build";
    notification.informativeText = message;

    [[NSUserNotificationCenter defaultUserNotificationCenter] deliverNotification: notification];
}


- (void)awakeFromNib
{
    self.buildCollectionView.itemPrototype = [[PCBuildViewItem alloc] init];
    
    statusItem = [[NSStatusBar systemStatusBar] statusItemWithLength: NSVariableStatusItemLength];
    statusItem.title = @"CI";
    statusItem.menu = self.menu;

}

- (IBAction)didPressShowLatestBuilds:(id)sender
{
    NSLog(@"Show latest builds");
    [self.window makeKeyAndOrderFront: self];
}

- (IBAction)didPressQuit:(id)sender
{
    [[NSApplication sharedApplication] terminate: nil];
}


@end
