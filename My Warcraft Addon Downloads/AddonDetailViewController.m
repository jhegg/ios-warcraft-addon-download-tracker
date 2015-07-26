//
//  AddonDetailViewController.m
//  My Warcraft Addon Downloads
//
//  Created by jhegg on 7/25/15.
//  Copyright (c) 2015 Josh Hegg. All rights reserved.
//

#import "AddonDetailViewController.h"

@interface AddonDetailViewController ()

@end

@implementation AddonDetailViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = self.addon.name;
}

@end
