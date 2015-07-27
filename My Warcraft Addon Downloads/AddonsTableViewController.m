//
//  AddonsTableViewController.m
//  My Warcraft Addon Downloads
//
//  Created by jhegg on 7/20/15.
//  Copyright (c) 2015 Josh Hegg. All rights reserved.
//

#import "AddonsTableViewController.h"
#import "AddonDownloadsTableViewController.h"
#import "Addon.h"
#import "Addons.h"

@interface AddonsTableViewController ()

@property Addons *addons;

- (IBAction)refresh:(UIRefreshControl *)sender;

@end

@implementation AddonsTableViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self.refreshControl addTarget:self
                            action:@selector(refresh:)
                  forControlEvents:UIControlEventValueChanged];
    
    self.addons = [[Addons alloc] init];
    self.addons.delegate = self;
    
    [self refresh:self.refreshControl];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

- (IBAction)updateAddons:(void (^)(void))handler {
    [self.addons updateAddons:^{
        [self.tableView reloadData];
        handler();
    }];
}

- (void)refreshTable {
    [self.tableView reloadData];
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    if (self.addons && self.addons.count > 0) {
        tableView.backgroundView = nil;
        tableView.separatorStyle = UITableViewCellSeparatorStyleSingleLine;
        return 1;
    } else {
        tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
        return 0;
    }
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.addons.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"ListPrototypeCell" forIndexPath:indexPath];
    Addon *addon = [[self.addons allAddons] objectAtIndex:indexPath.row];
    cell.textLabel.text = addon.name;
    cell.detailTextLabel.text = [NSString stringWithFormat:@"%@", addon.currentDownloadCount ?: @"..."];
    return cell;
}


#pragma mark - Navigation

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if ([segue.identifier isEqualToString:@"addonDetail"]) {
        AddonDownloadsTableViewController *destination = [segue destinationViewController];
        NSIndexPath *indexPath = [self.tableView indexPathForSelectedRow];
        destination.addon = [[self.addons allAddons] objectAtIndex:indexPath.row];
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
