//
//  KMMemberManger.m
//  InstantCare
//
//  Created by bruce-zhu on 15/11/30.
//  Copyright © 2015年 omg. All rights reserved.
//

#import "KMMemberManager.h"

@implementation KMMemberManager

+ (KMMemberManager *)sharedInstance
{
    static dispatch_once_t pred = 0;
    __strong static id _sharedObject = nil;
    
    dispatch_once(&pred, ^{
        _sharedObject = [[self alloc] init];
    });
    
    return _sharedObject;
}

- (KMUserModel *)userModel
{
    if (_userModel == nil) {
        _userModel = [[KMUserModel alloc] init];
    }

    return _userModel;
}

#pragma mark - 登录账号

- (void)setLoginAccount:(NSString *)loginAccount {
    [[NSUserDefaults standardUserDefaults] setObject:loginAccount forKey:@"loginAccount"];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

- (NSString *)loginAccount
{
    return [[NSUserDefaults standardUserDefaults] objectForKey:@"loginAccount"];
}

#pragma mark - 登录密码
- (void)setLoginPd:(NSString *)loginPd
{
    [[NSUserDefaults standardUserDefaults] setObject:loginPd forKey:@"loginPd"];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

- (NSString *)loginPd
{
    return [[NSUserDefaults standardUserDefaults] objectForKey:@"loginPd"];
}
#pragma mark - 是否记住密码
- (void)setIsSavePwd:(BOOL)isSavePwd{
    [[NSUserDefaults standardUserDefaults] setObject:@(isSavePwd) forKey:@"isSavePwd"];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

- (BOOL)isSavePwd{
    return [[[NSUserDefaults standardUserDefaults] objectForKey:@"isSavePwd"]boolValue];
}

#pragma mark - 根据imei来获取用户的头像，如果不存在返回默认头像
+ (UIImage *)userHeaderImageWithIMEI:(NSString *)imei
{
    NSData *data = [NSData dataWithContentsOfFile:[self headerImagePathWithIMEI:imei]];
    UIImage *image =  [UIImage imageWithData:data];
    if (image == nil) {     // 如果没有存储使用默认的头像
        image = [UIImage imageNamed:@"omg_call_noimage"];
    }

    return image;
}

// 设置用户头像
+ (void)addUserHeaderImage:(UIImage *)image IMEI:(NSString *)imei
{
    NSData *data;

    if (UIImagePNGRepresentation(image) == nil) {
        data = UIImageJPEGRepresentation(image, 1);
    } else {
        data = UIImagePNGRepresentation(image);
    }

    NSFileManager *fileManager = [NSFileManager defaultManager];
    // Document/headerImage_xxxx
    NSString *filePath = [NSString stringWithString:[self headerImagePathWithIMEI:imei]];
    DMLog(@"addUserHeaderImage: %@", filePath);

    BOOL ret = [fileManager createFileAtPath:filePath
                                    contents:data
                                  attributes:nil];
    if (ret == NO) {
        DMLog(@"%@ write fail", filePath);
    }
}

+ (NSString *)headerImagePathWithIMEI:(NSString *)imei
{
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentDirectory = [paths objectAtIndex:0];
    return [documentDirectory stringByAppendingString:[NSString stringWithFormat:@"/headerImage_%@", imei]];
}

#pragma mark - 根据imei来获取用户名字
+ (NSString *)userNameWithIMEI:(NSString *)imei
{
    NSString *keyString = [NSString stringWithFormat:@"username_%@", imei];
    return [[NSUserDefaults standardUserDefaults] objectForKey:keyString];
}

+ (void)addUserName:(NSString *)name IMEI:(NSString *)imei
{
    if (imei.length > 0) {
        NSString *keyString = [NSString stringWithFormat:@"username_%@", imei];
        [[NSUserDefaults standardUserDefaults] setObject:name forKey:keyString];
        [[NSUserDefaults standardUserDefaults] synchronize];
    }
}

#pragma mark - 根据imei来获取用户电话号码
+ (NSString *)userPhoneNumberWithIMEI:(NSString *)imei
{
    NSString *keyString = [NSString stringWithFormat:@"phoneNumber_%@", imei];
    return [[NSUserDefaults standardUserDefaults] objectForKey:keyString];
}

+ (void)addUserPhoneNumber:(NSString *)phoneNumber IMEI:(NSString *)imei
{
    if (imei.length > 0) {
        NSString *keyString = [NSString stringWithFormat:@"phoneNumber_%@", imei];
        [[NSUserDefaults standardUserDefaults] setObject:phoneNumber forKey:keyString];
        [[NSUserDefaults standardUserDefaults] synchronize];
    }
}

#pragma mark - 根据imei来获取佩戴手表类型
+ (KMUserWatchType)userWatchTypeWithIMEI:(NSString *)imei
{
    NSString *keyString = [NSString stringWithFormat:@"watchType_%@", imei];
    return [[[NSUserDefaults standardUserDefaults] objectForKey:keyString] intValue];
}

+ (void)addUserWatchType:(KMUserWatchType)type IMEI:(NSString *)imei
{
    NSString *keyString = [NSString stringWithFormat:@"watchType_%@", imei];
    [[NSUserDefaults standardUserDefaults] setObject:@(type) forKey:keyString];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

+ (NSString *)showErrorWithCode:(NSInteger)code {
    NSString *errorCodeString = [NSString stringWithFormat:@"errorCode_%ld", (long)code];
    NSString *errorCode = kLoadStringWithKey(errorCodeString);
    // 如果没有这个error code返回网络错误
    if ([errorCode isEqualToString:errorCodeString]) {
        errorCode = kLoadStringWithKey(@"Common_network_request_fail");
    }
    return errorCode;
}

@end
