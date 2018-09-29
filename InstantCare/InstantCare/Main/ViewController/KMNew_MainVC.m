//
//  KMNew_MainVC.m
//  InstantCare
//
//  Created by Jasonh on 16/12/16.
//  Copyright © 2016年 omg. All rights reserved.
//

#import "KMNew_MainVC.h"
#import "KMPictureCarouselView.h"
#import "KMImageTitleButton.h"
#import "KMLocationVC.h"
#import "KMCallVC.h"
//#import "KMVIPServiceVC.h"
//#import "KMIndexMenuView.h"
#import "KMDeviceSettingVC.h"
#import "KMHealthRecordVC.h"
#import "KMPushMsgModel.h"
#import "KMShowAlertMsgWindow.h"
#import "JPUSHService.h"
#import "KMHealthRecordVC.h"
#import "UIViewController+ECSlidingViewController.h"
#import "UINavigationBar+Awesome.h"
#import "KMiTunesVersionModel.h"
//#import "KMHealthVC.h"
#import "KMGeofenceVC.h"
#import "KMDeviceSettingVC.h"
#import "MJExtension.h"
#import "KMMessageVc.h"
//#import "KMCertificationVc.h"
#import "KMAuthenticationVc.h"
#import "KMNetAPI.h"
#import "KMNewTitleImageBtn.h"
#import "UDNavigationController.h"
#import "UIBarButtonItem+Extension.h"
#import "KMCommonAlertView.h"
//#import "UINavigationController+FDFullscreenPopGesture.h"

#define kButtonHeight           0.2
#define kCarouselViewHeight     0.6
#define kNewCarouselViewHeight  0.5

#define kButtonFontSize         16
#define kButtonOffset           20

#define kImageTitleButtonOffset 16

@interface KMNew_MainVC ()<KMPictureCarouselViewDelegate, ECSlidingViewControllerDelegate>

/**
 *  防止侧滑时误击的View
 */
@property (nonatomic, strong) UIView *topTouchView;

@property (nonatomic, weak) UIView *topView;

/**
 *  是否进入电子围栏提示框
 */
@property(nonatomic,strong)CustomIOSAlertView * geofenceAction;

/**
 *  电子围栏推送imei
 */
@property (nonatomic, strong) KMPushMsgModel *geofencePushModel;

@end

@implementation KMNew_MainVC

- (void)viewDidLoad
{
    
    [super viewDidLoad];

    [self configRemoteNotification];
    [self configNavBar];
    
    [self checkVersion];
    
    [self configTopView];
    [self configbottomView];
    [self configView];
    
}
- (UIStatusBarStyle)preferredStatusBarStyle
{
//    DMLog(@"%@",UIStatusBarStyleLightContent);
    return UIStatusBarStyleLightContent;
}

- (BOOL)prefersStatusBarHidden
{
    return NO;
}

- (void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    UDNavigationController *nav = (UDNavigationController *)self.navigationController;
    [nav setAlph];
}

- (void)viewWillDisappear:(BOOL)animated{
    [super viewWillDisappear:animated];

    UDNavigationController *nav = (UDNavigationController *)self.navigationController;
    [nav setAlph];

}


#pragma mark - configTopView
- (void)configTopView{
    UIImageView *topView = [[UIImageView alloc]init];
    self.topView = topView;
    [topView setImage:[UIImage imageNamed:@"home_banner医养云首页_01"]];
    [self.view addSubview:topView];
    [topView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.left.right.equalTo(self.view);
        make.height.equalTo(@(SCREEN_HEIGHT * kNewCarouselViewHeight));
    }];
    
    
}

- (void)configbottomView{
    
    UIView *bottomView = [[UIView alloc]init];
    bottomView.backgroundColor = [UIColor whiteColor];
    [self.view addSubview:bottomView];
    [bottomView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.topView.mas_bottom);
        make.left.right.bottom.equalTo(self.view);
    }];
    
    // 下面四个按钮
    // 1. 定位记录
    KMNewTitleImageBtn *locationBtn = [[KMNewTitleImageBtn alloc] initWithImage:[UIImage imageNamed:@"Location"]  title:NSLocalizedStringFromTable(@"MAIN_VC_location_btn", APP_LAN_TABLE, nil)];
    locationBtn.tag = 100;
    locationBtn.label.font = [UIFont systemFontOfSize:kImageTitleButtonOffset];
    [locationBtn addTarget:self action:@selector(btnDidClicked:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:locationBtn];
    [locationBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(bottomView);
        make.left.equalTo(bottomView);
        make.height.equalTo(bottomView).multipliedBy(0.5);
        make.width.equalTo(bottomView).multipliedBy(0.5);
    }];

    // 2. 健康记录
    KMNewTitleImageBtn *healthBtn = [[KMNewTitleImageBtn alloc] initWithImage:[UIImage imageNamed:@"Health"]title:NSLocalizedStringFromTable(@"MAIN_VC_health_btn", APP_LAN_TABLE, nil)];
    healthBtn.tag = 101;
    healthBtn.label.font = [UIFont systemFontOfSize:kImageTitleButtonOffset];
    [healthBtn addTarget:self action:@selector(btnDidClicked:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:healthBtn];
    [healthBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(bottomView);
        make.right.equalTo(bottomView);
        make.height.equalTo(locationBtn);
        make.width.equalTo(locationBtn);
    }];
    
    // 3. 健康档案
    //    KMImageTitleButton *callBtn = [[KMImageTitleButton alloc] initWithLeftImage:[UIImage imageNamed:@"healthrecord_icon"]
    //                                                                      title:NSLocalizedStringFromTable(@"MAIN_VC_record_btn", APP_LAN_TABLE, nil)];
    // 3. 拨打电话
    KMNewTitleImageBtn *callBtn = [[KMNewTitleImageBtn alloc] initWithImage:[UIImage imageNamed:@"call"] title:NSLocalizedStringFromTable(@"MAIN_VC_call_btn", APP_LAN_TABLE, nil)];
    callBtn.tag = 102;
    callBtn.label.font = [UIFont systemFontOfSize:kImageTitleButtonOffset];
    [callBtn addTarget:self action:@selector(btnDidClicked:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:callBtn];
    [callBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(locationBtn.mas_bottom);
        make.left.equalTo(bottomView);
        make.height.equalTo(locationBtn);
        make.width.equalTo(locationBtn);
    }];
    
    // 4. 会员服务
    
    NSString * title;
    // 设置马来差异
#ifdef kApplicationMLVersion
    title  = kLoadStringWithKey(@"SlideVC_device_manage");
#else
    title  = kLoadStringWithKey(@"MAIN_VC_vip_btn");
#endif
    
    KMNewTitleImageBtn *vipBtn = [[KMNewTitleImageBtn alloc] initWithImage:[UIImage imageNamed:@"VIP"]title:title];
    
    //    KMImageTitleButton *vipBtn = [KMImageTitleButton buttonWithType:UIButtonTypeCustom];
    //    [vipBtn setImage:[UIImage imageNamed:@"omg_main_btn_service_icon"] forState:UIControlStateNormal];
    //    [vipBtn setTitle:title forState:UIControlStateNormal];
    vipBtn.tag = 103;
    //    vipBtn.label.textAlignment = NSTextAlignmentCenter;
    
    vipBtn.label.font = [UIFont systemFontOfSize:kImageTitleButtonOffset];
    [vipBtn addTarget:self action:@selector(btnDidClicked:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:vipBtn];
    [vipBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(healthBtn.mas_bottom);
        make.right.equalTo(bottomView);
        make.height.equalTo(locationBtn);
        make.width.equalTo(locationBtn);
    }];

}

#pragma mark - 推送相关

- (void)configRemoteNotification
{
    [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleLightContent animated:NO];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(kmReceiveRemoteNotification:) name:@"kmReceiveRemoteNotification" object:nil];
    WS(ws);
    if (member.deviceToken.length != 0) {
        [self updateDeviceTokenToServer];
    } else {                                    // 否则等待10秒再上传(这里使用监听可能效果更好)
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(10 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            if (member.deviceToken.length != 0) {
                [ws updateDeviceTokenToServer];
            }
        });
    }
    
    // 检查是否有推送消息
    NSUserDefaults *userDefault = [NSUserDefaults standardUserDefaults];
    NSDictionary *data = [userDefault valueForKey:@"pushNotificationKey"];
    if (data) {
        [[NSNotificationCenter defaultCenter] postNotificationName:@"kmReceiveRemoteNotification"
                                                            object:data];
        // 清楚之前保存的信息
        [userDefault setObject:nil forKey:@"pushNotificationKey"];
    }
    
    
}

- (void)updateDeviceTokenToServer
{
    NSString *request = [NSString stringWithFormat:@"addJPushToken/%@/%@",
                         member.loginAccount,
                         [JPUSHService registrationID]];
    
    [[KMNetAPI manager] commonGetRequestWithURL:request Block:^(int code, NSString *res) {
        KMNetworkResModel *resModel = [KMNetworkResModel mj_objectWithKeyValues:res];
        if (code == 0 && resModel.errorCode <= kNetReqSuccess) {
            
        } else {
            NSLog(@"JPush upload errors");
        }
    }];
}

- (void)kmReceiveRemoteNotification:(NSNotification*)notify
{
    NSDictionary *userInfo = notify.object;
    
    if (userInfo) {
        KMPushMsgModel *pushModel = [KMPushMsgModel mj_objectWithKeyValues:userInfo];
        if ([pushModel.content.type isEqualToString:@"SOS"] ||
            [pushModel.content.type isEqualToString:@"FALL"]) {          // 跳转到地图界面
            KMLocationVC *vc = [[KMLocationVC alloc] init];
            vc.pushModel = pushModel;
            [self.navigationController pushViewController:vc animated:YES];
        } else if ([pushModel.content.type isEqualToString:@"BO"] ||
                   [pushModel.content.type isEqualToString:@"BS"] ||
                   [pushModel.content.type isEqualToString:@"BP"]) {
            KMHealthRecordVC *vc = [[KMHealthRecordVC alloc] init];
            vc.pushModel = pushModel;
            [self.navigationController pushViewController:vc animated:YES];
        } else if ([pushModel.content.type isEqualToString:@"BATTERY"]) {
            NSString *msg = [NSString stringWithFormat:@"%@%@",
                             pushModel.content.imei,
                             kLoadStringWithKey(@"Device_low_power")];
            [[KMShowAlertMsgWindow sharedInstance] showMsg:msg];
        }else if ([pushModel.content.type isEqualToString:@"LVGF"]){
            
            /// 判断是否在电子围栏页面
            if (member.isGeofenceAppear) {
                
                /// 通知电子围栏页面刷新
                [[NSNotificationCenter defaultCenter] postNotificationName:@"kmGeofenceRemoteNotification"
                                                                    object:userInfo];
                
            }else{
                /// 没有弹框 (避免因为推送弹多个框 用户体验不好)
                if (self.geofenceAction == nil) {
                    
                    self.geofencePushModel = pushModel;
                    /// 弹框是否跳转到电子围栏
                    [self showGeofenceAlert];
                }
                
            }
            
        }else {
            // 其余信息只显示alert信息
            NSLog(@"%@", pushModel.aps.alert);
            //[[KMShowAlertMsgWindow sharedInstance] showMsg:pushModel.aps.alert];
        }
    }
}

/// 进入电子围栏弹框
- (void)showGeofenceAlert {
    // 提示框
    self.geofenceAction = [[CustomIOSAlertView alloc] init];
    
    //提示框自定义视图
    KMCommonAlertView * view = [[KMCommonAlertView alloc] initWithFrame:CGRectMake(0, 0,SCREEN_WIDTH*0.8,180)];
    view.titleLabel.text = kLoadStringWithKey(@"DeviceSetting_VC_select");
    view.buttonsArray = @[@"查看",
                          @"取消"];
    
    view.msgLabel.text = @"收到电子围栏推送,是否立即查看?";
    
    // 删除提示框按钮添加点击事件
    //1.左侧按钮
    UIButton *btn = view.realButtons[0];
    btn.tag = 3001;
    [btn addTarget:self action:@selector(didClickGeofenceAlertBtn:) forControlEvents:UIControlEventTouchUpInside];
    
    //2.右侧按钮
    btn = view.realButtons[1];
    btn.tag = 3002;
    [btn addTarget:self action:@selector(didClickGeofenceAlertBtn:) forControlEvents:UIControlEventTouchUpInside];
    
    //提示框显示
    self.geofenceAction.containerView = view;
    self.geofenceAction.buttonTitles = nil;
    [self.geofenceAction setUseMotionEffects:NO];
    [self.geofenceAction show];
    
}

- (void)didClickGeofenceAlertBtn:(UIButton *)sender {
    
    if (sender.tag == 3001) {
        /// 发送刷新电子围栏通知
        KMGeofenceVC *geofenceVC = [[KMGeofenceVC alloc] initGeofenceWithModel:self.geofencePushModel];
        [self.navigationController pushViewController:geofenceVC animated:YES];
    }
    
    // 关闭提示框
    [self.geofenceAction close];
    self.geofenceAction = nil;
    self.geofencePushModel = nil;
}

/**
 *  显示推送过来的消息
 *
 *  @param msg 消息
 */
- (void)showAlertMsg:(NSString *)msg
{
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"远程推送"
                                                    message:msg
                                                   delegate:nil
                                          cancelButtonTitle:@"退出"
                                          otherButtonTitles:nil];
    [alert show];
}

- (void)configNavBar
{
    self.title = kLoadStringWithKey(@"MAIN_VC_title");
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"menu-button"] style:UIBarButtonItemStyleDone target:self action:@selector(leftBarButtonDidClicked:)];
    //右边 消息
    self.navigationItem.rightBarButtonItem = [UIBarButtonItem itemWithImage2:@"home_message" hightImage:nil target:self action:@selector(messageAction:)];
//    self.navigationController.fd_fullscreenPopGestureRecognizer.enabled = NO;
}

- (void)messageAction:(UIButton *)item
{
    DMLog(@"---------消息---------");
    
    //消息
    KMMessageVc *msVc = [[KMMessageVc alloc]init];
//    msVc.fd_interactivePopDisabled = YES;
    [self.navigationController pushViewController:msVc animated:YES];
}

- (void)configView
{
    self.view.backgroundColor = [UIColor whiteColor];
    
    // 添加侧滑手势
    [self.view addGestureRecognizer:self.slidingViewController.panGesture];
    [self.view addGestureRecognizer:self.slidingViewController.resetTapGesture];
    self.slidingViewController.delegate = self;
   
    self.topTouchView = [[UIView alloc] init];
    self.topTouchView.backgroundColor = [UIColor clearColor];
    [self.view addSubview:self.topTouchView];
    self.topTouchView.userInteractionEnabled = YES;
    [self.topTouchView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.equalTo(self.view);
    }];
    self.topTouchView.hidden = YES;
}

- (void)checkVersion {
    [[KMNetAPI manager] checkVersionWithAPPID:KM_APPID block:^(int code, NSString *res) {
        KMiTunesVersionModel *model = [KMiTunesVersionModel mj_objectWithKeyValues:res];
        if (code == 0 && model.resultCount > 0) {
            KMiTunesVersionDetailModel *versionModel = model.results[0];
            NSDictionary *infoDic = [[NSBundle mainBundle] infoDictionary];
            double currentVersion = [infoDic[@"CFBundleShortVersionString"] doubleValue];
            double latesVersion = [versionModel.version doubleValue];
            if (currentVersion < latesVersion) {
                [self showUpdateAlertViewWithModel:versionModel];
            }
        } else {
            DMLog(@"获取软件版本失败");
        }
    }];
}

- (void)showUpdateAlertViewWithModel:(KMiTunesVersionDetailModel *)model {
    NSString *msg = [NSString stringWithFormat:kLoadStringWithKey(@"MAIN_VC_new_version_msg"), model.version];
    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:kLoadStringWithKey(@"MAIN_VC_new_version")
                                                                             message:msg
                                                                      preferredStyle:UIAlertControllerStyleAlert];
    
    // 取消
    UIAlertAction *actionCancel = [UIAlertAction actionWithTitle:kLoadStringWithKey(@"Common_cancel")
                                                           style:UIAlertActionStyleCancel
                                                         handler:nil];
    [alertController addAction:actionCancel];
    
    // 升级
    UIAlertAction *OKAction = [UIAlertAction actionWithTitle:kLoadStringWithKey(@"MAIN_VC_new_version_update")
                                                       style:UIAlertActionStyleDefault
                                                     handler:^(UIAlertAction *action) {
                                                         [[UIApplication sharedApplication] openURL:[NSURL URLWithString:model.trackViewUrl]];
                                                     }];
    [alertController addAction:OKAction];
    
    alertController.modalPresentationStyle = UIModalPresentationPopover;
    UIPopoverPresentationController *popPresenter = alertController.popoverPresentationController;
    popPresenter.sourceView = self.view;
    popPresenter.sourceRect = self.view.bounds;
    [self presentViewController:alertController animated:YES completion:nil];
}

#pragma mark - 侧滑
- (void)leftBarButtonDidClicked:(UIBarButtonItem *)item
{
    if (self.slidingViewController.currentTopViewPosition != ECSlidingViewControllerTopViewPositionCentered) {
        self.topTouchView.hidden = NO;
        [self.slidingViewController resetTopViewAnimated:YES];
    } else {
        self.topTouchView.hidden = YES;
        [self.slidingViewController anchorTopViewToRightAnimated:YES];
    }
}

#pragma mark - ECSlidingViewControllerDelegate
- (id<UIViewControllerAnimatedTransitioning>)slidingViewController:(ECSlidingViewController *)slidingViewController animationControllerForOperation:(ECSlidingViewControllerOperation)operation topViewController:(UIViewController *)topViewController {
    
    // 回到正常位置
    if (operation == ECSlidingViewControllerOperationResetFromRight) {
        // 显示侧滑，添加手势识别
        self.topTouchView.hidden = YES;
    } else {
        // 显示主界面，移除手势识别
        self.topTouchView.hidden = NO;
    }
    return nil;
}

#pragma mark - KMPictureCarouselViewDelegate
- (void)BannerViewDidClicked:(NSUInteger)index
{
    //[SVProgressHUD showInfoWithStatus:[NSString stringWithFormat:@"Clicked %lu", (unsigned long)index]];
}

- (void)btnDidClicked:(UIButton *)sender
{
//    KMHealthRecordVC *vc = [[KMHealthRecordVC alloc] init];
//    UINavigationController *navVC = [[UINavigationController alloc] initWithRootViewController:vc];
//    [self presentViewController:navVC animated:NO completion:nil];
    switch (sender.tag) {
        case 100:           // 定位记录
        {
            KMLocationVC *vc = [[KMLocationVC alloc] init];
//            vc.fd_interactivePopDisabled = YES;
            [self.navigationController pushViewController:vc animated:YES];
        } break;
        case 101:           // 健康记录
        {
            KMHealthRecordVC *vc = [[KMHealthRecordVC alloc] init];
//            vc.fd_interactivePopDisabled = YES;
            [self.navigationController pushViewController:vc animated:YES];
        } break;
        case 102:           // 拨打电话
        {
            //            KMHealthVC *vc = [[KMHealthVC alloc] init];
            //            [self.navigationController pushViewController:vc animated:YES];
            
            KMCallVC *vc = [[KMCallVC alloc] init];
//            vc.fd_interactivePopDisabled = YES;
            [self.navigationController pushViewController:vc animated:YES];
        } break;
        case 103:           // 会员服务
        {
            // 设置马来差异
            UIViewController * vc;
#ifdef kApplicationMLVersion
            vc = [[KMDeviceSettingVC alloc] init];
#else
            //            vc = [[KMVIPServiceVC alloc] init];
            vc = [[KMAuthenticationVc alloc] init];
#endif
//            vc.fd_interactivePopDisabled = YES;
            [self.navigationController pushViewController:vc animated:YES];
        } break;
            
        default:
            break;
    }
    
}

- (void)dealloc
{
    DMLog(@"*** MainVC dealloc ***");
    NSNotificationCenter *defaultCenter = [NSNotificationCenter defaultCenter];
    
    [defaultCenter removeObserver:self
                             name:@"receiveRemoteNotification"
                           object:nil];
}
@end
