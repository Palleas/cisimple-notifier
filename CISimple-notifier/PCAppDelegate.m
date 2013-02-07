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
    builds = @[];
    client = [[BLYClient alloc] initWithAppKey: @"5a44e74babe5c2550330" delegate:self];

    buildChannel = [client subscribeToChannelWithName:@"builds"];
    [buildChannel bindToEvent:@"ci-build" block:^(id message) {
        NSLog(@"Received build");

        PCBuild *build = [PCBuild buildWithDictionnary: message];
        NSLog(@"Build #%@ %@", build.buildNumber, build.passing ? @"PASSED" : @"Failed");
//        [builds addObject: build];
        builds = [builds arrayByAddingObject: build];
        self.buildCollectionView.content = builds;
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

- (void)awakeFromNib
{
    NSLog(@"I'm awake");
    self.buildCollectionView.itemPrototype = [[PCBuildViewItem alloc] init];
}

@end
