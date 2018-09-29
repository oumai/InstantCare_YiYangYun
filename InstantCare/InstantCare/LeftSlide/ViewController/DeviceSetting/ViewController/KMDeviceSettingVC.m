//
//  KMDeviceSettingVC.m
//  InstantCare
//
//  Created by bruce-zhu on 15/12/2.
//  Copyright © 2015年 omg. All rights reserved.
//

#import "KMDeviceSettingVC.h"
#import "CustomIOSAlertView.h"
#import "KMImageTitleButton.h"
#import "KMDeviceEditVC.h"
#import "KMBundleDevicesModel.h"
#import "KMCommonAlertView.h"
#import "KMAddNewDeviceVC.h"
#import "KMDeviceListCell.h"
#import "KMPushMsgModel.h"
#import "MJExtension.h"
#import "MJRefresh.h"
#import "KMNetAPI.h"
#import "UIImageView+WebCache.h"
#import "UIImageView+SDWebImage.h"
#define kEdgeOffset         15
#define kTextFieldHeight    30

#define kButtonHeight       50

@interface KMDeviceSettingVC() <UITableViewDataSource, UITableViewDelegate, UIActionSheetDelegate, UINavigationControllerDelegate, UIImagePickerControllerDelegate>

@property (nonatomic, strong) UITableView *tableView;
// 添加设备
@property (nonatomic, strong) CustomIOSAlertView *addNewDeviceAlertView;
// 设备列表
@property (nonatomic, strong) KMBundleDevicesModel *devicesListModel;
/**
 *  当前正在操作的row
 */
@property (nonatomic, assign) NSInteger currentEditRow;
/**
 *  添加设备时用户选择的头像
 */
@property (nonatomic, strong) UIImage *userHeaderImage;
/**
 *  提示框
 */
@property(nonatomic,strong)CustomIOSAlertView * userAction;
/**
 *  保存当前选中的标识
 */
@property(nonatomic,strong)KMBundleDevicesDetailModel* selectedModel;

/** 选中IMEI */
@property (nonatomic, copy) NSString *selectedImei;

@end

@implementation KMDeviceSettingVC

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor whiteColor];
    
    [self configNavBar];
    [self configView];
    // 手表认证推动通知
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(kmReceiveRemoteNotification:)
                                                 name:@"kmReceiveRemoteNotification"
                                            object:nil];
}

/**
 *   手表认证推送
 */
- (void)kmReceiveRemoteNotification:(NSNotification*)notify
{
    NSDictionary *userInfo = notify.object;
    
    if (userInfo)
    {
        // 解析数据模型
        KMPushMsgModel *pushModel = [KMPushMsgModel mj_objectWithKeyValues:userInfo];
        if ([pushModel.content.type isEqualToString:@"BU"])
        {
            /** 关闭提示框  */
            if (self.userAction != nil) {
                
                [self.userAction close];
            }
            
            /** 进行数据刷新  */
            [self getDevicesFromServer];
        }
    }
}

/**
 *   视图将要显示
 */
- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self getDevicesFromServer];
}

/**
 *   视图销毁
 */
-(void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

/**
 *   配置导航栏
 */
- (void)configNavBar
{
    UIButton *leftNavButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [leftNavButton setBackgroundImage:[UIImage imageNamed:@"return_normal"]
                             forState:UIControlStateNormal];
    [leftNavButton addTarget:self
                      action:@selector(backBarButtonDidClicked:)
            forControlEvents:UIControlEventTouchUpInside];
    leftNavButton.frame = CGRectMake(0, 0, 30, 30);
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:leftNavButton];
    
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAdd
                                                                                           target:self
                                                                                           action:@selector(rightBarButtonDidClicked:)];

    self.navigationItem.title = kLoadStringWithKey(@"MAIN_VC_menu_device");
}

- (void)configView
{
    WS(ws);

    self.tableView = [[UITableView alloc] init];
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    self.tableView.rowHeight = 70;
    self.tableView.tableFooterView = [UIView new];
    [self.tableView registerClass:[KMDeviceListCell class] forCellReuseIdentifier:@"cell"];
    [self.view addSubview:self.tableView];
    [self.tableView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.equalTo(self.view);
    }];
    self.tableView.mj_header = [MJRefreshNormalHeader headerWithRefreshingBlock:^{
        [ws getDevicesFromServer];
    }];
}

#pragma mark - 新增设备
- (void)rightBarButtonDidClicked:(UIBarButtonItem *)item
{
    self.addNewDeviceAlertView = [[CustomIOSAlertView alloc] init];
    KMCommonAlertView *view = [[KMCommonAlertView alloc] initWithFrame:CGRectMake(0, 0,SCREEN_WIDTH*0.8, 220)];
    view.titleLabel.text = kLoadStringWithKey(@"DeviceSetting_VC_SIM");
    view.msgLabel.text = kLoadStringWithKey(@"DeviceSetting_VC_is_SIM");
    view.buttonsArray = @[kLoadStringWithKey(@"DeviceSetting_VC_NO"),
                          kLoadStringWithKey(@"DeviceSetting_VC_YES")];
    // cancelButton;
    UIButton *cancelButton = view.realButtons[0];
    cancelButton.tag = 100;
    [cancelButton addTarget:self action:@selector(simButtonDidClicked:) forControlEvents:UIControlEventTouchUpInside];
    
    // okButton;
    UIButton * okButton = view.realButtons[1];
    okButton.tag = 101;
    [okButton addTarget:self action:@selector(simButtonDidClicked:) forControlEvents:UIControlEventTouchUpInside];
    
    self.addNewDeviceAlertView.containerView = view;
    self.addNewDeviceAlertView.buttonTitles = nil;
    [self.addNewDeviceAlertView setUseMotionEffects:NO];

    [self.addNewDeviceAlertView show];
}

#pragma mark - 添加设备SIM卡确认
- (void)simButtonDidClicked:(UIButton *)sender {
    [self.addNewDeviceAlertView close];
    
    KMAddNewDeviceVC *vc = [KMAddNewDeviceVC new];
    switch (sender.tag) {
        case 100:       // 左边按钮
        {
            vc.flag = NO;
            [self.navigationController pushViewController:vc animated:YES];
        } break;
        case 101:       // 右边按钮
        {
            vc.flag = YES;
            [self.navigationController pushViewController:vc animated:YES];
        } break;
        default:
            break;
    }
}

- (void)deleteDeviceBtnDidClicked:(UIButton *)sender {
    [self.addNewDeviceAlertView close];
    switch (sender.tag) {
        case 100:       // 否
            // nothing to do
            break;
        case 101:       // 是
        {
            WS(ws);
            // unbindDevice/{account}/{imei}
            [SVProgressHUD showWithStatus:kLoadStringWithKey(@"Common_network_request_now")];
            KMBundleDevicesDetailModel *detailModel = self.devicesListModel.list[self.currentEditRow];
            NSString *request = [NSString stringWithFormat:@"unbindDevice/%@/%@",
                                 member.loginAccount,
                                 detailModel.imei];
            [[KMNetAPI manager] commonGetRequestWithURL:request Block:^(int code, NSString *res) {
                KMNetworkResModel *resModel = [KMNetworkResModel mj_objectWithKeyValues:res];
                if (code == 0 && resModel.errorCode <= kNetReqSuccess) {
                    [SVProgressHUD dismiss];
                    [ws getDevicesFromServer];
                } else {
                    [SVProgressHUD showErrorWithStatus:kNetReqFailWithCode(resModel.errorCode)];
                }
            }];
        } break;
        default:
            break;
    }
}

#pragma mark - 获取设备列表
- (void)getDevicesFromServer
{
    // 清除SD缓存，否则会出现头像不更新的情况
    [[SDImageCache sharedImageCache] clearDiskOnCompletion:nil];
//    [[SDImageCache sharedImageCache] clearMemory];
//    [[SDImageCache sharedImageCache] clearDiskOnCompletion:nil];
    
    // 创建请求地址
    NSString *deviceListURL = [NSString stringWithFormat:@"getbindDeviceWithWearersInfo/%@", member.loginAccount];
    
    // 发送网络请求
    [SVProgressHUD show];
    [[KMNetAPI manager] commonGetRequestWithURL:deviceListURL Block:^(int code, NSString *res)
    {
        // 暂停刷新状态、解析数据模型
        [SVProgressHUD dismiss];
        [_tableView.mj_header endRefreshing];
        KMNetworkResModel *resModel = [KMNetworkResModel mj_objectWithKeyValues:res];
        
        // 模型解析；
        if (code == 0 && resModel.errorCode <= kNetReqSuccess)
        {
            [SVProgressHUD dismiss];
            _devicesListModel = [KMBundleDevicesModel mj_objectWithKeyValues:resModel.content];
            [_tableView reloadData];
        } else
        {
            // 显示错误状态
            [SVProgressHUD showErrorWithStatus:kNetReqFailWithCode(resModel.errorCode)];
        }
    }];
}

#pragma mark - UITableView
/**
 *  返回编辑状态
 *
 */
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    return NO;
}

/**
 *  执行编辑操作
 *
 */
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        self.currentEditRow = indexPath.row;

        // 确认删除
        [self.addNewDeviceAlertView removeFromSuperview];
        
        self.addNewDeviceAlertView = [[CustomIOSAlertView alloc] init];
        KMCommonAlertView *view = [[KMCommonAlertView alloc] initWithFrame:CGRectMake(0, 0, 300, 200)];
        
        KMBundleDevicesDetailModel *detailModel = self.devicesListModel.list[indexPath.row];
        view.titleLabel.text = kLoadStringWithKey(@"DeviceSetting_VC_delete_confirm");
        view.msgLabel.text = [NSString stringWithFormat:@"%@\n%@", detailModel.realName, detailModel.imei];
        view.buttonsArray = @[kLoadStringWithKey(@"DeviceSetting_VC_NO"),
                              kLoadStringWithKey(@"DeviceSetting_VC_YES")];
        UIButton *btn = view.realButtons[0];
        btn.tag = 100;
        [btn addTarget:self action:@selector(deleteDeviceBtnDidClicked:) forControlEvents:UIControlEventTouchUpInside];
        btn = view.realButtons[1];
        btn.tag = 101;
        [btn addTarget:self action:@selector(deleteDeviceBtnDidClicked:) forControlEvents:UIControlEventTouchUpInside];
        
        self.addNewDeviceAlertView.containerView = view;
        self.addNewDeviceAlertView.buttonTitles = nil;
        [self.addNewDeviceAlertView setUseMotionEffects:NO];
        
        [self.addNewDeviceAlertView show];
    }
}


/**
 *  返回行数
 *
 */
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.devicesListModel.list.count;
}

/**
 *  返回显示对象
 *
 */
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    KMDeviceListCell *cell = (KMDeviceListCell *)[tableView dequeueReusableCellWithIdentifier:@"cell"];
    
    KMBundleDevicesDetailModel *detailModel = self.devicesListModel.list[indexPath.row];
    
    [cell.userHeaderImageView sdImageWithIMEI:detailModel.imei];
    cell.userNameLabel.text = detailModel.realName;
    if (detailModel.phone.length == 0)
    {
        cell.userPhoneLabel.text = kLoadStringWithKey(@"Call_VC_noSet_phone");
    }else
    {
        cell.userPhoneLabel.text = detailModel.phone;
    }
    cell.accessoryView = [self watchTypeViewWithType:[KMMemberManager userWatchTypeWithIMEI:detailModel.imei] withMywear:detailModel.myWear];

    return cell;
}

/**
 *  选择手表样式图片
 *
 *  @param type   手表类型
 *  @return 手表样式视图
 */
- (UIView *)watchTypeViewWithType:(int)type withMywear:(int)myWear{
    UIImageView *view = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 30, 30)];
    view.contentMode = UIViewContentModeScaleAspectFit;
    switch (type) {
        case KM_WATCH_TYPE_GRAY:        // 灰
            view.image = [UIImage imageNamed:@"set_icon_watch_gray"];
            break;
        case KM_WATCH_TYPE_RED:         // 红
            view.image = [UIImage imageNamed:@"set_icon_watch_red"];
            break;
        case KM_WATCH_TYPE_YELLOW:      // 黄
            view.image = [UIImage imageNamed:@"set_icon_watch_yellow"];
            break;
        default:
            break;
    }
    
    UILabel * label = [[UILabel alloc] init];
    label.adjustsFontSizeToFitWidth = YES;
    [view addSubview:label];
    [label mas_makeConstraints:^(MASConstraintMaker *make)
    {
        make.top.equalTo(view.mas_bottom).offset(-5);
        make.centerX.equalTo(view);
        make.height.mas_equalTo(20);
        make.width.mas_equalTo(45);
    }];
    
    label.textAlignment = NSTextAlignmentCenter;
    label.textColor  = [UIColor orangeColor];
    label.font = [UIFont systemFontOfSize:12];
    if (myWear == 1)
    {
        label.text = kLoadStringWithKey(@"DeviceSetting_VC_current_device");
    }else
    {
        label.text = @"";
    }
    return view;
}


#pragma mark 用户操作界面
/**
 *  cell 点击效果
 */
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    // 取消cell 选中效果
    [tableView deselectRowAtIndexPath:indexPath animated:NO];
    
    //保存选中的数据模型
    self.selectedModel = self.devicesListModel.list[indexPath.row];
    self.selectedImei = self.selectedModel.imei;
    
    //显示用户操作界面
    [self showUserOperationView];
}

/**
 *  显示用户操作提示框
 */
- (void)showUserOperationView
{
    // 提示框
    self.userAction = [[CustomIOSAlertView alloc] init];
    
    // 提示框自定义视图；
    KMCommonAlertView * view = [[KMCommonAlertView alloc] initWithFrame:CGRectMake(0, 0,SCREEN_WIDTH*0.8,220)];
    
    // 设置提示框标题、按钮标题
    view.titleLabel.text = kLoadStringWithKey(@"DeviceSetting_VC_select");
    view.buttonsArray = @[kLoadStringWithKey(@"DeviceSetting_VC_delete"),
                          kLoadStringWithKey(@"DeviceSetting_VC_edit")];
    
    //用户操作按钮添加点击事件
    //1.左侧按钮
    UIButton *btn = view.realButtons[0];
    btn.tag = 3001;
    [btn addTarget:self action:@selector(userOperation:) forControlEvents:UIControlEventTouchUpInside];
    
    //2.右侧按钮
    btn = view.realButtons[1];
    btn.tag = 3002;
    [btn addTarget:self action:@selector(userOperation:) forControlEvents:UIControlEventTouchUpInside];
    
    //布局自定义提示框视图；
    //头像
    UIImageView * icon = [[UIImageView alloc] init];
    [view.customerView addSubview:icon];
    [icon mas_makeConstraints:^(MASConstraintMaker *make) {
        make.height.width.mas_equalTo(50);
        make.centerX.equalTo(view.mas_centerX);
        make.bottom.equalTo(view.mas_centerY).offset(-5);
    }];
    [icon sdImageWithIMEI:self.selectedModel.imei];
    icon.layer.cornerRadius  = 25;
    icon.layer.masksToBounds = YES;
    
    //姓名
    UILabel * nameLabel = [[UILabel alloc] init];
    nameLabel.textAlignment = NSTextAlignmentCenter;
    [view addSubview:nameLabel];
    [nameLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.right.equalTo(@0);
        make.height.mas_equalTo(20);
        make.centerX.equalTo(view.mas_centerX);
        make.top.equalTo(icon.mas_bottom).offset(5);
    }];
    nameLabel.text = self.selectedModel.realName;
    
    //电话号码
    UILabel * numberLabel = [[UILabel alloc] init];
    numberLabel.font = [UIFont systemFontOfSize:15];
    numberLabel.textAlignment = NSTextAlignmentCenter;
    [view addSubview:numberLabel];
    [numberLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(nameLabel.mas_bottom);
        make.left.mas_equalTo(0);
        make.right.mas_equalTo(0);
        make.height.mas_equalTo(35);
    }];
    
    numberLabel.text = self.selectedModel.phone;
    if (self.selectedModel.phone.length == 0)
    {
        numberLabel.text = kLoadStringWithKey(@"Call_VC_noSet_phone");
    }
    
    //提示框显示
    self.userAction.containerView = view;
    self.userAction.buttonTitles = nil;
    [self.userAction setUseMotionEffects:NO];
    [self.userAction show];
}

/**
 *  用户操作事件
 */
-(void)userOperation:(UIButton *)sender{
    
    // 获取tag 值用于区别不同的按钮点击并且关闭提示框
    NSInteger index = sender.tag - 3000;
    [self.userAction close];
    
    // 根据不同的按钮触发不同的事件
    // 1.删除操作
    if (index == 1)
    {
        // 删除选择提示框
        [self showDeleteChooseView];
    }
    
    // 2.编辑操作
    if (index == 2)
    {
        // 手表确认判断
        if (self.selectedModel.accept)//
        {
            // 编辑界面
            KMDeviceEditVC *vc = [[KMDeviceEditVC alloc] init];
            vc.detailModel = self.selectedModel;
            [self.navigationController pushViewController:vc animated:YES];
        }else{
            
             // 用户没有确认手表提示
            [self userEditOperation];
        }
    }
}

/**
 *   用户操作方法
 */
- (void)userEditOperation
{
    WS(ws);
    // 清除SD缓存，否则会出现头像不更新的情况
    [[SDImageCache sharedImageCache] clearMemory];
    [[SDImageCache sharedImageCache] clearDiskOnCompletion:nil];
    
    // 创建请求地址
    NSString *deviceListURL = [NSString stringWithFormat:@"getbindDeviceWithWearersInfo/%@", member.loginAccount];
    
    // 发送网络请求
    [SVProgressHUD show];
    [[KMNetAPI manager] commonGetRequestWithURL:deviceListURL Block:^(int code, NSString *res)
     {
         // 暂停刷新状态、解析数据模型
         [SVProgressHUD dismiss];
         KMNetworkResModel *resModel = [KMNetworkResModel mj_objectWithKeyValues:res];
         
         // 模型解析；
         if (code == 0 && resModel.errorCode <= kNetReqSuccess)
         {
             [SVProgressHUD dismiss];
             _devicesListModel = [KMBundleDevicesModel mj_objectWithKeyValues:resModel.content];
             // 刷新界面
             [self.tableView reloadData];
             
             
             // 找到指定模型；
             KMBundleDevicesDetailModel * newModel;
             for (KMBundleDevicesDetailModel * model in _devicesListModel.list)
             {
                 if ([model.imei isEqualToString:ws.selectedImei])
                 {
                     newModel = model;
                     break;
                 }
             }
            
             // 赋值模型
             if (newModel !=nil ) {
                 
                 _selectedModel = newModel;
                 // 手表确认判断
                 if (self.selectedModel.accept)
                 {
                     // 编辑界面
                     KMDeviceEditVC *vc = [[KMDeviceEditVC alloc] init];
                     vc.detailModel = self.selectedModel;
                     [self.navigationController pushViewController:vc animated:YES];
                 }else{
                     
                     // 用户没有确认手表提示
                     [self customAlertViewShowWithMessage:kLoadStringWithKey(@"DeviceSetting_VC_alert_refresh") withStatus:NO];
                 }
             }else{
                 
                 // 用户没有确认手表提示
                 [self customAlertViewShowWithMessage:kLoadStringWithKey(@"DeviceSetting_VC_alert_delete") withStatus:NO];
                 return ;
             }
         } else
         {
             // 显示错误状态
             [SVProgressHUD showErrorWithStatus:kNetReqFailWithCode(resModel.errorCode)];
         }
     }];
}

#pragma mark --- 信息提示框显示
//显示信息提示框
-(void)customAlertViewShowWithMessage:(NSString *)message withStatus:(BOOL)status
{
    // 提示框
    self.userAction = [[CustomIOSAlertView alloc] init];
    self.userAction.buttonTitles = nil;
    [self.userAction setUseMotionEffects:NO];
    
    UIView * alertView = [[UIView alloc] initWithFrame:CGRectMake(0,0,SCREEN_WIDTH*0.9,220)];
    alertView.backgroundColor = [UIColor whiteColor];
    self.userAction.containerView = alertView;
    
    // 图标
    UIImageView * fail = [[UIImageView alloc] init];
    [alertView addSubview:fail];
    [fail mas_makeConstraints:^(MASConstraintMaker *make)
     {
         make.centerX.equalTo(alertView);
         make.width.height.mas_equalTo(70);
         make.bottom.equalTo(alertView.mas_centerY);
     }];
    if (!status)
    {
        fail.image = [UIImage imageNamed:@"pop_icon_fail"];
    }else
    {
        fail.image = [UIImage imageNamed:@"pop_icon_success"];
    }
    //信息
    UILabel * massageLabel = [[UILabel alloc] init];
    [alertView addSubview:massageLabel];
    [massageLabel mas_makeConstraints:^(MASConstraintMaker *make)
     {
         make.left.mas_equalTo(20);
         make.right.mas_equalTo(-20);
         make.height.mas_equalTo(80);
         make.top.equalTo(alertView.mas_centerY);
     }];
    massageLabel.textAlignment = NSTextAlignmentCenter;
    massageLabel.text = message;
    massageLabel.numberOfLines = 0;
    [self.userAction show];
}


#pragma mark - 用户删除界面
/**
 *  删除选择提示框
 */
- (void)showDeleteChooseView
{
    // 提示框
    self.userAction = [[CustomIOSAlertView alloc] init];
    
    //提示框自定义视图
    KMCommonAlertView * view = [[KMCommonAlertView alloc] initWithFrame:CGRectMake(0, 0,SCREEN_WIDTH*0.8,180)];
    view.titleLabel.text = kLoadStringWithKey(@"DeviceSetting_VC_select");
    view.buttonsArray = @[kLoadStringWithKey(@"DeviceSetting_VC_YES"),
                          kLoadStringWithKey(@"DeviceSetting_VC_NO")];
    
    view.msgLabel.text = kLoadStringWithKey(@"DeviceSetting_VC_delete_devices");
    
    // 删除提示框按钮添加点击事件
    //1.左侧按钮
    UIButton *btn = view.realButtons[0];
    btn.tag = 3001;
    [btn addTarget:self action:@selector(chooseYes) forControlEvents:UIControlEventTouchUpInside];
    
    //2.右侧按钮
    btn = view.realButtons[1];
    btn.tag = 3002;
    [btn addTarget:self action:@selector(chooseNO) forControlEvents:UIControlEventTouchUpInside];
    
    //提示框显示
    self.userAction.containerView = view;
    self.userAction.buttonTitles = nil;
    [self.userAction setUseMotionEffects:NO];
    [self.userAction show];
    
}


/**
 *  确认删除操作
 */
- (void)chooseYes
{
    // 关闭提示框
    [self.userAction close];
    
    // 调用删除设备的方法
    [self deleteDevice];
}

/**
 *  取消删除操作
 */
- (void)chooseNO
{
    // 关闭提示框
    [self.userAction close];
}

/**
 *  删除设备
 *  unbindDevice/{account}/{imei}
 */
- (void)deleteDevice
{
    WS(ws);
    // 设置网络请求连接
    KMBundleDevicesDetailModel *detailModel = self.selectedModel;
    NSString *request = [NSString stringWithFormat:@"unbindDevice/%@/%@",
                         member.loginAccount,
                         detailModel.imei];
    // 删除设备网络操作
    [SVProgressHUD show];
    [[KMNetAPI manager] commonGetRequestWithURL:request Block:^(int code, NSString *res)
    {
        // 解析网络模型
        KMNetworkResModel *resModel = [KMNetworkResModel mj_objectWithKeyValues:res];
        if (code == 0 && resModel.errorCode <= kNetReqSuccess)
        {
            [SVProgressHUD dismiss];
            [ws getDevicesFromServer];
            
        } else
        {
            // 显示错误提示
            [SVProgressHUD showErrorWithStatus:kNetReqFailWithCode(resModel.errorCode)];
        }
    }];
}

#pragma mark - 返回上一级界面
- (void)backBarButtonDidClicked:(UIButton *)sender {
    
    // 返回上一级界面
    [self.navigationController popToRootViewControllerAnimated:YES];
}


@end
