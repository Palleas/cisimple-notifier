//
//  PCBuildViewItem.m
//  CISimple-notifier
//
//  Created by Romain Pouclet on 06/02/13.
//  Copyright (c) 2013 Perfectly Cooked. All rights reserved.
//

#import "PCBuildViewItem.h"

#import "PCBuildView.h"
#import "PCBuild.h"

@interface PCBuildViewItem ()

@end

@implementation PCBuildViewItem

- (id)init
{
    return [super initWithNibName: @"BuildView" bundle: nil];
}

- (id)copyWithZone:(NSZone *)zone
{
    id result = [super copyWithZone: zone];
    [NSBundle loadNibNamed: @"BuildView" owner: result];
    
    return result;
}

- (void)setRepresentedObject:(id)representedObject
{
    [super setRepresentedObject: representedObject];
    
    if (!representedObject) {
        return;
    }
    
    NSAssert([representedObject isKindOfClass: [PCBuild class]], @"PCBuildViewItem only accepts NSDictionnary as represented object");
    
    BOOL passing = ((PCBuild *)representedObject).passing;
    NSString *buildString = [NSString stringWithFormat: @"#%@", ((PCBuild *)representedObject).buildNumber];
    self.textField.stringValue = buildString;
    if (passing) {
        self.textField.textColor = [NSColor colorWithDeviceRed: 0.273
                                                         green: 0.531
                                                          blue: 0.277
                                                         alpha: 1.0];
    } else {
        
    }

    PCBuildView *view = (PCBuildView *)self.view;
    view.passing = passing;
}

@end
