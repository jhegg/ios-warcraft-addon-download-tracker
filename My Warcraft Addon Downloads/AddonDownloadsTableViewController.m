//
//  AddonDownloadsTableViewController.m
//  My Warcraft Addon Downloads
//
//  Created by jhegg on 7/26/15.
//  Copyright (c) 2015 Josh Hegg. All rights reserved.
//

#import "AddonDownloadsTableViewController.h"

@interface AddonDownloadsTableViewController ()

@property NSDateFormatter *dateFormatter;

@end

@implementation AddonDownloadsTableViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = self.addon.name;
    self.dateFormatter = [self buildDateFormatter];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

- (NSDateFormatter *)buildDateFormatter {
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    NSLocale *enUsPosixLocale = [NSLocale localeWithLocaleIdentifier:@"en_US_POSIX"];
    [formatter setLocale:enUsPosixLocale];
    [formatter setDateStyle:NSDateFormatterMediumStyle];
    [formatter setTimeStyle:NSDateFormatterMediumStyle];
    return formatter;
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.addon.downloadHistory.count;
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
    return @"Downloads (+Change)";
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"ListPrototypeCell" forIndexPath:indexPath];
    NSDate *date = [[[self.addon downloadHistory] objectAtIndex:indexPath.row] objectForKey:@"timestamp"];
    cell.detailTextLabel.text = [self.dateFormatter stringFromDate:date];
    cell.textLabel.text = [self getTitleTextForRowAtIndexPath:indexPath];
    return cell;
}

- (NSString *)getTitleTextForRowAtIndexPath:(NSIndexPath *)indexPath {
    NSNumber *count = [[[self.addon downloadHistory] objectAtIndex:indexPath.row] objectForKey:@"count"];
    NSNumber *delta = [[NSNumber alloc] initWithInt:0];
    if (indexPath.row + 1 < [self.addon downloadHistory].count) {
        NSDictionary *previous = [[self.addon downloadHistory] objectAtIndex:(indexPath.row + 1)];
        NSNumber *previousCount = [previous objectForKey:@"count"];
        delta = [[NSNumber alloc] initWithInt:(count.intValue - previousCount.intValue)];
    }
    
    return [NSString stringWithFormat:@"%d (+%d)", count.intValue, delta.intValue];
}


/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
