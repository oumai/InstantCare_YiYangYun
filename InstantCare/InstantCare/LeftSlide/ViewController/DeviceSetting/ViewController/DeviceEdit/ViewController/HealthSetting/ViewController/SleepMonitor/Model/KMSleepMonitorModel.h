//
//  KMSleepCheckModel.h
//  InstantCare
//
//  Created by km on 16/8/31.
//  Copyright © 2016年 omg. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface KMSleepMonitorModel : NSObject

/** 开始时间 */
@property (nonatomic, copy) NSString *starttime;

/** 结束时间 */
@property (nonatomic, copy) NSString *endtime;

/** 状态 */
@property (nonatomic, assign) NSInteger status;

@end
