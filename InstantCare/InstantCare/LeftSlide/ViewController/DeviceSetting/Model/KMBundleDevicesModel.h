//
//  KMBundleDevicesModel.h
//  InstantCare
//
//  Created by bruce-zhu on 15/12/8.
//  Copyright © 2015年 omg. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface KMBundleDevicesModel : NSObject

@property (nonatomic, strong) NSArray *list;

@end


@interface KMBundleDevicesDetailModel : NSObject

@property (nonatomic, copy) NSString *imei;

@property (nonatomic, copy) NSString *realName;

@property (nonatomic, copy) NSString *phone;

// TODO: 暂时存储在本地
//@property (nonatomic, assign) int watchStyle;

@property (nonatomic, copy) NSString *portrait;

@property (nonatomic,copy)NSString * type;
// 正在使用标志，1 -> 正在使用
@property (nonatomic, assign) int myWear;

/** 绑定状态 */
@property (nonatomic, assign) NSInteger accept;

@end

@interface KMBundleDevices2SeverModel : NSObject
/**
 *  账户
 */
@property (nonatomic, copy) NSString *account;
/**
 *  昵称
 */
@property (nonatomic, copy) NSString *nickname;
/**
 *  IMEI
 */
@property (nonatomic, copy) NSString *deviceId;
/**
 *  SIM卡号
 */
@property (nonatomic, copy) NSString *SIM;
/**
 *  手表认证码
 */
@property (nonatomic, copy) NSString *deviceVerifyCode;

@end

/**
 *  上传用户头像模型
 */
@interface KMPortraitModel : NSObject
/**
 *  jpg, png
 */
@property (nonatomic, copy) NSString *type;
/**
 *  base64编码的头像
 */
@property (nonatomic, copy) NSString *portrait;

@end

