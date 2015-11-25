//
//  BudgetFormViewController.m
//  PerDiem
//
//  Created by Francisco Rojas Gallegos on 11/24/15.
//  Copyright © 2015 PerDiem. All rights reserved.
//

#import "BudgetFormViewController.h"
#import "XLForm.h"
#import "User.h"
#import "Budget.h"
#import "Transaction.h"

NSString *const kName = @"name";
NSString *const kBudgetAmount = @"amount";

@interface BudgetFormViewController ()

@property(strong, nonatomic) Budget *budget;

@end

@implementation BudgetFormViewController

-(id)init
{
    return [self setup:[Budget object]];
}

-(id) initWithBudget: (Budget*) budget {

    return [self setup: budget];
}


- (void)viewDidLoad {
    [super viewDidLoad];
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemSave target:self action:@selector(savePressed:)];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

#pragma mark - On Action
-(void)savePressed:(UIBarButtonItem * __unused)button
{
    NSArray * validationErrors = [self formValidationErrors];
    if (validationErrors.count > 0){
        [self showFormValidationError:[validationErrors firstObject]];
        return;
    }
    [self.tableView endEditing:YES];

    NSDictionary *values = [self formValues];
    User *user = [User currentUser];
    self.budget.organization = user.organization;
    self.budget.name = values[kName];
    self.budget.amount = values[kBudgetAmount];
    [self.budget saveInBackground];

    [self.navigationController popViewControllerAnimated:YES];
}

#pragma mark - Form Setup
-(id) setup: (Budget*) budget {
    XLFormDescriptor * formDescriptor = [XLFormDescriptor formDescriptorWithTitle:@"Budget"];
    XLFormSectionDescriptor * section;
    XLFormRowDescriptor * row;
    formDescriptor.assignFirstResponderOnShow = YES;

    self.budget = budget;

    // Basic Information - Section
    section = [XLFormSectionDescriptor formSectionWithTitle:@"Budget"];
    [formDescriptor addFormSection:section];

    // Summary
    row = [XLFormRowDescriptor formRowDescriptorWithTag:kName rowType:XLFormRowDescriptorTypeText title:@"Name"];
    row.required = YES;
    row.value = budget.name;
    [section addFormRow:row];

    // Number
    row = [XLFormRowDescriptor formRowDescriptorWithTag:kBudgetAmount rowType:XLFormRowDescriptorTypeDecimal title:@"Amount"];
    row.required = YES;
    row.value = budget.amount;
    [section addFormRow:row];

    return [super initWithForm:formDescriptor];
}

@end
