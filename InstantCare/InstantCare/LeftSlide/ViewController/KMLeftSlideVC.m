//
//  KMLeftSlideVC.m
//  InstantCare
//
//  Created by 朱正晶 on 16/5/18.
//  Copyright © 2016年 omg. All rights reserved.
//

#import "KMLeftSlideVC.h"
#import "UIViewController+ECSlidingViewController.h"
#import "KMPersonalInformationVC.h"
#import "KMDeviceSettingVC.h"
#import "KMCommonAlertView.h"
#import "JPUSHService.h"
#import "KMWebViewVC.h"
#import "KMNetAPI.h"
#import "MJExtension.h"
//#import "KMCallVC.h"
//#import "UINavigationController+FDFullscreenPopGesture.h"

@interface KMLeftSlideVC () <UITableViewDelegate, UITableViewDataSource>

@property (nonatomic, strong) NSMutableArray *imageArray;
@property (nonatomic, strong) NSMutableArray *titleArray;

@end

@implementation KMLeftSlideVC

- (UIStatusBarStyle)preferredStatusBarStyle
{
    return UIStatusBarStyleLightContent;
}

- (BOOL)prefersStatusBarHidden
{
    return NO;
}
- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self initDataArray];
    [self configView];
}

- (void)initDataArray {
    self.imageArray = @[@"leftbar_porfile",
                        @"leftbar_set",
//                      @"leftbar_phone",
                        @"leftbar_help",
                        @ "leftbar_question",
                        @"leftbar_signout"].mutableCopy;
    
    self.titleArray = @[kLoadStringWithKey(@"SlideVC_person_info"),
                        kLoadStringWithKey(@"SlideVC_device_manage"),
//                      kLoadStringWithKey(@"SlideVC_device_call"),
                        kLoadStringWithKey(@"SlideVC_help"),
                        kLoadStringWithKey(@"SlideVC_question"),
                        kLoadStringWithKey(@"SlideVC_logout")].mutableCopy;
    
    // 设置马来差异
    #ifdef kApplicationMLVersion
    [self.imageArray removeObjectAtIndex:1];
    [self.titleArray removeObjectAtIndex:1];
        
    #else
        
    #endif
}

- (void)configView {
    self.view.backgroundColor = kGrayColor;
    
    UIImageView *topImageView = [UIImageView new];
    topImageView.clipsToBounds = YES;
    topImageView.image = [UIImage imageNamed:@"leftbar_bg"];
    topImageView.contentMode = UIViewContentModeScaleAspectFill;
    [self.view addSubview:topImageView];
    [topImageView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.top.equalTo(self.view);
        make.right.equalTo(self.view).offset(-44);
        make.height.equalTo(@(SCREEN_HEIGHT*0.3));
    }];
    
    UIImageView *iconImageView = [UIImageView new];
    iconImageView.image = [UIImage imageNamed:@"leftbar_icon"];
    [topImageView addSubview:iconImageView];
    [iconImageView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerY.equalTo(topImageView);
        make.left.equalTo(topImageView).offset(20);
        make.width.height.equalTo(@60);
    }];
    
    UILabel *versionLabel = [UILabel new];
    versionLabel.textColor = [UIColor whiteColor];
    versionLabel.font = [UIFont systemFontOfSize:18];
    NSDictionary *infoDic = [[NSBundle mainBundle] infoDictionary];
    versionLabel.text = [NSString stringWithFormat:@"%@: %@",
                         kLoadStringWithKey(@"MAIN_VC_version"),
                         infoDic[@"CFBundleShortVersionString"]];
    [self.view addSubview:versionLabel];
    [versionLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(iconImageView.mas_right).offset(10);
        make.centerY.equalTo(iconImageView);
        make.right.equalTo(self.view);
    }];
    
    UITableView *tableView = [[UITableView alloc] init];
    tableView.backgroundColor = [UIColor clearColor];
    tableView.backgroundView = [UIView new];
    tableView.delegate = self;
    tableView.dataSource = self;
    tableView.rowHeight = 50;
    tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    tableView.tableFooterView = [UIView new];
    [tableView registerClass:[UITableViewCell class] forCellReuseIdentifier:@"cell"];
    [self.view addSubview:tableView];
    [tableView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.right.bottom.equalTo(self.view);
        make.top.equalTo(topImageView.mas_bottom);
    }];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.imageArray.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"cell"];
    cell.imageView.image = [UIImage imageNamed:self.imageArray[indexPath.row]];
    cell.textLabel.text = self.titleArray[indexPath.row];
    cell.textLabel.textColor = [UIColor whiteColor];
    
    // cell透明
    cell.backgroundColor = [UIColor clearColor];
    cell.backgroundView = [UIView new];

    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:NO];
    
    NSInteger row = indexPath.row;
    
        // 设置马来差异
    #ifdef kApplicationMLVersion
    row = row!=0?row+1:row;
    #else
        
    #endif
    
    switch (row) {
        case 0:     // 个人资料
        {
            KMPersonalInformationVC *vc = [[KMPersonalInformationVC alloc] init];
            UINavigationController *nav = (UINavigationController *)self.slidingViewController.topViewController;
//            vc.fd_interactivePopDisabled = YES;
            [nav pushViewController:vc animated:NO];
        } break;
        case 1:     // 设备管理
        {
            KMDeviceSettingVC *vc = [KMDeviceSettingVC new];
            UINavigationController *nav = (UINavigationController *)self.slidingViewController.topViewController;
//            vc.fd_interactivePopDisabled = YES;
            [nav pushViewController:vc animated:NO];
        } break;
//        case 2: // 拨打电话
//        {
//            KMCallVC *vc = [[KMCallVC alloc] init];
//            UINavigationController *nav = (UINavigationController *)self.slidingViewController.topViewController;
//            [nav pushViewController:vc animated:NO];
//            
//        }break;
        case 2:    // 帮助文档
        {
            KMWebViewVC * webView = [[KMWebViewVC alloc] init];
            UINavigationController *nav = (UINavigationController *)self.slidingViewController.topViewController;
            webView.navigationTitle = kLoadStringWithKey(@"SlideVC_help");
            // 特殊处理
            webView.htmURL = @"_help";
//            nav.fd_interactivePopDisabled = YES;
            [nav pushViewController:webView animated:NO];
        }break;
        case 3:    // 常见问题
        {
            KMWebViewVC * webView = [[KMWebViewVC alloc] init];
            UINavigationController *nav = (UINavigationController *)self.slidingViewController.topViewController;
            webView.navigationTitle = kLoadStringWithKey(@"SlideVC_question");
            webView.htmURL = kLoadStringWithKey(@"HTML_type_question");
//            webView.fd_interactivePopDisabled = YES;
            [nav pushViewController:webView animated:NO];
        }break;
        case 4:     // 退出登录
        {
            CustomIOSAlertView * AlertView = [[CustomIOSAlertView alloc] init];
            KMCommonAlertView * contentView = [[KMCommonAlertView alloc] initWithFrame:CGRectMake(0, 0,SCREEN_WIDTH*0.8,180)];
            contentView.titleLabel.text = kLoadStringWithKey(@"Logout_title");
            contentView.msgLabel.text = kLoadStringWithKey(@"Logout_message");
            contentView.buttonsArray  = @[kLoadStringWithKey(@"DeviceSetting_VC_YES"),
                                          kLoadStringWithKey(@"DeviceSetting_VC_NO")];
            UIButton * cancelButton = contentView.realButtons[0];
            UIButton * okButton = contentView.realButtons[1];
            cancelButton.tag = 2002;
            okButton.tag = 2001;
            [cancelButton addTarget:self action:@selector(loginOutButtonClickedAction:) forControlEvents:UIControlEventTouchDown];
            [okButton addTarget:self action:@selector(loginOutButtonClickedAction:) forControlEvents:UIControlEventTouchDown];
            	
            [AlertView setContainerView:contentView];
            [AlertView setButtonTitles:nil];
            [AlertView setUseMotionEffects:NO];
            [AlertView show];
        } break;
        default:
            break;
    }
    
    [self.slidingViewController resetTopViewAnimated:NO];
}

#pragma mark --- 退出登录cell时间处理
-(void)loginOutButtonClickedAction:(UIButton *)sender
{
    KMCommonAlertView * contentView = (KMCommonAlertView *)sender.superview;
    CustomIOSAlertView * alertView = (CustomIOSAlertView *)contentView.superview;
    NSInteger index = sender.tag - 2000;
    if (index == 1){
        [alertView removeFromSuperview];
    }else{
        [alertView removeFromSuperview];
        //没有记住密码则清除密码
        if (!member.isSavePwd) {
            member.loginPd = @"";
        }
        
        // 从服务器中移除deviceToken
        UINavigationController *nav = (UINavigationController *)self.slidingViewController.topViewController;
        [SVProgressHUD showWithStatus:kLoadStringWithKey(@"MAIN_VC_menu_logout")];
        
        NSString *request = [NSString stringWithFormat:@"removeJPushToken/%@/%@",
                             member.loginAccount,
                             [JPUSHService registrationID]];

        [[KMNetAPI manager] commonGetRequestWithURL:request Block:^(int code, NSString *res) {
            KMNetworkResModel *resModel = [KMNetworkResModel mj_objectWithKeyValues:res];
            if (code == 0 && resModel.errorCode <= kNetReqSuccess) {
                dispatch_async(dispatch_get_main_queue(), ^{
                    [SVProgressHUD dismiss];
                    [nav dismissViewControllerAnimated:YES completion:nil];
                });
            } else {
                dispatch_async(dispatch_get_main_queue(), ^{
                    [SVProgressHUD dismiss];
                    [nav dismissViewControllerAnimated:YES completion:nil];
                });
            }
        }];
    }
}


@end
