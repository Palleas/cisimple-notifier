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
#import "NSHTTPError.h"

static NSString *kCISKeychainServiceName = @"cisimple";
static NSString *kCISKeychainTokenAccountName = @"token";
static NSString *kCISKeychainChannelAccountName = @"pusherChannel";

@implementation PCAppDelegate {
    CISimple *cisimple;
    BLYClient *bullyClient;
    BLYChannel *buildChannel;
    NSStatusItem *statusItem;
}

- (void)applicationDidFinishLaunching:(NSNotification *)aNotification
{
    NSError *error = nil;
    NSString *apiKey = [SSKeychain passwordForService: kCISKeychainServiceName
                                                account: kCISKeychainTokenAccountName
                                                  error: &error];
    bullyClient = [[BLYClient alloc] initWithAppKey: @"01dfb12713a82c1e7088"
                                           delegate: self];
    
    NSLog(@"error code : %ld", (long)error.code);
    if (error != nil || apiKey == nil) {
        if ([error code] == errSecItemNotFound || apiKey == nil) {
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
        } else {
            [NSAlert alertWithError: error];
        }
    } else {
        self.apiTokenField.stringValue = apiKey;
        [self useApiKey: apiKey];
    }
}

- (void)connectToChannel:(NSString *)channel
{
    NSLog(@"Connecting to channel");
    
    buildChannel = [bullyClient subscribeToChannelWithName:channel authenticationBlock:^(BLYChannel *channel) {
        NSLog(@"Authenticate ?");
        [cisimple retrieveAuthentificationForParameters: channel.authenticationParameters
                                        completionBlock: ^(id response, NSError *error) {
                                            NSLog(@"Error %@", error.localizedDescription);
                                            [channel subscribeWithAuthentication: response];
                                        }];
    }];
    
    NSLog(@"Binding channel to build event");
    
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

- (void)didEnterAPIToken:(id)sender
{
    // Retrieve entered value
    NSString *apiKey = self.apiTokenField.stringValue;
    NSLog(@"Entered api key = %@", apiKey);
    
    [SSKeychain setPassword: apiKey
                 forService: kCISKeychainServiceName
                    account: kCISKeychainTokenAccountName];
    
    [self useApiKey: apiKey];
}

- (void)useApiKey:(NSString *)key
{
    if (nil != cisimple) {
        cisimple = nil;
    }
    
    if (nil != buildChannel) {
        buildChannel = nil;
    }
    
    cisimple = [[CISimple alloc] initWithToken: key];
    
    // kCISKeychainChannelAccountName
    NSError *error;
    NSString *channel = [SSKeychain passwordForService: kCISKeychainServiceName
                                               account: kCISKeychainChannelAccountName
                                                 error: &error];
    
    if (error.code == 0 && nil != channel) {
        NSLog(@"Channel name is = %@", channel);
        [self connectToChannel: channel];
    } else {
        [self presentProgressView:@"Retrieving pusher informations"];

        [cisimple retrieveChannelInfo:^(id response, NSError *error) {
            [NSApp endSheet: self.progressWindow];

            if (nil == error) {
                NSLog(@"Channel name is = %@", response);
                [self.preferencesWindow orderOut: self];
                [self connectToChannel: response];
                [SSKeychain setPassword: response forService: kCISKeychainServiceName account:kCISKeychainChannelAccountName];
            } else {
                NSLog(@"Got an error retrieving channel : %@", error.localizedDescription);
            
                NSAlert *errorAlert;
                // @todo better error handling ?
                if (error.code == 401) {
                    errorAlert = [NSAlert alertWithMessageText: @"An error occured"
                                                 defaultButton: @"Dismiss"
                                               alternateButton: nil
                                                   otherButton: nil
                                     informativeTextWithFormat: @"Unable to retrieve informations about your pusher channel (Access denied). Check your API token."];
                } else {
                    errorAlert = [NSAlert alertWithMessageText: @"An error occured"
                                                 defaultButton: @"Dismiss"
                                               alternateButton: nil
                                                   otherButton: nil
                                     informativeTextWithFormat: @"An error occured when talking to cisimple. Try again later."];
                }
            
                [self presentPreferencesWindow];
                [errorAlert beginSheetModalForWindow: self.preferencesWindow
                                   modalDelegate: nil
                                  didEndSelector: nil
                                     contextInfo: nil];
            }
        }];
    }
}

- (void)presentProgressView:(NSString *)message
{
    [self presentPreferencesWindow];
    [self.preferencesWindow resignKeyWindow];
    self.progressMessage.stringValue = message;

    [NSApp beginSheet: self.progressWindow
                                   modalForWindow: self.preferencesWindow
                                    modalDelegate: self
                                   didEndSelector: @selector(sheetDidEnd:returnCode:contextInfo:)
                                      contextInfo: nil];
}

- (void)sheetDidEnd:(NSWindow *)sheet returnCode:(NSInteger)returnCode contextInfo:(void *)contextInfo;
{
    [sheet orderOut: self];
}

- (IBAction)didPressShowPreferencesWindow:(id)sender
{
    [self presentPreferencesWindow];
}

- (IBAction)didPressQuit:(id)sender
{
    NSLog(@"Terminate cisimple");
    [[NSApplication sharedApplication] terminate: nil];
}

- (void)awakeFromNib
{
    statusItem = [[NSStatusBar systemStatusBar] statusItemWithLength: NSVariableStatusItemLength];
    statusItem.menu = self.statusBarMenu;
    statusItem.highlightMode = YES;
    statusItem.image = [NSImage imageNamed: @"icon_16x16"];
}

- (void)bullyClientDidConnect:(BLYClient *)client
{
    NSLog(@"Bully client did connect");
}
- (void)bullyClient:(BLYClient *)client didReceiveError:(NSError *)error
{
    NSLog(@"Bully client did receive error %@", error.localizedDescription);
}
- (void)bullyClientDidDisconnect:(BLYClient *)client
{
    NSLog(@"Bully client did disconnect");
}


@end
