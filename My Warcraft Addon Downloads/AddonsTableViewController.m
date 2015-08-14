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
#import "SettingsViewController.h"

@interface AddonsTableViewController ()

@property Addons *addons;
@property (strong, nonatomic) NSURL *url;
@property (weak, nonatomic) IBOutlet UILabel *urlLabel;

- (IBAction)refresh:(UIRefreshControl *)sender;

@end

@implementation AddonsTableViewController

@synthesize managedObjectContext;

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self.refreshControl addTarget:self
                            action:@selector(refresh:)
                  forControlEvents:UIControlEventValueChanged];
    
    self.addons = [[Addons alloc] init];
    self.addons.delegate = self;
    
    [self fetchUrlFromCoreData];
    [self updateViewBasedOnUrl];
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
    [self.refreshControl endRefreshing];
}

- (void)fetchUrlFromCoreData {
    NSManagedObjectContext *context = [self managedObjectContext];
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    [fetchRequest setEntity:[NSEntityDescription entityForName:@"Settings" inManagedObjectContext:context]];
    NSError *error;
    NSArray *fetchedObjects = [context executeFetchRequest:fetchRequest error:&error];
    if (fetchedObjects.count == 1) {
        self.url = [NSURL URLWithString:[[fetchedObjects firstObject] valueForKey:@"url"]];
    }
    NSLog(@"Fetched %lu settings entries", (unsigned long)fetchedObjects.count);
}

- (void)updateViewBasedOnUrl {
    [self updateUrlLabel];
    [self beginRefreshingAddons];
}

- (void)updateUrlLabel {
    [self urlIsConfigured]
        ? (self.urlLabel.text = self.url.absoluteString)
        : (self.urlLabel.text = @"Please tap Settings to configure");
}

- (BOOL)urlIsConfigured {
    return self.url && self.url.host.length > 0;
}

- (void)beginRefreshingAddons {
    if ([self urlIsConfigured]) {
        [self.refreshControl beginRefreshing];
        [self.tableView setContentOffset:CGPointMake(0, self.tableView.contentOffset.y - self.refreshControl.frame.size.height) animated:YES];
        [self.refreshControl sendActionsForControlEvents:UIControlEventValueChanged];
    }
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
    cell.detailTextLabel.text = [self getDownloadCountTextForAddon:addon];
    return cell;
}

- (NSString *)getDownloadCountTextForAddon:(Addon *)addon {
    if (!addon.currentDownloadCount) {
        return @"...";
    }
    
    NSNumber *count = [[[addon downloadHistory] objectAtIndex:0] objectForKey:@"count"];
    NSNumber *delta = [[NSNumber alloc] initWithInt:0];
    if ([addon downloadHistory].count > 1) {
        NSNumber *previousCount = [[[addon downloadHistory] objectAtIndex:1] objectForKey:@"count"];
        delta = [[NSNumber alloc] initWithInt:(count.intValue - previousCount.intValue)];
    }
    
    return [NSString stringWithFormat:@"%d (+%d)", count.intValue, delta.intValue];
}

#pragma mark - Navigation

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if ([segue.identifier isEqualToString:@"addonDetail"]) {
        AddonDownloadsTableViewController *destination = (AddonDownloadsTableViewController *)[[segue destinationViewController] topViewController];
        NSIndexPath *indexPath = [self.tableView indexPathForSelectedRow];
        destination.addon = [[self.addons allAddons] objectAtIndex:indexPath.row];
    } else if ([segue.identifier isEqualToString:@"settingsDetail"]) {
        SettingsViewController *destination = (SettingsViewController *)[[segue destinationViewController] topViewController];
        destination.url = self.url;
    }
}

- (IBAction)refresh:(UIRefreshControl *)sender {
    if (![self urlIsConfigured]) {
        [sender endRefreshing];
        return;
    }
    
    sender.attributedTitle = [[NSAttributedString alloc] initWithString:[self getLastUpdatedTitle]];
    
    [self updateAddons:^{
    }];
}

- (NSString *)getLastUpdatedTitle {
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    [formatter setDateFormat:@"MMM d, h:mm a"];
    NSString *lastUpdated = [NSString stringWithFormat:@"Last updated on %@",
                             [formatter stringFromDate:[NSDate date]]];
    return lastUpdated;
}

- (IBAction)unwindToList:(UIStoryboardSegue *)segue {
    SettingsViewController *source = [segue sourceViewController];
    
    if ([self shouldUpdateWithUrl:source.url]) {
        [self createOrUpdateSettingsUrlInCoreData:source.url];
        self.url = source.url;
        [self updateViewBasedOnUrl];
    }
}

- (Boolean)shouldUpdateWithUrl:(NSURL *)url {
    if (!url) {
        return NO;
    }
    
    return ![url isEqual:self.url];
}

- (void)createOrUpdateSettingsUrlInCoreData:(NSURL *)url {
    NSManagedObjectContext *context = [self managedObjectContext];
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    [fetchRequest setEntity:[NSEntityDescription entityForName:@"Settings" inManagedObjectContext:context]];
    NSError *error;
    NSArray *fetchedObjects = [context executeFetchRequest:fetchRequest error:&error];
    if (error) {
        NSLog(@"Error fetching URL: %@", [error localizedDescription]);
    } else {
        NSLog(@"Fetched %lu settings entries", (unsigned long)fetchedObjects.count);
        if (fetchedObjects.count == 0) {
            NSManagedObject *settings = [NSEntityDescription insertNewObjectForEntityForName:@"Settings" inManagedObjectContext:context];
            [settings setValue:url.absoluteString forKey:@"url"];
            NSLog(@"Creating URL with: %@", url.absoluteString);
        } else {
            NSManagedObject *settings = [fetchedObjects firstObject];
            [settings setValue:url.absoluteString forKey:@"url"];
            NSLog(@"Updating URL with: %@", url.absoluteString);
        }
        NSError *error;
        if (![context save:&error]) {
            NSLog(@"Unable to save URL: %@", [error localizedDescription]);
        }
    }
}

@end
