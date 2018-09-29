//
//  KMAccountManager.m
//  InstantCare
//
//  Created by Jasonh on 16/11/24.
//  Copyright © 2016年 omg. All rights reserved.
//

#import "KMAccountManager.h"
#import "KMMemberManager.h"

@interface KMAccountManager ()
//保存文件路径
@property (nonatomic,copy) NSString *filePath;

@property (nonatomic,strong) NSMutableArray *saveAccountArray;
@end

@implementation KMAccountManager

- (NSString *)filePath{
    if (_filePath != nil){
        return _filePath;
    }
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *filePath = [paths lastObject];
    _filePath = [filePath stringByAppendingFormat:@"/account.plist"];
    return _filePath;
}

+ (instancetype)sharedInstance{
    static KMAccountManager* instance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        instance = [[self alloc] init];
    });
    return instance;
}


- (NSArray *)getAccountList{
    
    self.saveAccountArray = [NSMutableArray arrayWithContentsOfFile:self.filePath];
    if (self.saveAccountArray == nil) {
        self.saveAccountArray = [NSMutableArray array];
    }
    return self.saveAccountArray.copy;
}

- (void)setAccountListWithSave:(BOOL)isSave{
    
    NSInteger flag = 0;
    
    NSString *pd = @"";
    if (isSave && member.loginPd != nil) {
        //base64加密
        NSData *pwdData = [member.loginPd dataUsingEncoding:NSUTF8StringEncoding];
        pd = [pwdData base64EncodedStringWithOptions:0];
    }
    

//    NSDictionary *dic = @{@"account":,
//                          @"password":pd};
    
    for (int i = 0;i < self.saveAccountArray.count;i++) {
        NSDictionary *tdic = self.saveAccountArray[i];
        if ([tdic[@"account"] isEqualToString:member.loginAccount]) {
            //账号密码不变
            if ([tdic[@"password"]isEqualToString:member.loginPd]) {
                return;
            }else{
                //更改了密码
                flag = 1;
                NSDictionary *dic = @{@"account":member.loginAccount,@"password":pd};
                self.saveAccountArray[i] = dic;
                break;
            }
        }
    }
    if (flag == 0) {
        //新增账号
        NSDictionary *dic = @{@"account":member.loginAccount,@"password":pd};
        
        [self.saveAccountArray insertObject:dic atIndex:0];
    }

    [self.saveAccountArray writeToFile:self.filePath atomically:YES];
}

//删除最近登录账号
- (void)removeAccount:(NSString *)account{
    
    for (int i = 0;i < self.saveAccountArray.count;i++) {
        NSDictionary *tdic = self.saveAccountArray[i];
        if ([tdic[@"account"] isEqualToString:account]) {
            [self.saveAccountArray removeObjectAtIndex:i];
            break;
        }
    }
    
    [self.saveAccountArray writeToFile:self.filePath atomically:YES];
}
@end
