//
//  KMRemindUpdateModel.h
//  InstantCare
//
//  Created by bruce-zhu on 16/2/22.
//  Copyright © 2016年 omg. All rights reserved.
//

#import <Foundation/Foundation.h>

/**
 *  更新服务器提醒信息
 */
@interface KMRemindUpdateModel : NSObject

@property (nonatomic, copy) NSString *id;

@property (nonatomic, copy) NSString *key;

@property (nonatomic, copy) NSString *target;

@property (nonatomic, strong) NSArray *clinic;

@property (nonatomic, strong) NSArray *medical;

@property (nonatomic, strong) NSArray *custom;

@end
