//
//  Addon.m
//  My Warcraft Addon Downloads
//
//  Created by jhegg on 7/20/15.
//  Copyright (c) 2015 Josh Hegg. All rights reserved.
//

#import "Addon.h"

@implementation Addon

- (BOOL)isEqual:(Addon *)other {
    return [self.addonName isEqualToString:other.addonName];
}

@end
