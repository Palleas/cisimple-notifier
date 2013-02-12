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

static NSString *BuildListFile = @"builds";

@implementation PCAppDelegate {
    PCCiSimple *cisimple;
}

- (void)applicationDidFinishLaunching:(NSNotification *)aNotification
{
    // Load previous builds
    NSURL *applicationSupportPath = [self applicationSupportDirectory];
    self.builds = [NSMutableArray array];

    if (nil == applicationSupportPath) {
        NSLog(@"Unable to retrieve application support directory : builds won't be saved");
    } else {
        NSLog(@"Application Support Path is %@", applicationSupportPath);
        buildsURL = [applicationSupportPath URLByAppendingPathComponent: BuildListFile];
        NSError *error;
        if ([buildsURL checkResourceIsReachableAndReturnError:&error] == NO) {
            NSLog(@"URL is not reachable");
        } else {
            NSLog(@"URL is reachable");
            
            NSMutableArray *builds = (NSMutableArray *)[NSKeyedUnarchiver unarchiveObjectWithData: [NSData dataWithContentsOfURL: buildsURL]];
            
            self.builds = builds == nil ? [NSMutableArray array] : builds;
            NSLog(@"Initialized builds with %ld builds", self.builds.count);
        }
    }

    bullyClient = [[BLYClient alloc] initWithAppKey: @"01dfb12713a82c1e7088" delegate:self];

    cisimple = [[PCCiSimple alloc] initWithKey: @"uox72jjk6867q59vlj1cbu4qbf63av2yw"];
    [cisimple retrieveChannelInfo:^(id response, NSError *error) {
        if (nil == error) {
            NSLog(@"Channel name is = %@", response);
        } else {
            NSLog(@"Got an error retrieving channel : %@", error.localizedDescription);
        }
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
    
    statusItem.title = build.passing ? @"🎉" : @"🙀";

    if (self.builds.count == 1) {
        message = build.passing ? [NSString stringWithFormat: @"Build #%@ passed !", build.buildNumber] : [NSString stringWithFormat: @"Build #%@ failed", build.buildNumber];
    } else {
        NSUInteger index = [self.builds indexOfObject: build];
        PCBuild *previousBuild = [self.builds objectAtIndex: index - 1];
        
        if (!previousBuild.passing && !build.passing) {
            message = [NSString stringWithFormat: @"Build #%@ is still failing.", build.buildNumber];
        } else if (previousBuild.passing && !build.passing) {
            message = [NSString stringWithFormat: @"Somebody broke build #%@.", build.buildNumber];
        } else if (!previousBuild.passing && build.passing) {
            message = [NSString stringWithFormat: @"Build #%@ was fixed.", build.buildNumber];
        } else {
            message = [NSString stringWithFormat: @"Build #%@ was fixed.", build.buildNumber];
        }
    }
    
    NSUserNotification *notification = [[NSUserNotification alloc] init];
    notification.title = build.projectName;
    notification.informativeText = message;

    [[NSUserNotificationCenter defaultUserNotificationCenter] deliverNotification: notification];
}


- (void)awakeFromNib
{
    self.buildCollectionView.itemPrototype = [[PCBuildViewItem alloc] init];
    
    statusItem = [[NSStatusBar systemStatusBar] statusItemWithLength: NSVariableStatusItemLength];
    statusItem.title = @"😎";
    statusItem.menu = self.menu;
}

- (IBAction)didPressShowLatestBuilds:(id)sender
{
    [[NSRunningApplication currentApplication] activateWithOptions: NSApplicationActivateIgnoringOtherApps];
    [self.window makeKeyAndOrderFront: self];
}

- (IBAction)didPressQuit:(id)sender
{
    [[NSApplication sharedApplication] terminate: nil];
}

- (NSURL *)applicationSupportDirectory
{
    NSArray *paths = [[NSFileManager defaultManager] URLsForDirectory:NSApplicationSupportDirectory inDomains:NSUserDomainMask];
    
    if (paths.count == 0) {
        return nil;
    }

    NSURL* directory = [paths[0] URLByAppendingPathComponent:@"cisimple-notifier" isDirectory: YES].filePathURL;
    
    NSError *error;
    BOOL created = [[NSFileManager defaultManager] createDirectoryAtURL: directory
                             withIntermediateDirectories: YES
                                              attributes: nil
                                                   error:&error];
    
    if (created) {
        NSLog(@"Directory was created (or already exist)");
    } else {
        NSLog(@"Directory wasn't created (error : %@)", error.localizedDescription);
    }
    
    return error == nil ? directory : nil;
}

- (void)applicationWillTerminate:(NSNotification *)notification
{
    NSLog(@"Application is about to terminate 😱");
    if (self.builds.count > 0 && nil != buildsURL) {
        NSRange range;
        range.location = 0;
        range.length = self.builds.count > 10 ? 10 : self.builds.count;
        NSArray *buildsToBeSaved = [self.builds subarrayWithRange: range];
        
        NSLog(@"We have a build URL : saving builds into file");
        NSData* buildsData = [NSKeyedArchiver archivedDataWithRootObject: buildsToBeSaved];

        NSError *error;
        if ([buildsData writeToURL:buildsURL options:NSDataWritingAtomic error:&error] == NO) {
            NSLog(@"Content wasn't written to file (error = %@)", error.localizedDescription);
        } else {
            NSLog(@"Build list was written to file");
        }
    }
}

- (void)client:(PCCiSimple *)client didFetchChannelName:(NSString *)channelName
{
    NSLog(@"Did find channel name : %@", channelName);
    buildChannel = [bullyClient subscribeToChannelWithName: channelName authenticationBlock:^(BLYChannel *channel) {
        NSLog(@"Authentification ?");
    }];
    [buildChannel bindToEvent:@"ci-build" block:^(id message) {
        NSLog(@"Received build : %@", message);
        
        if (nil == message) {
            NSLog(@"Notification wasn't parsed properly : not adding build");
            return;
        }
        
        PCBuild *build = [PCBuild buildWithDictionnary: message];
        [[self mutableArrayValueForKey:@"builds"] addObject: build];
        [self notifyBuildResult];
    }];
    
}

@end
