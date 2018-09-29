//
//  KMPushMsgModel.h
//  InstantCare
//
//  Created by bruce-zhu on 15/12/31.
//  Copyright © 2015年 omg. All rights reserved.
//

#import <Foundation/Foundation.h>

@class KMAPSPushMsgModel;
@class KMContentPushMsgModel;


/**
 *  消息推送数据模型
 */
@interface KMPushMsgModel : NSObject

@property (nonatomic, copy) NSString *_j_msgid;

@property (nonatomic, strong) KMContentPushMsgModel *content;

@property (nonatomic, strong) KMAPSPushMsgModel *aps;

@end

@interface KMAPSPushMsgModel : NSObject

@property (nonatomic, copy) NSString *alert;

@end

@interface KMContentPushMsgModel : NSObject

/**
 *  事件紧急程度(1, 2, 3) (低中高)
 */
@property (nonatomic, assign) int level;

/**
 *  SOS         紧急求救
 *  FALL        跌倒
 *  BATTERY     低电量提醒
 *  BP          血压异常
 *  BO          血氧异常
 *  BS          血糖异常
 */
@property (nonatomic, copy) NSString *type;

@property (nonatomic, copy) NSString *imei;

/**
 *  手表类型: KM8000, KM8010
 */
@property (nonatomic, copy) NSString *device;

/**
 *  通知图标，iOS暂时不用
 */
@property (nonatomic, assign) int builder_id;

// SOS
@property (nonatomic, copy) NSString *address;

@property (nonatomic, assign) double lat;

@property (nonatomic, assign) double lon;
@property (nonatomic, assign) double hpe;
/**
 *  是否是GPS定位
 */
@property (nonatomic, assign) BOOL gps;

// BP
@property (nonatomic, assign) int systolic;

@property (nonatomic, assign) int diastolic;

@property (nonatomic, assign) int puls;

// BS
@property (nonatomic, assign) int glucose;

// BO
@property (nonatomic, assign) int spo2;

@end


