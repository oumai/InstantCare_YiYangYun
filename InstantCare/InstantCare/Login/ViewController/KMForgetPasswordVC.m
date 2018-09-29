//
//  KMForgetPasswordVC.m
//  InstantCare
//
//  Created by km on 16/6/15.
//  Copyright © 2016年 omg. All rights reserved.
//

#import "KMForgetPasswordVC.h"
#import "KMForgetPasswordView.h"
#import "CustomIOSAlertView.h"
#import "KMNetAPI.h"
#import "MJExtension.h"

static dispatch_source_t _changeTimer;

@interface KMForgetPasswordVC ()<UITextFieldDelegate>

/**
 *  根视图
 */
@property(nonatomic,strong)KMForgetPasswordView * rootView;
/**
 *  信息提示框
 */
@property(nonatomic,strong)CustomIOSAlertView * messageView;


@end

@implementation KMForgetPasswordVC

- (void)viewDidLoad
{
    [super viewDidLoad];
    [self configNavigation];
    [self configSubViews];
    
    
}

#pragma mark - 配置导航栏模块
-(void)configNavigation
{
    self.title = kLoadStringWithKey(@"VC_login_forgetPd");
    UIButton * leftButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [leftButton setBackgroundImage:[UIImage imageNamed:@"return_normal"] forState:UIControlStateNormal];
    [leftButton setBackgroundImage:[UIImage imageNamed:@"return_sel"] forState:UIControlStateSelected];
    [leftButton setFrame:CGRectMake(0, 0, 30, 30)];
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:leftButton];
    [leftButton addTarget:self action:@selector(leftButtonDidClickedAction:) forControlEvents:UIControlEventTouchDown];
    
}
#pragma mark - 配置子视图模块
-(void)configSubViews
{
    
    // 设置视图背景颜色为白色 并添加子视图；
    self.view.backgroundColor = [UIColor whiteColor];
    [self.view addSubview:self.rootView];
    [self.rootView mas_makeConstraints:^(MASConstraintMaker *make)
    {
         make.edges.equalTo(self.view).insets(UIEdgeInsetsMake(64,0,0, 0));
    }];
    self.rootView.changePassword.contentTextField.secureTextEntry = YES;
    self.rootView.againPassword.contentTextField.secureTextEntry  = YES;
    self.rootView.changePassword.contentTextField.delegate = self;
    self.rootView.againPassword.contentTextField.delegate = self;
    self.rootView.phoneNumber.contentTextField.delegate = self;
    self.rootView.verifyCode.contentTextField.delegate =self;
    
    //设置子视图的逻辑处理；
    [self.rootView.getVerifyButton addTarget:self action:@selector(getVerifyButtonDidClickedAction:) forControlEvents:UIControlEventTouchDown];
    [self.rootView.finishButton addTarget:self action:@selector(finishButtonDidClickedAction:) forControlEvents:UIControlEventTouchDown];
}

#pragma mark - UITextFieldDelegate
-(BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string
{
    if (string.length == 0)  return YES;
    if (textField == self.rootView.verifyCode.contentTextField)
    {
        if (textField.text.length >=10)
        {
            return NO;
        }
    }
    
    if (textField.text.length >=15)
    {
        if (string.length == 0)  return YES;
        return NO;
    }
    return YES;
}
-(void)textFieldDidBeginEditing:(UITextField *)textField
{
    KMCustomTextField * view = (KMCustomTextField *)textField.superview;
    view.grayLine.backgroundColor = [UIColor orangeColor];
}
-(void)textFieldDidEndEditing:(UITextField *)textField
{
    KMCustomTextField * view = (KMCustomTextField *)textField.superview;
    view.grayLine.backgroundColor = [UIColor colorWithRed:0 green:0 blue:0 alpha:0.05];
}


#pragma mark - 按钮点击事件处理模块
//  导航栏左侧按钮点击事件
-(void)leftButtonDidClickedAction:(UIButton *)sender
{
    [self dismissViewControllerAnimated:YES completion:nil];
}

//  获取验证码按钮点击事件
-(void)getVerifyButtonDidClickedAction:(UIButton *)sender
{
   BOOL result = [self userInputInfomationVerifyWithIndex:1];
    if (result)
    {
        [self requestSenderVerifyCode];
    }
}

//  完成按钮点击事件
-(void)finishButtonDidClickedAction:(UIButton *)sender
{
   BOOL result =  [self userInputInfomationVerifyWithIndex:2];
    if (result)
    {
        [self requestUseVerifyCodeChangePassword];
    }
}

#pragma mark - 用户忘记密码操作模块
//用户忘记密码请求发送忘记密码认证简讯
-(void)requestSenderVerifyCode
{
    // 开始更改操作
    [SVProgressHUD showWithStatus:kLoadStringWithKey(@"Common_network_request_now")];
    // 获取用户录入信息；
    NSString * phoneNumber = self.rootView.phoneNumber.contentTextField.text;
    NSString * request = [NSString stringWithFormat:@"forgetPassword/%@",phoneNumber];
    // 进行网络操作；
    [[KMNetAPI manager] commonGetRequestWithURL:request Block:^(int code, NSString *res)
    {
        [SVProgressHUD dismiss];
        KMNetworkResModel * resModel = [KMNetworkResModel mj_objectWithKeyValues:res];
        if (code == 0 && resModel.errorCode <= kNetReqSuccess)
        {
            [self theTimer];
            [self customAlertViewShowWithMessage:kLoadStringWithKey(@"Reg_VC_register_request_success") withImage:@"pop_icon_success"];
            [self customAlertViewClose];
        }else
        {
            [self customAlertViewShowWithMessage:kNetReqFailWithCode(resModel.errorCode) withImage:@"pop_icon_fail"];
        }
    }];
}

//用户重新设置密码，以简讯认证码重新设置新用户密码
-(void)requestUseVerifyCodeChangePassword
{
    // 获取用户录入信息；
    NSString * phoneNumber = self.rootView.phoneNumber.contentTextField.text;
    NSString * verifyCode = self.rootView.verifyCode.contentTextField.text;
    NSString * changePassword = self.rootView.changePassword.contentTextField.text;
    NSString * request = [NSString stringWithFormat:@"setPassBySms/%@/%@/%@",phoneNumber,verifyCode,changePassword];
    
    // 进行网络操作；
    [[KMNetAPI manager] commonGetRequestWithURL:request Block:^(int code, NSString *res)
     {
         KMNetworkResModel * resModel = [KMNetworkResModel mj_objectWithKeyValues:res];
         if (code == 0 && resModel.errorCode <= kNetReqSuccess)
         {
             [self shutDownTimer];
             [self customAlertViewShowWithMessage:kLoadStringWithKey(@"VC_login_foundPassword_success") withImage:@"pop_icon_success"];
             [self customAlertViewClose];
             [self dismissViewControllerAnimated:YES completion:nil];
         }else
         {
             [self customAlertViewShowWithMessage:kNetReqFailWithCode(resModel.errorCode) withImage:@"pop_icon_fail"];
         }
     }];
}


#pragma mark - 用户录入信息监测模块
-(BOOL)userInputInfomationVerifyWithIndex:(NSInteger)index
{
    //手机号码检测；
    if (index == 1)
    {
        
        //注册检测信息完整度
        if (![self checkTelNumber:self.rootView.phoneNumber.contentTextField.text])
        {
            
            [self customAlertViewShowWithMessage:kLoadStringWithKey(@"CustomAlert_phone_title") withImage:@"pop_icon_fail"];
            return NO;
        }else
        {
            return YES;
        }
    }
    
    NSString * changePassword = self.rootView.changePassword.contentTextField.text;
    NSString * againPassword  = self.rootView.againPassword.contentTextField.text;
    NSString * verifyCode = self.rootView.verifyCode.contentTextField.text;
    //密码检测；
    if (![self checkPassword:changePassword])
    {
        [self customAlertViewShowWithMessage:kLoadStringWithKey(@"CustomAlert_password_title") withImage:@"pop_icon_fail"];
        [self customAlertViewClose];
        return NO;
    }

    
    //密码比对；
    if ([changePassword compare:againPassword])
    {
        [self customAlertViewShowWithMessage:kLoadStringWithKey(@"CustomAlert_againPW_title") withImage:@"pop_icon_fail"];
        return NO;
    }
    //验证码检测；
    if (verifyCode.length == 0)
    {
        [self customAlertViewShowWithMessage:kLoadStringWithKey(@"CustomAlert_verity_title") withImage:@"pop_icon_fail"];
        return  NO;
    }
    return YES;
}

// 正则匹配手机号码
-(BOOL)checkTelNumber:(NSString *)telNumber
{
    NSString *pattern = @"^1+[3578]+\\d{9}";
    NSPredicate *pred = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", pattern];
    BOOL isMatch = [pred evaluateWithObject:telNumber];
    return isMatch;
}

// 正则匹配密码
-(BOOL)checkPassword:(NSString *)password
{
    NSString * pattern = @"^.{6,15}$";
    NSPredicate *pred = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", pattern];
    BOOL isMatch = [pred evaluateWithObject:password];
    return isMatch;
}

#pragma mark - 定时器功能模块
// 设置定时器
-(void)theTimer
{
    __block int  timeout = 59; // 定时时间
    dispatch_queue_t queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
    _changeTimer = dispatch_source_create(DISPATCH_SOURCE_TYPE_TIMER, 0, 0,queue);
    dispatch_source_set_timer(_changeTimer,dispatch_walltime(NULL, 0),1.0*NSEC_PER_SEC, 0); //每秒执行
    dispatch_source_set_event_handler(_changeTimer, ^{
          if(timeout<=0)
          { //倒计时结束，关闭
              dispatch_source_cancel(_changeTimer);
              dispatch_async(dispatch_get_main_queue(), ^{
                  //设置界面的按钮显示 根据自己需求设置
                  [self.rootView.getVerifyButton setTitle:kLoadStringWithKey(@"Reg_VC_register_GetVerify") forState:UIControlStateNormal];
                  self.rootView.getVerifyButton.userInteractionEnabled = YES;
                });
          }else
          {
              int seconds = timeout % 60;
              NSString *strTime = [NSString stringWithFormat:@"%.2d", seconds];
              dispatch_async(dispatch_get_main_queue(), ^{
             //设置界面的按钮显示 根据自己需求设置
             [UIView beginAnimations:nil context:nil];
             [UIView setAnimationDuration:1];
             [self.rootView.getVerifyButton setTitle:[NSString stringWithFormat:@"%@%@",strTime,kLoadStringWithKey(@"Reg_VC_register_request_wait")] forState:UIControlStateNormal];
             [UIView commitAnimations];
             self.rootView.getVerifyButton.userInteractionEnabled = NO;
            });
              timeout--;
          }
    });
    dispatch_resume(_changeTimer);
}

// 关闭定时器
-(void)shutDownTimer
{
    dispatch_source_cancel(_changeTimer);
    [self.rootView.getVerifyButton setTitle:kLoadStringWithKey(@"Reg_VC_register_GetVerify") forState:UIControlStateNormal];
}


#pragma mark - 信息提示显示模块
//显示信息提示框
-(void)customAlertViewShowWithMessage:(NSString *)message withImage:(NSString *)imageString
{
    // 提示框
    self.messageView = [[CustomIOSAlertView alloc] init];
    self.messageView.buttonTitles = nil;
    [self.messageView setUseMotionEffects:NO];
    
    UIView * alertView = [[UIView alloc] initWithFrame:CGRectMake(0,0,SCREEN_WIDTH*0.9,220)];
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
         make.height.mas_equalTo(100);
         make.top.equalTo(alertView.mas_centerY);
     }];
    massageLabel.textAlignment = NSTextAlignmentCenter;
    massageLabel.text = message;
    massageLabel.numberOfLines = 0;
    [self.messageView show];
}

// 关闭信息提示框
-(void)customAlertViewClose
{
    //1.移除提示框
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.8 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                       [self.messageView close];
        });
}

#pragma mark - 懒加载模块
// 子视图懒加载
-(KMForgetPasswordView *)rootView
{
    if (_rootView == nil)
    {
        _rootView = [[KMForgetPasswordView alloc] init];
    }
    return _rootView;
}


@end
