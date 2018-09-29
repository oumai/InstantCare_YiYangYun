//
//  KMCheckHeartRateModel.h
//  InstantCare
//
//  Created by km on 16/8/16.
//  Copyright © 2016年 omg. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface KMCheckHeartRateModel : NSObject

/** 开始时间 */
@property (nonatomic, copy) NSString *starttime;

/** 结束时间 */
@property (nonatomic, copy) NSString *endtime;

/** 事件间隔 */
@property (nonatomic, assign) NSInteger span;

@end


@interface KMCheckHeartRateModel2 : NSObject

/** 开始时间 */
@property (nonatomic, copy) NSString *start_time;

/** 结束时间 */
@property (nonatomic, copy) NSString *end_time;

/** 事件间隔 */
@property (nonatomic, copy) NSString *span;

@end