//
//  KMCheckHeartRateVC.m
//  Temp
//
//  Created by km on 16/8/11.
//  Copyright © 2016年 km. All rights reserved.
//

#import "KMStepSettingVC.h"
#import "KMCheckHeartRateModel.h"
#import "CustomIOSAlertView.h"
#import "KMCommonAlertView.h"
#import "KMNetAPI.h"
#import "MJExtension.h"

@interface KMStepSettingVC ()

/** 时间间隔 */
@property (weak, nonatomic) IBOutlet UITextField *timeInterval;

/** 开始时间 */
@property (weak, nonatomic) IBOutlet UIDatePicker *startPicker;

/** 结束时间 */
@property (weak, nonatomic) IBOutlet UIDatePicker *endPicker;

/** 开始Label */
@property (weak, nonatomic) IBOutlet UILabel *startLabel;

/** 结束Label */
@property (weak, nonatomic) IBOutlet UILabel *endLabel;

/** 分钟Label */
@property (weak, nonatomic) IBOutlet UILabel *minLabel;

/** 间隔Label */
@property (weak, nonatomic) IBOutlet UILabel *intervalLabel;

/** post模型 */
@property (nonatomic, strong) KMCheckHeartRateModel *postModel;

/** 提示框 */
@property (nonatomic, strong) CustomIOSAlertView * alert;

@end

@implementation KMStepSettingVC

//  postModel
- (KMCheckHeartRateModel *)postModel
{
    if (_postModel == nil) {
        
        _postModel = [[KMCheckHeartRateModel alloc] init];
    }
    return _postModel;
}

// 视图加载完成
- (void)viewDidLoad {
    [super viewDidLoad];
    
    //  设置导航栏
    [self configNavigationBar];
    
    // 设置显示数据
    [self configViewData];
    
    // 添加监听限制输入信息
    [self.timeInterval addTarget:self action:@selector(textFieldDidChange:) forControlEvents:UIControlEventEditingChanged];
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

#pragma mark - 设置显示数据
- (void)configViewData
{
    NSDateFormatter * dateFormat = [[NSDateFormatter alloc] init];
    dateFormat.dateFormat = @"HH:mm:ss";
    
    NSDate * start = [dateFormat dateFromString:self.model.starttime];
    NSDate * end   = [dateFormat dateFromString:self.model.endtime];
    
    if (start != nil) {
        self.startPicker.date = start;
        
    }
    if (end != nil) {
        
        self.endPicker.date   =  end;
    }
    self.timeInterval.text = [NSString stringWithFormat:@"%zd",self.model.span];
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
    // 结束编辑
    [self.view endEditing:YES];
    
    // 检查数据
    if (![self checkChangeData]) {
        
        return;
    }
    
    //1.保存用户数据
    [self saveUserData];
    
    
    // 创建请求连接
    NSString * URL = [NSString stringWithFormat:@"deviceManager/step/%@/%@",member.loginAccount,self.imei];
    
    // 开始进行网络请求
    [SVProgressHUD show];
    [[KMNetAPI manager] commonPOSTRequestWithURL:URL jsonBody:[_postModel mj_JSONString] Block:^(int code, NSString *res)
     {
         KMNetworkResModel *resModel = [KMNetworkResModel mj_objectWithKeyValues:res];
         if (code == 0 && resModel.errorCode <= kNetReqSuccess)
         {
             dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(3 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^
                            {
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
 *   保存数据
 */
- (void)saveUserData
{
    NSDateFormatter * dateFormat = [[NSDateFormatter alloc] init];
    dateFormat.dateFormat = @"HH:mm:ss";
    
    NSString * start = [dateFormat stringFromDate:self.startPicker.date];
    NSString * end   = [dateFormat stringFromDate:self.endPicker.date];
    
    self.postModel.starttime = start;
    self.postModel.endtime   = end;
    self.postModel.span = [self.timeInterval.text integerValue];
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
    if ([self.timeInterval.text containsString:@"."]) {
        
        // 显示提示框
        [self customAlertViewShowWithMessage:kLoadStringWithKey(@"Remind_TimeIntervalIntChecking") withStatus:NO];
        return NO;
    }
    
    NSInteger span = [self.timeInterval.text integerValue];
    if (span < 5) {
        
        // 显示提示框
        [self customAlertViewShowWithMessage:kLoadStringWithKey(@"Remind_TimeIntervalChecking") withStatus:NO];
        return NO;
    }
    
    NSInteger second = [self.endPicker.date timeIntervalSinceDate:self.startPicker.date];
    if (second < 0) {
        
        // 显示提示框
        [self customAlertViewShowWithMessage:kLoadStringWithKey(@"Remind_TimeChecking") withStatus:NO];
        return NO;
    }
    
    return YES;
}

/**
 *   编辑时间间隔
 */
- (IBAction)editTimeinterval:(UITapGestureRecognizer *)sender
{
    [self.timeInterval becomeFirstResponder];
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







