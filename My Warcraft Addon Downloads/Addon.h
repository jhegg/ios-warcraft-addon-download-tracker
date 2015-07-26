//
//  Addon.h
//  My Warcraft Addon Downloads
//
//  Created by jhegg on 7/20/15.
//  Copyright (c) 2015 Josh Hegg. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface Addon : NSObject

@property NSString *name;
@property NSNumber *currentDownloadCount;

- (BOOL)isEqual:(Addon *)other;

@end
