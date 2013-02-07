//
//  PCBuildView.m
//  CISimple-notifier
//
//  Created by Romain Pouclet on 06/02/13.
//  Copyright (c) 2013 Perfectly Cooked. All rights reserved.
//

#import "PCBuildView.h"
#import "NSColor+CISimple.h"

@implementation PCBuildView

@synthesize passing = _passing;

- (void)setPassing:(BOOL)passing
{
    _passing = passing;
    
    [self setNeedsDisplay: YES];
}

- (void)drawRect:(NSRect)dirtyRect
{
    if (self.passing) {
        [[NSColor successBackground] setFill];
    } else {
        [[NSColor failureBackground] setFill];
    }
    
    NSRectFill(dirtyRect);
}

@end
