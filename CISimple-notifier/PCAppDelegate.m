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
        NSLog(@"Received payload : %@", message);
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

//- (void)notifyBuildResult
//{
//    NSString *message;
//    
//    statusItem.title = build.passing ? @"🎉" : @"🙀";
//
//    message = build.passing ? [NSString stringWithFormat: @"Build #%@ passed !", build.buildNumber] : [NSString stringWithFormat: @"Build #%@ failed", build.buildNumber];
//
//    NSUserNotification *notification = [[NSUserNotification alloc] init];
//    notification.title = build.projectName;
//    notification.informativeText = message;
//
//    [[NSUserNotificationCenter defaultUserNotificationCenter] deliverNotification: notification];
//}


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
