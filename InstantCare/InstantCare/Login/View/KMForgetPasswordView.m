
//
//  KMForgetPasswordView.m
//  InstantCare
//
//  Created by km on 16/6/15.
//  Copyright © 2016年 omg. All rights reserved.
//

#import "KMForgetPasswordView.h"

#define kSpace 25

@implementation KMForgetPasswordView

// 初始化对象；
- (instancetype)init
{
    self = [super init];
    if (self)
    {
        [self configSubViews];
    }
    return self;
}

#pragma mark - 配置子视图
-(void)configSubViews
{
    //手机号；
    self.phoneNumber = [self makeKMCustomTextFieldWithTitle:kLoadStringWithKey(@"VC_login_phone")];
    [self.phoneNumber mas_makeConstraints:^(MASConstraintMaker *make)
    {
        make.top.mas_equalTo(30);
        make.width.mas_equalTo(SCREEN_WIDTH*0.8);
        make.centerX.equalTo(self);
        make.height.mas_equalTo(SCREEN_HEIGHT*0.09);
    }];
    
    //新密码；
    self.changePassword = [self makeKMCustomTextFieldWithTitle:kLoadStringWithKey(@"VC_login_pd")];
    [self.changePassword mas_makeConstraints:^(MASConstraintMaker *make)
     {
         make.width.height.centerX.equalTo(self.phoneNumber);
         make.top.equalTo(self.phoneNumber.mas_bottom).offset(kSpace);
    }];
    //再次输入新密码；
    self.againPassword = [self makeKMCustomTextFieldWithTitle:kLoadStringWithKey(@"Reg_VC_tip_again_pd")];
    [self.againPassword mas_makeConstraints:^(MASConstraintMaker *make)
    {
        make.width.height.centerX.equalTo(self.phoneNumber);
        make.top.equalTo(self.changePassword.mas_bottom).offset(kSpace);
    }];
    
    //验证码；
    self.verifyCode = [self makeKMCustomTextFieldWithTitle:kLoadStringWithKey(@"Reg_VC_register_Verify")];
    [self.verifyCode mas_makeConstraints:^(MASConstraintMaker *make)
    {
        make.width.height.centerX.equalTo(self.phoneNumber);
        make.top.equalTo(self.againPassword.mas_bottom).offset(kSpace);
    }];
    
    //获取验证码；
    self.getVerifyButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [self.verifyCode addSubview:self.getVerifyButton];
    [self.getVerifyButton mas_makeConstraints:^(MASConstraintMaker *make)
     {
         make.width.mas_equalTo(110);
         make.height.mas_equalTo(35);
         make.right.equalTo(self.verifyCode).offset(SCREEN_WIDTH*0.08);
         make.bottom.equalTo(self.verifyCode);
    }];
    [self.getVerifyButton.layer setBorderColor:[UIColor orangeColor].CGColor];
    [self.getVerifyButton.layer setCornerRadius:(SCREEN_HEIGHT*0.06)/2];
    [self.getVerifyButton.layer setBorderWidth:1];
    [self.getVerifyButton setTitleColor:[UIColor orangeColor] forState:UIControlStateNormal];
    [self.getVerifyButton setTitle:kLoadStringWithKey(@"Reg_VC_register_GetVerify")forState:UIControlStateNormal];
    [self.getVerifyButton.titleLabel setFont:[UIFont systemFontOfSize:14]];
    
    //完成
    self.finishButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [self addSubview:self.finishButton];
    [self.finishButton mas_makeConstraints:^(MASConstraintMaker *make)
    {
        make.width.mas_equalTo(SCREEN_WIDTH*0.8);
        make.centerX.equalTo(self);
        make.height.mas_equalTo(50);
        make.top.equalTo(self.verifyCode.mas_bottom).offset(15);
    }];
    [self.finishButton setTitle:kLoadStringWithKey(@"Reg_VC_birthday_OK") forState:UIControlStateNormal];
    [self.finishButton setBackgroundColor:[UIColor orangeColor]];
    self.finishButton.layer.cornerRadius = 25;
    
}


#pragma mark - KMCustomTextField 遍历构造器
-(KMCustomTextField *)makeKMCustomTextFieldWithTitle:(NSString *)title
{
    KMCustomTextField * customTextField = [[KMCustomTextField alloc] init];
    customTextField.titleLabel.text = title;
    [self addSubview:customTextField];
    return customTextField;
}




@end
