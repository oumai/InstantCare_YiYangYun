//
//  KMBloodRangeModel.h
//  InstantCare
//
//  Created by km on 16/8/15.
//  Copyright © 2016年 omg. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface KMBloodRangeModel : NSObject
/** 低压上限 */
@property (nonatomic, assign) NSInteger bpdH;
/** 低压下限 */
@property (nonatomic, assign) NSInteger bpdL;

/** 高压上限 */
@property (nonatomic, assign) NSInteger bpsH;
/** 高压下限 */
@property (nonatomic, assign) NSInteger bpsL;
@end
