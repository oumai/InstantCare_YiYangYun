//
//  KMAlter.h
//  InstantCare
//
//  Created by mac on 2016/11/26.
//  Copyright © 2016年 omg. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface KMAlter : NSObject
/** 推送提醒内容 */
@property (nonatomic,copy)NSString *loc_key;

/**
 *名称
 */
@property (nonatomic,strong)NSArray *loc_args;

//+ (instancetype)alterWithDict:(NSDictionary *)dict;

@end
