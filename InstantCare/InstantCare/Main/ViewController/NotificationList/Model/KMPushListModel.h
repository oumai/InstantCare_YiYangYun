//
//  KMPushListModel.h
//  InstantCare
//
//  Created by Jasonh on 16/12/2.
//  Copyright © 2016年 omg. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "KMAlter.h"
#import "KMExtrasModel.h"
@class Content,List;
@interface KMPushListModel : NSObject
/**
 *  消息
 */
@property (nonatomic, copy) NSString *msg;

@property (nonatomic, strong) Content *content;
/**
 *  状态，0=正常, 1=错误
 */
@property (nonatomic, assign) NSInteger errorCode;

@end

@interface Content : NSObject

@property (nonatomic, strong) NSMutableArray<List *> *list;

@end

@interface List : NSObject
/**
 *  push_id
 */
@property (nonatomic, assign) NSInteger p_id;
/**
 *  push_标题
 */
@property (nonatomic, copy) NSString *p_title;
/**
 *  push_标题
 */
@property (nonatomic, strong) KMAlter *p_alter;
/**
 *  p_builder_id
 */
@property (nonatomic, assign) NSInteger p_builder_id;
/**
 *  push_标题
 */
@property (nonatomic, strong) KMExtrasModel *p_extras;
/**
 *  推送创建时间
 */
@property (nonatomic, assign) NSUInteger p_create_time;
/**
 *  push_账号
 */
@property (nonatomic, copy) NSString *p_account;
/**
 *  是否选中
 */
@property (nonatomic, assign) BOOL isSelected;
@end
