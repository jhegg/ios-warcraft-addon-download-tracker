//
//  AddonsTableViewController.m
//  My Warcraft Addon Downloads
//
//  Created by jhegg on 7/20/15.
//  Copyright (c) 2015 Josh Hegg. All rights reserved.
//

#import "AddonsTableViewController.h"
#import "Addon.h"

@interface AddonsTableViewController ()

@property NSMutableSet *addons;

- (IBAction)refresh:(UIRefreshControl *)sender;

@end

@implementation AddonsTableViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.navigationItem.title = @"My Warcraft Addon Downloads";
    
    [self.refreshControl addTarget:self
                            action:@selector(refresh:)
                  forControlEvents:UIControlEventValueChanged];
    
    _addons = [[NSMutableSet alloc] init];
    [self refresh:self.refreshControl];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

- (void)updateAddonDownloadCount:(NSNumber *)count addonName:(NSString *)addonName {
    for (Addon *addon in _addons) {
        if ([addon.addonName isEqualToString:addonName]) {
            addon.addonTotalDownloads = count;
            [self.tableView reloadData];
            return;
        }
    }
}

- (void)updateAddonDownloadCountFromJson:(NSData *)data addonName:(NSString *)addonName {
    NSDictionary *addonsFromJson = [NSJSONSerialization
                                    JSONObjectWithData:data
                                    options:0
                                    error:NULL];
    NSArray *downloads = [addonsFromJson valueForKey:@"downloads"];
    NSArray *sortedCounts = [downloads sortedArrayUsingComparator:^(id obj1, id obj2) {
        NSNumber *first = @([[obj1 objectForKey:@"count"] intValue]);
        NSNumber *second = @([[obj2 objectForKey:@"count"] intValue]);
        return [first compare:second];
    }];
    
    NSNumber *maxCount = @([[[sortedCounts lastObject] objectForKey:@"count"] intValue]);
    [self updateAddonDownloadCount:maxCount addonName:addonName];
}

- (void)queryDownloadCountForAddon:(NSString *)addonName {
    NSURL *url = [NSURL URLWithString:[NSString stringWithFormat:@"https://boxing-marks-7365.herokuapp.com/addons/%@/downloads", addonName]];
    NSURLRequest *request = [NSURLRequest requestWithURL:url];
    [NSURLConnection
     sendAsynchronousRequest:request
     queue:[NSOperationQueue mainQueue]
     completionHandler:^(NSURLResponse *response, NSData *data, NSError *connectionError) {
         if (data.length > 0 && connectionError == nil) {
             [self updateAddonDownloadCountFromJson:data addonName:addonName];
         }
     }];
}

- (void)createAddon:(NSString *)addonName {
    Addon *addon = [[Addon alloc] init];
    addon.addonName = addonName;
    [self queryDownloadCountForAddon:addonName];
    [_addons addObject:addon];
}

- (void)updateAddon:(Addon *)addon {
    [self queryDownloadCountForAddon:addon.addonName];
}

- (void)processAddonFromJson:(NSString *)addonName {
    for (Addon *addon in _addons) {
        if ([addon.addonName isEqualToString:addonName]) {
            [self updateAddon:addon];
            return;
        }
    }
    
    [self createAddon:addonName];
}

- (void)updateTableFromJsonData:(NSData *)data {
    NSDictionary *addonsFromJson = [NSJSONSerialization
                                    JSONObjectWithData:data
                                    options:0
                                    error:NULL];
    for (NSString *key in addonsFromJson) {
        [self processAddonFromJson:key];
    }
    [self.tableView reloadData];
}

- (IBAction)updateAddons:(void (^)(void))handler {
    NSURL *url = [NSURL URLWithString:@"https://boxing-marks-7365.herokuapp.com/addons"];
    NSURLRequest *request = [NSURLRequest requestWithURL:url];
    [NSURLConnection
     sendAsynchronousRequest:request
     queue:[NSOperationQueue mainQueue]
     completionHandler:^(NSURLResponse *response, NSData *data, NSError *connectionError) {
         if (data.length > 0 && connectionError == nil) {
             [self updateTableFromJsonData:data];
             handler();
         }
     }];
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    if (_addons && _addons.count > 0) {
        tableView.backgroundView = nil;
        tableView.separatorStyle = UITableViewCellSeparatorStyleSingleLine;
        return 1;
    } else {
        tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
        return 0;
    }
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [_addons count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"ListPrototypeCell" forIndexPath:indexPath];
    
    NSSortDescriptor *sort = [NSSortDescriptor sortDescriptorWithKey:@"addonName" ascending:YES];
    Addon *addon = [[_addons sortedArrayUsingDescriptors:[NSArray arrayWithObject:sort]] objectAtIndex:indexPath.row];
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
