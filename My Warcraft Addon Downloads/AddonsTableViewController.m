//
//  AddonsTableViewController.m
//  My Warcraft Addon Downloads
//
//  Created by jhegg on 7/20/15.
//  Copyright (c) 2015 Josh Hegg. All rights reserved.
//

#import "AddonsTableViewController.h"
#import "AddonDetailViewController.h"
#import "Addon.h"
#import "Addons.h"

@interface AddonsTableViewController ()

@property Addons *addons2;

- (IBAction)refresh:(UIRefreshControl *)sender;

@end

@implementation AddonsTableViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self.refreshControl addTarget:self
                            action:@selector(refresh:)
                  forControlEvents:UIControlEventValueChanged];
    
    self.addons2 = [[Addons alloc] init];
    self.addons2.delegate = self;
    
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

- (void)refreshTable {
    [self.tableView reloadData];
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


#pragma mark - Navigation

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if ([segue.identifier isEqualToString:@"addonDetail"]) {
        AddonDetailViewController *destination = [segue destinationViewController];
        NSIndexPath *indexPath = [self.tableView indexPathForSelectedRow];
        destination.addon = [[self.addons2 allAddons] objectAtIndex:indexPath.row];
    }
}

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
