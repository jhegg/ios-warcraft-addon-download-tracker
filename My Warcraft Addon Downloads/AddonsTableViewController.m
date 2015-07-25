//
//  AddonsTableViewController.m
//  My Warcraft Addon Downloads
//
//  Created by jhegg on 7/20/15.
//  Copyright (c) 2015 Josh Hegg. All rights reserved.
//

#import "AddonsTableViewController.h"
#import "Addon.h"
#import "Addons.h"

@interface AddonsTableViewController ()

@property Addons *addons2;
@property (nonatomic, strong) id addonsObserveToken;

- (IBAction)refresh:(UIRefreshControl *)sender;

@end

@implementation AddonsTableViewController

// TODO: register KVO for Addons changes

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.navigationItem.title = @"My Warcraft Addon Downloads";
    
    [self.refreshControl addTarget:self
                            action:@selector(refresh:)
                  forControlEvents:UIControlEventValueChanged];
    
    self.addons2 = [[Addons alloc] init];
    [self refresh:self.refreshControl];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

- (IBAction)updateAddons:(void (^)(void))handler {
    [self.addons2 updateAddons:^{
        [self.tableView reloadData];
        handler();
    }];
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    if (self.addons2 && self.addons2.count > 0) {
        tableView.backgroundView = nil;
        tableView.separatorStyle = UITableViewCellSeparatorStyleSingleLine;
        return 1;
    } else {
        tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
        return 0;
    }
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.addons2.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"ListPrototypeCell" forIndexPath:indexPath];
    Addon *addon = [[self.addons2 allAddons] objectAtIndex:indexPath.row];
    cell.textLabel.text = [NSString
                           stringWithFormat:@"%@ - %@",
                           addon.addonName,
                           addon.addonTotalDownloads ?: @"..."];
    return cell;
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

- (IBAction)refresh:(UIRefreshControl *)sender {
    sender.attributedTitle = [[NSAttributedString alloc] initWithString:@"Refreshing data..."];
    
    [self updateAddons:^{
        NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
        [formatter setDateFormat:@"MMM d, h:mm a"];
        NSString *lastUpdated = [NSString stringWithFormat:@"Last updated on %@",
                                 [formatter stringFromDate:[NSDate date]]];
        sender.attributedTitle = [[NSAttributedString alloc] initWithString:lastUpdated];
        [sender endRefreshing];
    }];
}

@end
