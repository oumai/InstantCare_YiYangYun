//
//  KMBindDeviceListVC.m
//  InstantCare
//
//  Created by 朱正晶 on 16/5/23.
//  Copyright © 2016年 omg. All rights reserved.
//

#import "KMBindDeviceListVC.h"
#import "KMDeviceListCell.h"
#import "CustomIOSAlertView.h"
#import "MJRefresh.h"
#import "KMNetAPI.h"
#import "MJExtension.h"
#import "UIImageView+SDWebImage.h"
#import "KMDeviceSettingModel.h"
@interface KMBindDeviceListVC () <UITableViewDelegate, UITableViewDataSource>

@property (nonatomic, strong) UIButton *leftNavButton;

@property (nonatomic, strong) UITableView *tableView;

@property (nonatomic, strong) KMBundleDevicesModel *deviceListModel;

/**
 *  提示框
 */
@property(nonatomic,strong)CustomIOSAlertView * userAction;

@end

@implementation KMBindDeviceListVC

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self configNavBar];
    [self configView];
    
    [SVProgressHUD showWithStatus:kLoadStringWithKey(@"Common_network_request_now")];
    [self updateBindDeviceListFromServer];
}

- (void)configNavBar {
    self.leftNavButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [self.leftNavButton setBackgroundImage:[UIImage imageNamed:@"return_normal"]
                                  forState:UIControlStateNormal];
    [self.leftNavButton addTarget:self
                           action:@selector(backBarButtonDidClicked:)
                 forControlEvents:UIControlEventTouchUpInside];
    self.leftNavButton.frame = CGRectMake(0, 0, 30, 30);
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:self.leftNavButton];
    
    self.navigationItem.title = kLoadStringWithKey(@"BindDevice_VC_title");
}

- (void)configView {
    self.view.backgroundColor = [UIColor whiteColor];
    
    WS(ws);
    self.tableView = [[UITableView alloc] init];
    self.tableView.backgroundColor = [UIColor clearColor];
    self.tableView.backgroundView = [UIView new];
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    self.tableView.tableFooterView = [UIView new];
    self.tableView.rowHeight = 70;
    [self.tableView registerClass:[KMDeviceListCell class] forCellReuseIdentifier:@"cell"];
    self.tableView.mj_header = [MJRefreshNormalHeader headerWithRefreshingBlock:^{
        [ws updateBindDeviceListFromServer];
    }];
    [self.view addSubview:self.tableView];
    [self.tableView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.equalTo(self.view);
    }];
}

- (void)updateBindDeviceListFromServer {
    [[KMNetAPI manager] getDevicesListWithAccount:member.loginAccount Block:^(int code, NSString *res) {
        [SVProgressHUD dismiss];
        [_tableView.mj_header endRefreshing];
        KMNetworkResModel *resModel = [KMNetworkResModel mj_objectWithKeyValues:res];
        if (code == 0 && resModel.errorCode <= kNetReqSuccess) {
            _deviceListModel = [KMBundleDevicesModel mj_objectWithKeyValues:resModel.content];
            [_tableView reloadData];
        } else {
            [SVProgressHUD showErrorWithStatus:kNetReqFailWithCode(resModel.errorCode)];
            DMLog(@"*** DeviceList: %@", resModel.msg);
        }
    }];
}

#pragma mark - UITableView

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return _deviceListModel.list.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    KMDeviceListCell *cell = (KMDeviceListCell *)[tableView dequeueReusableCellWithIdentifier:@"cell"];
    KMBundleDevicesDetailModel *m = self.deviceListModel.list[indexPath.row];

    [cell.userHeaderImageView sdImageWithIMEI:m.imei];
    cell.userNameLabel.text = m.realName;
    cell.userPhoneLabel.text = m.phone;
    if ([self.detailModel.imei isEqualToString:m.imei]) {
        cell.accessoryType = UITableViewCellAccessoryCheckmark;
    } else {
        cell.accessoryType = UITableViewCellAccessoryNone;
    }

    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    
    
    if (![self.deviceListModel.list[indexPath.row] accept]){
        // 用户没有确认手表提示
        [self customAlertViewShowWithMessage:kLoadStringWithKey(@"DeviceSetting_VC_alert_select") withStatus:NO];
        [tableView deselectRowAtIndexPath:indexPath animated:NO];
        return ;
    }
    
    if ([self.delegate respondsToSelector:@selector(didSelectBindDeviceWithModel:)]) {
        [self.delegate didSelectBindDeviceWithModel:self.deviceListModel.list[indexPath.row]];
    }

    [self dismissViewControllerAnimated:YES completion:nil];
}

#pragma mark - 返回
- (void)backBarButtonDidClicked:(UIButton *)sender {
    
    [self dismissViewControllerAnimated:YES completion:nil];
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

@end
