//
//  PCAppDelegate.h
//  CISimple-notifier
//
//  Created by Romain Pouclet on 06/02/13.
//  Copyright (c) 2013 Perfectly Cooked. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import <Bully/Bully.h>

@interface PCAppDelegate : NSObject <NSApplicationDelegate, BLYClientDelegate>
{
    // @move ?
    BLYClient *client;
    BLYChannel *buildChannel;
}

@property (assign) IBOutlet NSWindow *window;
@property (nonatomic, strong) IBOutlet NSCollectionView *buildCollectionView;
@property (nonatomic, strong) NSMutableArray *builds;
@end
