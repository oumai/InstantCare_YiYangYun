//
//  KMUserModel.h
//  InstantCare
//
//  Created by bruce-zhu on 15/12/4.
//  Copyright © 2015年 omg. All rights reserved.
//

#import <Foundation/Foundation.h>

// 登录用户模型
@interface KMUserModel : NSObject

/**
 *  用户名
 */
@property (nonatomic, copy) NSString *loginToken;
/**
 *  密码
 */
@property (nonatomic, copy) NSString *passwd;
/**
 *  GCM推送id，iOS用不到
 */
@property (nonatomic, copy) NSString *gid;
/**
 *  极光推送获取的id
 */
@property (nonatomic, copy) NSString *jid;
/**
 *  APNs
 */
@property (nonatomic, copy) NSString *aid;
/**
 *  服务器返回的id
 */
@property (nonatomic, copy) NSString *id;
/**
 *  服务器返回的key
 */
@property (nonatomic, copy) NSString *key;

@end
