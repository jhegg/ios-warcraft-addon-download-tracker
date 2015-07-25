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
        if ([addon.addonName isEqualToString:addonName]) {
            [self updateAddon:addon];
            return;
        }
    }
    
    [self createAddon:addonName];
}

- (void)createAddon:(NSString *)addonName {
    Addon *addon = [[Addon alloc] init];
    addon.addonName = addonName;
    [self queryDownloadCountForAddon:addonName];
    [self.addons addObject:addon];
    self.count = self.addons.count;
}

- (void)updateAddon:(Addon *)addon {
    [self queryDownloadCountForAddon:addon.addonName];
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
    NSArray *sortedCounts = [downloads sortedArrayUsingComparator:^(id obj1, id obj2) {
        NSNumber *first = @([[obj1 objectForKey:@"count"] intValue]);
        NSNumber *second = @([[obj2 objectForKey:@"count"] intValue]);
        return [first compare:second];
    }];
    
    NSNumber *maxCount = @([[[sortedCounts lastObject] objectForKey:@"count"] intValue]);
    [self updateAddonDownloadCount:maxCount addonName:addonName];
}

- (void)updateAddonDownloadCount:(NSNumber *)count addonName:(NSString *)addonName {
    for (Addon *addon in _addons) {
        if ([addon.addonName isEqualToString:addonName]) {
            addon.addonTotalDownloads = count;
            [self.delegate refreshTable];
            return;
        }
    }
}

- (NSArray *)allAddons {
    NSSortDescriptor *nameDescriptor = [[NSSortDescriptor alloc]
                                        initWithKey:@"addonName"
                                        ascending:YES
                                        selector:@selector(localizedCaseInsensitiveCompare:)];
    return [self.addons sortedArrayUsingDescriptors:[NSArray arrayWithObjects:nameDescriptor, nil]];
}

@end
