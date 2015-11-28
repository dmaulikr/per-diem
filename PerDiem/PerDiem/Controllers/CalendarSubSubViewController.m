//
//  CalendarSubSubViewController.m
//  PerDiem
//
//  Created by Florent Bonomo on 11/21/15.
//  Copyright © 2015 PerDiem. All rights reserved.
//

#import "CalendarSubSubViewController.h"
#import "DayViewTableViewCell.h"

@interface CalendarSubSubViewController () <UITableViewDataSource, UITableViewDelegate>

@property (weak, nonatomic) IBOutlet UILabel *label;
@property (weak, nonatomic) IBOutlet UITableView *tableView;

@end

@implementation CalendarSubSubViewController


#pragma mark - UIViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self updateLabel];
    
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    self.tableView.rowHeight = UITableViewAutomaticDimension;
    self.tableView.estimatedRowHeight = 30.0;
    self.tableView.scrollEnabled = NO;
    [self.tableView registerNib:[UINib nibWithNibName:@"DayViewTableViewCell" bundle:nil]
         forCellReuseIdentifier:@"cell"];
    
    [Transaction transactionsWithinPeriod:self.timePeriod
                               completion:^(TransactionList *transactionList, NSError *error) {
                                   self.transactionList = transactionList;
                                   
                                   // This call should be parallelized with the previous one, probably...
                                   [Budget budgets:^(NSArray *budgets, NSError *error) {
                                       self.budgets = budgets;
                                       [self.tableView reloadData];
                                   }];
                               }];
}


#pragma mark - UITableViewDataSource

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.timePeriod.durationInDays;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    NSDate *day = [[self.timePeriod StartDate] dateByAddingDays:indexPath.row];
    DTTimePeriod *period = [DTTimePeriod timePeriodWithSize:DTTimePeriodSizeDay
                                                 startingAt:day];
    DayViewTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"cell"];
    cell.transactionList = [TransactionList transactionListWithTransactionList:self.transactionList
                                                              filterWithPeriod:period];
    cell.budgets = self.budgets;
    return cell;
}


#pragma mark - Private

- (void)setDate:(NSDate *)date {
    _date = date;
    [self updateLabel];
}

- (void)setTimePeriod:(DTTimePeriod *)timePeriod {
    _timePeriod = timePeriod;
    [self updateLabel];
}

- (void)updateLabel {
    NSString *from = [[self.timePeriod StartDate] formattedDateWithStyle:NSDateFormatterFullStyle];
    NSString *to = [[self.timePeriod EndDate] formattedDateWithStyle:NSDateFormatterFullStyle];
    self.label.text = [NSString stringWithFormat:@"%@ to %@", from, to];
}

@end
