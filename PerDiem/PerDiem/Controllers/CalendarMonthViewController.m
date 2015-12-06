//
//  CalendarMonthViewController.m
//  PerDiem
//
//  Created by Florent Bonomo on 12/1/15.
//  Copyright © 2015 PerDiem. All rights reserved.
//

#import "CalendarMonthViewController.h"
#import "CalendarDayViewController.h"
#import <DateTools/DateTools.h>
#import <UIKit/UIKit.h>
#import "NSDate+DateTools.h"
#import "DayViewTableViewCell.h"
#import "UIColor+PerDiem.h"

@interface CalendarMonthViewController () <UITableViewDataSource, UITableViewDelegate>

@property (weak, nonatomic) IBOutlet UITableView *tableView;

@end

@implementation CalendarMonthViewController

#pragma mark - UIViewController

- (instancetype)initWithDate:(NSDate *)date
                  completion:(void(^)(NSArray<PerDiem *>*))completionHandler {
    if (self = [super initWithNibName:@"CalendarMonthViewController" bundle:nil]) {
        self.date = date;
        [self fetchPerDiemsWithCompletion:^(NSArray<PerDiem *> *perDiems) {
             [self.tableView reloadData];
            if (completionHandler != nil) {
                completionHandler(perDiems);
            }
        }];
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.tableView.backgroundColor = [UIColor backgroundColor];
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    self.tableView.estimatedRowHeight = 100;
    self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    self.tableView.rowHeight = UITableViewAutomaticDimension;
    [self.tableView registerNib:[UINib nibWithNibName:@"DayViewTableViewCell" bundle:nil]
         forCellReuseIdentifier:@"cell"];
}


#pragma mark - UITableViewDataSource

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.timePeriod.durationInDays;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    DayViewTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"cell"];
    cell.perDiem = [self.perDiems objectAtIndex:indexPath.row];
    [cell setNeedsLayout];
    [cell layoutIfNeeded];
    return cell;
}


#pragma mark - UITableViewDelegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:NO];
    if ([self.delegate respondsToSelector:@selector(calendarMonthViewController:navigateToDayWithPerDiem:animated:)]) {
        [self.delegate calendarMonthViewController:self
                          navigateToDayWithPerDiem:[self.perDiems objectAtIndex:indexPath.row]
                                          animated:YES];
    }
}


#pragma mark - Private

- (void)fetchPerDiemsWithCompletion:(void(^)(NSArray<PerDiem *>*))completionHandler {
    [PerDiem perDiemsForPeriod:self.timePeriod
                    completion:^void(NSArray<PerDiem *> *perDiems, NSError *error) {
                        self.perDiems = perDiems;
                        [self.tableView reloadData];
                        if (completionHandler != nil) {
                            completionHandler(perDiems);
                        }
                    }];
}

- (void)setDate:(NSDate *)date {
    _date = date;
    NSDate *startOfDay = [[NSCalendar currentCalendar] startOfDayForDate:date];
    NSInteger monthStartedDaysAgo = startOfDay.day - 1;
    NSDate *startOfMonth = [startOfDay dateBySubtractingDays:monthStartedDaysAgo];
    self.timePeriod = [DTTimePeriod timePeriodWithSize:DTTimePeriodSizeMonth
                                            startingAt:startOfMonth];
    [self.tableView reloadData];
}

- (void)setTimePeriod:(DTTimePeriod *)timePeriod {
    _timePeriod = timePeriod;
    [self.tableView reloadData];
}

- (DTTimePeriod *)periodAtIndex:(NSIndexPath *)indexPath {
    NSDate *day = [[self.timePeriod StartDate] dateByAddingDays:indexPath.row];
    DTTimePeriod *period = [DTTimePeriod timePeriodWithSize:DTTimePeriodSizeDay
                                                 startingAt:day];
    return period;
}

- (void)updateTitle {
    [self updateTitleWithTitle:[self.date formattedDateWithFormat:@"LLL u"]];
}

- (void)updateTitleWithTitle:(NSString *)title {
    if ([self.delegate respondsToSelector:@selector(calendarMonthViewController:updateTitle:)]) {
        [self.delegate calendarMonthViewController:self
                                       updateTitle:title];
    }
}

- (UITableViewCell *)viewForPerDiem:(PerDiem *)perDiem {
    NSInteger perDiemIndex = [self.perDiems indexOfObject:perDiem];
    NSIndexPath *viewIndexPath = [NSIndexPath indexPathForRow:perDiemIndex inSection:0];
    return [self.tableView cellForRowAtIndexPath:viewIndexPath];
}


@end
