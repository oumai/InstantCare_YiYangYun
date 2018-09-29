//
//  KMChangeDateVC.m
//  InstantCare
//
//  Created by bruce-zhu on 15/12/15.
//  Copyright © 2015年 omg. All rights reserved.
//

#import "KMChangeDateVC.h"
#import "UIImage+Extension.h"
#define kButtonHeight       60

@interface KMChangeDateVC ()
/**
 *  开始日期
 */
@property (nonatomic, strong) UIDatePicker *startDatePicker;
/**
 *  结束日期
 */
@property (nonatomic, strong) UIDatePicker *endDatePicker;
/**
 *  确定按钮
 */
@property (nonatomic, strong) UIButton *okBtn;
/**
 *  取消按钮
 */
@property (nonatomic, strong) UIButton *cancelBtn;

@end

@implementation KMChangeDateVC

- (void)viewDidLoad
{
    [super viewDidLoad];

    [self configNavBar];
    [self configView];
}

- (void)configNavBar {
    UIButton *leftNavButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [leftNavButton setBackgroundImage:[UIImage imageNamed:@"return_normal"]
                             forState:UIControlStateNormal];
    [leftNavButton addTarget:self
                      action:@selector(backBarButtonDidClicked:)
            forControlEvents:UIControlEventTouchUpInside];
    leftNavButton.frame = CGRectMake(0, 0, 30, 30);
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:leftNavButton];
    
    self.navigationItem.title = kLoadStringWithKey(@"HealthRecord_VC_change_date");
}

- (void)configView {
    self.view.backgroundColor = [UIColor whiteColor];

    UIView *containerView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, SCREEN_HEIGHT*0.7)];
    
    UILabel *startLabel = [[UILabel alloc] init];
    startLabel.text = kLoadStringWithKey(@"HealthRecord_VC_change_date_start");
    startLabel.font = [UIFont systemFontOfSize:20];
    startLabel.textAlignment = NSTextAlignmentCenter;
    [containerView addSubview:startLabel];
    [startLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.right.top.equalTo(containerView);
    }];
    
    // 开始日期
    NSDate * currentDate = [NSDate date];
    self.startDatePicker = [[UIDatePicker alloc] init];
    self.startDatePicker.datePickerMode = UIDatePickerModeDate;
    self.startDatePicker.date = self.startDate ? self.startDate : [NSDate date];
    [containerView addSubview:self.startDatePicker];
    [self.startDatePicker mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(startLabel.mas_bottom).offset(10);
        make.left.right.equalTo(containerView);
        make.height.equalTo(@150);
    }];
    self.startDatePicker.maximumDate = [NSDate dateWithTimeInterval:-1*24*60*60 sinceDate:currentDate];
    // 结束日期
    self.endDatePicker = [[UIDatePicker alloc] init];
    self.endDatePicker.datePickerMode = UIDatePickerModeDate;
    self.endDatePicker.date = self.endDate ? self.endDate : [NSDate date];
    [containerView addSubview:self.endDatePicker];
    [self.endDatePicker mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.bottom.right.equalTo(containerView);
        make.height.equalTo(@150);
    }];
    self.endDatePicker.maximumDate = currentDate;
    
    UILabel *endLabel = [[UILabel alloc] init];
    endLabel.text = kLoadStringWithKey(@"HealthRecord_VC_change_date_end");
    endLabel.font = [UIFont systemFontOfSize:20];
    endLabel.textAlignment = NSTextAlignmentCenter;
    [containerView addSubview:endLabel];
    [endLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.right.equalTo(containerView);
        make.bottom.equalTo(_endDatePicker.mas_top).offset(-10);
    }];

    containerView.center = self.view.center;
    [self.view addSubview:containerView];

    UIButton *okBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    okBtn.layer.cornerRadius = 20;
    okBtn.clipsToBounds = YES;
    [okBtn setTitle:kLoadStringWithKey(@"VC_login_OK") forState:UIControlStateNormal];
    [okBtn setBackgroundImage:[UIImage imageWithColor:kMainColor] forState:UIControlStateNormal];
    [okBtn addTarget:self action:@selector(btnDidClicked:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:okBtn];
    [okBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.view).offset(30);
        make.right.equalTo(self.view).offset(-30);
        make.height.equalTo(@40);
        make.bottom.equalTo(self.view).offset(-40);
    }];
}

- (void)btnDidClicked:(UIButton *)sender
{
    if (self.startDatePicker.date.timeIntervalSince1970 > self.endDatePicker.date.timeIntervalSince1970) {
        [SVProgressHUD showErrorWithStatus:kLoadStringWithKey(@"HealthRecord_VC_change_date_error")];
        return;
    }
    
    WS(ws);
    [self dismissViewControllerAnimated:YES completion:^{
        if ([ws.delegate respondsToSelector:@selector(changeDateComplete:endDate:Index:)]) {
            [ws.delegate changeDateComplete:_startDatePicker.date endDate:_endDatePicker.date Index:_currentIndex];
        }
    }];
}

- (void)backBarButtonDidClicked:(UIButton *)sender {
    [self dismissViewControllerAnimated:YES completion:nil];
}

@end
