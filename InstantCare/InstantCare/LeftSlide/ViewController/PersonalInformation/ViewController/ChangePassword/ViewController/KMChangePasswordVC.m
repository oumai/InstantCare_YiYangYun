//
//  KMChangePasswordVC.m
//  InstantCare
//
//  Created by 朱正晶 on 16/5/24.
//  Copyright © 2016年 omg. All rights reserved.
//

#import "KMChangePasswordVC.h"
#import "KMCustomTextField.h"
#import "CustomIOSAlertView.h"
#import "MJExtension.h"
#import "KMNetAPI.h"
#define kSpace 15

@interface KMChangePasswordVC ()<UITextFieldDelegate>

//原密码
@property(nonatomic,strong)KMCustomTextField * oldPassWord;
//新密码
@property(nonatomic,strong)KMCustomTextField * changePassWord;
//再次数据新密码；
@property(nonatomic,strong)KMCustomTextField * againchangePassWord;
//确定按钮；
@property(nonatomic,strong)UIButton * confirmButton;
//信息提示框
@property(nonatomic,strong)CustomIOSAlertView * messageView;


@end

@implementation KMChangePasswordVC

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
    
    self.title = kLoadStringWithKey(@"Personal_info_change_password");
}

- (void)configView {
    self.view.backgroundColor = [UIColor whiteColor];
    
    self.oldPassWord = [[KMCustomTextField alloc] init];
    [self.view addSubview:self.oldPassWord];
    [self.oldPassWord mas_makeConstraints:^(MASConstraintMaker *make)
     {
         make.centerX.equalTo(self.view);
         make.width.mas_equalTo(SCREEN_WIDTH*0.8);
         make.height.mas_equalTo(SCREEN_HEIGHT*0.1);
         make.top.mas_equalTo(30+64);
     }];
    self.oldPassWord.titleLabel.text = kLoadStringWithKey(@"Personal_info_change_oldPassword");
    self.oldPassWord.contentTextField.secureTextEntry = YES;
    self.oldPassWord.contentTextField.keyboardType = UIKeyboardTypeDefault;
    self.oldPassWord.contentTextField.delegate = self;

    
    self.changePassWord = [[KMCustomTextField alloc] init];
    [self.view addSubview:self.changePassWord];
    [self.changePassWord mas_makeConstraints:^(MASConstraintMaker *make)
     {
         make.centerX.width.height.equalTo(self.oldPassWord);
         make.top.equalTo(self.oldPassWord.mas_bottom).offset(kSpace);
     }];
    self.changePassWord.titleLabel.text = kLoadStringWithKey(@"Personal_info_change_newPassword");
    self.changePassWord.contentTextField.secureTextEntry = YES;
    self.changePassWord.contentTextField.keyboardType = UIKeyboardTypeDefault;
    self.changePassWord.contentTextField.delegate = self;

    
    self.againchangePassWord = [[KMCustomTextField alloc] init];
    [self.view addSubview:self.againchangePassWord];
    [self.againchangePassWord mas_makeConstraints:^(MASConstraintMaker *make)
     {
         make.centerX.width.height.equalTo(self.oldPassWord);
         make.top.equalTo(self.changePassWord.mas_bottom).offset(kSpace);
     }];
    self.againchangePassWord.titleLabel.text = kLoadStringWithKey(@"Reg_VC_tip_again_pd");
    self.againchangePassWord.contentTextField.secureTextEntry  = YES;
    self.againchangePassWord.contentTextField.keyboardType = UIKeyboardTypeDefault;
    self.againchangePassWord.contentTextField.delegate = self;

    
    
    //完成按钮；
    self.confirmButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [self.view addSubview:self.confirmButton];
    [self.confirmButton mas_makeConstraints:^(MASConstraintMaker *make)
     {
         make.centerX.equalTo(self.view);
         make.top.equalTo(self.againchangePassWord.mas_bottom).offset(35);
         make.width.mas_equalTo(SCREEN_WIDTH*0.8);
         make.height.mas_equalTo(50);
     }];
    [self.confirmButton setTitle:kLoadStringWithKey(@"Reg_VC_birthday_OK") forState:UIControlStateNormal];
    self.confirmButton.layer.cornerRadius = 25;
    self.confirmButton.backgroundColor = [UIColor orangeColor];
    [self.confirmButton addTarget:self action:@selector(confirmChangePassWordAction:) forControlEvents:UIControlEventTouchDown];
    
}
#pragma mark - UITextFieldDelegate
-(BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string
{
     if (string.length == 0)  return YES;
    NSInteger existedLength = textField.text.length;
    NSInteger selectedLength = range.length;
    NSInteger replaceLength = string.length;
    if (existedLength - selectedLength + replaceLength >15)
    {
        return NO;
    }
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

#pragma mark - 确定更改密码操作
-(void)confirmChangePassWordAction:(UIButton *)sender
{
    if([self changeInfomationDecetion])
    {
        // 开始更改操作
        [SVProgressHUD showWithStatus:kLoadStringWithKey(@"Common_network_request_now")];
        
        NSString * reuqest = [NSString stringWithFormat:@"updatePassword/%@/%@/%@",member.loginAccount,self.oldPassWord.contentTextField.text,self.changePassWord.contentTextField.text];
        [[KMNetAPI manager] commonGetRequestWithURL:reuqest Block:^(int code, NSString *res) {
            [SVProgressHUD dismiss];
            KMNetworkResModel * resModel = [KMNetworkResModel mj_objectWithKeyValues:res];
            if (code == 0 && resModel.errorCode <= kNetReqSuccess)
            {
                [self customAlertViewShowWithMessage:kLoadStringWithKey(@"ChangePassword_DecetionError_success") withStatus:1];
                [self customAlertViewClose];
            }else
            {
                [self customAlertViewShowWithMessage:kNetReqFailWithCode(resModel.errorCode)
                                          withStatus:0];
            }
        }];
    }
}

#pragma mark - 返回
- (void)backBarButtonDidClicked:(UIButton *)sender
{
    [self.navigationController popViewControllerAnimated:YES];
}

#pragma mark ---  注册信息检测
-(BOOL)changeInfomationDecetion{
    if (self.oldPassWord.contentTextField.text.length == 0)
    {
        [self customAlertViewShowWithMessage:kLoadStringWithKey(@"ChangePassword_DecetionError_oldNull") withStatus:0];
        return NO;
    }
    if (self.changePassWord.contentTextField.text.length == 0 || self.changePassWord.contentTextField.text.length < 6)
    {
        [self customAlertViewShowWithMessage:kLoadStringWithKey(@"ChangePassword_DecetionError_newNull") withStatus:0];
        return NO;
    }
    
    if (![self.changePassWord.contentTextField.text isEqualToString:self.againchangePassWord.contentTextField.text])
    {
        [self customAlertViewShowWithMessage:kLoadStringWithKey(@"ChangePassword_DecetionError_noAgree") withStatus:0];
        return NO;
    }
    if ([self.changePassWord.contentTextField.text isEqualToString:self.oldPassWord.contentTextField.text])
    {
        [self customAlertViewShowWithMessage:kLoadStringWithKey(@"ChangePassword_DecetionError_same") withStatus:0];
        return NO;
    }
    

    
    return YES;
}

#pragma mark --- 信息提示框显示
//显示信息提示框
-(void)customAlertViewShowWithMessage:(NSString *)message withStatus:(NSInteger)index
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
    if (index == 0)
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
    
}@end
