//
//  KMAuthCodeEditView.m
//  InstantCare
//
//  Created by km on 16/6/15.
//  Copyright © 2016年 omg. All rights reserved.
//

#import "KMAuthCodeEditView.h"

@implementation KMAuthCodeEditView

- (instancetype)init
{
    self = [super init];
    if (self)
    {
        [self configSubViews];
    }
    return self;
}

#pragma makr - 配置子视图
-(void)configSubViews
{
    //旧的认证码
    self.oldAuthCode = [[KMCustomTextField alloc] init];
    self.oldAuthCode.contentTextField.keyboardType = UIKeyboardTypeDefault;
    [self addSubview:self.oldAuthCode];
    [self.oldAuthCode mas_makeConstraints:^(MASConstraintMaker *make)
    {
        make.width.mas_equalTo(SCREEN_WIDTH*0.9);
        make.height.mas_equalTo(SCREEN_HEIGHT*0.1);
        make.centerX.equalTo(self);
        make.top.mas_equalTo(30);
        
    }];
    self.oldAuthCode.titleLabel.text = kLoadStringWithKey(@"DeviceEdit_VC_setting_title_device_verify_oldVerify");
    
    
    //新的认证码
    self.nowAuthCode = [[KMCustomTextField alloc] init];
    self.nowAuthCode.contentTextField.keyboardType = UIKeyboardTypeDefault;
    [self addSubview:self.nowAuthCode];
    [self.nowAuthCode mas_makeConstraints:^(MASConstraintMaker *make)
     {
         make.width.height.centerX.equalTo(self.oldAuthCode);
         make.top.equalTo(self.oldAuthCode.mas_bottom).offset(15);
     }];
    self.nowAuthCode.titleLabel.text = kLoadStringWithKey(@"DeviceEdit_VC_setting_title_device_verify_newVerify");

    //确定
    self.okButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [self addSubview:self.okButton];
    [self.okButton mas_makeConstraints:^(MASConstraintMaker *make)
     {
         make.width.mas_equalTo(SCREEN_WIDTH*0.75);
         make.centerX.equalTo(self.oldAuthCode);
         make.height.mas_equalTo(50);
         make.top.equalTo(self.nowAuthCode.mas_bottom).offset(30);
         
     }];
    [self.okButton setTitle:kLoadStringWithKey(@"Reg_VC_birthday_OK") forState:UIControlStateNormal];
    [self.okButton setTitleColor:[UIColor orangeColor] forState:UIControlStateNormal];
    [self.okButton.layer setCornerRadius:50/2];
    self.okButton.layer.borderColor = [UIColor orangeColor].CGColor;
    self.okButton.layer.borderWidth = 1;
    
    
    //重置
    self.resetButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [self addSubview:self.resetButton];
    [self.resetButton mas_makeConstraints:^(MASConstraintMaker *make)
     {
         make.width.height.centerX.equalTo(self.okButton);
         make.top.equalTo(self.okButton.mas_bottom).offset(15);
     }];
    [self.resetButton setTitle:kLoadStringWithKey(@"DeviceEdit_VC_setting_title_device_reset") forState:UIControlStateNormal];
    [self.resetButton setBackgroundColor:[UIColor orangeColor]];
    [self.resetButton.layer setCornerRadius:50/2];
    
    
}




@end
