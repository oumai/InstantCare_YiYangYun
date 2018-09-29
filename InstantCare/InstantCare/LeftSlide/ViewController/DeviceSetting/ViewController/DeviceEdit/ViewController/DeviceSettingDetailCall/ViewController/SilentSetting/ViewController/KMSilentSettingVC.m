//
//  KMMuteSettingVC.m
//  InstantCare
//
//  Created by km on 16/9/1.
//  Copyright © 2016年 omg. All rights reserved.
//

#import "KMSilentSettingVC.h"
#import "KMSilentSettingModel.h"
#import "KMSilentRemindVC.h"
#import "MJRefresh.h"
#import "KMNetAPI.h"
#import "MJExtension.h"
@interface KMSilentSettingVC ()<UITableViewDataSource,UITableViewDelegate>

/** 数据模型 */
@property (nonatomic, strong) KMSilentSettingModel *silentModel;


@end

@implementation KMSilentSettingVC

// 视图加载完成
- (void)viewDidLoad {
    [super viewDidLoad];
    WS(ws);
    
    //  设置视图属性
    self.tableView.tableFooterView = [UIView new];
    self.tableView.mj_header = [MJRefreshNormalHeader headerWithRefreshingBlock:^{
        [ws loadDataFromNetwork];
    }];
   
    //  设置导航栏
    [self configNavBar];
}

// 视图将要显示
- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    // 开始网络请求
    [self loadDataFromNetwork];
}

// 进行网络请求
- (void)loadDataFromNetwork
{
    WS(ws);
    // 创建请求地址
    NSString *deviceListURL = [NSString stringWithFormat:@"deviceManager/%@/%@?type=silent", member.loginAccount,self.imei];
    
    // 发送网络请求
    [SVProgressHUD show];
    [[KMNetAPI manager] commonGetRequestWithURL:deviceListURL Block:^(int code, NSString *res)
     {
         // 暂停刷新状态、解析数据模型
         [SVProgressHUD dismiss];
         [ws.tableView.mj_header endRefreshing];
         KMNetworkResModel *resModel = [KMNetworkResModel mj_objectWithKeyValues:res];
         // 模型解析；
         if (code == 0 && resModel.errorCode <= kNetReqSuccess)
         {
             [SVProgressHUD dismiss];
             _silentModel = [KMSilentSettingModel mj_objectWithKeyValues:[resModel.content[@"list"] lastObject]];
            [ws.tableView reloadData];
         } else
         {
             // 显示错误状态
             [SVProgressHUD showErrorWithStatus:kNetReqFailWithCode(resModel.errorCode)];
         }
     }];

}

#pragma mark - 设置导航栏
- (void)configNavBar
{
    UIButton *leftButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [leftButton setBackgroundImage:[UIImage imageNamed:@"return_normal"] forState:UIControlStateNormal];
    [leftButton setBackgroundImage:[UIImage imageNamed:@"return_sel"] forState:UIControlStateSelected];
    leftButton.frame = CGRectMake(0, 0,30, 30);
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:leftButton];
    
    [leftButton addTarget:self action:@selector(leftBarButtonDidClickedAction:) forControlEvents:UIControlEventTouchDown];
}

/**
 *   返回上一级界面
 */
-(void)leftBarButtonDidClickedAction:(UIButton *)sender
{
    [self.navigationController popViewControllerAnimated:YES];
}

#pragma mark - UITableViewDataSource
/**
 *    分区
 */
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

/**
 *    分组
 */
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return 3;
}

/**
 *    数据对象
 */
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    //1.创建cell
    static NSString * identifer = @"Subtitle";
    UITableViewCell * cell = [tableView dequeueReusableCellWithIdentifier:identifer];
    if (cell == nil) {
        
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:identifer];
    }
    cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    
    //2.赋值cell
    switch (indexPath.row) {
        case 0:
            cell.textLabel.text = [NSString stringWithFormat:@"%@ ~ %@",self.silentModel.starttime1,self.silentModel.endtime1];
            cell.detailTextLabel.text = [self weekStringWithString:self.silentModel.dayflag1];
            break;
        case 1:
            cell.textLabel.text = [NSString stringWithFormat:@"%@ ~ %@",self.silentModel.starttime2,self.silentModel.endtime2];
            cell.detailTextLabel.text = [self weekStringWithString:self.silentModel.dayflag2];
            break;
        case 2:
            cell.textLabel.text = [NSString stringWithFormat:@"%@ ~ %@",self.silentModel.starttime3,self.silentModel.endtime3];
            cell.detailTextLabel.text = [self weekStringWithString:self.silentModel.dayflag3];
            break;
    }
    cell.detailTextLabel.textColor = [UIColor lightGrayColor];
    cell.textLabel.font = [UIFont systemFontOfSize:18];
    cell.detailTextLabel.font = [UIFont systemFontOfSize:14];
    //3.返回cell
    return cell;
}

// 获取日期字符串
- (NSString *)weekStringWithString:(NSString *)string{
    
    /** 判断设置周提醒  */
    if ([string isEqualToString:@"1111111"]) {
        
        return kLoadStringWithKey(@"DeviceManager_HealthSetting_alert_call_onceDay");
    }
    /** 判断位置提醒  */
    if ([string isEqualToString:@"0000000"]) {
        
        return kLoadStringWithKey(@"DeviceManager_HealthSetting_alert_call_unSet");
    }
    
/** 拆分字符  */
    NSInteger mon = [[string substringWithRange:NSMakeRange(0,1)] integerValue];
    NSInteger tue = [[string substringWithRange:NSMakeRange(1,1)] integerValue];
    NSInteger wed = [[string substringWithRange:NSMakeRange(2,1)] integerValue];
    NSInteger thu = [[string substringWithRange:NSMakeRange(3,1)] integerValue];
    NSInteger fri = [[string substringWithRange:NSMakeRange(4,1)] integerValue];
    NSInteger sat = [[string substringWithRange:NSMakeRange(5,1)] integerValue];
    NSInteger sun = [[string substringWithRange:NSMakeRange(6,1)] integerValue];
    
    NSMutableString *mutableString = [NSMutableString string];

// 一
    if (mon) {
        
         [mutableString appendString:kLoadStringWithKey(@"Remind_week_1")];
    }
    
// 二
    if (tue) {
        
        if (mutableString.length == 0) {
            
            [mutableString appendString:kLoadStringWithKey(@"Remind_week_2")];
        }else{
            
            [mutableString appendFormat:@"、%@",kLoadStringWithKey(@"Remind_week_2")];
        }
    }
    
// 三
    if (wed) {
        
        if (mutableString.length == 0) {
            
            [mutableString appendString:kLoadStringWithKey(@"Remind_week_3")];
        }else{
            
            [mutableString appendFormat:@"、%@",kLoadStringWithKey(@"Remind_week_3")];
        }
    }
// 四
    // 三
    if (thu) {
        
        if (mutableString.length == 0) {
            
            [mutableString appendString:kLoadStringWithKey(@"Remind_week_4")];
        }else{
            
            [mutableString appendFormat:@"、%@",kLoadStringWithKey(@"Remind_week_4")];
        }
    }
// 五
    if (fri) {
        
        if (mutableString.length == 0) {
            
            [mutableString appendString:kLoadStringWithKey(@"Remind_week_5")];
        }else{
            
            [mutableString appendFormat:@"、%@",kLoadStringWithKey(@"Remind_week_5")];
        }
    }
// 六
    if (sat) {
        
        if (mutableString.length == 0) {
            
            [mutableString appendString:kLoadStringWithKey(@"Remind_week_6")];
        }else{
            
            [mutableString appendFormat:@"、%@",kLoadStringWithKey(@"Remind_week_6")];
        }
    }
// 日
    if (sun) {
        
        if (mutableString.length == 0) {
            
            [mutableString appendString:kLoadStringWithKey(@"Remind_week_7")];
        }else{
            
            [mutableString appendFormat:@"、%@",kLoadStringWithKey(@"Remind_week_7")];
        }
    }
    
    return mutableString;
}



#pragma mark - UITableViewDelegate
/**
 *    cell点击事件
 */
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    KMSilentRemindVC * vc = [[KMSilentRemindVC alloc] init];
    vc.imei= self.imei;
    vc.index = indexPath.row;
    vc.model = self.silentModel;
    vc.title = kLoadStringWithKey(@"DeviceSettingDetailCall_VC_call_mute");
    [self.navigationController pushViewController:vc animated:YES];
    
}

/**
 *   返回cell高度
 */
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 70;
}



@end
