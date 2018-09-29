//
//  KMGeofenceSettingVC.m
//  InstantCare
//
//  Created by bruce zhu on 16/8/16.
//  Copyright © 2016年 omg. All rights reserved.
//

#import "KMGeofenceSettingVC.h"
#import "KMGeofenceModel.h"
#import "CustomIOSAlertView.h"
#import "KMCommonAlertView.h"
#import "KMNetAPI.h"
#import "MJExtension.h"

@interface KMGeofenceSettingVC ()

@property (nonatomic, strong) KMGeofenceModel *geofenceModel;

@property (weak, nonatomic) IBOutlet UITextField *intervalTextField;
@property (weak, nonatomic) IBOutlet UIDatePicker *startDatePicker;
@property (weak, nonatomic) IBOutlet UIDatePicker *endDatePicker;

/** 开始Label */
@property (weak, nonatomic) IBOutlet UILabel *startLabel;

/** 结束Label */
@property (weak, nonatomic) IBOutlet UILabel *endLabel;

/** 分钟Label */
@property (weak, nonatomic) IBOutlet UILabel *minLabel;

/** 间隔Label */
@property (weak, nonatomic) IBOutlet UILabel *intervalLabel;

/** 提示框 */
@property (nonatomic, strong) CustomIOSAlertView * alert;

@end

@implementation KMGeofenceSettingVC

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self configNavigationBar];
    [SVProgressHUD show];
    [self updateGeofenceFromServer];
    // 添加监听限制输入信息
    [self.intervalTextField addTarget:self action:@selector(textFieldDidChange:) forControlEvents:UIControlEventEditingChanged];
    
    self.intervalLabel.text = kLoadStringWithKey(@"DeviceManager_HealthSetting_time_interval");
    self.startLabel.text = kLoadStringWithKey(@"DeviceManager_HealthSetting_time_start");
    self.endLabel.text = kLoadStringWithKey(@"DeviceManager_HealthSetting_time_end");
    self.minLabel.text = kLoadStringWithKey(@"DeviceManager_HealthSetting_time_minute");
}

/**
 *   限制文本输入
 */
- (void)textFieldDidChange:(UITextField *)textField
{
    if (textField.text.length > 5) {
        
        textField.text = [textField.text substringToIndex:5];
    }
    
}

#pragma mark - 设置导航栏
- (void)configNavigationBar
{
    // left 左
    UIButton *leftNavButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [leftNavButton setBackgroundImage:[UIImage imageNamed:@"return_normal"]
                             forState:UIControlStateNormal];
    leftNavButton.frame = CGRectMake(0, 0, 30, 30);
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:leftNavButton];
    [leftNavButton addTarget:self
                      action:@selector(backLastView:)
            forControlEvents:UIControlEventTouchUpInside];
    
    // right 右
    UIButton *rightButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [rightButton setTitle:kLoadStringWithKey(@"Common_save") forState:UIControlStateNormal];
    [rightButton setTitleColor:[UIColor grayColor] forState:UIControlStateHighlighted];
    rightButton.frame = CGRectMake(0, 0, 60, 30);
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:rightButton];
    [rightButton addTarget:self
                    action:@selector(saveUserOperation:)
          forControlEvents:UIControlEventTouchUpInside];
    self.title = kLoadStringWithKey(@"Geofence_VC_time");
}

/// 获取电子围栏信息
- (void)updateGeofenceFromServer {
    
    WS(ws);
    NSString *reqURL = [NSString stringWithFormat:@"deviceSettingGfence/%@/%@", member.loginAccount, self.imei];
    [[KMNetAPI manager] commonGetRequestWithURL:reqURL Block:^(int code, NSString *res) {
        KMNetworkResModel *resModel = [KMNetworkResModel mj_objectWithKeyValues:res];
        if (code == 0 && resModel.errorCode <= kNetReqSuccess) {
            [SVProgressHUD dismiss];
            _geofenceModel = [KMGeofenceModel mj_objectWithKeyValues:resModel.content];
            [ws updateGeofenceSetting];
        } else {
            [SVProgressHUD showErrorWithStatus:resModel.msg.length > 0 ? resModel.msg : kNetError];
        }
    }];
}

- (void)updateGeofenceSetting {
    if (_geofenceModel) {
        self.intervalTextField.text = [NSString stringWithFormat:@"%@", @(_geofenceModel.interval)];
    }
    
    if (_geofenceModel.starttime && _geofenceModel.endtime) {
        NSDateFormatter * dateFormatter = [[NSDateFormatter alloc] init];
        dateFormatter.dateFormat = @"HH:mm:ss";
        NSDate *startDate = [dateFormatter dateFromString:_geofenceModel.starttime];
        self.startDatePicker.date = startDate;
        
        dateFormatter.dateFormat = @"HH:mm:ss";
        NSDate *endDate = [dateFormatter dateFromString:_geofenceModel.endtime];
        self.endDatePicker.date = endDate;
    }
}

- (void)backLastView:(UIButton *)sender {
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)saveUserOperation:(UIButton *)sender
{
    // 结束编辑
    [self.view endEditing:YES];
    
    // 检查数据
    if (![self checkChangeData]) {
        
        return;
    }
    
    //1.保存用户数据
    [self saveUserData];

    [SVProgressHUD show];
    WS(ws);
    NSString *reqURL = [NSString stringWithFormat:@"deviceSettingGfence/%@/%@", member.loginAccount, self.imei];
    [[KMNetAPI manager] commonPOSTRequestWithURL:reqURL jsonBody:[_geofenceModel mj_JSONString] Block:^(int code, NSString *res) {
        KMNetworkResModel *resModel = [KMNetworkResModel mj_objectWithKeyValues:res];
        if (code == 0 && resModel.errorCode <= kNetReqSuccess) {
            [SVProgressHUD showSuccessWithStatus:kLoadStringWithKey(@"Common_save_success")];
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.6 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                [ws.navigationController popViewControllerAnimated:YES];
            });
        } else {
            [SVProgressHUD showErrorWithStatus:resModel.msg.length > 0 ? resModel.msg : kNetError];
        }
    }];
}

/**
 *   保存数据
 */
- (void)saveUserData
{
    if (_geofenceModel == nil) {
        _geofenceModel = [KMGeofenceModel new];
    }
    _geofenceModel.interval = [self.intervalTextField.text intValue];
    
    NSDateFormatter * dateFormatter = [[NSDateFormatter alloc] init];
    dateFormatter.dateFormat = @"HH:mm:ss";
    
    NSString *startTime = [dateFormatter stringFromDate:self.startDatePicker.date];
    _geofenceModel.starttime = startTime;
    
    NSString *endTime = [dateFormatter stringFromDate:self.endDatePicker.date];
    _geofenceModel.endtime = endTime;
}

/**
 *   检查保存信息
 */
- (BOOL)checkChangeData
{
    if ([self.intervalTextField.text containsString:@"."]) {
    
    // 显示提示框
    [self customAlertViewShowWithMessage:kLoadStringWithKey(@"Remind_TimeIntervalIntChecking") withStatus:NO];
    return NO;
    }
    
    NSInteger span = [self.intervalTextField.text integerValue];
    if (span < 5) {
        
        // 显示提示框
        [self customAlertViewShowWithMessage:kLoadStringWithKey(@"Remind_TimeIntervalChecking") withStatus:NO];
        return NO;
    }
    
    NSInteger second = [self.endDatePicker.date timeIntervalSinceDate:self.startDatePicker.date];
    if (second < 0) {
        
        // 显示提示框
        [self customAlertViewShowWithMessage:kLoadStringWithKey(@"Remind_TimeChecking") withStatus:NO];
        return NO;
    }
    
    return YES;
}

/**
 *  显示用户操作提示框
 */
#pragma mark --- 信息提示框显示
//显示信息提示框
-(void)customAlertViewShowWithMessage:(NSString *)message withStatus:(BOOL)status
{
    // 提示框
    self.alert = [[CustomIOSAlertView alloc] init];
    self.alert.buttonTitles = nil;
    [self.alert setUseMotionEffects:NO];
    
    UIView * alertView = [[UIView alloc] initWithFrame:CGRectMake(0,0,SCREEN_WIDTH*0.9,220)];
    alertView.backgroundColor = [UIColor whiteColor];
    self.alert.containerView = alertView;
    
    // 图标
    UIImageView * fail = [[UIImageView alloc] init];
    [alertView addSubview:fail];
    [fail mas_makeConstraints:^(MASConstraintMaker *make)
     {
         make.centerX.equalTo(alertView);
         make.width.height.mas_equalTo(70);
         make.bottom.equalTo(alertView.mas_centerY);
     }];
    if (!status)
    {
        fail.image = [UIImage imageNamed:@"pop_icon_fail"];
    }else
    {
        fail.image = [UIImage imageNamed:@"pop_icon_success"];
    }
    //信息
    UILabel * massageLabel = [[UILabel alloc] init];
    [alertView addSubview:massageLabel];
    [massageLabel mas_makeConstraints:^(MASConstraintMaker *make)
     {
         make.left.mas_equalTo(20);
         make.right.mas_equalTo(-20);
         make.height.mas_equalTo(80);
         make.top.equalTo(alertView.mas_centerY);
     }];
    massageLabel.textAlignment = NSTextAlignmentCenter;
    massageLabel.text = message;
    massageLabel.numberOfLines = 0;
    [self.alert show];
}

/** 开始时间  */
- (IBAction)startTime:(id)sender {
    [self.view endEditing:YES];
}
/** 结束时间  */
- (IBAction)endTime:(id)sender {
    [self.view endEditing:YES];
}
@end
