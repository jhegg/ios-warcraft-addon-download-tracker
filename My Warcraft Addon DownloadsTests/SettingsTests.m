//
//  SettingsTests.m
//  My Warcraft Addon Downloads
//
//  Created by jhegg on 8/24/15.
//  Copyright (c) 2015 Josh Hegg. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <XCTest/XCTest.h>
#import "Settings.h"

@interface SettingsTests : XCTestCase

@property (nonatomic, retain) NSManagedObjectContext *context;
@property (nonatomic, retain) NSManagedObjectModel *model;

@end

@implementation SettingsTests

- (void)setUp {
    [super setUp];
    
    if (!self.model) {
        self.model = [NSManagedObjectModel mergedModelFromBundles:[NSBundle allBundles]];
    }
    
    [self createInMemoryManagedObjectContext];
}

- (void)tearDown {
    self.context = nil;
    [super tearDown];
}

- (void)createInMemoryManagedObjectContext {
    NSPersistentStoreCoordinator *coordinator = [[NSPersistentStoreCoordinator alloc] initWithManagedObjectModel:self.model];
    NSPersistentStore *store = [coordinator addPersistentStoreWithType:NSInMemoryStoreType configuration:nil URL:nil options:nil error:nil];
    NSAssert(store, @"The persistent store should exist");
    self.context = [[NSManagedObjectContext alloc] initWithConcurrencyType:NSMainQueueConcurrencyType];
    self.context.persistentStoreCoordinator = coordinator;
}

- (void)testLoadingSettingsWhenNoneExist {
    Settings *settings = [self createSettingsUsingContext];
    [settings loadUrl];
    XCTAssertNil(settings.url);
}

- (Settings *)createSettingsUsingContext {
    Settings *settings = [[Settings alloc] init];
    settings.managedObjectContext = self.context;
    return settings;
}

- (void)testLoadingSettingsWhenOneExists {
    NSString *url = @"http://example.com";
    [self createSettingsObjectWithUrl:[NSURL URLWithString:url]];
    
    Settings *settings = [self createSettingsUsingContext];
    [settings loadUrl];
    XCTAssertEqual(settings.url.absoluteString, url);
}

- (void)createSettingsObjectWithUrl:(NSURL *)url {
    NSManagedObject *settings = [self createSettingsObjectWithoutUrl];
    [settings setValue:url.absoluteString forKey:@"url"];
}

- (NSManagedObject *)createSettingsObjectWithoutUrl {
    return [NSEntityDescription insertNewObjectForEntityForName:@"Settings" inManagedObjectContext:self.context];
}

- (void)testLoadingSettingsWhenUrlDoesNotExist {
    [self createSettingsObjectWithoutUrl];
    
    Settings *settings = [self createSettingsUsingContext];
    [settings loadUrl];
    XCTAssertNil(settings.url.absoluteString);
}

- (void)testUrlDoesNotNeedUpdating {
    Settings *settings = [self createSettingsUsingContext];
    settings.url = [NSURL URLWithString:@"http://example.com"];
    XCTAssertFalse([settings urlNeedsUpdating:settings.url]);
}

- (void)testUrlNeedsUpdatingFromNil {
    Settings *settings = [self createSettingsUsingContext];
    settings.url = nil;
    XCTAssertTrue([settings urlNeedsUpdating:[NSURL URLWithString:@"http://example.com"]]);
}

- (void)testUrlNeedsUpdatingWhenDifferent {
    Settings *settings = [self createSettingsUsingContext];
    settings.url = [NSURL URLWithString:@"http://example.com"];
    XCTAssertTrue([settings urlNeedsUpdating:[NSURL URLWithString:@"http://foo.example.com"]]);
}

- (void)testUrlIsNotConfigured {
    Settings *settings = [self createSettingsUsingContext];
    settings.url = nil;
    XCTAssertFalse([settings urlIsConfigured]);
}

- (void)testUrlIsConfigured {
    Settings *settings = [self createSettingsUsingContext];
    settings.url = [NSURL URLWithString:@"http://example.com"];
    XCTAssertTrue([settings urlIsConfigured]);
}

- (void)testUrlIsMisconfigured {
    Settings *settings = [self createSettingsUsingContext];
    settings.url = [NSURL URLWithString:@"-1"];
    XCTAssertFalse([settings urlIsConfigured]);
}

- (void)testUpdatingSettingsCreatesIfDoesNotExist {
    Settings *settings = [self createSettingsUsingContext];
    [settings updateUrl:[NSURL URLWithString:@"http://example.com"]];
    
    NSError *error;
    NSArray *fetchedObjects = [self fetchSettingsObjectsFromStore:error];
    
    XCTAssertNil(error);
    XCTAssertNotNil(fetchedObjects);
    XCTAssertEqual(1, fetchedObjects.count);
    XCTAssertEqual([fetchedObjects.firstObject valueForKey:@"url"], @"http://example.com");
}

- (NSArray *)fetchSettingsObjectsFromStore:(NSError *)error {
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    [fetchRequest setEntity:[NSEntityDescription entityForName:@"Settings" inManagedObjectContext:self.context]];
    return [self.context executeFetchRequest:fetchRequest error:&error];
}

- (void)testUpdatingSettingsWhenOneExists {
    [self createSettingsObjectWithUrl:[NSURL URLWithString:@"http://example.com"]];
    Settings *settings = [self createSettingsUsingContext];
    [settings updateUrl:[NSURL URLWithString:@"http://foo.example.com"]];
    
    NSError *error;
    NSArray *fetchedObjects = [self fetchSettingsObjectsFromStore:error];
    
    XCTAssertNil(error);
    XCTAssertNotNil(fetchedObjects);
    XCTAssertEqual(1, fetchedObjects.count);
    XCTAssertEqual([fetchedObjects.firstObject valueForKey:@"url"], @"http://foo.example.com");
}

- (void)testUpdatingSettingsTwiceDoesNotCreateExtraSettingsObjects {
    [self createSettingsObjectWithUrl:[NSURL URLWithString:@"http://example.com"]];
    Settings *settings = [self createSettingsUsingContext];
    [settings updateUrl:[NSURL URLWithString:@"http://foo.example.com"]];
    [settings updateUrl:[NSURL URLWithString:@"http://bar.example.com"]];
    
    NSError *error;
    NSArray *fetchedObjects = [self fetchSettingsObjectsFromStore:error];
    
    XCTAssertNil(error);
    XCTAssertNotNil(fetchedObjects);
    XCTAssertEqual(1, fetchedObjects.count);
    XCTAssertEqual([fetchedObjects.firstObject valueForKey:@"url"], @"http://bar.example.com");
}

@end
