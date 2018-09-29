//
//  AppDelegate.m
//  InstantCare
//
//  Created by bruce-zhu on 15/11/27.
//  Copyright © 2015年 omg. All rights reserved.
//

#import "AppDelegate.h"
#import "JPUSHService.h"
#import "KMLaunchVC.h"
#import "KMLoginVC.h"
#import "KMMalaysiaLoginVC.h"
#import "AFNetworking.h"
#import "UMMobClick/MobClick.h"
@interface AppDelegate ()

@end

@implementation AppDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    [self configIQKeyBoardManager];
    [self configSVHUD];
    [self configNavBarColor];
    [self configUM];
    [self checkNetworkReachabilityStatus];
    // 开始统计配置
    
    // 推送配置
    [self configJPushWithOption:launchOptions];
    // 检查当前的语言
    [self checkCurrentCountry];
    // 处理推送消息
    [self checkRemotePushMsg:launchOptions];
    // 地图配置
    member.userMapType = KM_USER_MAP_TYPE_IOS;
    
    // 初始化窗口手表不存在
    self.window = [[UIWindow alloc] initWithFrame:[UIScreen mainScreen].bounds];
    self.window.backgroundColor = [UIColor whiteColor];
    [self.window makeKeyAndVisible];
    
    // 取出版本进行比较
    float version = [[NSUserDefaults standardUserDefaults] floatForKey:@"CFBundleShortVersionString"];
    float currentVersion = [[NSBundle mainBundle].infoDictionary[@"CFBundleShortVersionString"] floatValue];
    if (currentVersion > version)
    {
        KMLaunchVC * launchVC = [[KMLaunchVC alloc] init];
        self.window.rootViewController = launchVC;
    }else
    {
#ifdef kApplicationMLVersion
        
        KMMalaysiaLoginVC * mainVC = [[KMMalaysiaLoginVC alloc] init];
#else
        
        KMLoginVC * mainVC = [[KMLoginVC alloc] init];
#endif
        
        self.window.rootViewController = mainVC;
    }
    
    
    
    // 下拉刷新控件
    //    [self configMJRefresh];
    return YES;
}

- (void)application:(UIApplication *)application didRegisterForRemoteNotificationsWithDeviceToken:(NSData *)deviceToken
{
    NSString *str = [NSString stringWithFormat:@"%@", deviceToken];
    
    // 去掉空格和<>
    NSString *newString = [str stringByReplacingOccurrencesOfString:@" " withString:@""];
    newString = [newString stringByReplacingOccurrencesOfString:@"<" withString:@""];
    newString = [newString stringByReplacingOccurrencesOfString:@">" withString:@""];
    DMLog(@"## deviceToken: %@", newString);
    
    member.deviceToken = newString;
    
    [JPUSHService registerDeviceToken:deviceToken];
}

- (void)application:(UIApplication *)application didFailToRegisterForRemoteNotificationsWithError:(NSError *)error
{
    NSLog(@"did Fail To Register For Remote Notifications With Error: %@", error);
}

#pragma mark - 收到推送消息

- (void)application:(UIApplication *)application didReceiveRemoteNotification:(NSDictionary *)userInfo
{
    [JPUSHService handleRemoteNotification:userInfo];
    NSLog(@"userInfo-------%@",userInfo);
    [self handleServerNotifaction:userInfo];
    
    [JPUSHService setBadge:0];
    
    [[UIApplication sharedApplication] setApplicationIconBadgeNumber:0];
}

- (void)application:(UIApplication *)application didReceiveRemoteNotification:(NSDictionary *)userInfo fetchCompletionHandler:(void (^)(UIBackgroundFetchResult))completionHandler
{
    [JPUSHService handleRemoteNotification:userInfo];
    NSLog(@"userInfo-------%@",userInfo);
    [self handleServerNotifaction:userInfo];
    
    completionHandler(UIBackgroundFetchResultNewData);
    
    [JPUSHService setBadge:0];
    [[UIApplication sharedApplication] setApplicationIconBadgeNumber:0];
    
}

- (void)applicationDidBecomeActive:(UIApplication *)application
{
    [JPUSHService setBadge:0];
    [[UIApplication sharedApplication] setApplicationIconBadgeNumber:0];
}

- (void)application:(UIApplication *)application didReceiveLocalNotification:(UILocalNotification *)notification
{
    [JPUSHService showLocalNotificationAtFront:notification identifierKey:nil];
}

#pragma mark - 处理通知
-(void)handleServerNotifaction:(NSDictionary*)userInfo{
    NSDictionary* contentDictionary = userInfo[@"content"];
    
    NSString* messageType = contentDictionary[@"type"];
    
    if([messageType isEqualToString:@"REMINDSET"]){
        [[NSNotificationCenter defaultCenter] postNotificationName:@"kmRemindSetNotification"
                                                            object:nil];
    }
    
    if([messageType isEqualToString:@"IMADD"]){
        [[NSNotificationCenter defaultCenter] postNotificationName:@"kmIMADDNotification"
                                                            object:userInfo];
    }
    
    if([messageType isEqualToString:@"IMHR"]){
        [[NSNotificationCenter defaultCenter] postNotificationName:@"kmIMHRNotification"
                                                            object:userInfo];
    }
    
    [[NSNotificationCenter defaultCenter] postNotificationName:@"kmReceiveRemoteNotification"
                                                        object:userInfo];
    
}



#pragma mark - 配置键盘样式
- (void)configIQKeyBoardManager
{
    IQKeyboardManager *manager = [IQKeyboardManager sharedManager];
    manager.enable = YES;
    manager.shouldResignOnTouchOutside = YES;
    manager.shouldToolbarUsesTextFieldTintColor = YES;
    manager.enableAutoToolbar = YES;
    manager.shouldShowTextFieldPlaceholder = YES;
    manager.toolbarManageBehaviour = IQAutoToolbarByPosition;
}

#pragma mark - 配置HUD
- (void)configSVHUD
{
    [SVProgressHUD setDefaultStyle:SVProgressHUDStyleCustom];
    [SVProgressHUD setDefaultMaskType:SVProgressHUDMaskTypeClear];
    [SVProgressHUD setMinimumDismissTimeInterval:3];
    [SVProgressHUD setBackgroundColor:[[UIColor blackColor] colorWithAlphaComponent:0.6]];
    [SVProgressHUD setForegroundColor:[UIColor whiteColor]];
}

#pragma mark - 设置全局导航栏背景颜色
- (void)configNavBarColor
{
    // 导航栏背景
    [[UINavigationBar appearance] setBarTintColor:kMainColor];
    //    [[UINavigationBar appearance] setBarTintColor:[UIColor colorWithRed:0.42 green:0.23 blue:0.93 alpha:1.00]];
    
    // 设置线条的颜色为白色
    [[UINavigationBar appearance] setTintColor:[UIColor whiteColor]];
    
    [[UINavigationBar appearance] setTitleTextAttributes:@{NSForegroundColorAttributeName:[UIColor whiteColor], NSFontAttributeName:[UIFont boldSystemFontOfSize:18]}];
    
    
}
#pragma mar - 设置友盟统计
- (void)configUM
{
    [MobClick setLogEnabled:YES];
    UMConfigInstance.appKey = kUMengAppKey;
    UMConfigInstance.channelId = @"App Store";
    [MobClick startWithConfigure:UMConfigInstance];
}

#pragma mark - 设置JPush推送
- (void)configJPushWithOption:(NSDictionary *)launchOptions
{
    [JPUSHService registerForRemoteNotificationTypes:(UIUserNotificationTypeBadge|UIUserNotificationTypeSound |UIUserNotificationTypeAlert)categories:nil];
    
    // TODO: 发布正式版本需要修改
    [JPUSHService setupWithOption:launchOptions
                           appKey:kJPushAPPKEY
                          channel:@"App Store"
                 apsForProduction:YES
            advertisingIdentifier:nil];
}

#pragma mark - 检查用户在哪个国家
- (void)checkCurrentCountry
{
    NSLocale *currentLocale = [NSLocale currentLocale];
    NSLog(@"Country Code is %@", [currentLocale objectForKey:NSLocaleCountryCode]);
}

//#pragma mark - 配置MJRefresh显示字符串
//- (void)configMJRefresh
//{
//    MJRefreshHeaderIdleText = kLoadStringWithKey(@"MJRefresh_Pull_down_refresh");
//    MJRefreshHeaderPullingText = kLoadStringWithKey(@"MJRefresh_Refresh_Now");
//    MJRefreshHeaderRefreshingText = kLoadStringWithKey(@"MJRefresh_Refreshing_data");
//}

#pragma mark - 检查是否有推送消息
/**
 *  检查用户是否点击推送消息进入APP，如果是则保存为pushNotificationKey
 *  在KMLoginVC中进行统一处理
 *
 *  @param launchOptions launchOptions
 */
- (void)checkRemotePushMsg:(NSDictionary *)launchOptions
{
    // 检查用户是否通过通知进入程序
    if (launchOptions) {
        NSDictionary* pushNotificationKey = [launchOptions objectForKey:UIApplicationLaunchOptionsRemoteNotificationKey];
        if (pushNotificationKey) {
            // 先保存，登录成功后在KMMainVC中处理推送消息
            NSUserDefaults *userDefault = [NSUserDefaults standardUserDefaults];
            [userDefault setObject:pushNotificationKey forKey:@"pushNotificationKey"];
        }
    }
}

#pragma mark - 网络状态检查
- (void)checkNetworkReachabilityStatus
{
    // 1.创建网络状态监测管理者
    AFNetworkReachabilityManager * manger = [AFNetworkReachabilityManager sharedManager];
    
    // 2.监听改变
    [manger setReachabilityStatusChangeBlock:^(AFNetworkReachabilityStatus status) {
        
        [KMMemberManager sharedInstance].netStatus = status;
    }];
    [manger startMonitoring];
}

//禁用第三方输入键盘

- (BOOL)application:(UIApplication *)application shouldAllowExtensionPointIdentifier:(NSString *)extensionPointIdentifier
{
    return NO;
}

//进入后天结束编辑
-(void)applicationWillResignActive:(UIApplication *)application
{
    [self.window endEditing:YES];
}
@end
