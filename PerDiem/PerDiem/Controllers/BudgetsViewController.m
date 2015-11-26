//
//  BudgetsViewController.m
//  PerDiem
//
//  Created by Florent Bonomo on 11/21/15.
//  Copyright © 2015 PerDiem. All rights reserved.
//

#import "BudgetsViewController.h"
#import "TransactionFormViewController.h"
#import "BudgetFormViewController.h"
#import "TransactionsViewController.h"
#import "BudgetCell.h"
#import "Budget.h"
#import <SWTableViewCell.h>

@interface BudgetsViewController () <UITableViewDelegate, UITableViewDataSource, SWTableViewCellDelegate, BudgetFormActionDelegate>

@property(strong, nonatomic) NSArray* budgets;
@property (weak, nonatomic) IBOutlet UITableView *tableView;

@end

@implementation BudgetsViewController


#pragma mark - UIViewController

- (void)viewDidLoad {
    [super viewDidLoad];

    [self setupNavBar];

    [Budget budgets:^(NSArray *budgets, NSError *error) {
        NSMutableSet *list = [NSMutableSet setWithArray:self.budgets];
        [list addObjectsFromArray:budgets];
        self.budgets = [list allObjects];
        [self.tableView reloadData];
    }];

    [Budget budgetsWithTransaction:^(NSArray *budgets, NSError *error) {
        NSSet *oldBudgets = [NSSet setWithArray:self.budgets];
        NSMutableSet *newBudgets = [NSMutableSet setWithArray:budgets];
        [newBudgets unionSet:oldBudgets];

        self.budgets = [newBudgets allObjects];
        [self.tableView reloadData];
    }];

    [self setupTableView];

}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:YES];
}
#pragma mark - Table View Delegate Methods

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [self.tableView deselectRowAtIndexPath:indexPath animated:YES];
    Budget *budget = self.budgets[indexPath.row];
    TransactionsViewController *vc = [[TransactionsViewController alloc] initWithBudget:budget];

    [self.navigationController pushViewController:vc animated:YES];
}

#pragma mark - Table view methods

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.budgets.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    BudgetCell *cell = [tableView dequeueReusableCellWithIdentifier:@"BudgetCell"];
    cell.budget = self.budgets[indexPath.row];
    cell.rightUtilityButtons = [self rightButtons];
    cell.delegate = self;
    return cell;
}

- (NSArray *)rightButtons
{
    NSMutableArray *rightUtilityButtons = [NSMutableArray new];
    [rightUtilityButtons sw_addUtilityButtonWithColor:
     [UIColor colorWithRed:0.78f green:0.78f blue:0.8f alpha:1.0]
                                                title:@"Edit"];
    [rightUtilityButtons sw_addUtilityButtonWithColor:
     [UIColor colorWithRed:1.0f green:0.231f blue:0.188 alpha:1.0f]
                                                title:@"Delete"];
    return rightUtilityButtons;
}

#pragma mark - TabBarViewController

- (void)setupUI {
    [self setupBarItemWithImageNamed:@"budgets"];
}

- (void)setupTableView {
    self.tableView.dataSource = self;
    self.tableView.delegate = self;
    [self.tableView registerNib:[UINib nibWithNibName:@"BudgetCell" bundle:nil] forCellReuseIdentifier:@"BudgetCell"];
    self.tableView.estimatedRowHeight = 60;
    self.tableView.rowHeight = UITableViewAutomaticDimension;
}

#pragma mark - SWTableViewDelegate

- (void)swipeableTableViewCell:(SWTableViewCell *)cell didTriggerRightUtilityButtonWithIndex:(NSInteger)index {
    NSIndexPath *indexPath = [self.tableView indexPathForCell:cell];
    switch (index) {
        case 0:
        {
            BudgetFormViewController *vc = [[BudgetFormViewController alloc] initWithBudget:self.budgets[indexPath.row]];
            vc.delegator = self;
            [self.navigationController pushViewController:vc animated:YES];
            break;
        }
        case 1:
        {
            // Delete from Parse
            [self.budgets[indexPath.row] deleteBudget];

            // Delete from model
            NSMutableArray *budgets = [self.budgets mutableCopy];
            [budgets removeObjectAtIndex:indexPath.row];
            self.budgets = budgets;

            // Delete from tableView
            [self.tableView beginUpdates];
            [self.tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationAutomatic];
            [self.tableView endUpdates];
            break;
        }
        default:
            break;
    }
}

#pragma mark - BudgetFormActionDelegate

-(void)budgetCreated:(Budget*) budget {
    [self.tableView beginUpdates];

    NSMutableArray *budgets = [self.budgets mutableCopy];
    [budgets addObject:budget];
    self.budgets = budgets;

    NSIndexPath *indexPath = [NSIndexPath indexPathForRow:(budgets.count -1) inSection:0];

    [self.tableView insertRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationAutomatic];
    [self.tableView endUpdates];
}
-(void)budgetUpdated:(Budget*) budget {
    [self.tableView beginUpdates];

    NSUInteger index = [self.budgets indexOfObject:budget];
    NSIndexPath *indexPath = [NSIndexPath indexPathForRow:index inSection:0];

    [self.tableView reloadRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationAutomatic];
    [self.tableView endUpdates];
}

#pragma mark - NavBar Controller

- (void) setupNavBar {
    UIBarButtonItem *transactionButton = [[UIBarButtonItem alloc] initWithTitle:@"New Transaction" style:UIBarButtonItemStylePlain target:self action:@selector(onNewTransaction)];

    UIBarButtonItem *budgetButton = [[UIBarButtonItem alloc] initWithTitle:@"New Budget" style:UIBarButtonItemStylePlain target:self action:@selector(onNewBudget)];

    self.navigationItem.rightBarButtonItem = transactionButton;
    self.navigationItem.leftBarButtonItem = budgetButton;
}
- (void) onNewTransaction {
    [self.navigationController pushViewController:[[TransactionFormViewController alloc] init] animated:YES];
}

- (void) onNewBudget {
    BudgetFormViewController *vc = [[BudgetFormViewController alloc] init];
    vc.delegator = self;
    [self.navigationController pushViewController:vc animated:YES];
}

@end
