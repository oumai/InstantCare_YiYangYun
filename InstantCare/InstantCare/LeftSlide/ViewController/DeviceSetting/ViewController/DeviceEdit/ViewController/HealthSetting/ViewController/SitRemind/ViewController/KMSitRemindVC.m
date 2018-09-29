//
//  KMSitRemindVC.m
//  InstantCare
//
//  Created by km on 16/9/12.
//  Copyright © 2016年 omg. All rights reserved.
//

#import "KMSitRemindVC.h"
#import "KMSleepMonitorModel.h"
#import "CustomIOSAlertView.h"
#import "KMCommonAlertView.h"
#import "KMNetAPI.h"
#import "MJExtension.h"

@interface KMSitRemindVC ()

/** 自动模式标题  */
@property (weak, nonatomic) IBOutlet UILabel *autoTitle;
/** 自动模式开关  */
@property (weak, nonatomic) IBOutlet UISwitch *autoSwitch;

/** 开始时间标题  */
@property (weak, nonatomic) IBOutlet UILabel *startTitle;
/** 结束时间标题  */
@property (weak, nonatomic) IBOutlet UILabel *endTitle;

/**  开始时间  */
@property (weak, nonatomic) IBOutlet UIDatePicker *startTiem;
/** 结束时间 */
@property (weak, nonatomic) IBOutlet UIDatePicker *endTiem;

/** 日期格式 */
@property (nonatomic, strong) NSDateFormatter *dateFormatter;

/** postModel */
@property (nonatomic, strong) KMSleepMonitorModel *postModel;

/** 提示框 */
@property (nonatomic, strong) CustomIOSAlertView * alert;

@end

@implementation KMSitRemindVC

/** 日期格式 */
- (NSDateFormatter *)dateFormatter
{
    if (_dateFormatter == nil) {
        
        _dateFormatter = [[NSDateFormatter alloc] init];
        _dateFormatter.dateFormat = @"HH:mm:ss";
    }
    return _dateFormatter;
}

/** postModel */
- (KMSleepMonitorModel *)postModel
{
    if (_postModel == nil) {
        
        _postModel = [[KMSleepMonitorModel alloc] init];
    }
    
    return _postModel;
}


// 视图加载完成
- (void)viewDidLoad {
    [super viewDidLoad];
    // 设置导航栏
    [self configNavigationBar];
    
    // 设置数据
    [self configView];
    
    self.autoTitle.text = kLoadStringWithKey(@"DeviceManager_HealthSetting_alert_remind_automatic");
    self.startTitle.text = kLoadStringWithKey(@"DeviceManager_HealthSetting_time_start");
    self.endTitle.text = kLoadStringWithKey(@"DeviceManager_HealthSetting_time_end");
}

// 设置数据
- (void)configView
{
    self.autoSwitch.on = self.model.status;
    
    NSDate * start = [self.dateFormatter dateFromString:self.model.starttime];
    NSDate * end  =  [self.dateFormatter dateFromString:self.model.endtime];
    
    if (start != nil) {
        
        [self.startTiem setDate:start];
    }
    if (end != nil) {
        
        [self.endTiem setDate:end];
    }
    NSLog(@"start:%@ end:%@",start,end);
    
    self.postModel.starttime = self.model.starttime;
    self.postModel.endtime = self.model.endtime;
    self.postModel.status = self.model.status;
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
                      action:@selector(backLastView)
            forControlEvents:UIControlEventTouchUpInside];
    
    // right 右
    UIButton *rightButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [rightButton setTitle:kLoadStringWithKey(@"Personal_info_save") forState:UIControlStateNormal];
    [rightButton setTitleColor:[UIColor grayColor] forState:UIControlStateHighlighted];
    rightButton.frame = CGRectMake(0, 0, 60, 30);
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:rightButton];
    [rightButton addTarget:self
                    action:@selector(saveUserOperation)
          forControlEvents:UIControlEventTouchUpInside];
}

/**
 *   返回上一级界面
 */
- (void)backLastView
{
    [self.navigationController popViewControllerAnimated:YES];
}
/**
 *   保存数据
 */
- (void)saveUserOperation
{
    
    // 检查数据
    if (![self checkChangeData]) {
        
        return;
    }
    
    // 创建请求连接
    NSString * URL = [NSString stringWithFormat:@"deviceManager/sit/%@/%@",member.loginAccount,self.imei];
    // 开始进行网络请求
    [SVProgressHUD show];
    [[KMNetAPI manager] commonPOSTRequestWithURL:URL jsonBody:[_postModel mj_JSONString] Block:^(int code, NSString *res)
     {
         KMNetworkResModel *resModel = [KMNetworkResModel mj_objectWithKeyValues:res];
         if (code == 0 && resModel.errorCode <= kNetReqSuccess)
         {
             dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(3 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                 [SVProgressHUD dismiss];
                 [self.navigationController popViewControllerAnimated:YES];
             });
             
         } else
         {
             [SVProgressHUD showErrorWithStatus:kNetReqFailWithCode(resModel.errorCode)];
         }
     }];
    
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

/**
 *   检查保存信息
 */
- (BOOL)checkChangeData
{
    NSInteger second = [self.endTiem.date timeIntervalSinceDate:self.startTiem.date];
    if (second < 0) {
        
        // 显示提示框
        [self customAlertViewShowWithMessage:kLoadStringWithKey(@"DeviceManager_HealthSetting_alert_time") withStatus:NO];
        return NO;
    }
    
    return YES;
}

/**
 *   自动模式按钮事件监听
 */
- (IBAction)autoModeSwitchValueChanged:(UISwitch *)sender
{
    self.postModel.status = self.autoSwitch.isOn?1:0;
}

- (IBAction)startTiem:(UIDatePicker *)sender
{
    self.postModel.starttime = [self.dateFormatter stringFromDate:sender.date];
}

- (IBAction)endTime:(UIDatePicker *)sender
{
    self.postModel.endtime = [self.dateFormatter stringFromDate:sender.date];
}

@end
