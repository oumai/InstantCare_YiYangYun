//
//  KMAuthCodeEditVC.m
//  InstantCare
//
//  Created by km on 16/6/15.
//  Copyright © 2016年 omg. All rights reserved.
//

#import "KMAuthCodeEditVC.h"
#import "KMAuthCodeEditView.h"
#import "CustomIOSAlertView.h"
#import "KMNetAPI.h"
#import "MJExtension.h"
@interface KMAuthCodeEditVC ()<UITextFieldDelegate>

@property(nonatomic,strong)KMAuthCodeEditView * rootView;
@property(nonatomic,strong)CustomIOSAlertView * messageView;

@end

@implementation KMAuthCodeEditVC

- (void)viewDidLoad
{
    [super viewDidLoad];
    //1.设置背景颜色
    self.view.backgroundColor = [UIColor whiteColor];
    
    [self configNavigation];
    [self configSubViews];
}

#pragma mark - 配置导航栏
-(void)configNavigation
{
    self.title = kLoadStringWithKey(@"DeviceEdit_VC_setting_title_device_auth");
    
    UIButton *leftButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [leftButton setBackgroundImage:[UIImage imageNamed:@"return_normal"] forState:UIControlStateNormal];
    [leftButton setBackgroundImage:[UIImage imageNamed:@"return_sel"] forState:UIControlStateSelected];
    leftButton.frame = CGRectMake(0, 0,30, 30);
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:leftButton];
    
    [leftButton addTarget:self action:@selector(leftBarButtonDidClickedAction:) forControlEvents:UIControlEventTouchDown];
    
    
    
}
// leftItem 按钮点击时间
-(void)leftBarButtonDidClickedAction:(UIButton *)sender
{
    [self.navigationController popViewControllerAnimated:YES];
}




#pragma mark - 配置子视图
-(void)configSubViews
{
    
    [self.view addSubview:self.rootView];
    self.rootView.oldAuthCode.contentTextField.delegate = self;
    self.rootView.nowAuthCode.contentTextField.delegate = self;
    [self.rootView mas_makeConstraints:^(MASConstraintMaker *make)
     {
         make.edges.equalTo(self.view).insets(UIEdgeInsetsMake(64,0,0,0));
    }];
    
    //设置子视图事件处理
    [self.rootView.okButton addTarget:self action:@selector(okButtonDidClickedAction:) forControlEvents:UIControlEventTouchDown];
    [self.rootView.resetButton addTarget:self action:@selector(resetButtonDidClicedAction:) forControlEvents:UIControlEventTouchDown];
}

// 确定选择
-(void)okButtonDidClickedAction:(UIButton *)sender
{
    BOOL result  = [self checkUserInputContent];
    if (result)
    {
        [self updateUserAuthCode];
    }
}

// 重置选择
-(void)resetButtonDidClicedAction:(UIButton *)sender
{
    [self retUserAuthCode];
}


#pragma mark - 更新用户鉴定码
-(void)updateUserAuthCode
{
    // 开始更改操作
    [SVProgressHUD showWithStatus:kLoadStringWithKey(@"Common_network_request_now")];
    NSString * oldVerity = self.rootView.oldAuthCode.contentTextField.text;
    NSString * newVerity = self.rootView.nowAuthCode.contentTextField.text;
    NSString * request = [NSString stringWithFormat:@"update/verity/%@/%@/%@",self.imei,oldVerity,newVerity];
    [[KMNetAPI manager] commonGetRequestWithURL:request Block:^(int code, NSString *res)
    {
        [SVProgressHUD dismiss];
        KMNetworkResModel * resModel = [KMNetworkResModel mj_objectWithKeyValues:res];
        if (code == 0 && resModel.errorCode <= kNetReqSuccess)
        {
            [self customAlertViewShowWithMessage:kLoadStringWithKey(@"ChangePassword_DecetionError_success")
                                       withImage:@"pop_icon_success"];
            [self customAlertViewClose];
        }else
        {
            [self customAlertViewShowWithMessage:kNetReqFailWithCode(resModel.errorCode)
                                       withImage:@"pop_icon_fail"];
        }
    }];
}


#pragma mark - 重置用户鉴定码
-(void)retUserAuthCode
{
    // 开始更改操作
    [SVProgressHUD showWithStatus:kLoadStringWithKey(@"Common_network_request_now")];
    NSString * request = [NSString stringWithFormat:@"default/verity/%@/%@",self.imei,member.loginAccount];
    [[KMNetAPI manager] commonGetRequestWithURL:request Block:^(int code, NSString *res)
     {
         [SVProgressHUD dismiss];
         KMNetworkResModel * resModel = [KMNetworkResModel mj_objectWithKeyValues:res];
         if (code == 0 && resModel.errorCode <= kNetReqSuccess)
         {
             [self customAlertViewShowWithMessage:kLoadStringWithKey(@"DeviceEdit_VC_setting_title_device_reset_success") withImage:@"pop_icon_success"];
             dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.8 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                                [self.messageView close];
            });
         }else
         {
             [self customAlertViewShowWithMessage:kNetReqFailWithCode(resModel.errorCode)
                                        withImage:@"pop_icon_fail"];
         }
     }];
}


#pragma mark - 检测输入内容
-(BOOL)checkUserInputContent
{
    NSString * oldVerfity = self.rootView.oldAuthCode.contentTextField.text;
    NSString * newVerfity = self.rootView.nowAuthCode.contentTextField.text;
    if (oldVerfity.length == 0)
    {
        [self customAlertViewShowWithMessage:kLoadStringWithKey(@"DeviceEdit_VC_setting_title_device_auth_oldCode") withImage:@"pop_icon_fail"];
        return NO;
    }
    if (newVerfity.length == 0)
    {
        [self customAlertViewShowWithMessage:kLoadStringWithKey(@"DeviceEdit_VC_setting_title_device_auth_newCode") withImage:@"pop_icon_fail"];
        return NO;
    }
    return YES;
}
#pragma mark - UITextFieldDelegate
-(BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string
{
    if (string.length == 0)  return YES;
    if (textField.text.length >=15)
    {
                return NO;
    }
    return YES;
}
-(void)textFieldDidBeginEditing:(UITextField *)textField
{
    UIView * view = textField.superview;
    if ([view isKindOfClass:[KMCustomTextField class]])
    {
        KMCustomTextField* newView = (KMCustomTextField *)view;
        newView.grayLine.backgroundColor = [UIColor orangeColor];
    }
}
-(void)textFieldDidEndEditing:(UITextField *)textField
{
    
    UIView * view = textField.superview;
    if ([view isKindOfClass:[KMCustomTextField class]])
    {
        KMCustomTextField* newView = (KMCustomTextField *)view;
        newView.grayLine.backgroundColor = [UIColor colorWithRed:0 green:0 blue:0 alpha:0.05];
    }
    
}
#pragma mark - 信息提示框显示
//显示信息提示框
-(void)customAlertViewShowWithMessage:(NSString *)message withImage:(NSString *)imageString
{
    // 提示框
    self.messageView = [[CustomIOSAlertView alloc] init];
    self.messageView.buttonTitles = nil;
    [self.messageView setUseMotionEffects:NO];
    
    UIView * alertView = [[UIView alloc] initWithFrame:CGRectMake(0,0,SCREEN_WIDTH*0.9,180)];
    alertView.backgroundColor = [UIColor whiteColor];
    self.messageView.containerView = alertView;
    
    // 图标
    UIImageView * fail = [[UIImageView alloc] init];
    [alertView addSubview:fail];
    [fail mas_makeConstraints:^(MASConstraintMaker *make)
     {
         make.centerX.equalTo(alertView);
         make.width.height.mas_equalTo(70);
         make.bottom.equalTo(alertView.mas_centerY);
     }];
    fail.image = [UIImage imageNamed:imageString];
    
    //信息
    UILabel * massageLabel = [[UILabel alloc] init];
    [alertView addSubview:massageLabel];
    [massageLabel mas_makeConstraints:^(MASConstraintMaker *make)
     {
         make.left.mas_equalTo(20);
         make.right.mas_equalTo(-20);
         make.height.mas_equalTo(60);
         make.top.equalTo(alertView.mas_centerY);
     }];
    massageLabel.textAlignment = NSTextAlignmentCenter;
    massageLabel.text = message;
    massageLabel.numberOfLines = 0;
    [self.messageView show];
}

#pragma mark --- 信息提示框显示隐藏
-(void)customAlertViewClose
{
    //1.移除提示框
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.8 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^
    {
                       [self.messageView close];
                       [self.navigationController popViewControllerAnimated:YES];
    });
    
}


#pragma mark - 懒加载
-(KMAuthCodeEditView *)rootView
{
    if (_rootView == nil)
    {
        _rootView = [[KMAuthCodeEditView alloc] init];
    }
    return _rootView;
}


@end
