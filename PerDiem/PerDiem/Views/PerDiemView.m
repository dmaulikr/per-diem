//
//  PerDiemView.m
//  PerDiem
//
//  Created by Florent Bonomo on 12/2/15.
//  Copyright © 2015 PerDiem. All rights reserved.
//

#import "PerDiemView.h"
#import "UIColor+PerDiem.h"
#import "DateTools.h"

@interface PerDiemView ()
@property (strong, nonatomic) IBOutletCollection(UIView) NSArray *cellUIViews;

@property (weak, nonatomic) IBOutlet UIView *progressBarBackgroundView;
@property (weak, nonatomic) IBOutlet UIView *progressBarView;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *widthConstraint;
@property (weak, nonatomic) IBOutlet UILabel *dayLabel;
@property (weak, nonatomic) IBOutlet UILabel *spentLabel;

@end

@implementation PerDiemView

- (instancetype)initWithCoder:(NSCoder *)coder {
    self = [super initWithCoder:coder];
    if (self) {
        [self initSubview];
    }
    return self;
}

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        [self initSubview];
    }
    return self;
}

- (void) initSubview {
    UINib *nib = [UINib nibWithNibName:@"PerDiemView" bundle:nil];
    [nib instantiateWithOwner:self options:nil];
    self.view.frame = [self bounds];
    self.view.backgroundColor = [UIColor backgroundColor];
    self.widthConstraint.constant = 0;
    self.hasAnimated = NO;
    [self addSubview:self.view];
}

- (void)setPerDiem:(PerDiem *)perDiem animated:(BOOL)animated {
    self.perDiem = perDiem;
    [self updateUIWithAnimation:animated];
}

- (void)updateUI {
    [self updateUIWithAnimation:NO];
}


- (void)updateUIWithAnimation:(BOOL)animation {
    NSNumberFormatter *amountFormatter = [[NSNumberFormatter alloc] init];
    [amountFormatter setNumberStyle: NSNumberFormatterCurrencyStyle];

    self.dayLabel.text = [[self.perDiem.date formattedDateWithFormat:@"ccc d"] uppercaseString];
    
    CGFloat budget = [self.perDiem.budget floatValue];
    CGFloat spent = [self.perDiem.spent floatValue];

    NSInteger percentage = 0;
    if (budget <= 0) {
        budget = 0;
        if (spent > 0) {
            percentage = 100;
        } else {
            percentage = 0;
        }
    } else {
        percentage = spent * 100 / budget;
    }

    NSString *budgetAmountString = [amountFormatter stringFromNumber:@(budget)];
    NSString *spentAmountString = [amountFormatter stringFromNumber:@(spent)];
    self.spentLabel.text = [NSString stringWithFormat:@"Spent %@ of %@", spentAmountString, budgetAmountString];
    
    if ([self.perDiem.date isLaterThan:[NSDate date]]) {
        for (UIView *view in self.cellUIViews) {
            view.alpha = .6;
        }
    } else {
        for (UIView *view in self.cellUIViews) {
            view.alpha = 1;
        }
    }
    self.progressBarView.backgroundColor = [UIColor colorWithProgress:percentage alpha:1];

    self.progressBarBackgroundView.backgroundColor = [UIColor colorWithProgress:percentage alpha:.4];

    self.widthConstraint.constant = percentage * (self.frame.size.width / 100);
    if (animation) {
        [self animateProgressBar:percentage];
    }
    [self.progressBarBackgroundView.layer setCornerRadius:5.0f];
    [self.progressBarBackgroundView.layer setMasksToBounds:YES];
    
}

- (void)animateProgressBar:(NSInteger)percentage {
    if (percentage <= 0) {
        [self.progressBarBackgroundView layoutIfNeeded];
    } else if (!self.hasAnimated) {
        [UIView animateWithDuration:.5 delay:0
             usingSpringWithDamping:1
              initialSpringVelocity:0
                            options:UIViewAnimationOptionCurveEaseInOut
                         animations:^{
                             [self.progressBarBackgroundView layoutIfNeeded];
                         } completion:nil];
        self.hasAnimated = YES;
    }
}
@end
