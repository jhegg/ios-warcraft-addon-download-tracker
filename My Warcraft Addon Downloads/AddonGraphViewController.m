//
//  AddonGraphViewController.m
//  My Warcraft Addon Downloads
//
//  Created by jhegg on 7/27/15.
//  Copyright (c) 2015 Josh Hegg. All rights reserved.
//

#import "AddonGraphViewController.h"

@interface AddonGraphViewController ()

@property (weak, nonatomic) IBOutlet UILabel *detailLabel;
@property (weak, nonatomic) IBOutlet BEMSimpleLineGraphView *graph;
@property NSArray *orderedHistory;
@property NSDateFormatter *detailLabelDateFormatter;
@property NSDateFormatter *xAxisDateFormatter;

@end

@implementation AddonGraphViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self initializeHistory];
    _detailLabelDateFormatter = [self buildDetailLabelDateFormatter];
    _xAxisDateFormatter = [self buildXAxisDateFormatter];
    
    _graph.enableTouchReport = YES;
    _graph.enablePopUpReport = YES;
    _graph.enableYAxisLabel = YES;
    _graph.enableXAxisLabel = YES;
    _graph.autoScaleYAxis = YES;
    _graph.alwaysDisplayDots = NO;
    
    _detailLabel.text = @"Touch the graph for details";
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)initializeHistory {
    NSSortDescriptor *sortByDateAscending = [[NSSortDescriptor alloc] initWithKey:@"timestamp" ascending:YES];
    self.orderedHistory = [self.addon.downloadHistory sortedArrayUsingDescriptors:@[sortByDateAscending]];
}

- (NSDateFormatter *)buildDetailLabelDateFormatter {
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    NSLocale *enUsPosixLocale = [NSLocale localeWithLocaleIdentifier:@"en_US_POSIX"];
    [formatter setLocale:enUsPosixLocale];
    [formatter setDateStyle:NSDateFormatterMediumStyle];
    [formatter setTimeStyle:NSDateFormatterMediumStyle];
    return formatter;
}

- (NSDateFormatter *)buildXAxisDateFormatter {
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    NSLocale *enUsPosixLocale = [NSLocale localeWithLocaleIdentifier:@"en_US_POSIX"];
    [formatter setLocale:enUsPosixLocale];
    [formatter setDateStyle:NSDateFormatterMediumStyle];
    return formatter;
}

- (NSInteger)numberOfPointsInLineGraph:(BEMSimpleLineGraphView * __nonnull)graph {
    return self.addon.downloadHistory.count;
}

- (CGFloat)lineGraph:(BEMSimpleLineGraphView * __nonnull)graph valueForPointAtIndex:(NSInteger)index {
    return [[[self.orderedHistory objectAtIndex:index] valueForKey:@"count"] floatValue];
}

- (NSString *)lineGraph:(nonnull BEMSimpleLineGraphView *)graph labelOnXAxisForIndex:(NSInteger)index {
    NSDate *date = [[self.orderedHistory objectAtIndex:index] objectForKey:@"timestamp"];
    return [self.xAxisDateFormatter stringFromDate:date];
}

- (NSInteger)numberOfGapsBetweenLabelsOnLineGraph:(BEMSimpleLineGraphView * __nonnull)graph {
    return self.addon.downloadHistory.count;
}

- (CGFloat)minValueForLineGraph:(BEMSimpleLineGraphView * __nonnull)graph {
    return 0.0f;
}

- (CGFloat)maxValueForLineGraph:(BEMSimpleLineGraphView * __nonnull)graph {
    return [[[self.addon.downloadHistory firstObject] valueForKey:@"count"] floatValue] * 1.10f;
}

- (void) lineGraph:(BEMSimpleLineGraphView * __nonnull)graph didTouchGraphWithClosestIndex:(NSInteger)index {
    id dataPoint = [self.orderedHistory objectAtIndex:index];
    NSDate *date = [dataPoint objectForKey:@"timestamp"];
    NSNumber *count = [dataPoint objectForKey:@"count"];
    self.detailLabel.text = [NSString stringWithFormat:@"%@ - %@", [self.detailLabelDateFormatter stringFromDate:date], count];
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
