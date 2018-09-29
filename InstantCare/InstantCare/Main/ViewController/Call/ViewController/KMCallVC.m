//
//  KMCallVC.m
//  InstantCare
//
//  Created by bruce-zhu on 15/12/1.
//  Copyright © 2015年 omg. All rights reserved.
//

#import "KMCallVC.h"
#import "KMCallCell.h"
#import "KMCallView.h"
#import "KMNetAPI.h"
#import "KMBundleDevicesModel.h"
#import "KMDeviceListCell.h"
#import "CustomIOSAlertView.h"
#import "KMCommonAlertView.h"
#import "KMDeviceSettingVC.h"
#import "KMDeviceEditVC.h"
#import "MJRefresh.h"
#import "MJExtension.h"
#import "UIImageView+SDWebImage.h"

@interface KMCallVC() <UITableViewDataSource, UITableViewDelegate, KMCallViewDelegate>

@property (nonatomic, strong) UITableView *tableView;
@property (nonatomic, strong) KMBundleDevicesModel *devicesListModel;
@property(nonatomic,strong)KMBundleDevicesDetailModel *selectedModel;
@property(nonatomic,strong)CustomIOSAlertView * callAction;
/**
 *  电话号码
 */
@property (nonatomic, copy) NSString *phoneNum;

@end

@implementation KMCallVC

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor whiteColor];
    
    [self configNavBar];
    [self configView];
    
}

- (void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    [self getDevicesFromServer];
}

- (void)configNavBar
{
    self.navigationItem.title = NSLocalizedStringFromTable(@"MAIN_VC_call_btn", APP_LAN_TABLE, nil);
    UIButton * leftButton = [UIButton buttonWithType:UIButtonTypeCustom];
    leftButton.frame = CGRectMake(0, 0, 30, 30);
    [leftButton setBackgroundImage:[UIImage imageNamed:@"return_normal"] forState:UIControlStateNormal];
    [leftButton setBackgroundImage:[UIImage imageNamed:@"return_sel"] forState:UIControlStateSelected];
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:leftButton];
    
    // 添加事件处理
    [leftButton addTarget:self action:@selector(leftBarButtonDidClickedAction:) forControlEvents:UIControlEventTouchDown];
}

// leftButton 按钮点击事件
-(void)leftBarButtonDidClickedAction:(UIButton *)sender
{
    [self.navigationController popViewControllerAnimated:YES];
}


- (void)configView
{
    
    WS(ws);
    
    self.tableView = [[UITableView alloc] init];
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    self.tableView.rowHeight = 65;
    self.tableView.tableFooterView  = [UIView new];
    [self.view addSubview:self.tableView];
    [self.tableView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.equalTo(self.view);
    }];
    self.tableView.mj_header = [MJRefreshNormalHeader headerWithRefreshingBlock:^{
        [ws getDevicesFromServer];
    }];
}

- (void)getDevicesFromServer
{
    [SVProgressHUD show];
    NSString *requestString = [NSString stringWithFormat:@"getbindDeviceWithWearersInfo/%@", member.loginAccount];
    [[KMNetAPI manager] commonGetRequestWithURL:requestString Block:^(int code, NSString *res) {
        [_tableView.mj_header endRefreshing];
        KMNetworkResModel *resModel = [KMNetworkResModel mj_objectWithKeyValues:res];
        if (code == 0 && resModel.errorCode <= kNetReqSuccess)
        {
            [SVProgressHUD dismiss];
            _devicesListModel = [KMBundleDevicesModel mj_objectWithKeyValues:resModel.content];
            if (_devicesListModel.list.count == 0)
            {
                [self jumpToBundleDeviceVC];
            }else
            {
                [_tableView reloadData];
            }
        } else {
            [SVProgressHUD showErrorWithStatus:kNetReqFailWithCode(resModel.errorCode)];
        }
    }];
}

- (void)jumpToBundleDeviceVC {
    self.callAction = [[CustomIOSAlertView alloc] init];
    KMCommonAlertView *view = [[KMCommonAlertView alloc] initWithFrame:CGRectMake(0, 0,300, 200)];
    view.titleLabel.text = kLoadStringWithKey(@"DeviceSetting_VC_select");
    view.titleLabel.backgroundColor = kRedColor;
    view.msgLabel.text = kLoadStringWithKey(@"DeviceSetting_VC_no_device_bind");
    view.buttonsArray = @[kLoadStringWithKey(@"DeviceSetting_VC_YES")];
    
    UIButton *cancelButton = view.realButtons[0];
    cancelButton.tag = 100;
    [cancelButton addTarget:self action:@selector(jumpToRealBundleDeviceVC:) forControlEvents:UIControlEventTouchUpInside];
    
    self.callAction.containerView = view;
    self.callAction.buttonTitles = nil;
    [self.callAction setUseMotionEffects:NO];
    
    [self.callAction show];
}

- (void)jumpToRealBundleDeviceVC:(UIButton *)sender {
    [self.callAction close];
    KMDeviceSettingVC *vc = [KMDeviceSettingVC new];
    [self.navigationController pushViewController:vc animated:YES];
}


- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.devicesListModel.list.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    KMDeviceListCell *cell = [tableView dequeueReusableCellWithIdentifier:@"cell"];
    if (cell == nil) {
        cell = [[KMDeviceListCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"cell"];
    }
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

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:NO];
    self.selectedModel= self.devicesListModel.list[indexPath.row];

    if (self.selectedModel.phone.length == 0 ){
        // 提示框
        self.callAction = [[CustomIOSAlertView alloc] init];
        
        // 提示框自定义视图；
        KMCommonAlertView * view = [[KMCommonAlertView alloc] initWithFrame:CGRectMake(0, 0,SCREEN_WIDTH*0.8,240)];
        
        // 设置提示框标题、按钮标题
        view.titleLabel.text = kLoadStringWithKey(@"DeviceSetting_VC_select");
        view.buttonsArray = @[@"取消",
                              @"设置"];
        //用户操作按钮添加点击事件
        //1.左侧按钮
        UIButton *btn = view.realButtons[0];
        btn.tag = 3001;
        [btn addTarget:self action:@selector(userOperation:) forControlEvents:UIControlEventTouchUpInside];
        
        //2.右侧按钮
        btn = view.realButtons[1];
        btn.tag = 3002;
        [btn addTarget:self action:@selector(userOperation:) forControlEvents:UIControlEventTouchUpInside];
        
        UIView * alertView = [[UIView alloc] initWithFrame:CGRectMake(0,0,SCREEN_WIDTH*0.9,150)];
        alertView.backgroundColor = [UIColor whiteColor];
        
        // 图标
        UIImageView * fail = [[UIImageView alloc] init];
        [alertView addSubview:fail];
        [fail mas_makeConstraints:^(MASConstraintMaker *make) {
            make.centerX.equalTo(alertView);
            make.width.height.mas_equalTo(60);
            make.top.mas_equalTo(15);
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
        massage.text = kLoadStringWithKey(@"Call_VC_noSet_phone");
        
        [view addSubview:alertView];
        [alertView mas_makeConstraints:^(MASConstraintMaker *make) {
            
            make.top.equalTo(view).offset(60);
            make.left.equalTo(view);
            make.right.equalTo(view);
            make.height.equalTo(@(140));
            
        }];
        
        self.callAction.containerView = view;
        self.callAction.buttonTitles = nil;
        [self.callAction setUseMotionEffects:NO];
        [self.callAction show];
        
        
        return;
    }
    
    NSString * phoneString = [NSString stringWithFormat:@"tel:%@",self.selectedModel.phone];
    [[UIApplication sharedApplication] openURL:[NSURL URLWithString:phoneString]];
    
//    [[UIApplication sharedApplication] openURL:[NSURL URLWithString:phoneString] options:@{} completionHandler:nil];
}

/**
 *  用户操作事件
 */
-(void)userOperation:(UIButton *)sender{
    
    // 获取tag 值用于区别不同的按钮点击并且关闭提示框
    NSInteger index = sender.tag - 3000;

    // 根据不同的按钮触发不同的事件
    // 1.取消操作
    if (index == 1)
    {
        // 关闭选择提示框
        [ self.callAction close];
    }
    
    // 2.设置操作
    if (index == 2)
    {
        KMDeviceEditVC *vc = [[KMDeviceEditVC alloc] init];
        vc.detailModel = self.selectedModel;
        [self.navigationController pushViewController:vc animated:YES];
        [ self.callAction close];
    }
    [ self.callAction close];
}



#pragma mark - 自定义提示框 《未使用》
-(void)customAlertView
{
    //提示框自定义视图；
    KMCommonAlertView * view = [[KMCommonAlertView alloc] initWithFrame:CGRectMake(0, 0,SCREEN_WIDTH*0.9,260)];
    view.titleLabel.text = @"选择执行的操作";
    view.buttonsArray = @[@"快速拨号",@"静音拨号"];
    
    //按钮点击事件；
    UIButton *btn = view.realButtons[0];
    btn.tag = 3001;
    [btn addTarget:self action:@selector(speedDialAction:) forControlEvents:UIControlEventTouchUpInside];
    btn = view.realButtons[1];
    btn.tag = 3002;
    [btn addTarget:self action:@selector(speedDialAction:) forControlEvents:UIControlEventTouchUpInside];
    
    //布局自定义提示框视图；
    //头像；
    UIImageView * icon = [[UIImageView alloc] init];
    [view.customerView addSubview:icon];
    [icon mas_makeConstraints:^(MASConstraintMaker *make) {
        make.height.width.mas_equalTo(60);
        make.centerX.equalTo(view.mas_centerX);
        make.bottom.equalTo(view.mas_centerY).offset(-5);
    }];
    [icon sdImageWithIMEI:self.selectedModel.imei];
    icon.layer.cornerRadius = 30;
    
    
    //姓名；
    UILabel * nameLabel = [[UILabel alloc] init];
    nameLabel.textAlignment = NSTextAlignmentCenter;
    [view addSubview:nameLabel];
    [nameLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.right.equalTo(@0);
        make.height.mas_equalTo(25);
        make.centerX.equalTo(view.mas_centerX);
        make.top.equalTo(icon.mas_bottom).offset(5);
    }];
    nameLabel.text = self.selectedModel.realName;
    
    //numberLabel
    UILabel * numberLabel = [[UILabel alloc] init];
    numberLabel.font = [UIFont systemFontOfSize:15];
    numberLabel.textAlignment = NSTextAlignmentCenter;
    [view addSubview:numberLabel];
    [numberLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(nameLabel.mas_bottom);
        make.height.mas_equalTo(30);
        make.left.right.mas_equalTo(0);
    }];
    numberLabel.text = self.selectedModel.phone;
    
    //提示框显示
    self.callAction.containerView = view;
    self.callAction.buttonTitles = nil;
    [self.callAction setUseMotionEffects:NO];
    [self.callAction show];
    
}


#pragma mark --- 快速拨号事件
-(void)speedDialAction:(UIButton *)sender{
    NSInteger index = sender.tag - 3000;
    [self.callAction close];
    if (index == 1) {
        NSString * phoneString = [NSString stringWithFormat:@"tel:%@",self.selectedModel.phone];
        [[UIApplication sharedApplication] openURL:[NSURL URLWithString:phoneString]];
        
    }else{
        self.callAction = [[CustomIOSAlertView alloc] init];
        //提示框自定义视图；
        KMCommonAlertView * view = [[KMCommonAlertView alloc] initWithFrame:CGRectMake(0, 0,SCREEN_WIDTH*0.9,180)];
        view.titleLabel.text = @"确认拨号";
        view.msgLabel.text = @"此拨号方式会产生额外的费用，是否确认以此方式拨打？";
        view.buttonsArray = @[@"否",@"是"];
        
        //按钮点击事件；
        UIButton *btn = view.realButtons[0];
        btn.tag = 3003;
        [btn addTarget:self action:@selector(muteDialAction:) forControlEvents:UIControlEventTouchUpInside];
        btn = view.realButtons[1];
        btn.tag = 3004;
        [btn addTarget:self action:@selector(muteDialAction:) forControlEvents:UIControlEventTouchUpInside];
        
        //提示框显示
        self.callAction.containerView = view;
        self.callAction.buttonTitles = nil;
        [self.callAction setUseMotionEffects:NO];
        [self.callAction show];
    }
}


#pragma mark --- 静音拨号点击事件
-(void)muteDialAction:(UIButton *)sender{
    NSInteger index = sender.tag - 3002;
    [self.callAction close];
    if (index == 2) {
        
        
    }
    
    
}

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
    NSLog(@"myWear:%d",myWear);
    
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


#pragma mark - KMCallViewDelegate
- (void)KMCallViewBtnDidClicked:(KMCallViewType)button
{
    switch (button) {
        case KM_CALL_TYPE_SPEED_CALL:       // 快速拨号
        {
            NSString *phoneNumber = [@"tel://" stringByAppendingString:self.phoneNum];
            [[UIApplication sharedApplication] openURL:[NSURL URLWithString:phoneNumber]];
        } break;
        case KM_CALL_TYPE_LISTION_CALL:     // 环境监听
            [SVProgressHUD showInfoWithStatus:@"LISTION_CALL"];
            break;
        default:
            break;
    }
}

@end
