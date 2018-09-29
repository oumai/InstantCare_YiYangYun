//
//  KMPushContent.h
//  InstantCare
//
//  Created by KM on 2016/11/25.
//  Copyright © 2016年 omg. All rights reserved.
//

#import <Foundation/Foundation.h>
@class KMExtrasModel;
@class KMAlter;
@interface KMPushContent : NSObject

/**
 *时间
 */
@property (nonatomic,copy)NSString *p_create_time;

/** KMExtrasModel */
@property (nonatomic,strong)KMExtrasModel *p_extras;



//
//{
//    "errorCode":0,
//    "msg":"OK",
//    "content":{
//        "list":[
//                {
//                    "p_id":60,
//                    "p_title":"power_low_title_key",
//                    "p_alter":"{"loc-args":["866545022045881"],"loc-key":"power_low_key"}",
//                    "p_tocken":"100d8559094edb020e9",
//                    "p_builder_id":1,
//                    "p_extras":"{"imei":"866545022045881","type":"BATTERY","level":1,"builder_id":1,"device":"KM8010"}",
//                    "p_create_time":1480044668847,
//                    "p_account":"15221508161"
//                },
//                {
//                    "p_id":56,
//                    "p_title":"glucose_title_key",
//                    "p_alter":"{"loc-args":["866545022045881"],"loc-key":"glucose_alert_key"}",
//                    "p_tocken":"100d8559094edb020e9",
//                    "p_builder_id":5,
//                    "p_extras":"{"imei":"866545022045881","level":2,"type":"BS","builder_id":5,"glucose":"87","device":"KM8010"}",
//                    "p_create_time":1480044226193,
//                    "p_account":"15221508161"
//                },
//                {
//                    "p_id":52,
//                    "p_title":"glucose_title_key",
//                    "p_alter":"{"loc-args":["866545022045881"],"loc-key":"glucose_alert_key"}",
//                    "p_tocken":"100d8559094edb020e9",
//                    "p_builder_id":5,
//                    "p_extras":"{"imei":"866545022045881","level":2,"type":"BS","builder_id":5,"glucose":"87","device":"KM8010"}",
//                    "p_create_time":1480044214100,
//                    "p_account":"15221508161"
//                },
//                {
//                    "p_id":48,
//                    "p_title":"glucose_title_key",
//                    "p_alter":"{"loc-args":["866545022045881"],"loc-key":"glucose_alert_key"}",
//                    "p_tocken":"100d8559094edb020e9",
//                    "p_builder_id":5,
//                    "p_extras":"{"imei":"866545022045881","level":2,"type":"BS","builder_id":5,"glucose":"87","device":"KM8010"}",
//                    "p_create_time":1480043140453,
//                    "p_account":"15221508161"
//                },
//                {
//                    "p_id":44,
//                    "p_title":"glucose_title_key",
//                    "p_alter":"{"loc-args":["866545022045881"],"loc-key":"glucose_alert_key"}",
//                    "p_tocken":"100d8559094edb020e9",
//                    "p_builder_id":5,
//                    "p_extras":"{"imei":"866545022045881","level":2,"type":"BS","builder_id":5,"glucose":"87","device":"KM8010"}",
//                    "p_create_time":1480043104460,
//                    "p_account":"15221508161"
//                }
//                ]
//    }
//}

@end
