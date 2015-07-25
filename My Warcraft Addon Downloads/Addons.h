//
//  Addons.h
//  My Warcraft Addon Downloads
//
//  Created by jhegg on 7/24/15.
//  Copyright (c) 2015 Josh Hegg. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface Addons : NSObject

@property NSInteger count;

- (NSArray *)allAddons;
- (void)updateAddons:(void(^)(void))handler;

@end
