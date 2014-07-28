//
//  NSColor+ShipIO.h
//  ShipIO-notifier
//
//  Created by Romain Pouclet on 06/02/13.
//  Copyright (c) 2013 Perfectly Cooked. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@interface NSColor (ShipIO)

+ (NSColor *)successText;
+ (NSColor *)successBackground;
+ (NSColor *)failureText;
+ (NSColor *)failureBackground;

@end
