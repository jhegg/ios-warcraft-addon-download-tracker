//
//  Settings.m
//  My Warcraft Addon Downloads
//
//  Created by jhegg on 8/24/15.
//  Copyright (c) 2015 Josh Hegg. All rights reserved.
//

#import "Settings.h"

@implementation Settings

@synthesize managedObjectContext;

- (void)loadUrl {
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

- (void)updateUrl:(NSURL *)url {
    NSManagedObjectContext *context = [self managedObjectContext];
    NSError *error;
    NSArray *fetchedObjects = [self fetchSettingsObjectFromContext:context withErrorTracking:error];
    
    NSLog(@"Fetched %lu settings entries", (unsigned long)fetchedObjects.count);
    if (fetchedObjects.count == 0) {
        [self createSettingsUrl:url inContext:context];
    } else {
        [self updateFetchedSettingsObject:fetchedObjects withUrl:url];
    }
    
    if (![context save:&error]) {
        NSLog(@"Unable to save URL: %@", [error localizedDescription]);
    } else {
        self.url = url;
    }
}

- (NSArray *)fetchSettingsObjectFromContext:(NSManagedObjectContext *)context withErrorTracking:(NSError *)error{
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    [fetchRequest setEntity:[NSEntityDescription entityForName:@"Settings" inManagedObjectContext:context]];
    NSArray *fetchedObjects = [context executeFetchRequest:fetchRequest error:&error];
    if (error) {
        NSLog(@"Error fetching URL: %@", [error localizedDescription]);
        return nil;
    } else {
        return fetchedObjects;
    }
}

- (void)createSettingsUrl:(NSURL *)url inContext:(NSManagedObjectContext *)context {
    NSManagedObject *settings = [NSEntityDescription insertNewObjectForEntityForName:@"Settings" inManagedObjectContext:context];
    [settings setValue:url.absoluteString forKey:@"url"];
    NSLog(@"Creating URL with: %@", url.absoluteString);
}

- (void)updateFetchedSettingsObject:(NSArray *)fetchedObjects withUrl:(NSURL *)url {
    NSManagedObject *settings = [fetchedObjects firstObject];
    [settings setValue:url.absoluteString forKey:@"url"];
    NSLog(@"Updating URL with: %@", url.absoluteString);
}

- (BOOL)urlNeedsUpdating:(NSURL *)url {
    if (!url) {
        return NO;
    }
    
    return ![url isEqual:self.url];
}

- (BOOL)urlIsConfigured {
    return self.url && self.url.host.length > 0;
}

@end
