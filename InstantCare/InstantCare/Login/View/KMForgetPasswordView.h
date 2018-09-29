//
//  KMForgetPasswordView.h
//  InstantCare
//
//  Created by km on 16/6/15.
//  Copyright © 2016年 omg. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "KMCustomTextField.h"

@interface KMForgetPasswordView : UIView
/**
 *  手机号码
 */
@property(nonatomic,strong)KMCustomTextField * phoneNumber;

/**
 *  新密码
 */
@property(nonatomic,strong)KMCustomTextField * changePassword;

/**
 *  再次输入新密码
 */
@property(nonatomic,strong)KMCustomTextField * againPassword;

/**
 *  验证码
 */
@property(nonatomic,strong)KMCustomTextField * verifyCode;

/**
 *  获取验证码
 */
@property(nonatomic,strong)UIButton * getVerifyButton;

/**
 *  确定
 */
@property(nonatomic,strong)UIButton * finishButton;


@end
