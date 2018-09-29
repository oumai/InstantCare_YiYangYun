//
//  KMChangeSingleDateVCViewController.m
//  InstantCare
//
//  Created by Frank He on 9/9/16.
//  Copyright © 2016 omg. All rights reserved.
//

#import "KMChangeSingleDateVC.h"
#import "UIImage+Extension.h"
#define kButtonHeight       60

@interface KMChangeSingleDateVC ()
/**
 *  当前日期
 */
@property (nonatomic, strong) UIDatePicker *datePicker;

/**
 *  确定按钮
 */
@property (nonatomic, strong) UIButton *okBtn;
/**
 *  取消按钮
 */
@property (nonatomic, strong) UIButton *cancelBtn;

@end

@implementation KMChangeSingleDateVC

- (void)viewDidLoad {
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
    
    // 开始日期
    NSDate * currentDate = [NSDate date];
    self.datePicker = [[UIDatePicker alloc] init];
    self.datePicker.datePickerMode = UIDatePickerModeDate;
    self.datePicker.date = self.chooseDate ? self.chooseDate : [NSDate date];
    [containerView addSubview:self.datePicker];
    [self.datePicker mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerY.equalTo(containerView);
        make.left.right.equalTo(containerView);
        make.height.equalTo(@150);
    }];
    self.datePicker.maximumDate = currentDate;
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
    WS(ws);
    [self dismissViewControllerAnimated:YES completion:^{
        if ([ws.delegate respondsToSelector:@selector(changeDateComplete:Index:)]) {
            [ws.delegate changeDateComplete:_datePicker.date Index:_currentIndex];
        }
    }];
}

- (void)backBarButtonDidClicked:(UIButton *)sender {
    [self dismissViewControllerAnimated:YES completion:nil];
}


@end
