//
//  KMQRCodeVC.m
//  InstantCare
//
//  Created by bruce-zhu on 15/12/7.
//  Copyright © 2015年 omg. All rights reserved.
//

#import "KMQRCodeVC.h"
#import "LBXScanView.h"
#import "LBXScanWrapper.h"
#import "KMDeviceSettingVC.h"

@interface KMQRCodeVC ()
/**
 @brief  扫码区域视图, 二维码一般都是框
 */
@property (nonatomic,strong) LBXScanView* qRScanView;
/**
 @brief  扫码功能封装对象
 */
@property (nonatomic,strong) LBXScanWrapper* scanObj;

@end

@implementation KMQRCodeVC

- (void)viewDidLoad
{
    [super viewDidLoad];

    self.view.backgroundColor = [UIColor blackColor];
    
    [self configView];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];

    [self.qRScanView startDeviceReadyingWithText:NSLocalizedStringFromTable(@"QRCode_VC_start_camera", APP_LAN_TABLE, nil)];

    [self performSelector:@selector(startScan) withObject:nil afterDelay:0.2];
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    
    [self.qRScanView stopDeviceReadying];
}

- (void)configView
{
    [self.view addSubview:self.qRScanView];
}

- (LBXScanView *)qRScanView
{
    if (_qRScanView == nil) {
        CGRect rect = self.view.frame;
        rect.origin = CGPointMake(0, 0);
        _qRScanView = [[LBXScanView alloc] initWithFrame:rect style:self.style];
    }
    
    return _qRScanView;
}

- (LBXScanWrapper *)scanObj
{
    if (_scanObj == nil) {
        __weak __typeof(self) weakSelf = self;
        _scanObj = [[LBXScanWrapper alloc] initWithPreView:self.view ArrayObjectType:nil cropRect:CGRectZero success:^(NSArray<LBXScanResult *> *array){
            [weakSelf scanResultWithArray:array];
        }];
    }

    return _scanObj;
}

// 启动设备
- (void)startScan
{
    if (![LBXScanWrapper isGetCameraPermission]) {
        [_qRScanView stopDeviceReadying];
        [SVProgressHUD showErrorWithStatus:NSLocalizedStringFromTable(@"QRCode_VC_camera_permission", APP_LAN_TABLE, nil)];

//        [self performSelector:@selector(startScan) withObject:nil afterDelay:0.2];
        return;
    }

    [self.scanObj startScan];
    [_qRScanView stopDeviceReadying];
    [_qRScanView startScanAnimation];
    self.view.backgroundColor = [UIColor clearColor];
}

- (void)scanResultWithArray:(NSArray<LBXScanResult*>*)array
{
    if (array.count < 1) {
        [SVProgressHUD showErrorWithStatus:@"识别错误"];
        return;
    }

    for (LBXScanResult *result in array) {
        NSLog(@"scanResult:%@, %@", result.strScanned, result.strBarCodeType);
    }

    //震动提醒
    [LBXScanWrapper systemVibrate];
    //声音提醒
    [LBXScanWrapper systemSound];

    LBXScanResult *scanResult = array[0];
    if ([self.delegate respondsToSelector:@selector(KMQRCodeVCResult:barCodeType:)]) {
        [self.delegate KMQRCodeVCResult:scanResult.strScanned barCodeType:scanResult.strBarCodeType];
    }

    dispatch_time_t when = dispatch_time(DISPATCH_TIME_NOW, 0.5*NSEC_PER_SEC);
    dispatch_after(when, dispatch_get_main_queue(), ^{
        [self.navigationController popViewControllerAnimated:YES];
    });
}

@end
