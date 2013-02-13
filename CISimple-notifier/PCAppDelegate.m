//
//  PCAppDelegate.m
//  CISimple-notifier
//
//  Created by Romain Pouclet on 06/02/13.
//  Copyright (c) 2013 Perfectly Cooked. All rights reserved.
//

#import "PCAppDelegate.h"
#import "CISBuild.h"
#import "CISimple.h"
#import "SVHTTPRequest.h"
#import "NSUserNotification+Build.h"
#import "SSKeychain.h"

static NSString *kCISKeychainServiceName = @"cisimple";
static NSString *kCISKeychainAccountName = @"default";

@implementation PCAppDelegate {
    CISimple *cisimple;
}

- (void)applicationDidFinishLaunching:(NSNotification *)aNotification
{
    NSError *error = nil;
    NSString *apiKey = [SSKeychain passwordForService: kCISKeychainServiceName
                                                account: kCISKeychainAccountName
                                                  error: &error];

    NSLog(@"error code : %ld", (long)error.code);
    if ([error code] == errSecItemNotFound) {
        NSAlert *activateAlert = [NSAlert alertWithMessageText: @"API key required"
                                                 defaultButton: @"OK"
                                               alternateButton: nil
                                                   otherButton: nil
                                     informativeTextWithFormat: @"Looks like it's your 1st time running cisimple. Please provide your API key."];

        [self presentPreferencesWindow];
        [activateAlert beginSheetModalForWindow: self.preferencesWindow
                                  modalDelegate: nil
                                 didEndSelector: nil
                                    contextInfo: nil];
    }
    
    bullyClient = [[BLYClient alloc] initWithAppKey: @"01dfb12713a82c1e7088" delegate:self];

    cisimple = [[CISimple alloc] initWithKey: @"uox72jjk6867q59vlj1cbu4qbf63av2yw"];
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
        
        if (build.phase == CISBuildPhaseCompleted) {
            NSLog(@"Phase is completed : ignoring");
            return;
        }
        
        NSUserNotification *n = [NSUserNotification notificationForBuild: build];
        [[NSUserNotificationCenter defaultUserNotificationCenter] deliverNotification: n];
    }];
}

- (void)presentPreferencesWindow
{
    [[NSRunningApplication currentApplication] activateWithOptions:NSApplicationActivateIgnoringOtherApps];
    [self.preferencesWindow makeKeyAndOrderFront: self];
}

- (void)didEnterAPIKey:(id)sender
{
    // Retrieve entered value
    NSString *apiKey = [sender stringValue];
    NSLog(@"Entered api key = %@", apiKey);
    
    [SSKeychain setPassword: apiKey
                 forService: kCISKeychainServiceName
                    account: kCISKeychainAccountName];
}





@end
