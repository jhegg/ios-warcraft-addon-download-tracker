//
//  Addons.m
//  My Warcraft Addon Downloads
//
//  Created by jhegg on 7/24/15.
//  Copyright (c) 2015 Josh Hegg. All rights reserved.
//

#import "Addons.h"
#import "Addon.h"

@interface Addons ()
@property NSMutableArray *addons;
@end

@implementation Addons

- (id)init {
    self = [super init];
    _count = 0;    
    _addons = [[NSMutableArray alloc] init];
    return self;
}

- (void)updateAddons:(void(^)(void))handler {
    NSURL *url = [NSURL URLWithString:@"https://boxing-marks-7365.herokuapp.com/addons"];
    NSURLRequest *request = [NSURLRequest requestWithURL:url];
    [NSURLConnection
     sendAsynchronousRequest:request
     queue:[NSOperationQueue mainQueue]
     completionHandler:^(NSURLResponse *response, NSData *data, NSError *connectionError) {
         if (data.length > 0 && connectionError == nil) {
             // TODO: better error handling, for example HTTP status code != 200
             
             [self updateTableFromJsonData:data];
             
             handler();
         }
     }];
}

- (void)updateTableFromJsonData:(NSData *)data {
    NSDictionary *addonsFromJson = [NSJSONSerialization
                                    JSONObjectWithData:data
                                    options:0
                                    error:NULL];
    for (NSString *key in addonsFromJson) {
        [self processAddonFromJson:key];
    }
}

- (void)processAddonFromJson:(NSString *)addonName {
    for (Addon *addon in self.addons) {
        if ([addon.name isEqualToString:addonName]) {
            [self updateAddon:addon];
            return;
        }
    }
    
    [self createAddon:addonName];
}

- (void)createAddon:(NSString *)addonName {
    Addon *addon = [[Addon alloc] init];
    addon.name = addonName;
    [self queryDownloadCountForAddon:addonName];
    [self.addons addObject:addon];
    self.count = self.addons.count;
}

- (void)updateAddon:(Addon *)addon {
    [self queryDownloadCountForAddon:addon.name];
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

- (void)updateAddonDownloadCountFromJson:(NSData *)data addonName:(NSString *)addonName {
    NSDictionary *addonsFromJson = [NSJSONSerialization
                                    JSONObjectWithData:data
                                    options:0
                                    error:NULL];
    NSArray *downloads = [addonsFromJson valueForKey:@"downloads"];
    NSArray *downloadsSortedByDate = [self sortByDate:downloads];
    NSNumber *maxCount = [[downloadsSortedByDate firstObject] valueForKey:@"count"];
    [self updateAddonDownloadCount:maxCount
               withDownloadHistory:downloadsSortedByDate
                     withAddonName:addonName];
}

- (NSArray *)sortByDate:(NSArray *)downloads {
    NSDateFormatter *formatter = [self buildDateFormatter];
    NSMutableArray *downloadsWithRealDates = [[NSMutableArray alloc] initWithCapacity:downloads.count];
    for (id object in downloads) {
        NSDate *date = [formatter dateFromString:[object valueForKey:@"timestamp"]];
        NSNumber *count = [object valueForKey:@"count"];
        NSDictionary *downloadData = [[NSDictionary alloc] initWithObjects:@[date, count] forKeys:@[@"timestamp", @"count"]];
        [downloadsWithRealDates addObject:downloadData];
    }
    NSSortDescriptor *sortByDate = [NSSortDescriptor sortDescriptorWithKey:@"timestamp" ascending:NO];
    return [downloadsWithRealDates sortedArrayUsingDescriptors:@[sortByDate]];
}

- (NSDateFormatter *)buildDateFormatter {
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    NSLocale *enUsPosixLocale = [NSLocale localeWithLocaleIdentifier:@"en_US_POSIX"];
    [formatter setLocale:enUsPosixLocale];
    [formatter setDateFormat:@"yyyy-MM-dd'T'HH:mm:ss.SSSZ"];
    return formatter;
}

- (void)updateAddonDownloadCount:(NSNumber *)count withDownloadHistory:(NSArray *)downloads withAddonName:(NSString *)addonName {
    for (Addon *addon in _addons) {
        if ([addon.name isEqualToString:addonName]) {
            addon.currentDownloadCount = count;
            addon.downloadHistory = downloads;
            dispatch_async(dispatch_get_main_queue(), ^{
                [self.delegate refreshTable];
            });
            
            return;
        }
    }
}

- (NSArray *)allAddons {
    NSSortDescriptor *nameDescriptor = [[NSSortDescriptor alloc]
                                        initWithKey:@"name"
                                        ascending:YES
                                        selector:@selector(localizedCaseInsensitiveCompare:)];
    return [self.addons sortedArrayUsingDescriptors:[NSArray arrayWithObjects:nameDescriptor, nil]];
}

@end
