//
//  KMAccountManager.h
//  InstantCare
//
//  Created by Jasonh on 16/11/24.
//  Copyright © 2016年 omg. All rights reserved.
//  最近登录账号管理

#import <Foundation/Foundation.h>

@interface KMAccountManager : NSObject



+ (instancetype)sharedInstance;
//获取登录账号
- (NSArray *)getAccountList;
//添加或修改登录账号
- (void)setAccountListWithSave:(BOOL)isSave;
//删除登录账号
- (void)removeAccount:(NSString *)account;

@end
