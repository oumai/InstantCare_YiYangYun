//
//  KMBloodSugarModel.h
//  InstantCare
//
//  Created by km on 16/8/15.
//  Copyright © 2016年 omg. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface KMBloodSugarModel : NSObject
///** 上限 */
//@property (nonatomic, assign) NSInteger boH;

///** 下限 */
//@property (nonatomic, assign) NSInteger boL;

/** 上限 */
@property (nonatomic, assign) NSInteger afterMealH;

/** 下限 */
@property (nonatomic, assign) NSInteger afterMealL;

@property (nonatomic, assign) NSInteger beforeBedH;

@property (nonatomic, assign) NSInteger beforeBedL;

@property (nonatomic, assign) NSInteger beforeMealH;

@property (nonatomic, assign) NSInteger beforeMealL;


@end
