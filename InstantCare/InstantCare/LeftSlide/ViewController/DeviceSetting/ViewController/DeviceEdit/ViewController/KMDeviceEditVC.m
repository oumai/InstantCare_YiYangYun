//
//  KMDeviceEditVC.m
//  InstantCare
//
//  Created by bruce-zhu on 15/12/2.
//  Copyright © 2015年 omg. All rights reserved.
//

#import <MobileCoreServices/MobileCoreServices.h>
#import <QuartzCore/QuartzCore.h>
#import "KMDeviceEditVC.h"
#import "KMDeviceSettingEditCell.h"
#import "KMCommonInputCell.h"
#import "KMImageTitleButton.h"
#import "KMDeviceSettingDetailVC.h"
#import "iCarousel.h"
#import "CustomIOSAlertView.h"
#import "KMDeviceSettingDetailCallVC.h"
#import "KMDeviceSettingDetailBodyVC.h"
#import "KMRemindSettingVC.h"
#import "KMRoundAddView.h"
#import "KMCommonAlertView.h"
#import "KMAuthCodeEditVC.h"
#import "KMHealthSettingVC.h"
#import "KM8020RemindSettingVC.h"
#import "KMNetAPI.h"
#import "UIImageView+WebCache.h"
#import "MJExtension.h"
#import "UIImageView+SDWebImage.h"


#define kEdgeOffset         20
#define kHeadWidth          60
#define kTextFieldHeight    30
#define kWatchSelBtnWidth   30
#define kWatchSelBtnHeiht   50
#define kBottomBtnHeight    50

@interface KMDeviceEditVC() <UITableViewDataSource, UITableViewDelegate, iCarouselDataSource, iCarouselDelegate, UIActionSheetDelegate, UIImagePickerControllerDelegate, UINavigationControllerDelegate, UITextFieldDelegate,UIViewControllerPreviewingDelegate>

@property (nonatomic, strong) KMRoundAddView *headImageView;        // 选择头像按钮

@property (nonatomic, strong) KMRoundAddView *watchBtn;             // 选择手表按钮


/**
 *  用于界面显示的控件和数据
 */
@property (nonatomic, strong) UITableView *tableView;
@property (nonatomic, strong) NSArray *settingTitleArray;
@property (nonatomic, strong) NSArray *settingDetailArray;


// 手表选择
@property (nonatomic, strong) iCarousel *carouselView;              // 手表选择view
@property (nonatomic, strong) CustomIOSAlertView *watchSelectView;  // 跳出手表选择界面
@property (nonatomic, assign) KMUserWatchType selectWatchType;      // 用户选择的手表样式

/**
 *  用户选择的头像
 */
@property (nonatomic, strong) UIImage *userHeaderImage;

/**
 *  提示框
 */
@property(nonatomic,strong)CustomIOSAlertView * resetAlert;

@end

@implementation KMDeviceEditVC
- (nullable UIViewController *)previewingContext:(id <UIViewControllerPreviewing>)previewingContext viewControllerForLocation:(CGPoint)location
{
    //获取按压的cell所在行，[previewingContext sourceView]就是按压的那个视图
    NSIndexPath *indexPath = [self.tableView indexPathForCell:(UITableViewCell* )[previewingContext sourceView]];
    //调整不被虚化的范围，按压的那个cell不被虚化（轻轻按压时周边会被虚化，再少用力展示预览，再加力跳页至设定界面）
    CGRect rect = CGRectMake(0, 0, self.view.frame.size.width,70);
    previewingContext.sourceRect = rect;
    //设定预览的界面
//    UIViewController *childVC = [[UIViewController alloc] init];
//    childVC.preferredContentSize = CGSizeMake(0.0f,500.0f);
    if (indexPath.section == 1)
    {
        switch (indexPath.row)
        {
            case 0:// 认证码
            {
                KMAuthCodeEditVC * vc = [[KMAuthCodeEditVC alloc] init];
                vc.imei = self.detailModel.imei;
//                [self.navigationController pushViewController:vc animated:YES];
                return vc;
            }
                break;
            case 1:     // 硬体设定
            {
                KMDeviceSettingDetailVC *vc = [[KMDeviceSettingDetailVC alloc] init];
                vc.imei = self.detailModel.imei;
                vc.type = self.detailModel.type;
                vc.is3DTouchLoad = 1;
//                [self.navigationController pushViewController:vc animated:YES];
                return vc;
            }
                break;
            case 2:     // 拨号设定
            {
                KMDeviceSettingDetailCallVC *vc = [[KMDeviceSettingDetailCallVC alloc] init];
                vc.imei = self.detailModel.imei;
                vc.type = self.detailModel.type;
                vc.is3DTouchLoad = 1;
//                [self.navigationController pushViewController:vc animated:YES];
                return vc;
            }
                break;
            case 3:     // 运动计步
            {
                KMDeviceSettingDetailBodyVC *vc = [[KMDeviceSettingDetailBodyVC alloc] init];
                vc.imei = self.detailModel.imei;
                vc.type = self.detailModel.type;
                vc.is3DTouchLoad = 1;
//                [self.navigationController pushViewController:vc animated:YES];
                return vc;
            }
                break;
            case 4:     // 提醒设定
            {
                if ([self.detailModel.type isEqualToString:@"20"]) {
                    
                    KM8020RemindSettingVC *vc = [[KM8020RemindSettingVC alloc] init];
                    vc.imei = self.detailModel.imei;
                    vc.title = kLoadStringWithKey(@"DeviceEdit_VC_setting_title_device_remind");
//                    [self.navigationController pushViewController:vc animated:YES];
                    return vc;
                }else{
                    
                    KMRemindSettingVC *vc = [[KMRemindSettingVC alloc] init];
                    vc.imei = self.detailModel.imei;
                    vc.type = self.detailModel.type;
//                    [self.navigationController pushViewController:vc animated:YES];
                    return vc;
                }
            }
                break;
            case 5:// 健康设置
            {
                KMHealthSettingVC * vc = [[KMHealthSettingVC alloc] init];
                vc.imei = self.detailModel.imei;
                vc.type = self.detailModel.type;
                vc.is3DTouchLoad = 1;
//                [self.navigationController pushViewController:vc animated:YES];
                return vc;
            } break;
                
            default:
                break;
        }
    }


    
    //返回预览界面
    return nil;
}

- (void)previewingContext:(id <UIViewControllerPreviewing>)previewingContext commitViewController:(UIViewController *)viewControllerToCommit
{
    
    [self.navigationController pushViewController:viewControllerToCommit animated:YES];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    //1.设置背景颜色
    self.view.backgroundColor = kGrayBackColor;
    [self initSettingArray];
    [self configNavBar];
    [self configView];
    NSLog(@"type-----%@",self.detailModel.type);
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    [self.tableView reloadData];
}

#pragma mark - 初始化数据模块
- (void)initSettingArray
{
    self.settingTitleArray = @[kLoadStringWithKey(@"DeviceEdit_VC_setting_title_device_auth"),
                               kLoadStringWithKey(@"DeviceEdit_VC_setting_title_device_set"),
                               kLoadStringWithKey(@"DeviceEdit_VC_setting_title_call_set"),
                               kLoadStringWithKey(@"DeviceEdit_VC_setting_title_body_set"),
                               kLoadStringWithKey(@"DeviceEdit_VC_setting_title_device_remind"),
                               kLoadStringWithKey(@"DeviceManager_HealthSetting"),
                               kLoadStringWithKey(@"DeviceEdit_VC_setting_title_device_reset")];
    
    NSString * string1 = [NSString stringWithFormat:@"%@、%@、%@、%@、%@、%@",kLoadStringWithKey(@"DeviceManager_HealthSetting_heathRate"),
                        kLoadStringWithKey(@"DeviceManager_HealthSetting_bloodPressure"),
                        kLoadStringWithKey(@"DeviceManager_HealthSetting_bloodSugar"),
                        kLoadStringWithKey(@"DeviceManager_HealthSetting_sleepMonitor"),
                        kLoadStringWithKey(@"DeviceManager_HealthSetting_Sedentary"),
                        kLoadStringWithKey(@"HealthRecord_VC_bo")];
    NSString * string2 = [NSString stringWithFormat:@"%@、%@、%@、%@",kLoadStringWithKey(@"DeviceManager_HealthSetting_heathRate"),
                          kLoadStringWithKey(@"DeviceManager_HealthSetting_bloodPressure"),
                          kLoadStringWithKey(@"DeviceManager_HealthSetting_bloodSugar"),
                          kLoadStringWithKey(@"HealthRecord_VC_bo")];
    
    NSString * title = [self.detailModel.type isEqualToString:@"20"]? string1:string2;
    
    self.settingDetailArray = @[kLoadStringWithKey(@"DeviceEdit_VC_setting_title_device_auth_detail"),
                                kLoadStringWithKey(@"DeviceEdit_VC_setting_title_device_set_detail"),
                                kLoadStringWithKey(@"DeviceEdit_VC_setting_title_call_set_detail"),
                                kLoadStringWithKey(@"DeviceEdit_VC_setting_title_body_set_detail"),
                                kLoadStringWithKey(@"DeviceEdit_VC_setting_title_device_remind_detail"),
                                title,
                                kLoadStringWithKey(@"DeviceEdit_VC_setting_title_device_reset_detail")];
}

#pragma mark - 设置导航栏模块
- (void)configNavBar
{
    // 1.leftItem
    UIButton *leftNarBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    [leftNarBtn setBackgroundImage:[UIImage imageNamed:@"return_normal"]forState:UIControlStateNormal];
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:leftNarBtn];
    leftNarBtn.frame = CGRectMake(0, 0, 30, 30);
    
    // 2.rightItem
    UIButton *rightNarBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    [rightNarBtn setTitle:kLoadStringWithKey(@"Personal_info_save") forState:UIControlStateNormal];
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:rightNarBtn];
    rightNarBtn.frame = CGRectMake(0, 0, 60, 30);
    
    // rightNarBtn 点击事件
    [rightNarBtn addTarget:self action:@selector(rightBarButtonDidClicked:)
          forControlEvents:UIControlEventTouchUpInside];
    
    // leftNavButton 点击事件
    [leftNarBtn addTarget:self action:@selector(leftBarButtonDidClicked:)
            forControlEvents:UIControlEventTouchUpInside];
    
    // 设置标题
    self.navigationItem.title = kLoadStringWithKey(@"DeviceEdit_VC_title");
}


//  leftItem 按钮点击事件 --> 返回上一级界面
- (void)leftBarButtonDidClicked:(UIButton *)sender
{
    [self.navigationController popViewControllerAnimated:YES];
}

#pragma mark - 保存资料
- (void)rightBarButtonDidClicked:(UIButton *)sender
{
    
    /** 保存用户信息  */
    [self save];
}

//TODO: 测试使用
- (void)Get
{
//    GET http://120.25.225.5:8090/kmhc-modem-restful/services/member/deviceManager/13823641029/865946021011109?type=hr
    // 创建请求地址
    NSString *deviceListURL = [NSString stringWithFormat:@"deviceManager/%@/%@?type=body", member.loginAccount,self.detailModel.imei];
    
    // 发送网络请求
    [SVProgressHUD show];
    [[KMNetAPI manager] commonGetRequestWithURL:deviceListURL Block:^(int code, NSString *res)
     {
         [SVProgressHUD dismiss];
         KMNetworkResModel *resModel = [KMNetworkResModel mj_objectWithKeyValues:res];
         NSLog(@"resModel-----%@",resModel.content);
     }];
    
}

- (void)Post
{
//    URL	/kmhc-modem-restful/services/member/deviceManager/sit/{account}/{imei}

    // 创建网络地址
    NSString *postURL = [NSString stringWithFormat:@"deviceManager/body/%@/%@",
                         member.loginAccount,
                         self.detailModel.imei];
    

    NSDictionary * body = @{@"step":@1,
                            @"height":@1,
                            @"weight":@1,
                            @"age":@1,
                            @"sex":@1,};
    
    // 发送网络请求
    [SVProgressHUD show];
    [[KMNetAPI manager] commonPOSTRequestWithURL:postURL jsonBody:[body mj_JSONString] Block:^(int code, NSString *res)
     {
         [SVProgressHUD dismiss];
         KMNetworkResModel *resModel = [KMNetworkResModel mj_objectWithKeyValues:res];
         
         NSLog(@"resModel-----%@",resModel.content);
         
     }];
}


// 保存用户信息
- (void)save
{
    [self.view endEditing:YES];
    // 如果用户更新了头像
    if (_userHeaderImage) {
        [SVProgressHUD show];
        
        // 更换头像，清除缓存
        [[SDImageCache sharedImageCache] clearMemory];
        [[SDImageCache sharedImageCache] clearDiskOnCompletion:nil];
        
        // 发起网络请求
        [[KMNetAPI manager] updateUserHeaderWithIMEI:self.detailModel.imei header:_userHeaderImage block:^(int code, NSString *res)
         {
             KMNetworkResModel *resModel = [KMNetworkResModel mj_objectWithKeyValues:res];
             if (code == 0 && resModel.errorCode <= kNetReqSuccess)
             {
                 [self updateUserInfo];
             } else
             {
                 [SVProgressHUD showErrorWithStatus:kNetReqFailWithCode(resModel.errorCode)];
             }
         }];
    } else
    {
        [self updateUserInfo];
    }

    
}


/**
 *  对用户信息进行更新
 *  wearersInfo/{account}/{imei}
 */
- (void)updateUserInfo
{
    WS(ws);
    // 创建网络地址
    NSString *postURL = [NSString stringWithFormat:@"wearersInfo/%@/%@",
                         member.loginAccount,
                         self.detailModel.imei];
    
    // 发送网络请求
    [SVProgressHUD show];
    [[KMNetAPI manager] commonPOSTRequestWithURL:postURL jsonBody:[self.detailModel mj_JSONString] Block:^(int code, NSString *res)
     {
         // 暂停刷新状态、解析数据模型
         [SVProgressHUD dismiss];
        KMNetworkResModel *resModel = [KMNetworkResModel mj_objectWithKeyValues:res];
         
         // 操作数据模型
        if (code == 0 && resModel.errorCode <= kNetReqSuccess)
        {
            // 保存用户手表类型到本地
            [KMMemberManager addUserWatchType:_selectWatchType IMEI:_detailModel.imei];
            [SVProgressHUD showSuccessWithStatus:kLoadStringWithKey(@"Common_save_success")];
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.5 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                [ws.navigationController popViewControllerAnimated:YES];
            });
        } else
        {
            [SVProgressHUD showErrorWithStatus:kNetReqFailWithCode(resModel.errorCode)];
        }
    }];
}


#pragma mark - 配置子视图模块
- (void)configView
{
    // 头像选择按钮
    self.headImageView = [KMRoundAddView buttonWithType:UIButtonTypeCustom];
    [self.view addSubview:self.headImageView];
    [self.headImageView mas_makeConstraints:^(MASConstraintMaker *make)
     {
         make.width.height.equalTo(@kHeadWidth);
         make.top.equalTo(@(kEdgeOffset + (IS_IPHONE_X ? 88 : 64)));
         make.right.equalTo(self.view.mas_centerX).offset(-40);
     }];
    [self.headImageView.bottomImageView sdImageWithIMEI:self.detailModel.imei];
    self.headImageView.bottomImageView.layer.cornerRadius = kHeadWidth/2.0;
    self.headImageView.contentMode = UIViewContentModeScaleAspectFit;
    self.headImageView.bottomImageView.clipsToBounds = YES;
    [self.headImageView addTarget:self action:@selector(headImageButtonDidClicked:)
                 forControlEvents:UIControlEventTouchUpInside];
    
    // 手表按钮选择按钮 - 10
    self.watchBtn = [KMRoundAddView buttonWithType:UIButtonTypeCustom];
    [self.view addSubview:self.watchBtn];
    [self.watchBtn mas_makeConstraints:^(MASConstraintMaker *make)
     {
         make.top.width.height.equalTo(self.headImageView);
         make.left.equalTo(self.view.mas_centerX).offset(40);
     }];
    self.selectWatchType = [KMMemberManager userWatchTypeWithIMEI:_detailModel.imei];
    self.watchBtn.bottomImageView.image = [self watchImageWithType:self.selectWatchType];
    self.watchBtn.bottomImageView.contentMode = UIViewContentModeScaleAspectFit;
    self.watchBtn.bottomImageView.layer.cornerRadius = kHeadWidth/2.0;
    self.watchBtn.bottomImageView.clipsToBounds = YES;
    self.watchBtn.tag = 10;
    [self.watchBtn addTarget:self action:@selector(watchSelBtnDidClicked:)
            forControlEvents:UIControlEventTouchUpInside];
    
    
    // 相关设定
    self.tableView = [[UITableView alloc] init];
    [self.view addSubview:self.tableView];
    [self.tableView mas_makeConstraints:^(MASConstraintMaker *make)
     {
         make.left.right.bottom.equalTo(self.view);
         make.top.equalTo(self.headImageView.mas_bottom).offset(kEdgeOffset);
     }];
    self.tableView.tableFooterView = [[UIView alloc] init];
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    self.tableView.rowHeight = 70;
}



#pragma mark - 选择头像模块
- (void)headImageButtonDidClicked:(UIButton *)sender
{
    WS(ws);
    NSString * title = kLoadStringWithKey(@"DeviceSetting_VC_edit_header_src");
    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:title
     message:@""  preferredStyle:UIAlertControllerStyleActionSheet];
    
    // 照相机
    title = kLoadStringWithKey(@"DeviceSetting_VC_edit_header_src_camera");
    UIAlertAction *cameraAction = [UIAlertAction actionWithTitle:title
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
    WS(ws);
    [picker dismissViewControllerAnimated:YES completion:^{
        if (img) {
            _userHeaderImage = img;
            ws.headImageView.bottomImageView.image = _userHeaderImage;
        }
    }];
}

- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker
{
    [picker dismissViewControllerAnimated:YES completion:nil];
}



#pragma mark - UITableViewDataSource模块
// Section
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 2;
}

// row
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    NSInteger rows = 0;
    switch (section)
    {
        case 0:
            rows = 4;
            break;
        case 1:
            if ([self.detailModel.type isEqualToString:@"20"]) {
                
                rows = self.settingTitleArray.count-1;
            }else{
                
                rows = self.settingTitleArray.count;
            }
            break;
        default:
            break;
    }
    return rows;
}

// cell
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell;
    switch (indexPath.section)
    {
        case 0:     // 上面三行
        {
            KMCommonInputCell *commonCell = [tableView dequeueReusableCellWithIdentifier:@"commonCell"];
            [commonCell.accessoryView removeFromSuperview];
            if (commonCell == nil) {
                commonCell = [[KMCommonInputCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"commonCell"];
            }
            commonCell.textField.delegate = self;
            commonCell.textField.enabled = YES;
            commonCell.textField.tag = indexPath.row;
            commonCell.selectionStyle = UITableViewCellSelectionStyleNone;
            
            switch (indexPath.row)
            {
                case 0:     // 用户名
                {
                    commonCell.imageView.image = [UIImage imageNamed:@"edit_name"];
                    commonCell.textField.placeholder = kLoadStringWithKey(@"Reg_VC_tip_nickname");
                    commonCell.textField.text = self.detailModel.realName;
                } break;
                case 1:     // 电话
                {
                    commonCell.imageView.image = [UIImage imageNamed:@"edit_phone"];
                    commonCell.textField.placeholder = kLoadStringWithKey(@"DeviceSetting_VC_add_phone");
                    commonCell.textField.text = self.detailModel.phone;
                    commonCell.textField.keyboardType = UIKeyboardTypePhonePad;
                } break;
                case 2:     // IMEI, 不可修改
                {
                    commonCell.imageView.image = [UIImage imageNamed:@"edit_imei"];
                    commonCell.textField.text = self.detailModel.imei;
                    commonCell.textField.enabled = NO;
                    commonCell.textField.textColor = kGrayContextColor;
                } break;
                case 3:     // 是否为当前使用设备
                {
                    commonCell.imageView.image = [UIImage imageNamed:@"edit_choose.png"];
                    commonCell.textField.text =  kLoadStringWithKey(@"DeviceEdit_VC_setting_title_myWear");
                    commonCell.textField.enabled = NO;
                    commonCell.textField.textColor = kGrayContextColor;
                    
                    UISwitch * mySwitch = [[UISwitch alloc] init];
                    commonCell.accessoryView = mySwitch;
                    [mySwitch addTarget:self action:@selector(setSwitchValueChangedAction:) forControlEvents:UIControlEventValueChanged];
                    if (self.detailModel.myWear == 1)
                    {
                        mySwitch.on = YES;
                    }else
                    {
                        mySwitch.on = NO;
                    }
                    
                } break;
                    
                default:
                    break;
            }
            cell = commonCell;
        } break;
        case 1:     // 下面section
        {
            KMDeviceSettingEditCell *editCell = [tableView dequeueReusableCellWithIdentifier:@"cell"];
            if (editCell == nil) {
                editCell = [[KMDeviceSettingEditCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"cell"];
            }
            
            editCell.titleLabel.text = self.settingTitleArray[indexPath.row];
            editCell.detailLabel.text = self.settingDetailArray[indexPath.row];
            
            cell = editCell;
        } break;
        default:
            break;
    }
    
    if (self.traitCollection.forceTouchCapability == UIForceTouchCapabilityAvailable) {
//        NSLog(@"3D Touch  可用!");
        //给cell注册3DTouch的peek（预览）和pop功能
//        [self registerForPreviewingWithDelegate:self sourceView:cell];
    } else {
//        NSLog(@"3D Touch 无效");
    }

    return cell;
}


/**
 *  MySwitch 事件
 *
 */
-(void)setSwitchValueChangedAction:(UISwitch *)mySwitch
{
    
    if (mySwitch.on ==YES)
    {
        self.detailModel.myWear = 1;
    }else
    {
        self.detailModel.myWear = 0;
    }
}



#pragma mark - UITableViewDelegate 模块

// cell 高度
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    CGFloat height = 0;
    switch (indexPath.section) {
        case 0:
            height = 50;
            break;
        case 1:
            height = 70;
            break;
        default:
            break;
    }
    
    return height;
}

// 分区高度
- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    if (section == 1)
    {
        return 20;
    }
    
    return 0;
}


// 分区视图
- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    UIView *footer;
    if (section == 1)
    {
        footer = [UIView new];
        
        footer.backgroundColor = kGrayBackColor;
    }
    
    return footer;
}



// UITableView 选中事件处理
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:NO];
    
    if (indexPath.section == 1)
    {
        switch (indexPath.row)
        {
            case 0:// 认证码
            {
                KMAuthCodeEditVC * authVC = [[KMAuthCodeEditVC alloc] init];
                authVC.imei = self.detailModel.imei;
                [self.navigationController pushViewController:authVC animated:YES];
            }
                break;
            case 1:     // 硬体设定
            {
                KMDeviceSettingDetailVC *vc = [[KMDeviceSettingDetailVC alloc] init];
                vc.imei = self.detailModel.imei;
                vc.type = self.detailModel.type;
                [self.navigationController pushViewController:vc animated:YES];
            }
                break;
            case 2:     // 拨号设定
            {
                KMDeviceSettingDetailCallVC *vc = [[KMDeviceSettingDetailCallVC alloc] init];
                vc.imei = self.detailModel.imei;
                vc.type = self.detailModel.type;
                [self.navigationController pushViewController:vc animated:YES];
            }
                break;
            case 3:     // 运动计步
            {
                KMDeviceSettingDetailBodyVC *vc = [[KMDeviceSettingDetailBodyVC alloc] init];
                vc.imei = self.detailModel.imei;
                vc.type = self.detailModel.type;
                [self.navigationController pushViewController:vc animated:YES];
            }
                break;
            case 4:     // 提醒设定
            {
                if ([self.detailModel.type isEqualToString:@"20"]) {
                    
                    KM8020RemindSettingVC *vc = [[KM8020RemindSettingVC alloc] init];
                    vc.imei = self.detailModel.imei;
                    vc.title = kLoadStringWithKey(@"DeviceEdit_VC_setting_title_device_remind");;
                    [self.navigationController pushViewController:vc animated:YES];
                    
                }else{
                    
                    KMRemindSettingVC *vc = [[KMRemindSettingVC alloc] init];
                    vc.imei = self.detailModel.imei;
                    vc.type = self.detailModel.type;
                    [self.navigationController pushViewController:vc animated:YES];
                    
                }
            }
                break;
            case 5:// 健康设置
            {
                KMHealthSettingVC * vc = [[KMHealthSettingVC alloc] init];
                vc.imei = self.detailModel.imei;
                vc.type = self.detailModel.type;
                [self.navigationController pushViewController:vc animated:YES];
                
            } break;
                
            case 6:// 重置
            {
                // 调用重置信息对话框；
                [self resetInfomationSessionView];
            } break;
                
            default:
                break;
        }
    }
}

/**
 *   设置类型
 */
- (DeviceType)returnDeviceTypeWithString:(NSString *)type
{
    NSInteger number = [type integerValue];
    
    switch (number)
    {
        case 1:
            return DeviceType_8000;
            break;
        case 2:
            return DeviceType_8010;
            break;
        case 3:
            return DeviceType_8020;
            break;
        default:
            return DeviceType_NO;
            break;
    }
}


// 重置信息功能 --> resetButton
-(void)resetButtonDidClickedAction:(UIButton *)sender
{
    [self.resetAlert close];
    NSInteger index = sender.tag - 300;
    if (index == 2)
    {
        //1.防止Block循环引用；
        WS(ws);
        //2.进行数据重置请求；
        NSString * request = [NSString stringWithFormat:@"defaultDeviceSetting/%@/%@",member.loginAccount,self.detailModel.imei];
        [[KMNetAPI manager] commonGetRequestWithURL:request Block:^(int code, NSString *res)
         {
             KMNetworkResModel * resModel = [KMNetworkResModel mj_objectWithKeyValues:res];
             if (code == 0 && resModel.errorCode <= kNetReqSuccess)
             {
                 [ws resetActionWithIndex:1];
             }else
             {
                 [ws resetActionWithIndex:2];
             }
         }];
    }
}

// 重置操作对话框
-(void)resetInfomationSessionView
{
    self.resetAlert = [[CustomIOSAlertView alloc] init];
    KMCommonAlertView * contentView = [[KMCommonAlertView alloc] initWithFrame:CGRectMake(0,0,240,200)];
    contentView.buttonsArray = @[kLoadStringWithKey(@"DeviceSetting_VC_YES"),kLoadStringWithKey(@"DeviceSetting_VC_NO")];
    contentView.titleLabel.text = kLoadStringWithKey(@"DeviceEdit_VC_setting_title_device_reset");
    contentView.msgLabel.text = kLoadStringWithKey(@"DeviceEdit_VC_setting_title_device_reset_msg");
    
    //获取button 设置button点击事件；
    UIButton * noButton = contentView.realButtons[0];
    UIButton * yesButton = contentView.realButtons[1];
    noButton.tag = 302;
    yesButton.tag = 301;
    [noButton addTarget:self action:@selector(resetButtonDidClickedAction:) forControlEvents:UIControlEventTouchDown];
    [yesButton addTarget:self action:@selector(resetButtonDidClickedAction:) forControlEvents:UIControlEventTouchDown];
    
    self.resetAlert.containerView = contentView;
    [self.resetAlert setButtonTitles:nil];
    [self.resetAlert setUseMotionEffects:NO];
    [self.resetAlert show];
    
}

// 重置操作结果提示
-(void)resetActionWithIndex:(NSInteger)index
{
    // 提示框
    self.resetAlert = [[CustomIOSAlertView alloc] init];
    self.resetAlert.buttonTitles = nil;
    [self.resetAlert setUseMotionEffects:NO];
    
    UIView * alertView = [[UIView alloc] initWithFrame:CGRectMake(0,0,SCREEN_WIDTH*0.9,150)];
    alertView.backgroundColor = [UIColor whiteColor];
    self.resetAlert.containerView = alertView;
    // 图标
    UIImageView * fail = [[UIImageView alloc] init];
    [alertView addSubview:fail];
    [fail mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.equalTo(alertView);
        make.width.height.mas_equalTo(60);
        make.top.mas_equalTo(25);
    }];
    fail.image = [UIImage imageNamed:@"pop_icon_fail"];
    //信息
    UILabel * massage = [[UILabel alloc] init];
    [alertView addSubview:massage];
    [massage mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.right.mas_equalTo(0);
        make.height.mas_equalTo(30);
        make.top.equalTo(fail.mas_bottom).offset(15);
    }];
    massage.textAlignment = NSTextAlignmentCenter;
    
    if (index == 1)
    {
        fail.image = [UIImage imageNamed:@"pop_icon_success"];
        massage.text = kLoadStringWithKey(@"DeviceEdit_VC_setting_title_device_reset_success");
        [self.resetAlert show];
    }else
    {
        fail.image = [UIImage imageNamed:@"pop_icon_fail"];
        massage.text = kLoadStringWithKey(@"DeviceEdit_VC_setting_title_device_reset_fail");
        [self.resetAlert show];
    }
    
    //移除提示框
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^
                   {
                       [self.resetAlert close];
                   });
}


#pragma mark - UITextFieldDelegate
- (void)textFieldDidEndEditing:(UITextField *)textField
{
    switch (textField.tag)
    {
        case 0:     // 用户名
            self.detailModel.realName = textField.text;
            break;
        case 1:
            self.detailModel.phone = textField.text;
            break;
        default:
            break;
    }
}

-(BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string
{
    if (textField.text.length >=15)
    {
        if (string.length == 0)  return YES;
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

#pragma mark - Carousel

- (NSInteger)numberOfItemsInCarousel:(iCarousel *)carousel
{
    return 3;
}

- (UIView *)carousel:(iCarousel *)carousel viewForItemAtIndex:(NSInteger)index reusingView:(UIView *)view
{
    //create new view if no view is available for recycling
    if (view == nil)
    {
        view = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 100, 100)];
        view.contentMode = UIViewContentModeScaleAspectFit;
        switch (index) {
            case KM_WATCH_TYPE_GRAY:
                ((UIImageView *)view).image = [UIImage imageNamed:@"set_button_gray_big"];
                break;
            case KM_WATCH_TYPE_RED:
                ((UIImageView *)view).image = [UIImage imageNamed:@"set_button_red_big"];
                break;
            case KM_WATCH_TYPE_YELLOW:
                ((UIImageView *)view).image = [UIImage imageNamed:@"set_button_yellow_big"];
                break;
            default:
                break;
        }
    }
    
    return view;
}

- (CGFloat)carousel:(iCarousel *)_carousel valueForOption:(iCarouselOption)option withDefault:(CGFloat)value
{
    //customize carousel display
    switch (option)
    {
        case iCarouselOptionSpacing:
        {
            //add a bit of spacing between the item views
            return value * 2.05f;
        }
        default:
        {
            return value;
        }
    }
}

- (void)carouselDidEndScrollingAnimation:(iCarousel *)carousel
{

}

#pragma mark - 选择手表样式
- (UIView *)createWatchSelectView
{
    KMCommonAlertView *view = [[KMCommonAlertView alloc] initWithFrame:CGRectMake(0, 0, 300, 250)];
    view.titleLabel.text = kLoadStringWithKey(@"DeviceEdit_VC_watch_select_title");
    view.buttonsArray = @[kLoadStringWithKey(@"Common_OK")];
    UIButton *btn = view.realButtons[0];
    btn.tag = 100;
    [btn addTarget:self action:@selector(watchSelBtnDidClicked:) forControlEvents:UIControlEventTouchUpInside];
    
    // 手表选择滑动view
    self.carouselView = [[iCarousel alloc] init];
    self.carouselView.type = iCarouselTypeRotary;
    self.carouselView.dataSource = self;
    self.carouselView.delegate = self;
    [view.customerView addSubview:self.carouselView];
    [self.carouselView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.equalTo(view.customerView).insets(UIEdgeInsetsMake(0, 35, 0, 35));
    }];
    
    // 左边选择按钮
    UIButton *leftSelBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    leftSelBtn.tag = 101;
    leftSelBtn.imageView.contentMode = UIViewContentModeScaleAspectFit;
    [leftSelBtn setImage:[UIImage imageNamed:@"pop_button_left"]
                forState:UIControlStateNormal];
    [leftSelBtn addTarget:self
                   action:@selector(watchSelBtnDidClicked:)
         forControlEvents:UIControlEventTouchUpInside];
    [view.customerView addSubview:leftSelBtn];
    [leftSelBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(view.customerView).offset(5);
        make.top.bottom.equalTo(view.customerView);
        make.width.equalTo(@30);
    }];
    
    // 右边的按钮
    UIButton *rightSelBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    rightSelBtn.tag = 102;
    rightSelBtn.imageView.contentMode = UIViewContentModeScaleAspectFit;
    [rightSelBtn setImage:[UIImage imageNamed:@"pop_button_right"]
                 forState:UIControlStateNormal];
    [rightSelBtn addTarget:self
                    action:@selector(watchSelBtnDidClicked:)
          forControlEvents:UIControlEventTouchUpInside];
    [view.customerView addSubview:rightSelBtn];
    [rightSelBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.right.equalTo(view.customerView).offset(-5);
        make.top.bottom.equalTo(view.customerView);
        make.width.equalTo(@30);
    }];
    
    return view;
}

#pragma mark - 手表选择
- (void)watchSelBtnDidClicked:(UIButton *)sender
{
    switch (sender.tag) {
        case 10:       // 开始切换手表
        {
            self.watchSelectView = [[CustomIOSAlertView alloc] init];
            self.watchSelectView.containerView = [self createWatchSelectView];
            self.watchSelectView.buttonTitles = nil;
            [self.watchSelectView setUseMotionEffects:NO];
            [self.watchSelectView show];
            // 切换到当前用户选择的手表
            [self.carouselView scrollToItemAtIndex:self.selectWatchType animated:YES];
        } break;
        case 100:       // 切换手表确认
        {
            self.selectWatchType = (NSInteger)self.carouselView.scrollOffset;
            self.watchBtn.bottomImageView.image = [self watchImageWithType:self.selectWatchType];
            
            // 删除弹出view
            self.carouselView.delegate = nil;
            self.carouselView.dataSource = nil;
            [self.carouselView removeFromSuperview];
            self.carouselView = nil;
            [self.watchSelectView removeFromSuperview];
            self.watchSelectView = nil;
        } break;
        case 101:       // 左边按钮
        {
            NSInteger index = (NSInteger)self.carouselView.scrollOffset + 1;
            [self.carouselView scrollToItemAtIndex:index animated:YES];
        } break;
        case 102:       // 右边按钮
        {
            NSInteger index = (NSInteger)self.carouselView.scrollOffset - 1;
            [self.carouselView scrollToItemAtIndex:index animated:YES];
        } break;
        default:
            break;
    }
}

// 根据类型返回手表样式
- (UIImage *)watchImageWithType:(int)type
{
    UIImage *watchImage;
    switch (type)
    {
        case KM_WATCH_TYPE_GRAY:        // 灰
            watchImage = [UIImage imageNamed:@"set_button_gray_small"];
            break;
        case KM_WATCH_TYPE_RED:         // 红
            watchImage = [UIImage imageNamed:@"set_button_red_small"];
            break;
        case KM_WATCH_TYPE_YELLOW:      // 黄
            watchImage = [UIImage imageNamed:@"set_button_yellow_small"];
            break;
        default:
            break;
    }
    return watchImage;
}
@end
