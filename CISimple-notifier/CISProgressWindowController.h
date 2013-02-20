//
//  CISProgressWindowController.h
//  CISimple-notifier
//
//  Created by Romain Pouclet on 15/02/13.
//  Copyright (c) 2013 Perfectly Cooked. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@interface CISProgressWindowController : NSWindowController

@property (nonatomic, strong) IBOutlet NSProgressIndicator *indicator;
@property (nonatomic, strong) IBOutlet NSTextField *messageField;

- (void) setMessage:(NSString *)message;

@end
