//
//  PCBuildView.m
//  CISimple-notifier
//
//  Created by Romain Pouclet on 06/02/13.
//  Copyright (c) 2013 Perfectly Cooked. All rights reserved.
//

#import "PCBuildView.h"

@implementation PCBuildView

@synthesize passing = _passing;

- (void)setPassing:(BOOL)passing
{
    NSLog(@"Setting passing");
    _passing = passing;
    
    [self setNeedsDisplay: YES];
}

- (void)drawRect:(NSRect)dirtyRect
{
    // Drawing code here.
    NSLog(@"drawing");
    if (self.passing) {
        [[NSColor colorWithDeviceRed: 0.871
                               green: 0.941
                                blue: 0.847
                               alpha:1.0] setFill];
    } else {
        [[NSColor redColor] setFill];
    }
    
    NSRectFill(dirtyRect);
}

@end
