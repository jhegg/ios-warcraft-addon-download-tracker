//
//  AddonsTableViewController.h
//  My Warcraft Addon Downloads
//
//  Created by jhegg on 7/20/15.
//  Copyright (c) 2015 Josh Hegg. All rights reserved.
//

#import <UIKit/UIKit.h>
@import CoreData;
#import "AddonsTableViewControllerDelegate.h"

@interface AddonsTableViewController : UITableViewController <AddonsTableViewControllerDelegate>

@property (nonatomic, strong) NSManagedObjectContext *managedObjectContext;
- (IBAction)unwindToList:(UIStoryboardSegue *)segue;

@end
