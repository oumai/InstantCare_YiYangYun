//
//  KMHealthSettingVC.m
//  Temp
//
//  Created by km on 16/8/11.
//  Copyright © 2016年 km. All rights reserved.
//

#import "KMHealthSettingVC.h"
#import "KMNetAPI.h"
#import "MJExtension.h"
// 二级控制器
#import "KMHeartRateRangeVC.h"
#import "KMCheckHeartRateVC.h"
#import "KMBloodRangeVC.h"
#import "KMBloodSugarRangeVC.h"
#import "KMBloodOxygenRangeVC.h"
#import "KMSleepMonitorVC.h"
#import "KMSitRemindVC.h"

// 数据模型
#import "KMHeartRateModel.h"
#import "KMBloodRangeModel.h"
#import "KMBloodSugarModel.h"
#import "KMBloodOxygenModel.h"
#import "KMCheckHeartRateModel.h"
#import "KMSleepMonitorModel.h"



#define kColor(R,G,B) [UIColor colorWithRed:R/255.0 green:G/255.0 blue:B/255.0 alpha:1.0];

@interface KMHealthSettingVC ()<UITableViewDelegate,UITableViewDataSource>

/** 表视图 */
@property (nonatomic, strong) UITableView *tableView;

/** 标题数组 */
@property (nonatomic, strong) NSMutableArray  *titles;

/** 标题字典 */
@property (nonatomic, strong) NSDictionary *titleDic;


/** 心率模型 */
@property (nonatomic, strong) KMHeartRateModel *heartRateModel;

/** 血压模型 */
@property (nonatomic, strong) KMBloodRangeModel *bloodRangeModel;

/** 血糖模型 */
@property (nonatomic, strong) KMBloodSugarModel *bloodSugarModel;

/** 血氧模型 */
@property (nonatomic, strong) KMBloodOxygenModel *bloodOxygenModel;

/** 心率检测模型 */
@property (nonatomic, strong) KMCheckHeartRateModel *checkHeartRateModel;

/** 睡眠监测模型 */
@property (nonatomic, strong) KMSleepMonitorModel  * sleepMonitroModel;

/** 久坐提醒 */
@property (nonatomic, strong) KMSleepMonitorModel  * sitRemindModel;


@end

@implementation KMHealthSettingVC

// tableView
-(UITableView *)tableView
{
    if (_tableView == nil) {
        
        _tableView = [[UITableView alloc] init];
        _tableView.frame = self.view.bounds;
        _tableView.tableFooterView = [UIView new];
        _tableView.delegate = self;
        _tableView.dataSource = self;
    }
    
    return _tableView;
}

// titles
- (NSMutableArray *)titles
{
    if (_titles == nil) {
        
        _titles = @[kLoadStringWithKey(@"DeviceManager_HealthSetting_heathRate"),
                    kLoadStringWithKey(@"DeviceManager_HealthSetting_bloodSugar"),
                    kLoadStringWithKey(@"DeviceManager_HealthSetting_bloodPressure"),
                    kLoadStringWithKey(@"DeviceManager_HealthSetting_bloodOxygen"),
                    kLoadStringWithKey(@"DeviceManager_HealthSetting_sleepMonitor"),
                    kLoadStringWithKey(@"DeviceManager_HealthSetting_Sedentary")].mutableCopy;
        
        if (![self.type isEqualToString:@"20"]) {
            [_titles removeLastObject];
            [_titles removeLastObject];
        }
    }
    return _titles;
}

// titleDic
- (NSDictionary *)titleDic
{
    if (_titleDic == nil) {
        NSArray * heart = [self.type isEqualToString:@"20"]?@[kLoadStringWithKey(@"DeviceManager_HealthSetting_HeathRate_Scope"),kLoadStringWithKey(@"DeviceManager_HealthSetting_HeathRate_check"),kLoadStringWithKey(@"DeviceManager_HealthSetting_HeathRate_alert")]:@[kLoadStringWithKey(@"DeviceManager_HealthSetting_HeathRate_Scope")];
        
        _titleDic = @{kLoadStringWithKey(@"DeviceManager_HealthSetting_heathRate"):heart,
                      kLoadStringWithKey(@"DeviceManager_HealthSetting_bloodSugar"):@[kLoadStringWithKey(@"DeviceManager_HealthSetting_bloodSugar_Scope")],
                     kLoadStringWithKey(@"DeviceManager_HealthSetting_bloodPressure"):@[kLoadStringWithKey(@"DeviceManager_HealthSetting_blood_Scope")],
                      kLoadStringWithKey(@"DeviceManager_HealthSetting_bloodOxygen"):@[kLoadStringWithKey(@"DeviceManager_HealthSetting_bloodOxygen")],
                      kLoadStringWithKey(@"DeviceManager_HealthSetting_sleepMonitor"):@[kLoadStringWithKey(@"DeviceManager_HealthSetting_sleepMonitor_setting")],
                      kLoadStringWithKey(@"DeviceManager_HealthSetting_Sedentary"):@[kLoadStringWithKey(@"DeviceManager_HealthSetting_Sedentary_remind")]
                      };
    }
    return _titleDic;
}

// heartRateModel
-(KMHeartRateModel *)heartRateModel
{
    if (_heartRateModel == nil) {
        
        _heartRateModel  = [[KMHeartRateModel alloc] init];
    }
    return _heartRateModel;
}

// 视图加载完成
- (void)viewDidLoad {
    
    [super viewDidLoad];
    
    // 添加表视图、设置背景颜色
    self.tableView.backgroundColor = kColor(247,248,249);
    [self.view addSubview:self.tableView];
    
    // 设置导航栏
    [self configNavigationBar];

}

// 视图将要显示
- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    if (self.is3DTouchLoad == 1) {
        /** 开始网络请求  */
        [self heartRateNetwork];
        [self bloodRangeNetwork];
        [self bloodSugarNetwork];
        [self bloodOxygenNetwork];
        
        /** 8020增加定时检测心率  睡眠监测 久坐提醒  */
        if ([self.type isEqualToString:@"20"]) {
            [self checkHeartRateNetwork];
            [self sleepMonitorNetwork];
            [self sittingNetwork];
        }
        self.is3DTouchLoad = 2;
    }else if (self.is3DTouchLoad == 2){
        return;
    }else{
        /** 开始网络请求  */
        [self heartRateNetwork];
        [self bloodRangeNetwork];
        [self bloodSugarNetwork];
        [self bloodOxygenNetwork];
        
        /** 8020增加定时检测心率  睡眠监测 久坐提醒  */
        if ([self.type isEqualToString:@"20"]) {
            [self checkHeartRateNetwork];
            [self sleepMonitorNetwork];
            [self sittingNetwork];
        }
    }

}



#pragma mark - 网络请求
/**
 *   调试使用网络接口
 */
- (void)netRequest
{
    
    // 开始更改操作
    [SVProgressHUD show];
    
    // URL
    NSString * reuqest = [NSString stringWithFormat:@"deviceManager/13823641029/865946021011109?type=hr"];
    
    // 网络请求
    [[KMNetAPI manager] commonGetRequestWithURL:reuqest Block:^(int code, NSString *res) {
      
        [SVProgressHUD dismiss];
        KMNetworkResModel * resModel = [KMNetworkResModel mj_objectWithKeyValues:res];
        if (code == 0 && resModel.errorCode <= kNetReqSuccess)
        {
            // 解析数据模型
            NSDictionary * dic = (NSDictionary *)resModel.content;
            NSArray * list = dic[@"list"];
            self.checkHeartRateModel = [KMCheckHeartRateModel mj_objectWithKeyValues:[list lastObject]];
            
            // 刷新表视图
            [self.tableView reloadData];
        }else
        {
            [SVProgressHUD showErrorWithStatus:kNetReqFailWithCode(resModel.errorCode)];
        }
    }];
    
}



/**
 *   心率网络请求
 */

- (void)heartRateNetwork
{
    // 开始更改操作
    [SVProgressHUD show];
    
    // URL
    NSString * reuqest = [NSString stringWithFormat:@"healthRange/hr/%@/%@",member.loginAccount,self.imei];
    
    // 网络请求
    [[KMNetAPI manager] commonGetRequestWithURL:reuqest Block:^(int code, NSString *res) {
        
        [SVProgressHUD dismiss];
        KMNetworkResModel * resModel = [KMNetworkResModel mj_objectWithKeyValues:res];
//        NSLog(@"heartRateNetwork----%@",resModel.content);
        if (code == 0 && resModel.errorCode <= kNetReqSuccess)
        {
            // 解析数据模型
            NSDictionary * dic = (NSDictionary *)resModel.content;
            NSArray * list = dic[@"list"];
            self.heartRateModel = [KMHeartRateModel mj_objectWithKeyValues:[list lastObject]];
            
            // 刷新表视图
            [self.tableView reloadData];
        }else
        {
            [SVProgressHUD showErrorWithStatus:kNetReqFailWithCode(resModel.errorCode)];
        }
    }];
}

/**
 *   心率检测网络请求
 */
- (void)checkHeartRateNetwork
{
    // 开始更改操作
    [SVProgressHUD show];
    // URL
    NSString * reuqest = [NSString stringWithFormat:@"deviceManager/%@/%@?type=hr",member.loginAccount,self.imei];
    
    // 网络请求
    [[KMNetAPI manager] commonGetRequestWithURL:reuqest Block:^(int code, NSString *res) {
        
        [SVProgressHUD dismiss];
        KMNetworkResModel * resModel = [KMNetworkResModel mj_objectWithKeyValues:res];
        if (code == 0 && resModel.errorCode <= kNetReqSuccess)
        {
            // 解析数据模型
            NSDictionary * dic = (NSDictionary *)resModel.content;
            NSArray * list = dic[@"list"];
            self.checkHeartRateModel = [KMCheckHeartRateModel mj_objectWithKeyValues:[list lastObject]];
            
            // 刷新表视图
            [self.tableView reloadData];
        }else
        {
            [SVProgressHUD showErrorWithStatus:kNetReqFailWithCode(resModel.errorCode)];
        }
    }];
}

/**
 *   血压网络请求
 */
- (void)bloodRangeNetwork
{
    // 开始更改操作
    [SVProgressHUD show];
    // url
    NSString * reuqest = [NSString stringWithFormat:@"healthRange/bp/%@/%@",member.loginAccount,self.imei];
    // 网络请求
    [[KMNetAPI manager] commonGetRequestWithURL:reuqest Block:^(int code, NSString *res) {
        
        [SVProgressHUD dismiss];
        KMNetworkResModel * resModel = [KMNetworkResModel mj_objectWithKeyValues:res];
//        NSLog(@"bloodRangeNetwork----%@",resModel.content);
        if (code == 0 && resModel.errorCode <= kNetReqSuccess)
        {
            // 解析数据模型
            NSDictionary * dic = (NSDictionary *)resModel.content;
            NSArray * list = dic[@"list"];
            self.bloodRangeModel = [KMBloodRangeModel mj_objectWithKeyValues:[list lastObject]];
            
            // 刷新表视图
            [self.tableView reloadData];
        }else
        {
            [SVProgressHUD showErrorWithStatus:kNetReqFailWithCode(resModel.errorCode)];
        }
    }];
}

/**
 *   血糖网络请求
 */
- (void)bloodSugarNetwork
{
    // 开始更改操作
    [SVProgressHUD show];
    // url
    NSString * reuqest = [NSString stringWithFormat:@"healthRange/bs/%@/%@",member.loginAccount,self.imei];
    // 网络请求
    [[KMNetAPI manager] commonGetRequestWithURL:reuqest Block:^(int code, NSString *res) {
        
        [SVProgressHUD dismiss];
        KMNetworkResModel * resModel = [KMNetworkResModel mj_objectWithKeyValues:res];
        if (code == 0 && resModel.errorCode <= kNetReqSuccess)
        {
            // 解析数据模型
            NSDictionary * dic = (NSDictionary *)resModel.content;
            NSArray * list = dic[@"list"];
            self.bloodSugarModel = [KMBloodSugarModel mj_objectWithKeyValues:[list lastObject]];
            
            // 刷新表视图
            [self.tableView reloadData];
        }else
        {
            [SVProgressHUD showErrorWithStatus:kNetReqFailWithCode(resModel.errorCode)];
        }
    }];
}

/**
 *   血氧网络请求
 */
- (void)bloodOxygenNetwork
{
    // 开始更改操作
    [SVProgressHUD show];
    // URL
    NSString * reuqest = [NSString stringWithFormat:@"healthRange/bo/%@/%@",member.loginAccount,self.imei];
    
    // 网络请求
    [[KMNetAPI manager] commonGetRequestWithURL:reuqest Block:^(int code, NSString *res) {
        
        [SVProgressHUD dismiss];
        KMNetworkResModel * resModel = [KMNetworkResModel mj_objectWithKeyValues:res];
        if (code == 0 && resModel.errorCode <= kNetReqSuccess)
        {
            // 解析数据模型
            NSDictionary * dic = (NSDictionary *)resModel.content;
            NSArray * list = dic[@"list"];
            self.bloodOxygenModel = [KMBloodOxygenModel mj_objectWithKeyValues:[list lastObject]];
            // 刷新表视图
            [self.tableView reloadData];
        }else
        {
            [SVProgressHUD showErrorWithStatus:kNetReqFailWithCode(resModel.errorCode)];
        }
    }];
}


/**
 *   睡眠监测网络请求
 */
- (void)sleepMonitorNetwork
{
    // 开始更改操作
    [SVProgressHUD show];
    // URL
    NSString * reuqest = [NSString stringWithFormat:@"deviceManager/%@/%@?type=sleep",member.loginAccount,self.imei];
    
    // 网络请求
    [[KMNetAPI manager] commonGetRequestWithURL:reuqest Block:^(int code, NSString *res) {
        
        [SVProgressHUD dismiss];
        KMNetworkResModel * resModel = [KMNetworkResModel mj_objectWithKeyValues:res];
        if (code == 0 && resModel.errorCode <= kNetReqSuccess)
        {
            // 解析数据模型
            NSDictionary * dic = (NSDictionary *)resModel.content;
            NSArray * list = dic[@"list"];
            self.sleepMonitroModel = [KMSleepMonitorModel mj_objectWithKeyValues:[list lastObject]];
            // 刷新表视图
            [self.tableView reloadData];
        }else
        {
            [SVProgressHUD showErrorWithStatus:kNetReqFailWithCode(resModel.errorCode)];
        }
    }];
}

/**
 *   久坐检测网络请求
 */
- (void)sittingNetwork
{
    // 开始更改操作
    [SVProgressHUD show];
    // URL
    NSString * reuqest = [NSString stringWithFormat:@"deviceManager/%@/%@?type=sit",member.loginAccount,self.imei];
    
    // 网络请求
    [[KMNetAPI manager] commonGetRequestWithURL:reuqest Block:^(int code, NSString *res) {
        
        [SVProgressHUD dismiss];
        KMNetworkResModel * resModel = [KMNetworkResModel mj_objectWithKeyValues:res];
        if (code == 0 && resModel.errorCode <= kNetReqSuccess)
        {
            // 解析数据模型
            NSDictionary * dic = (NSDictionary *)resModel.content;
            NSArray * list = dic[@"list"];
            self.sitRemindModel = [KMSleepMonitorModel mj_objectWithKeyValues:[list lastObject]];
            // 刷新表视图
            [self.tableView reloadData];
        }else
        {
            [SVProgressHUD showErrorWithStatus:kNetReqFailWithCode(resModel.errorCode)];
        }
    }];
    
    
    
}


#pragma mark - 设置导航栏
- (void)configNavigationBar
{
    // left 左
    UIButton *leftNavButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [leftNavButton setBackgroundImage:[UIImage imageNamed:@"return_normal"]
                             forState:UIControlStateNormal];
    leftNavButton.frame = CGRectMake(0, 0, 30, 30);
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:leftNavButton];
    [leftNavButton addTarget:self
                      action:@selector(backLastView)
            forControlEvents:UIControlEventTouchUpInside];
    self.title = kLoadStringWithKey(@"DeviceManager_HealthSetting");
}

/**
 *   返回上一级界面
 */
- (void)backLastView
{
    [self.navigationController popViewControllerAnimated:YES];
}

#pragma mark - TableViewDataSource
/**
 *   多少分区
 */
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    
    return self.titles.count;
}

/**
 *   每个分区有多少行
 */
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    
    NSString * key = self.titles[section];
    return [self.titleDic[key] count];
}

/**
 *   每行的具体显示对象
 */
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    // 0.取出数据模型
    NSString * key = self.titles[indexPath.section];
    NSArray * texts = self.titleDic[key];
    
    BOOL result = [self.type isEqualToString:@"20"]?((indexPath.section == 0 && indexPath.row == 2 )? YES:NO):((indexPath.section == 0 && indexPath.row == 1)? YES:NO);
    NSString * ID = result ? @"switch":@"default";
    
    // 1.创建Cell对象
    UITableViewCell * cell  = [tableView dequeueReusableCellWithIdentifier:ID];
    if (cell == nil) {
        
        cell  = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:ID];
    }
    
    // 2.设置Cell数据
     cell.textLabel.text = texts[indexPath.row];
    if (result)
    {
        cell.textLabel.font = [UIFont systemFontOfSize:18];
        UISwitch * mySwitch = [[UISwitch alloc] init];
        cell.accessoryView = mySwitch;
        [mySwitch addTarget:self action:@selector(saveUserOperation:) forControlEvents:UIControlEventValueChanged];
        if (self.heartRateModel.status == 0) {
            mySwitch.on = NO;
        }else{
            mySwitch.on = YES;
        }
    }else
    {
        cell.textLabel.textColor = [UIColor orangeColor];
        cell.textLabel.font = [UIFont systemFontOfSize:18];
        cell.detailTextLabel.textColor = [UIColor grayColor];
        cell.detailTextLabel.font = [UIFont systemFontOfSize:14];
        cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
        cell.detailTextLabel.text = @"";
        [self setDetailLabelDataWithIndexPath:indexPath withCell:cell];
    }
    
    // 3.返回Cell对象
    return cell;
}

/**
 *   保存用户操作
 */
- (void)saveUserOperation:(UISwitch *)mySwitch
{
    // 创建请求连接
    NSString * URL = [NSString stringWithFormat:@"healthRange/hr/%@/%@",member.loginAccount,self.imei];
    self.heartRateModel.status = mySwitch.isOn;
    
    // 开始进行网络请求
    [SVProgressHUD show];
    [[KMNetAPI manager] commonPOSTRequestWithURL:URL jsonBody:[_heartRateModel mj_JSONString] Block:^(int code, NSString *res)
     {
         KMNetworkResModel *resModel = [KMNetworkResModel mj_objectWithKeyValues:res];
         NSLog(@"KMNetworkResModel-----%@",resModel.content);
         if (code == 0 && resModel.errorCode <= kNetReqSuccess)
         {
             [SVProgressHUD dismiss];
             [self.tableView reloadData];
         } else
         {
             mySwitch.on = !mySwitch.isOn;
             [SVProgressHUD showErrorWithStatus:kNetReqFailWithCode(resModel.errorCode)];
         }
     }];
    
}

/**
 *   设置cell detailLabel 的数据
 */
- (void)setDetailLabelDataWithIndexPath:(NSIndexPath *)indexPath
                               withCell:(UITableViewCell *)cell
{
    
    switch (indexPath.section)
    {
        // 分区一
        case 0:
        {
            switch (indexPath.row)
            {
                // 分组一
                case 0:
                {
                    NSString * text = [NSString stringWithFormat:@"%zd~%zd bpm",self.heartRateModel.heartRateLow,self.heartRateModel.heartRateHigh];
                    cell.detailTextLabel.text = text;
                }break;
                 
                // 分组一
                case 1:
                {
                    NSString * start = self.checkHeartRateModel.starttime;
                    start = [start substringWithRange:NSMakeRange(0,5)];
                    NSString * end = self.checkHeartRateModel.endtime;
                    end = [end substringWithRange:NSMakeRange(0,5)];
                    
                    NSString * text = [NSString stringWithFormat:@"%@~%@,%@:%zd%@",start,end,kLoadStringWithKey(@"DeviceManager_HealthSetting_time_interval"),self.checkHeartRateModel.span,kLoadStringWithKey(@"DeviceManager_HealthSetting_time_minute")];
                    
                     cell.detailTextLabel.text = text;
                }break;
                
            }
        } break;
            
        // 分区二
        case 2:
        {
            NSString * low = [NSString stringWithFormat:@"%@%zd~%zdmmHg",kLoadStringWithKey(@"KMDeviceManager_health_DBP"),self.bloodRangeModel.bpdL,self.bloodRangeModel.bpdH];
            NSString * heigt = [NSString stringWithFormat:@"%@%zd~%zdmmHg",kLoadStringWithKey(@"KMDeviceManager_health_SBP"),self.bloodRangeModel.bpsL,self.bloodRangeModel.bpsH];
            NSString * text = [NSString stringWithFormat:@"%@,%@",low,heigt];
            cell.detailTextLabel.text = text;
        }break;
            
        // 分区三
        case 1:
        {
            CGFloat low = self.bloodSugarModel.beforeMealL/18.0;
            CGFloat height = self.bloodSugarModel.beforeMealH/18.0;

            NSString * text = [NSString stringWithFormat:@"%.1f~%.1f",low,height];
            text = [text stringByAppendingFormat:@"%@",kLoadStringWithKey(@"DeviceManager_HealthSetting_mole")];
            cell.detailTextLabel.text = text;
            
        }break;
            
         // 分区四
        case 3:
        {
            NSInteger boh = self.bloodOxygenModel.boH;
            NSInteger bol = self.bloodOxygenModel.boL;
            NSString * text = [NSString stringWithFormat:@"%zd%% ~ %zd%%",bol,boh];
            cell.detailTextLabel.text = text;
            
        }break;
            
            // 分区四
        case 4:
        {
            NSString * start = self.sleepMonitroModel.starttime;
            NSString * end = self.sleepMonitroModel.endtime;
            NSInteger status = self.sleepMonitroModel.status;
            NSString * text;
            if (status) {
              text  = [NSString stringWithFormat:@"%@ ~ %@",[start  substringWithRange:NSMakeRange(0, 5)],[end  substringWithRange:NSMakeRange(0, 5)]];
            }else{
              text  = kLoadStringWithKey(@"DeviceSettingDetail_VC_shutdown");
            }
            cell.detailTextLabel.text = text;
            
        }break;
            
            // 分区四
        case 5:
        {
            NSString * start = self.sitRemindModel.starttime;
            NSString * end = self.sitRemindModel.endtime;
            NSInteger status = self.sitRemindModel.status;
            NSString * text;
            if (status) {
               text  = [NSString stringWithFormat:@"%@ ~ %@",[start  substringWithRange:NSMakeRange(0, 5)],[end  substringWithRange:NSMakeRange(0, 5)]];
            }else{
                text  = kLoadStringWithKey(@"DeviceSettingDetail_VC_shutdown");
            }
            cell.detailTextLabel.text = text;
            
        }break;
    }
}

/**
 *   返回分区标题
 */
- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    
    NSString * title = self.titles[section];
    return title;
}

/**
 *   返回Cell高度
 */
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 70;
}

#pragma mark - UITableViewDelegate
/**
 *   选中Cell
 */
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    
    // 0.取消选中状态
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    // 1.获取数据
    NSString * key = self.titles[indexPath.section];
    NSArray * texts = self.titleDic[key];
    NSString * title = texts[indexPath.row];
    
    switch (indexPath.section)
    {
        // 分区一
        case 0:
        {
            switch (indexPath.row)
            {
                // 分组一
                case 0:
                {
                    KMHeartRateRangeVC * vc = [[KMHeartRateRangeVC alloc] init];
                    vc.title = title;
                    vc.imei = self.imei;
                    vc.model = self.heartRateModel;
                    [self.navigationController pushViewController:vc animated:YES];
                }break;
                    
                // 分组二
                case 1:
                {
                    BOOL result = [self.type isEqualToString:@"20"]?YES:NO;
                    if (result) {
                        KMCheckHeartRateVC * vc = [[KMCheckHeartRateVC alloc] init];
                        vc.title = title;
                        vc.imei = self.imei;
                        vc.model = self.checkHeartRateModel;
                        [self.navigationController pushViewController:vc animated:YES];
                    }
                }break;
            }
        }break;
           
        // 分区三
        case 2:
        {
            KMBloodRangeVC * vc = [[KMBloodRangeVC alloc] init];
            vc.title = title;
            vc.imei = self.imei;
            vc.model = self.bloodRangeModel;
            [self.navigationController pushViewController:vc animated:YES];
            
        }break;
            
         // 分区二
        case 1:
        {
            KMBloodSugarRangeVC * vc = [[KMBloodSugarRangeVC alloc] init];
            vc.title = title;
            vc.imei = self.imei;
            vc.model = self.bloodSugarModel;
            [self.navigationController pushViewController:vc animated:YES];
            
        }break;
            
            // 分区四
        case 3:
        {
            KMBloodOxygenRangeVC * vc = [[KMBloodOxygenRangeVC alloc] init];
            vc.title = title;
            vc.imei = self.imei;
            vc.model = self.bloodOxygenModel;
            [self.navigationController pushViewController:vc animated:YES];
            
        }break;
            
        // 分区五
        case 4:
        {
            KMSleepMonitorVC * vc = [[KMSleepMonitorVC alloc] init];
            vc.title = title;
            vc.imei = self.imei;
            vc.model = self.sleepMonitroModel;
            [self.navigationController pushViewController:vc animated:YES];
        }break;
            
            // 分区五
        case 5:
        {
            KMSitRemindVC * vc = [[KMSitRemindVC alloc] init];
            vc.title = title;
            vc.imei = self.imei;
            vc.model = self.sitRemindModel;
            [self.navigationController pushViewController:vc animated:YES];
        }break;
     }
}

@end










