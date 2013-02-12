//
//  PCAppDelegate.m
//  CISimple-notifier
//
//  Created by Romain Pouclet on 06/02/13.
//  Copyright (c) 2013 Perfectly Cooked. All rights reserved.
//

#import "PCAppDelegate.h"
#import "CISBuild.h"
#import "PCCiSimple.h"
#import "SVHTTPRequest.h"

@implementation PCAppDelegate {
    PCCiSimple *cisimple;
}

- (void)applicationDidFinishLaunching:(NSNotification *)aNotification
{
    bullyClient = [[BLYClient alloc] initWithAppKey: @"01dfb12713a82c1e7088" delegate:self];

    cisimple = [[PCCiSimple alloc] initWithKey: @"uox72jjk6867q59vlj1cbu4qbf63av2yw"];
    [cisimple retrieveChannelInfo:^(id response, NSError *error) {
        if (nil == error) {
            NSLog(@"Channel name is = %@", response);
            [self connectToChannel: response];
        } else {
            NSLog(@"Got an error retrieving channel : %@", error.localizedDescription);
        }
    }];
}

- (void)connectToChannel:(NSString *)channel
{
    buildChannel = [bullyClient subscribeToChannelWithName:channel authenticationBlock:^(BLYChannel *channel) {
        [cisimple retrieveAuthentificationForParameters: channel.authenticationParameters
                                        completionBlock:^(id response, NSError *error) {
                                            [channel subscribeWithAuthentication: response];
                                        }];
    }];
    
    [buildChannel bindToEvent:kBuildUpdatedEventName block:^(id message) {
        NSLog(@"Received payload");
        CISBuild *build = [CISBuild buildWithDictionnary: message];
        NSLog(@"Build #%@, phase = %d", build.buildNumber, build.phase);
        NSUserNotification *n = [self userNotificationForBuild: build];
        [[NSUserNotificationCenter defaultUserNotificationCenter] deliverNotification: n];
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

- (NSUserNotification *)userNotificationForBuild:(CISBuild *)build
{
    NSUserNotification *n = [[NSUserNotification alloc] init];
    n.title = build.projectName;
    
    switch (build.phase) {
        case CISBuildPhaseQueued:
            n.informativeText = [NSString stringWithFormat: @"A new build (#%@) was queued", build.buildNumber];
            break;
        case CISBuildPhaseStarted:
            n.informativeText = [NSString stringWithFormat: @"Build #%@ started", build.buildNumber];
            break;

        case CISBuildPhaseCompleted:
            n.informativeText = [NSString stringWithFormat: @"Build #%@ is complete", build.buildNumber];
            break;

        case CISBuildPhaseFinished:
            if (build.success) {
                n.informativeText = [NSString stringWithFormat: @"Build #%@ succeed", build.buildNumber];
            } else {
                n.informativeText = [NSString stringWithFormat: @"Build #%@ failed", build.buildNumber];
            }
            break;
    }
    
    return n;
}


- (void)awakeFromNib
{
    statusItem = [[NSStatusBar systemStatusBar] statusItemWithLength: NSVariableStatusItemLength];
    statusItem.title = @"😎";
    statusItem.menu = self.menu;
}

- (IBAction)didPressQuit:(id)sender
{
    [[NSApplication sharedApplication] terminate: nil];
}

@end
