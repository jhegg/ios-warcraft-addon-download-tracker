//
//  Settings.h
//  My Warcraft Addon Downloads
//
//  Created by jhegg on 8/24/15.
//  Copyright (c) 2015 Josh Hegg. All rights reserved.
//

#import <Foundation/Foundation.h>
@import CoreData;

@interface Settings : NSObject

@property (nonatomic, strong) NSManagedObjectContext *managedObjectContext;
@property (nonatomic, strong) NSURL *url;

- (void)loadUrl;
- (void)updateUrl:(NSURL *)url;
- (BOOL)urlNeedsUpdating:(NSURL *)url;
- (BOOL)urlIsConfigured;

@end
