//
//  KMDeviceSettingModel.h
//  InstantCare
//
//  Created by bruce-zhu on 15/12/10.
//  Copyright © 2015年 omg. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface KMDeviceManagerModel : NSObject

@property (nonatomic, strong) NSArray *list;

@end

@interface KMDeviceManagerDetailModel : NSObject

@property (nonatomic, copy) NSString *imei;

@property (nonatomic, copy) NSString *sosPhoneNo1;

@property (nonatomic, copy) NSString *sosPhoneNo2;

@property (nonatomic, copy) NSString *sosPhoneNo3;

@property (nonatomic, copy) NSString *fallPhoneNo1;

@property (nonatomic, copy) NSString *fallPhoneNo2;

@property (nonatomic, copy) NSString *fallPhoneNo3;

@property (nonatomic, copy) NSString *fmlyPhoneNo1;

@property (nonatomic, copy) NSString *fmlyPhoneNo2;

@property (nonatomic, copy) NSString *fmlyPhoneNo3;

@property (nonatomic, assign) int nonDistrub;

@property (nonatomic, assign) int fallDetect;

@property (nonatomic, assign) double uHeight;

@property (nonatomic, assign) double uWeight;
/**
 *  上传间隔频率
 */
@property (nonatomic, assign) int echoPrT;
/**
 *  Gps启动频率
 */
@property (nonatomic, assign) int echoGpsT;
/**
 *  通话限时
 */
@property (nonatomic, assign) int phoneLimitTime;
/**
 *  来电静音（0关1开）
 */
@property (nonatomic, assign) int phoneLimitOnoff;

@property (nonatomic, assign) int autoread;
/**
 *  步距
 */
@property (nonatomic, assign) int uStep;


@end


// TODO: 这个需要移除
@interface KMDeviceSettingModel : NSObject

// 设置时用到
@property (nonatomic, copy) NSString *id;
@property (nonatomic, copy) NSString *key;
@property (nonatomic, copy) NSString *target;       // 设备IMEI

@property (nonatomic, copy) NSString *phone;
@property (nonatomic, copy) NSString *aliasName;
@property (nonatomic, assign) int foot_length;
@property (nonatomic, assign) double weight;
@property (nonatomic, assign) double height;
@property (nonatomic, assign) int setting;
@property (nonatomic, copy) NSString *sos1;
@property (nonatomic, copy) NSString *sos2;
@property (nonatomic, copy) NSString *sos3;

@property (nonatomic, copy) NSString *contact1;
@property (nonatomic, copy) NSString *contact2;
@property (nonatomic, copy) NSString *contact3;

@end


@interface KMDeviceSettingDetailCallModel : NSObject

//亲情号码
/** fmy1 */
@property (nonatomic, copy) NSString *fmy1;
/** fmy2 */
@property (nonatomic, copy) NSString *fmy2;
/** fmy3 */
@property (nonatomic, copy) NSString *fmy3;
/** fmy4 */
@property (nonatomic, copy) NSString *fmy4;

//紧急号码
/** sos1 */
@property (nonatomic, copy) NSString *sos1;
/** sos2 */
@property (nonatomic, copy) NSString *sos2;
/** sos3 */
@property (nonatomic, copy) NSString *sos3;

//求救短信
/** sosSms */
@property (nonatomic, copy) NSString *sosSms;


@end


@interface KMDeviceSettingCallFamilyModel : NSObject
//亲情号码
/** fmy1 */
@property (nonatomic, copy) NSString *number1;
/** fmy2 */
@property (nonatomic, copy) NSString *number2;
/** fmy3 */
@property (nonatomic, copy) NSString *number3;
/** fmy4 */
@property (nonatomic, copy) NSString *number4;

@end


@interface KMDeviceSettingCallSosModel : NSObject
//紧急号码
/** sos1 */
@property (nonatomic, copy) NSString *number1;
/** sos2 */
@property (nonatomic, copy) NSString *number2;
/** sos3 */
@property (nonatomic, copy) NSString *number3;
@end


@interface KMDeviceSettingCallSosSmsModel : NSObject

//求救短信
/** sosSms */
@property (nonatomic, copy) NSString *sms;

@end


// 8020 身体素质模型
@interface KMDeviceSettingPhysiqueModel: NSObject

/** 身高 */
@property (nonatomic, assign) CGFloat height;

/** 体重 */
@property (nonatomic, assign) CGFloat weight;

/** 步长 */
@property (nonatomic, assign) NSInteger step;

/** 性别 */
@property (nonatomic, assign) NSInteger sex;

/** 年龄 */
@property (nonatomic, assign) NSInteger age;


@end


// 8020 硬件设置模型
@interface KMDeviceSettingCheckTimeModel : NSObject

/** 开始时间 */
@property (nonatomic, copy) NSString *starttime;

/** 结束时间 */
@property (nonatomic, copy) NSString *endtime;

/** 时间间隔 */
@property (nonatomic, assign) NSInteger span;


@end









