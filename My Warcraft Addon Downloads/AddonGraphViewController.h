//
//  AddonGraphViewController.h
//  My Warcraft Addon Downloads
//
//  Created by jhegg on 7/27/15.
//  Copyright (c) 2015 Josh Hegg. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Addon.h"
#import "BEMSimpleLineGraphView.h"

@interface AddonGraphViewController : UIViewController <BEMSimpleLineGraphDelegate, BEMSimpleLineGraphDataSource>

@property Addon *addon;

@end
