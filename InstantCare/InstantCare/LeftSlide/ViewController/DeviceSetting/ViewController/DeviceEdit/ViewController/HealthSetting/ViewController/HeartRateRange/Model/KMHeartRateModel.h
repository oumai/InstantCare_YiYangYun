//
//  KMHeartRateModel.h
//  InstantCare
//
//  Created by km on 16/8/15.
//  Copyright © 2016年 omg. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface KMHeartRateModel : NSObject

/** heartRateHigh */
@property (nonatomic, assign) NSInteger heartRateHigh;

/** heartRateLow */
@property (nonatomic, assign) NSInteger heartRateLow;

/** status */
@property (nonatomic, assign) NSInteger status;


@end
