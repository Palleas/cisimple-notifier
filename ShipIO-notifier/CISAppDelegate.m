//
//  PCAppDelegate.m
//  ShipIO-notifier
//
//  Created by Romain Pouclet on 06/02/13.
//  Copyright (c) 2013 Perfectly Cooked. All rights reserved.
//

#import "CISAppDelegate.h"
#import "CISBuild.h"
#import "ShipIO.h"
#import "SVHTTPRequest.h"
#import "NSUserNotification+Build.h"
#import "SSKeychain.h"
#import "NSHTTPError.h"
#import "CISProgressWindowController.h"

static NSString *kCISKeychainServiceName = @"shipio";
static NSString *kCISKeychainTokenAccountName = @"token";

@implementation CISAppDelegate {
    // Bully
    BLYClient *bullyClient;
    BLYChannel *buildChannel;
    
    // Ship.io client
    ShipIO *shipio;

    // Properties (channel name, token)
    NSString *shipioBuildChannelName;
    NSString *shipioToken;

    // UI
    NSStatusItem *statusItem;
    CISProgressWindowController *progressWindowController;
}

- (void)applicationDidFinishLaunching:(NSNotification *)aNotification
{
    NSLog(@"Did finish launching");
    
    self.preferencesWindow.level = NSFloatingWindowLevel;
    
    // Bootstrap used items (@todo move into interface builder ?)
    progressWindowController = [[CISProgressWindowController alloc] init];
    [progressWindowController window];

    if (nil == shipioToken) {
        NSLog(@"We don't have the token : presenting first launch notice");
        [self presentFirstLaunchNotice];

        return;
    }
    
    self.apiTokenField.stringValue = shipioToken;
    
    [self useApiToken: shipioToken];
}

- (void)applicationWillFinishLaunching:(NSNotification *)notification
{
    NSLog(@"Will finish launching");
    NSError *error;
    
    // Retrieve ship.io token from keychain
    shipioToken = [SSKeychain passwordForService: kCISKeychainServiceName
                           account: kCISKeychainTokenAccountName
                             error: &error];
    if ([error code] == errSecItemNotFound) {
        shipioToken = nil;
    }
}

- (void)presentFirstLaunchNotice
{
    NSAlert *activateAlert = [NSAlert alertWithMessageText: @"API key required"
                                             defaultButton: @"OK"
                                           alternateButton: nil
                                               otherButton: nil
                                 informativeTextWithFormat: @"It looks like this is your first time running the application. You'll need to enter your API Token to connect to ship.io."];
    
    [self presentPreferencesWindow];
    [activateAlert beginSheetModalForWindow: self.preferencesWindow
                              modalDelegate: nil
                             didEndSelector: nil
                                contextInfo: nil];
}

- (void)connectToChannel:(NSString *)channel withAppId:(NSString *)appId
{
    NSLog(@"Connecting to channel");
    
    if (nil != bullyClient) {
        [bullyClient disconnect];
    }
    
    bullyClient = [[BLYClient alloc] initWithAppKey: appId delegate: self];

    buildChannel = [bullyClient subscribeToChannelWithName:channel authenticationBlock:^(BLYChannel *channel) {
        NSLog(@"Authenticate ?");
        [shipio retrieveAuthentificationForParameters: channel.authenticationParameters
                                        completionBlock: ^(id response, NSError *error) {
                                            NSLog(@"Error %@", error.localizedDescription);
                                            [channel subscribeWithAuthentication: response];
                                        }];
    }];
    
    NSLog(@"Binding channel to build event");
    
    [buildChannel bindToEvent:kBuildUpdatedEventName block:^(id message) {
        NSLog(@"Received payload");
        CISBuild *build = [CISBuild buildWithDictionnary: message];
        NSLog(@"Build #%@, phase = %d", build.buildNumber, build.state);
        
        NSUserNotification *n = [NSUserNotification notificationForBuild: build];
        [[NSUserNotificationCenter defaultUserNotificationCenter] deliverNotification: n];
    }];
}

- (void)presentPreferencesWindow
{
    [[NSRunningApplication currentApplication] activateWithOptions:NSApplicationActivateIgnoringOtherApps];
    [self.preferencesWindow makeKeyAndOrderFront: self];
}

- (void)useApiToken:(NSString *)key
{
    if (nil != shipio) {
        NSLog(@"Already have a ship.io account : setting nil");
        shipio = nil;
    }
    
    if (nil != buildChannel) {
        NSLog(@"Already have a build channel : unbinding event");
        [buildChannel unbindEvent: kBuildUpdatedEventName];
        buildChannel = nil;
    }
    
    NSLog(@"Creating ship.io client with key %@", key);
    shipio = [[ShipIO alloc] initWithToken: key delegate: self];
    
    [shipio retrieveChannelInfo:^(id response, NSError *error) {
        if (nil == error) {
            NSLog(@"response = %@", response);
            NSLog(@"Pusher app id = %@", response[@"pusher_key"]);
            NSLog(@"Channel name is = %@", response[@"name"]);
            [self connectToChannel: response[@"name"]
                         withAppId: response[@"pusher_key"]];
        }
    }];
}

- (void)sheetDidEnd:(NSWindow *)sheet returnCode:(NSInteger)returnCode contextInfo:(void *)contextInfo;
{
    NSLog(@"Ordering out : %@", sheet);
    [sheet orderOut: self];
}

- (IBAction)didPressShowPreferencesWindow:(id)sender
{
    [self presentPreferencesWindow];
}

- (IBAction)didPressQuit:(id)sender
{
    NSLog(@"Terminate ship.io");
    [[NSApplication sharedApplication] terminate: nil];
}

- (void)awakeFromNib
{
    statusItem = [[NSStatusBar systemStatusBar] statusItemWithLength: NSVariableStatusItemLength];
    statusItem.menu = self.statusBarMenu;
    statusItem.highlightMode = YES;
    statusItem.image = [NSImage imageNamed: @"icon_16x16"];
}

- (void)presentProgressView:(NSString *)message
{
    [self presentPreferencesWindow];
    [progressWindowController setMessage: message];
    
    [NSApp beginSheet: [progressWindowController window]
       modalForWindow: self.preferencesWindow
        modalDelegate: self
       didEndSelector: @selector(sheetDidEnd:returnCode:contextInfo:)
          contextInfo: nil];
}


- (IBAction)didPressGetAPIToken:(id)sender;
{
    NSLog(@"Opening ship.io");
    NSURL *shipioURL = [NSURL URLWithString: @"https://ship.io/account"];
    [[NSWorkspace sharedWorkspace] openURL: shipioURL];
}

- (void)didEnterAPIToken:(id)sender
{
    // Retrieve entered value
    NSString *apiKey = self.apiTokenField.stringValue;
    NSLog(@"Entered api key = %@", apiKey);

    [self useApiToken: apiKey];
}

#pragma mark shipio
- (void)shipioClientFetchedChannel:(ShipIO *)client channel:(NSString *)channel
{
    NSLog(@"We fetched the channel name so the api key is correct : storing in keychain");
    [SSKeychain setPassword: client.token
                 forService: kCISKeychainServiceName
                    account: kCISKeychainTokenAccountName];
    
    if (progressWindowController.window.isVisible) {
        NSLog(@"Progress window is visible -> removing progress view");
        [NSApp endSheet: progressWindowController.window];
        [self.preferencesWindow orderOut: self];
    } else {
        NSLog(@"Progress window is not visible -> nothing to do");
    }

}

- (void)shipioClientStartedFetchingChannel:(ShipIO *)client
{
    NSLog(@"Started fetching channel");
    if (self.preferencesWindow.isVisible) {
        NSLog(@"Preferences window is visible -> showing progress view");
        [self presentProgressView: @"Connecting to ship.io..."];
    } else {
        NSLog(@"Preferences window is not visible -> not showing progress view");
    }
}

- (void)shipioClient:(ShipIO *)client didReceiveError:(NSError *)error
{
    NSLog(@"Got an error : %@", error.localizedDescription);

    NSAlert *errorSheet;
    if (error.code == 401) {
        errorSheet = [NSAlert alertWithMessageText: @"Unable to connect"
                                     defaultButton: @"Dismiss"
                                   alternateButton: nil
                                       otherButton: nil
                         informativeTextWithFormat: @"We were unable to connect to ship.io with the specified API token. Please verify you have entered it correctly."];
    } else {
        errorSheet = [NSAlert alertWithMessageText: @"An error occured"
                                     defaultButton: @"Dismiss"
                                   alternateButton: nil
                                       otherButton: nil
                         informativeTextWithFormat: @"An error occured when talking to ship.io. Try again later."];
    }

    NSLog(@"Presenting preferences window");
    [self presentPreferencesWindow];
    
    // If the progress view is visible, removing it
    if (progressWindowController.window.isVisible) {
        NSLog(@"Progress window is visible -> ordering out");
        [NSApp endSheet: progressWindowController.window];
    }
    
    [errorSheet beginSheetModalForWindow: self.preferencesWindow
                           modalDelegate: nil
                          didEndSelector: nil
                             contextInfo: nil];
}


#pragma mark bully

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
