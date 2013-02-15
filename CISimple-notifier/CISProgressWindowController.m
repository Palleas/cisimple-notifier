//
//  CISProgressWindowController.m
//  CISimple-notifier
//
//  Created by Romain Pouclet on 15/02/13.
//  Copyright (c) 2013 Perfectly Cooked. All rights reserved.
//

#import "CISProgressWindowController.h"

@interface CISProgressWindowController ()

@end

@implementation CISProgressWindowController

- (id)init
{
    return [super initWithWindowNibName:@"CISProgressWindow"];
}

- (void)windowDidLoad
{
    [super windowDidLoad];
    NSLog(@"Progress window did load");
}

- (void) setMessage:(NSString *)message
{
    self.messageField.stringValue = message;
}

@end
