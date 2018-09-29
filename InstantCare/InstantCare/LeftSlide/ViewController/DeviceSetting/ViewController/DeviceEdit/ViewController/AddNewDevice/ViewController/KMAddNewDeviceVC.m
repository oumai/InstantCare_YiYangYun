//
//  KMAddNewDeviceVC.m
//  InstantCare
//
//  Created by 朱正晶 on 16/5/25.
//  Copyright © 2016年 omg. All rights reserved.
//

#import "KMAddNewDeviceVC.h"
#import "KMCommonInputCell.h"
#import "KMBundleDevicesModel.h"
#import <MobileCoreServices/MobileCoreServices.h>
#import <QuartzCore/QuartzCore.h>
#import "LBXScanView.h"
#import "KMQRCodeVC.h"
#import "KMCommonAlertView.h"
//#import "KMVIPServiceVC.h"
#import "KMAuthenticationVc.h"
#import "KMNetAPI.h"
#import "MJExtension.h"
#import "UIImageView+WebCache.h"

@interface KMAddNewDeviceVC () <UITableViewDelegate, UITableViewDataSource, UINavigationControllerDelegate, UIImagePickerControllerDelegate, UITextFieldDelegate, KMQRCodeVCDelegate>

@property (nonatomic, strong) UITableView *tableView;
/**
 *  用户头像
 */
@property (nonatomic, strong) UIImage *userHeaderImage;

@property (nonatomic, strong) KMBundleDevices2SeverModel *bundleDeviceModel;

@property (nonatomic, copy) NSString * scanText;

// 提示身份认证
@property (nonatomic, strong) CustomIOSAlertView *infoAlertView;

@end

@implementation KMAddNewDeviceVC

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self setupModel];
    [self configNavBar];
    [self configView];
}

- (void)setupModel {
    self.bundleDeviceModel = [KMBundleDevices2SeverModel new];
    self.bundleDeviceModel.account = member.loginAccount;
}

- (void)configNavBar {
    UIButton *leftNavButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [leftNavButton setBackgroundImage:[UIImage imageNamed:@"return_normal"]
                             forState:UIControlStateNormal];
    [leftNavButton addTarget:self
                      action:@selector(backBarButtonDidClicked:)
            forControlEvents:UIControlEventTouchUpInside];
    leftNavButton.frame = CGRectMake(0, 0, 30, 30);
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:leftNavButton];
    
    UIButton *rightNarBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    [rightNarBtn setTitle:kLoadStringWithKey(@"Personal_info_save") forState:UIControlStateNormal];
    [rightNarBtn addTarget:self
                    action:@selector(rightBarButtonDidClicked:)
          forControlEvents:UIControlEventTouchUpInside];
    rightNarBtn.frame = CGRectMake(0, 0, 60, 30);
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:rightNarBtn];
    
    self.navigationItem.title = kLoadStringWithKey(@"DeviceSetting_VC_add_device");
}

- (void)configView {
    self.view.backgroundColor = kGrayBackColor;
    
    self.tableView = [[UITableView alloc] init];
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    self.tableView.rowHeight = 60;
    self.tableView.tableFooterView = [UIView new];
    self.tableView.backgroundColor = [UIColor clearColor];
    self.tableView.backgroundView = [UIView new];
    [self.tableView registerClass:[KMCommonInputCell class] forCellReuseIdentifier:@"cell"];
    [self.view addSubview:self.tableView];
    [self.tableView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.equalTo(self.view).insets(UIEdgeInsetsMake(10, 0, 0, 0));
    }];
}

#pragma mark - UITableView

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return 5;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    KMCommonInputCell *cell = [tableView dequeueReusableCellWithIdentifier:@"cell"];
    cell.textField.delegate = self;
    cell.textField.tag = indexPath.row;
    cell.textField.keyboardType = UIKeyboardTypeDefault;
    switch (indexPath.row) {
        case 0:     // 头像
        {
            cell.imageView.image = [UIImage imageNamed:@"edit_headportrait"];
            cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
            cell.textField.placeholder = kLoadStringWithKey(@"DeviceSetting_VC_user_header");
            cell.textField.enabled = NO;
            cell.rightImageView.image = _userHeaderImage ? _userHeaderImage : [UIImage imageNamed:@"default_photo"];
            cell.rightImageView.layer.cornerRadius = 45/2;
        } break;
        case 1:     // 昵称
        {
            cell.imageView.image = [UIImage imageNamed:@"edit_name"];
            cell.textField.placeholder = kLoadStringWithKey(@"Reg_VC_tip_nickname");
            cell.textField.enabled = YES;
        } break;
        case 2:     // 手表内预装SIM卡号
        {
            cell.imageView.image = [UIImage imageNamed:@"edit_phone"];
            cell.textField.placeholder = kLoadStringWithKey(@"DeviceSetting_VC_Preinstalled_SIM");
            cell.textField.enabled = YES;
            cell.textField.keyboardType = UIKeyboardTypePhonePad;
            cell.accessoryView = [self scanBtn];
            cell.accessoryView.tag = 3000+0;
        } break;
        case 3:     // IMEI（二维码）
        {
            cell.imageView.image = [UIImage imageNamed:@"edit_imei"];
            cell.textField.placeholder = kLoadStringWithKey(@"DeviceSetting_VC_SIM_QRCode");
            cell.textField.enabled = YES;
            cell.textField.keyboardType = UIKeyboardTypeNumberPad;
            cell.accessoryView = [self scanBtn];
            cell.accessoryView.tag = 3000+1;
        } break;
        case 4:     // 手表认证码
        {
            cell.imageView.image = [UIImage imageNamed:@"edit_Authenticationcode"];
            cell.textField.placeholder = kLoadStringWithKey(@"DeviceSetting_VC_Authentication_Code");
            cell.textField.keyboardType = UIKeyboardTypeNumberPad;
            cell.textField.enabled = YES;
        } break;
        case 5:     // 同意个人资料与个人电子健康档案关联
        {
            cell.textField.enabled = NO;
            cell.imageTitleBtn.selected = NO;
        } break;
        default:
            break;
    }

    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:NO];
    if (indexPath.row == 0) {           // 拍照
        UITableViewCell *cell = [tableView cellForRowAtIndexPath:indexPath];
        [self pickerImageForHeader:cell];
    } else if (indexPath.row == 5) {    // 同意个人资料与个人电子健康档案关联
        KMCommonInputCell *cell = (KMCommonInputCell *)[tableView cellForRowAtIndexPath:indexPath];
        cell.imageTitleBtn.selected = !cell.imageTitleBtn.isSelected;
    }
}

/**
 *  扫一扫按钮
 *
 *  return
 */
- (UIButton *)scanBtn {
    UIButton *scanBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    scanBtn.titleLabel.font = [UIFont systemFontOfSize:13];
    scanBtn.frame = CGRectMake(0, 0, 60, 20);
    scanBtn.layer.cornerRadius = 10;
    scanBtn.layer.borderColor = kMainColor.CGColor;
    scanBtn.layer.borderWidth = 1;
    [scanBtn setTitle:kLoadStringWithKey(@"DeviceSetting_VC_scan") forState:UIControlStateNormal];
    [scanBtn setTitleColor:kMainColor forState:UIControlStateNormal];
    [scanBtn addTarget:self action:@selector(scanBtnDidClicked:) forControlEvents:UIControlEventTouchUpInside];

    return scanBtn;
}

#pragma mark - 扫一扫
- (void)scanBtnDidClicked:(UIButton *)sender {
    
    NSInteger index = sender.tag - 3000;
    if (index == 0)
    {
        LBXScanViewStyle *style = [[LBXScanViewStyle alloc] init];
        style.centerUpOffset = 44;
        style.photoframeAngleStyle = LBXScanViewPhotoframeAngleStyle_Inner;
        style.photoframeLineW = 3;
        style.photoframeAngleW = 18;
        style.photoframeAngleH = 18;
        style.isNeedShowRetangle = NO;
        
        style.anmiationStyle = LBXScanViewAnimationStyle_LineMove;
        
        style.colorAngle = [UIColor greenColor];
        
        UIImage *imgLine = [UIImage imageNamed:@"CodeScan.bundle/qrcode_Scan_weixin_Line"];
        style.animationImage = imgLine;
        
        self.scanText = @"1";
        KMQRCodeVC *vc = [[KMQRCodeVC alloc] init];
        vc.style = style;
        vc.delegate = self;
        [self.navigationController pushViewController:vc animated:YES];
    }else
    {
        LBXScanViewStyle *style = [[LBXScanViewStyle alloc] init];
        style.centerUpOffset = 44;
        style.photoframeAngleStyle = LBXScanViewPhotoframeAngleStyle_Inner;
        style.photoframeLineW = 3;
        style.photoframeAngleW = 18;
        style.photoframeAngleH = 18;
        style.isNeedShowRetangle = NO;
        
        self.scanText = @"2";
        style.anmiationStyle = LBXScanViewAnimationStyle_LineMove;
        
        style.colorAngle = [UIColor greenColor];
        
        UIImage *imgLine = [UIImage imageNamed:@"CodeScan.bundle/qrcode_Scan_weixin_Line"];
        style.animationImage = imgLine;
        
        KMQRCodeVC *vc = [[KMQRCodeVC alloc] init];
        vc.style = style;
        vc.delegate = self;
        [self.navigationController pushViewController:vc animated:YES];
    }
    
}

#pragma mark - KMQRCodeVCDelegate
- (void)KMQRCodeVCResult:(NSString *)code barCodeType:(NSString *)type
{
    if ([self.scanText integerValue] == 2)
    {
        NSIndexPath *indexPath = [NSIndexPath indexPathForRow:3 inSection:0];
        KMCommonInputCell *cell = (KMCommonInputCell *)[self.tableView cellForRowAtIndexPath:indexPath];
        cell.textField.text = code;
        self.bundleDeviceModel.deviceId = code;
    }else
    {
        NSIndexPath *indexPath = [NSIndexPath indexPathForRow:2 inSection:0];
        KMCommonInputCell *cell = (KMCommonInputCell *)[self.tableView cellForRowAtIndexPath:indexPath];
        cell.textField.text = code;
        self.bundleDeviceModel.deviceId = code;
    }
}

#pragma mark - 是否同意
- (BOOL)agreeBtnSelectState
{
    NSIndexPath *indexPath = [NSIndexPath indexPathForRow:5 inSection:0];
    KMCommonInputCell *cell = (KMCommonInputCell *)[self.tableView cellForRowAtIndexPath:indexPath];

    // 因为cell比较少，这里不会有缓存，所以能够获取到正确的值
    return cell.imageTitleBtn.isSelected;
}

- (void)textFieldDidEndEditing:(UITextField *)textField {
    switch (textField.tag) {
        case 0:     // 头像
            break;
        case 1:     // 昵称
            self.bundleDeviceModel.nickname = textField.text;
            break;
        case 2:     // 手表内置SIM卡号
            self.bundleDeviceModel.SIM = textField.text;
            break;
        case 3:     // IMEI
            self.bundleDeviceModel.deviceId = textField.text;
            break;
        case 4:     // 手表认证码
            self.bundleDeviceModel.deviceVerifyCode = textField.text;
            break;
        default:
            break;
    }
}

#pragma mark - UITextFieldDelegate
-(BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string
{
     if (string.length == 0)  return YES;
    if (textField.text.length >=15)
    {
        return NO;
    }
    NSInteger existedLength = textField.text.length;
    NSInteger selectedLength = range.length;
    NSInteger replaceLength = string.length;
    if (existedLength - selectedLength + replaceLength >15)
    {
        return NO;
    }
    return YES;
}
#pragma mark - 选择头像
- (void)pickerImageForHeader:(UIView *)sender
{
    WS(ws);
    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:kLoadStringWithKey(@"DeviceSetting_VC_edit_header_src")
                                                                             message:@""
                                                                      preferredStyle:UIAlertControllerStyleActionSheet];
    // 照相机
    UIAlertAction *cameraAction = [UIAlertAction actionWithTitle:kLoadStringWithKey(@"DeviceSetting_VC_edit_header_src_camera")
                                                           style:UIAlertActionStyleDefault
                                                         handler:^(UIAlertAction *action) {
                                                             UIImagePickerController *imagePicker = [[UIImagePickerController alloc] init];
                                                             imagePicker.delegate = ws;
                                                             imagePicker.allowsEditing = YES;
                                                             imagePicker.sourceType = UIImagePickerControllerSourceTypeCamera;
                                                             [ws presentViewController:imagePicker animated:YES completion:nil];
                                                         }];
    [alertController addAction:cameraAction];
    
    // 本地相册
    UIAlertAction *galleryAction = [UIAlertAction actionWithTitle:kLoadStringWithKey(@"DeviceSetting_VC_edit_header_src_gallery")
                                                            style:UIAlertActionStyleDefault
                                                          handler:^(UIAlertAction *action) {
                                                              UIImagePickerController *imagePicker = [[UIImagePickerController alloc] init];
                                                              imagePicker.delegate = ws;
                                                              imagePicker.allowsEditing = YES;
                                                              imagePicker.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
                                                              [ws presentViewController:imagePicker animated:YES completion:nil];
                                                          }];
    [alertController addAction:galleryAction];
    
    // 取消
    UIAlertAction *action1 = [UIAlertAction actionWithTitle:NSLocalizedStringFromTable(@"Common_cancel", APP_LAN_TABLE, nil)
                                                      style:UIAlertActionStyleCancel
                                                    handler:nil];
    [alertController addAction:action1];
    alertController.modalPresentationStyle = UIModalPresentationPopover;
    UIPopoverPresentationController *popPresenter = alertController.popoverPresentationController;
    popPresenter.sourceView = sender;
    popPresenter.sourceRect = sender.bounds;
    [self presentViewController:alertController animated:YES completion:nil];
}

#pragma mark - UIImagePickerControllerDelegate
- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info
{
    UIImage *img = nil;
    if ([[info objectForKey:UIImagePickerControllerMediaType] isEqualToString:(__bridge NSString *)kUTTypeImage]) {
        img = [info objectForKey:UIImagePickerControllerEditedImage];
    }

    [picker dismissViewControllerAnimated:YES completion:^{
        _userHeaderImage = img;
        NSIndexPath *indexPath = [NSIndexPath indexPathForRow:0 inSection:0];
        [_tableView reloadRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
    }];
}

- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker
{
    [picker dismissViewControllerAnimated:YES completion:nil];
}

#pragma mark - 返回
- (void)backBarButtonDidClicked:(UIButton *)sender {
    [self.navigationController popViewControllerAnimated:YES];
}

#pragma mark - 保存
- (void)rightBarButtonDidClicked:(UIButton *)sender
{
    [self.view endEditing:YES];
    // 检查参数
    if (self.userHeaderImage == nil) {
        [SVProgressHUD showErrorWithStatus:kLoadStringWithKey(@"Device_VC_add_header_Photo")];
        return;
    }
    if (self.bundleDeviceModel.nickname.length == 0 ||
        self.bundleDeviceModel.SIM.length == 0 ||
        self.bundleDeviceModel.deviceId.length == 0 ||
        self.bundleDeviceModel.deviceVerifyCode.length == 0) {
        [SVProgressHUD showErrorWithStatus:kLoadStringWithKey(@"DeviceSetting_VC_check_again")];
        return;
    }

    WS(ws);
    // 上传其他参数
    // bindDevice/{account}/{imei}/{deviceVerifyCode}
    NSString *bindString = [NSString stringWithFormat:@"bindDevice/%@/%@/%@",
                            member.loginAccount,
                            self.bundleDeviceModel.deviceId,
                            self.bundleDeviceModel.deviceVerifyCode];
    [SVProgressHUD showWithStatus:kLoadStringWithKey(@"Common_network_request_now")];
    [[KMNetAPI manager] commonGetRequestWithURL:bindString Block:^(int code, NSString *res)
     {
        KMNetworkResModel *resModel = [KMNetworkResModel mj_objectWithKeyValues:res];
        if (code == 0 && resModel.errorCode <= kNetReqSuccess)
        {
            [ws uploadUserHeader];
        } else
        {
            [SVProgressHUD showErrorWithStatus:kNetReqFailWithCode(resModel.errorCode)];
        }
    }];
}

#pragma mark - 上传头像
- (void)uploadUserHeader {
    if (self.userHeaderImage) {
        NSData *jpg = UIImageJPEGRepresentation(self.userHeaderImage, 0.8);
        NSString *base64Encoded = [jpg base64EncodedStringWithOptions:0];
        
        WS(ws);
        KMPortraitModel *m = [KMPortraitModel new];
        m.portrait = base64Encoded;
        NSString *keyURL = [NSString stringWithFormat:@"portrait/%@/%@",
                            member.loginAccount,
                            self.bundleDeviceModel.deviceId];
        [SVProgressHUD showWithStatus:kLoadStringWithKey(@"Common_network_request_now")];
        [[KMNetAPI manager] commonPOSTRequestWithURL:keyURL jsonBody:[m mj_JSONString] Block:^(int code, NSString *res) {
            KMNetworkResModel *resModel = [KMNetworkResModel mj_objectWithKeyValues:res];
            if (code == 0 && resModel.errorCode <= kNetReqSuccess) {
                [ws updateUserInfo];
            } else {
                [SVProgressHUD showErrorWithStatus:kNetReqFailWithCode(resModel.errorCode)];
            }
        }];
    }
}

// 对用户信息进行更新
- (void)updateUserInfo
{
    WS(ws);
    NSString *postURL = [NSString stringWithFormat:@"wearersInfo/%@/%@",
                         member.loginAccount,
                         self.bundleDeviceModel.deviceId];
    KMBundleDevicesDetailModel * model = [[KMBundleDevicesDetailModel alloc ] init];
    model.phone = self.bundleDeviceModel.SIM;
    model.imei = self.bundleDeviceModel.deviceId;
    model.realName = self.bundleDeviceModel.nickname;
    
    [[KMNetAPI manager] commonPOSTRequestWithURL:postURL jsonBody:[model mj_JSONString] Block:^(int code, NSString *res) {
        KMNetworkResModel *resModel = [KMNetworkResModel mj_objectWithKeyValues:res];
        if (code == 0 && resModel.errorCode <= kNetReqSuccess)
        {
            [SVProgressHUD dismiss];
            // 清除SD缓存，否则会出现头像不更新的情况
            [[SDImageCache sharedImageCache] clearMemory];
            [[SDImageCache sharedImageCache] clearDiskOnCompletion:nil];
            
            
     #ifdef kApplicationMLVersion
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.5 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                [ws.navigationController popViewControllerAnimated:YES];
            });
           
        #else
            if (self.flag == YES) {
                self.infoAlertView = [[CustomIOSAlertView alloc] init];
                KMCommonAlertView *view = [[KMCommonAlertView alloc] initWithFrame:CGRectMake(0, 0,300, 260)];
                view.titleLabel.text = kLoadStringWithKey(@"DeviceSetting_VC_SIM");
                view.msgLabel.text = kLoadStringWithKey(@"DeviceEdit_VC_setting_Authentication");
                view.buttonsArray = @[kLoadStringWithKey(@"DeviceSetting_VC_YES")];
                
                // okButton
                UIButton * okButton = view.realButtons[0];
                okButton.tag = 101;
                [okButton addTarget:self action:@selector(infoButtonDidClicked:) forControlEvents:UIControlEventTouchUpInside];
                
                self.infoAlertView.containerView = view;
                self.infoAlertView.buttonTitles = nil;
                [self.infoAlertView setUseMotionEffects:NO];
                
                [self.infoAlertView show];
            } else {
                dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.5 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                    [ws.navigationController popViewControllerAnimated:YES];
                });
            }
        #endif
            
        } else
        {
            [SVProgressHUD showErrorWithStatus:kNetReqFailWithCode(resModel.errorCode)];

        };
    }];
}

- (void)infoButtonDidClicked:(UIButton *)sender {
    [self.infoAlertView close];

    KMAuthenticationVc *vc = [[KMAuthenticationVc alloc] init];
    [self.navigationController pushViewController:vc animated:YES];
}

@end
