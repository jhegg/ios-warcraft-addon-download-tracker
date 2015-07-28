//
//  AddonGraphViewController.m
//  My Warcraft Addon Downloads
//
//  Created by jhegg on 7/27/15.
//  Copyright (c) 2015 Josh Hegg. All rights reserved.
//

#import "AddonGraphViewController.h"

@interface AddonGraphViewController ()

@property (weak, nonatomic) IBOutlet BEMSimpleLineGraphView *graph;

@end

@implementation AddonGraphViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    _graph.enableTouchReport = YES;
    _graph.enablePopUpReport = YES;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (NSInteger)numberOfPointsInLineGraph:(BEMSimpleLineGraphView * __nonnull)graph {
    return self.addon.downloadHistory.count;
}

- (CGFloat)lineGraph:(BEMSimpleLineGraphView * __nonnull)graph valueForPointAtIndex:(NSInteger)index {
    NSSortDescriptor *sortByDateAscending = [[NSSortDescriptor alloc] initWithKey:@"timestamp" ascending:YES];
    NSArray *orderedHistory = [self.addon.downloadHistory sortedArrayUsingDescriptors:@[sortByDateAscending]];
    return [[[orderedHistory objectAtIndex:index] valueForKey:@"count"] floatValue];
}

- (CGFloat)minValueForLineGraph:(BEMSimpleLineGraphView * __nonnull)graph {
    return 0.0f;
}

- (CGFloat)maxValueForLineGraph:(BEMSimpleLineGraphView * __nonnull)graph {
    return [[[self.addon.downloadHistory firstObject] valueForKey:@"count"] floatValue] * 1.10f;
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
