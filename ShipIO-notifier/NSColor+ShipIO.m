//
//  NSColor+ShipIO.m
//  ShipIO-notifier
//
//  Created by Romain Pouclet on 06/02/13.
//  Copyright (c) 2013 Perfectly Cooked. All rights reserved.
//

#import "NSColor+ShipIO.h"

@implementation NSColor (ShipIO)

+ (NSColor *)successText
{
    return [NSColor colorWithDeviceRed: 0.273
                                 green: 0.531
                                  blue: 0.277
                                 alpha: 1.0];
}

+ (NSColor *)successBackground
{
    return [NSColor colorWithDeviceRed: 0.871
                                 green: 0.941
                                  blue: 0.847
                                 alpha: 1.0];
}

+ (NSColor *)failureText
{
    return [NSColor colorWithDeviceRed: 0.725
                                 green: 0.290
                                  blue: 0.283
                                 alpha: 1.0];
}

+ (NSColor *)failureBackground
{
    return [NSColor colorWithDeviceRed: 0.949
                                 green: 0.871
                                  blue: 0.871
                                 alpha: 1.0];
}

@end
