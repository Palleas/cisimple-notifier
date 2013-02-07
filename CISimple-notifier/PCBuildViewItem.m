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
#import "NSColor+CISimple.h"

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
    
    NSAssert([representedObject isKindOfClass: [PCBuild class]], @"PCBuildViewItem only accepts PCBuild as represented object");
    
    NSString *buildString = [NSString stringWithFormat: @"#%@", ((PCBuild *)representedObject).buildNumber];
    self.textField.stringValue = buildString;
    
    self.projectNameField.stringValue = ((PCBuild *)representedObject).projectName;

    BOOL passing = ((PCBuild *)representedObject).passing;
    if (passing) {
        self.textField.textColor = [NSColor successText];
        self.projectNameField.textColor = [NSColor successText];
    } else {
        self.textField.textColor = [NSColor failureText];
        self.projectNameField.textColor = [NSColor failureText];
    }

    PCBuildView *view = (PCBuildView *)self.view;
    view.passing = passing;
}

@end
