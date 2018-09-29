//
//  KMSettingRangeVC.m
//  Temp
//
//  Created by km on 16/8/11.
//  Copyright © 2016年 km. All rights reserved.
//

#import "KMBloodOxygenRangeVC.h"
#import "KMBloodOxygenModel.h"
#import "CustomIOSAlertView.h"
#import "KMCommonAlertView.h"
#import "MJExtension.h"
#import "KMNetAPI.h"

@interface  KMBloodOxygenRangeVC()

/** 上标题  */
@property (weak, nonatomic) IBOutlet UILabel *upperTitle;
/** 上数值  */
@property (weak, nonatomic) IBOutlet UILabel *upperValue;
/** 上滑块  */
@property (weak, nonatomic) IBOutlet UISlider *upperSlider;


/** 下标题  */
@property (weak, nonatomic) IBOutlet UILabel *lowerTitle;
/** 下数值  */
@property (weak, nonatomic) IBOutlet UILabel *lowerValue;
/** 下滑块  */
@property (weak, nonatomic) IBOutlet UISlider *lowerSlider;

/** post模型 */
@property (nonatomic, strong) KMBloodOxygenModel *postModel;

/** 提示框 */
@property (nonatomic, strong) CustomIOSAlertView * alert;

@end

@implementation KMBloodOxygenRangeVC

- (void)viewDidLoad {
    [super viewDidLoad];
    //  设置导航栏
    [self configNavigationBar];
    
    // 设置显示数据
    [self configViewData];
    
    self.upperTitle.text = kLoadStringWithKey(@"DeviceManager_HealthSetting_limit_upper");
    self.lowerTitle.text = kLoadStringWithKey(@"DeviceManager_HealthSetting_limit_lower");
}

#pragma mark - 设置显示数据
- (void)configViewData
{
    self.upperSlider.value = _model.boH;
    self.lowerSlider.value = _model.boL;
    self.upperValue.text = [NSString stringWithFormat:@"%zd%%",_model.boH];
    self.lowerValue.text = [NSString stringWithFormat:@"%zd%%",_model.boL];
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
    [rightButton setTitle:kLoadStringWithKey(@"Common_save") forState:UIControlStateNormal];
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
        
        // 显示提示框
        [self customAlertViewShowWithMessage:kLoadStringWithKey(@"DeviceManager_HealthSetting_alert_limit") withStatus:NO];
        return;
    }
    
    // 保存数据
    self.postModel = self.model;
    self.postModel.boL  = self.lowerSlider.value;
    self.postModel.boH  = self.upperSlider.value;
    
    // 创建请求连接
    NSString * URL = [NSString stringWithFormat:@"healthRange/bo/%@/%@",member.loginAccount,self.imei];
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
    NSInteger high = self.upperSlider.value;
    NSInteger low  = self.lowerSlider.value+1;
    
    return high > low;
}


/**
 *  上滑块滑动监听
 */
- (IBAction)upperSliderValueChanged:(UISlider *)sender
{
    NSInteger boH = sender.value;
     self.upperValue.text = [NSString stringWithFormat:@"%zd%%",boH];
}

/**
 *  下滑块滑动监听
 */
- (IBAction)lowerSliderValueChanged:(UISlider *)sender
{
    NSInteger boL = sender.value;
    self.lowerValue.text = [NSString stringWithFormat:@"%zd%%",boL];
}


@end



















