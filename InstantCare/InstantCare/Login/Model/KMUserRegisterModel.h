//
//  KMUserRegisterModel.h
//  InstantCare
//
//  Created by bruce-zhu on 15/12/7.
//  Copyright © 2015年 omg. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface KMUserRegisterModel : NSObject

@property (nonatomic, copy) NSString *loginToken;   // 和邮箱一样
@property (nonatomic, copy) NSString *passwd;       // 密码（必填）
@property (nonatomic, copy) NSString *email;        // 邮箱（必填）
@property (nonatomic, copy) NSString *aliasName;    // Nick name
@property (nonatomic, copy) NSString *name;         // user name
@property (nonatomic, copy) NSString *phone;        // 电话号码
@property (nonatomic, copy) NSString *address;      // 地址
@property (nonatomic, copy) NSString *birth;        // "yyyy-MM-dd"

@property (nonatomic, copy) NSString *accountId;

@property (nonatomic, assign) NSInteger permission;

@end
