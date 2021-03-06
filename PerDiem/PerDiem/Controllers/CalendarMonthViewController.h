//
//  CalendarMonthViewController.h
//  PerDiem
//
//  Created by Florent Bonomo on 12/1/15.
//  Copyright © 2015 PerDiem. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "NSDate+DateTools.h"
#import <DateTools/DateTools.h>
#import "PerDiem.h"
#import "DayViewTableViewCell.h"

@class CalendarMonthViewController;

@protocol CalendarMonthViewControllerDelegate <NSObject>

- (void)calendarMonthViewController:(CalendarMonthViewController *)controller
                        updateTitle:(NSString *)title;
- (void)calendarMonthViewController:(CalendarMonthViewController *)controller
           navigateToDayWithPerDiem:(PerDiem *)perDiem
                           animated:(BOOL)animated;

@end

@interface CalendarMonthViewController : UIViewController

@property (nonatomic, assign) id<CalendarMonthViewControllerDelegate> delegate;
@property (nonatomic, strong) NSDate *date;
@property (strong, nonatomic) DTTimePeriod *timePeriod;
@property (strong, nonatomic) NSMutableArray<PerDiem *> *perDiems;
@property (weak, nonatomic) IBOutlet UITableView *tableView;

- (void)updatePerDiems;
- (instancetype)initWithDate:(NSDate *)date
                  completion:(void(^)(NSArray<PerDiem *>*))completionHandler;
- (void)updateTitle;
- (void)updateTitleWithTitle:(NSString *)title;
- (DayViewTableViewCell *)viewForPerDiem:(PerDiem *)perDiem;

@end
