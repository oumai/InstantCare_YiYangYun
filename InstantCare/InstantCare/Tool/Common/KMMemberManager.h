//
//  KMMember.h
//  InstantCare
//
//  Created by bruce-zhu on 15/11/30.
//  Copyright © 2015年 omg. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "KMUserModel.h"

#define member  [KMMemberManager sharedInstance]

typedef NS_ENUM(NSInteger, KMUserWatchType) {
    KM_WATCH_TYPE_RED,      // 红色
    KM_WATCH_TYPE_GRAY,     // 灰色
    KM_WATCH_TYPE_YELLOW    // 黄色
};

/**
 *  APP使用的地图，三选一
 */
typedef NS_ENUM(NSInteger, KMUserMapType) {
    /**
     *  iOS自带地图
     */
    KM_USER_MAP_TYPE_IOS,
    /**
     *  iOS自带地图-大陆高德地图(需要纠偏)
     */
    KM_USER_MAP_TYPE_IOS_CHINA,
};

@interface KMMemberManager : NSObject

/**
 *  登录账号
 */
@property (nonatomic, copy) NSString *loginAccount;
/**
 *  登录密码
 */
@property (nonatomic, copy) NSString *loginPd;
/**
 *  是否记住密码
 */
@property (nonatomic, assign) BOOL isSavePwd;

@property (nonatomic, strong) KMUserModel *userModel;           // 用户成功登录信息

/**
 *  地图类型
 */
@property (nonatomic, assign) KMUserMapType userMapType;

/**
 *  保存获取到的DeviceToken
 */
@property (nonatomic, copy) NSString *deviceToken;

/** 网络状态  */
@property (nonatomic, assign) int netStatus;

/** 是否在电子围栏页面 (收到电子围栏推送时 如果在电子围栏页面 直接刷新 否则弹框提示)  */
@property (nonatomic, assign) BOOL isGeofenceAppear;

/**
 *  单例
 */
+ (KMMemberManager *)sharedInstance;

// 根据imei来获取用户的头像，如果不存在返回nil
+ (UIImage *)userHeaderImageWithIMEI:(NSString *)imei;
// 设置用户头像
+ (void)addUserHeaderImage:(UIImage *)image IMEI:(NSString *)imei;

// 根据imei来获取用户名字
+ (NSString *)userNameWithIMEI:(NSString *)imei;
+ (void)addUserName:(NSString *)name IMEI:(NSString *)imei;

// 根据imei来获取用户电话号码
+ (NSString *)userPhoneNumberWithIMEI:(NSString *)imei;
+ (void)addUserPhoneNumber:(NSString *)phoneNumber IMEI:(NSString *)imei;

// 根据imei来获取配套手表类型
+ (KMUserWatchType)userWatchTypeWithIMEI:(NSString *)imei;
+ (void)addUserWatchType:(KMUserWatchType)type IMEI:(NSString *)imei;

+ (NSString *)showErrorWithCode:(NSInteger)code;

@end
