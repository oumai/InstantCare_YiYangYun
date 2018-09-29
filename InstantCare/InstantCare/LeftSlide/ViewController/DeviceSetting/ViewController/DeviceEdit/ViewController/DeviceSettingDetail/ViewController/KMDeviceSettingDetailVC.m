//
//  KMDeviceSettingDetailVC.m
//  InstantCare
//
//  Created by 朱正晶 on 15/12/6.
//  Copyright © 2015年 omg. All rights reserved.
//

#import "KMDeviceSettingDetailVC.h"
#import "KMNetAPI.h"
#import "KMDeviceSettingResModel.h"
#import "KMDeviceSettingEditCell.h"
#import "KMGeofenceModel.h"
#import "KMGeofenceVC.h"
#import "KMGeofenceSettingVC.h"
#import "KMDeviceSettingCheckTiemVC.h"
#import "MJRefresh.h"
#import "MJExtension.h"

@interface KMDeviceSettingDetailVC() <UITableViewDataSource, UITableViewDelegate>

/** 表视图  */
@property (nonatomic, strong) UITableView *tableView;

/** 标题数组  */
@property (nonatomic, strong) NSArray *texts;
@property (nonatomic, strong) NSArray *texts2;
@property (nonatomic, strong) NSArray *texts3;
@property (nonatomic, strong) NSArray *titles;
/** 数据模型  */
@property (nonatomic, strong) KMDeviceManagerModel *deviceManagerModel;

/// Geofence模型
@property (nonatomic, strong) KMGeofenceModel *geofenceModel;

/** 分段定时模型 */
@property (nonatomic, strong) KMDeviceSettingCheckTimeModel *checkTiemModel;


/** numberCount */
@property (nonatomic, strong) NSArray *numberCounts;


@end

@implementation KMDeviceSettingDetailVC

//  titles
- (NSArray *)texts
{
    if(_texts == nil)
    {
        _texts = @[kLoadStringWithKey(@"DeviceSettingDetail_VC_light_on")];
    }
    return _texts;
}

//  texts2
- (NSArray *)texts2
{
    if(_texts2 == nil)
    {
        NSString * title1 = kLoadStringWithKey(@"DeviceManager_HealthSetting_position_section_setting");
        NSString * title12 = kLoadStringWithKey(@"DeviceSettingDetail_VC_gps_on");
        NSString * text = [self.type isEqualToString:@"20"]?title1:title12;
        _texts2 = @[text,
                    kLoadStringWithKey(@"DeviceSettingDetail_VC_upload")];
    }
    return _texts2;
}

//  texts
- (NSArray *)texts3
{
    if(_texts3 == nil)
    {
        _texts3 = @[kLoadStringWithKey(@"Geofence_VC_title"),
                    kLoadStringWithKey(@"Geofence_VC_time")
                    ];
    }
    return _texts3;
}

//  titles
- (NSArray *)titles
{
    if(_titles == nil)
    {
        _titles = @[@"",
                    kLoadStringWithKey(@"DeviceSettingDetail_VC_start_frequency"),
                    kLoadStringWithKey(@"Geofence_VC_location")
                    ];
    }
    return _titles;
}

//  numberCounts
- (NSArray *)numberCounts
{
    if(_numberCounts == nil)
    {
        BOOL result  = [self.type isEqualToString:@"20"];
        BOOL result2 = [self.type isEqualToString:@"1"];
        //        NSInteger num1 = (result||result2)?0:1;
        //        NSInteger num1;
        //        if (result || result2) {
        //            num1 = 0;
        //        }else{
        //            num1 = 1;
        //        }
        
        NSInteger num1 = (result2 | result)?0:1;
        NSInteger num2 = (result)?1:2;
        //      NSInteger num3 = (result)?2:1;
        NSInteger num3 = 1;
        
        _numberCounts = @[@(num1),@(num2),@(1)];
    }
    return _numberCounts;
}


// 视图加载完成
- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.view.backgroundColor = [UIColor whiteColor];
    
    [self configNavBar];
    [self configView];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    if (self.is3DTouchLoad == 1){
        [SVProgressHUD show];
        if ([self.type isEqualToString:@"20"]) {
            [self loadCheckTiemSetting];
        }else{
            [self requestDeviceSetting];
        }
        self.is3DTouchLoad = 2;

    }else if(self.is3DTouchLoad == 2 ){
        return;
    }else{
        [SVProgressHUD show];
        if ([self.type isEqualToString:@"20"]) {
            [self loadCheckTiemSetting];
        }else{
            [self requestDeviceSetting];
        }
    }

}

#pragma mark - 设置导航栏
- (void)configNavBar
{
    self.navigationItem.title = kLoadStringWithKey(@"DeviceSettingDetail_VC_title");
    UIButton *leftButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [leftButton setBackgroundImage:[UIImage imageNamed:@"return_normal"] forState:UIControlStateNormal];
    [leftButton setBackgroundImage:[UIImage imageNamed:@"return_sel"] forState:UIControlStateSelected];
    leftButton.frame = CGRectMake(0, 0,30, 30);
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:leftButton];
    
    [leftButton addTarget:self action:@selector(leftBarButtonDidClickedAction:) forControlEvents:UIControlEventTouchDown];
}

/**
 *   返回上级界面
 */
-(void)leftBarButtonDidClickedAction:(UIButton *)sender
{
    [self.navigationController popViewControllerAnimated:YES];
}

#pragma mark - 设置子视图
- (void)configView
{
    self.tableView = [[UITableView alloc] init];
    self.tableView.dataSource = self;
    self.tableView.delegate = self;
    self.tableView.tableFooterView = [UIView new];
    [self.view addSubview:self.tableView];
    [self.tableView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.equalTo(self.view);
    }];
    
    WS(ws);
    // 下拉刷新
    self.tableView.mj_header = [MJRefreshNormalHeader headerWithRefreshingBlock:^{
        
        if ([self.type isEqualToString:@"20"]) {
            [ws loadCheckTiemSetting];
        }else{
            [ws requestDeviceSetting];
        }
    }];
}

#pragma mark - 网络请求设置
/**
 *   请求数据
 */
- (void)requestDeviceSetting
{
    WS(ws);
    
    // deviceManager/{account}/{imei}
    NSString *request = [NSString stringWithFormat:@"deviceManager/%@/%@",
                         member.loginAccount,self.imei];
    [[KMNetAPI manager] commonGetRequestWithURL:request Block:^(int code, NSString *res)
     {
         [_tableView.mj_header endRefreshing];
         KMNetworkResModel *resModel = [KMNetworkResModel mj_objectWithKeyValues:res];
         if (code == 0 && resModel.errorCode <= kNetReqSuccess)
         {
             _deviceManagerModel = [KMDeviceManagerModel mj_objectWithKeyValues:resModel.content];
             [self.tableView reloadData];
             [ws updateGeofenceFromServer];
         } else
         {
             [SVProgressHUD showErrorWithStatus:kNetReqFailWithCode(resModel.errorCode)];
         }
     }];
}

/**
 *   更新数据
 */
- (void)updateDeviceSettingWithBody:(NSString *)body
{
    // deviceManager/{account}/{imei}
    WS(ws);
    NSString *request = [NSString stringWithFormat:@"deviceManager/%@/%@",
                         member.loginAccount,
                         self.imei];
    [[KMNetAPI manager] commonPOSTRequestWithURL:request jsonBody:body Block:^(int code, NSString *res)
     {
         [_tableView.mj_header endRefreshing];
         KMNetworkResModel *resModel = [KMNetworkResModel mj_objectWithKeyValues:res];
         if (code == 0 && resModel.errorCode <= kNetReqSuccess)
         {
             [SVProgressHUD dismiss];
             [ws requestDeviceSetting];
         } else
         {
             [SVProgressHUD showErrorWithStatus:kNetReqFailWithCode(resModel.errorCode)];
         }
     }];
}


/**
 *   获取分段定时设置
 */
- (void)loadCheckTiemSetting
{
    WS(ws);
    // 开始更改操作
    [SVProgressHUD show];
    // URL
    NSString * reuqest = [NSString stringWithFormat:@"deviceManager/%@/%@?type=lbs",member.loginAccount,self.imei];
    
    // 网络请求
    [[KMNetAPI manager] commonGetRequestWithURL:reuqest Block:^(int code, NSString *res) {
        [_tableView.mj_header endRefreshing];
        [SVProgressHUD dismiss];
        KMNetworkResModel * resModel = [KMNetworkResModel mj_objectWithKeyValues:res];
        if (code == 0 && resModel.errorCode <= kNetReqSuccess)
        {
            // 解析数据模型
            NSDictionary * dic = (NSDictionary *)resModel.content;
            NSArray * list = dic[@"list"];
            self.checkTiemModel = [KMDeviceSettingCheckTimeModel mj_objectWithKeyValues:[list lastObject]];
            // 刷新表视图
            [self.tableView reloadData];
            [ws updateGeofenceFromServer];
        }else
        {
            [SVProgressHUD showErrorWithStatus:kNetReqFailWithCode(resModel.errorCode)];
        }
    }];
}
/// 获取电子围栏信息
- (void)updateGeofenceFromServer {
    
    NSString *reqURL = [NSString stringWithFormat:@"deviceSettingGfence/%@/%@", member.loginAccount, self.imei];
    [[KMNetAPI manager] commonGetRequestWithURL:reqURL Block:^(int code, NSString *res) {
        [_tableView.mj_header endRefreshing];
        KMNetworkResModel *resModel = [KMNetworkResModel mj_objectWithKeyValues:res];
        if (code == 0 && resModel.errorCode <= kNetReqSuccess) {
            [SVProgressHUD dismiss];
            _geofenceModel = [KMGeofenceModel mj_objectWithKeyValues:resModel.content];
            [_tableView reloadData];
        } else {
            [SVProgressHUD showErrorWithStatus:resModel.msg.length > 0 ? resModel.msg : kNetError];
        }
    }];
}

#pragma mark - UITableViewDataSource
/**
 *   设置分区
 */
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return self.titles.count;
}

/**
 *   设置分组
 */
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    //    switch (section)
    //    {
    //        case 0:
    //            if ([self.type isEqualToString:@"1"])
    //            {
    //                return 0;
    //            }else
    //            {
    //                return self.texts.count;
    //            }
    //        case 1:
    //            return self.texts2.count;
    //        case 2:
    //            return self.texts3.count;
    //
    //        default:
    //            return 0;
    //            break;
    //    }
    
    return [self.numberCounts[section] integerValue];
}

/**
 *   设置区头标题
 */
- (nullable NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    NSString * title = self.titles[section];
    
    return  title;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell;
    KMDeviceManagerDetailModel *m = [self.deviceManagerModel.list objectAtIndex:0];
    
    // cell初始化
    if (indexPath.section == 0)
    {
        cell = [tableView dequeueReusableCellWithIdentifier:@"cell"];
        if (cell == nil)
        {
            cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault
                                          reuseIdentifier:@"cell"];
        }
        
        // cell赋值
        cell.textLabel.text = self.texts[indexPath.row];
        
        // 辅助视图
        UISwitch *mSwitch = [[UISwitch alloc] init];
        mSwitch.tag = indexPath.row;
        [mSwitch addTarget:self
                    action:@selector(switchDidClick:)
          forControlEvents:UIControlEventValueChanged];
        cell.accessoryView = mSwitch;
        
        // UISwitch开关
        switch (indexPath.row)
        {
                //            case 0:             // 跌倒侦测
                //                if (m.fallDetect)
                //                {
                //                    mSwitch.on = YES;
                //                } else
                //                {
                //                    mSwitch.on = NO;
                //                }
                //                break;
            case 0:             // 定时开关
                if (m.autoread)
                {
                    mSwitch.on = YES;
                } else
                {
                    mSwitch.on = NO;
                }
                break;
            default:
                break;
        }
    } else if (indexPath.section == 1)
    {
        // 初始化cell
        cell = [tableView dequeueReusableCellWithIdentifier:@"cell2"];
        if (cell == nil)
        {
            cell = [[KMDeviceSettingEditCell alloc] initWithStyle:UITableViewCellStyleDefault
                                                  reuseIdentifier:@"cell2"];
        }
        KMDeviceSettingEditCell *newCell = (KMDeviceSettingEditCell *)cell;
        
        // cell 赋值
        newCell.titleLabel.text = self.texts2[indexPath.row];
        NSString *detailString;
        
        if ([self.type isEqualToString:@"20"]) {
            
            NSString * start = [self.checkTiemModel.starttime substringWithRange:NSMakeRange(0,5)];
            NSString * end   = [self.checkTiemModel.endtime substringWithRange:NSMakeRange(0,5)];
            NSInteger span = self.checkTiemModel.span;
            
            NSString * text = [NSString stringWithFormat:@"%@ ~ %@,%@：%zd%@",start,end,kLoadStringWithKey(@"DeviceManager_HealthSetting_interval"),span,kLoadStringWithKey(@"DeviceManager_HealthSetting_time_minute")];
            newCell.detailLabel.text = text;
            
            
        }else{
            
            if ([self.type isEqualToString:@"1"])
            {
                switch (indexPath.row)
                {
                    case 0:
                    {
                        switch (m.echoGpsT)
                        {
                            case 0:         // GPS关闭
                                detailString = kLoadStringWithKey(@"DeviceSettingDetail_VC_shutdown");
                                break;
                            case 1:         // GPS10分钟
                                detailString = [NSString stringWithFormat:@"%@10%@",
                                                kLoadStringWithKey(@"DeviceSettingDetail_VC_every"),
                                                kLoadStringWithKey(@"DeviceSettingDetail_VC_every_minute")];
                                break;
                            case 2:         // GPS15分钟
                                detailString = [NSString stringWithFormat:@"%@15%@",
                                                kLoadStringWithKey(@"DeviceSettingDetail_VC_every"),
                                                kLoadStringWithKey(@"DeviceSettingDetail_VC_every_minute")];
                                
                                break;
                            case 3:         // GPS20分钟
                                detailString = [NSString stringWithFormat:@"%@20%@",
                                                kLoadStringWithKey(@"DeviceSettingDetail_VC_every"),
                                                kLoadStringWithKey(@"DeviceSettingDetail_VC_every_minute")];
                                
                                break;
                            case 4:         // GPS5分钟
                                detailString = [NSString stringWithFormat:@"%@5%@",
                                                kLoadStringWithKey(@"DeviceSettingDetail_VC_every"),
                                                kLoadStringWithKey(@"DeviceSettingDetail_VC_every_minute")];
                                break;
                            case 5:         // GPS30分钟
                                detailString = [NSString stringWithFormat:@"%@30%@",
                                                kLoadStringWithKey(@"DeviceSettingDetail_VC_every"),
                                                kLoadStringWithKey(@"DeviceSettingDetail_VC_every_minute")];
                                break;
                        }
                        
                    }
                        break;
                    case 1:
                    {
                        switch (m.echoPrT)
                        {
                            case 0:         // 同步频率关闭
                                detailString = kLoadStringWithKey(@"DeviceSettingDetail_VC_shutdown");
                                break;
                            case 1:         // 同步频率60分钟
                                detailString = [NSString stringWithFormat:@"%@60%@",
                                                kLoadStringWithKey(@"DeviceSettingDetail_VC_every"),
                                                kLoadStringWithKey(@"DeviceSettingDetail_VC_every_minute")];
                                break;
                            case 2:         // 同步频率120分钟
                                detailString = [NSString stringWithFormat:@"%@120%@",
                                                kLoadStringWithKey(@"DeviceSettingDetail_VC_every"),
                                                kLoadStringWithKey(@"DeviceSettingDetail_VC_every_minute")];
                                
                                break;
                            case 3:         // 同步频率180分钟
                                detailString = [NSString stringWithFormat:@"%@180%@",
                                                kLoadStringWithKey(@"DeviceSettingDetail_VC_every"),
                                                kLoadStringWithKey(@"DeviceSettingDetail_VC_every_minute")];
                                break;
                            case 4:         // 同步频率240分钟
                                detailString = [NSString stringWithFormat:@"%@240%@",
                                                kLoadStringWithKey(@"DeviceSettingDetail_VC_every"),
                                                kLoadStringWithKey(@"DeviceSettingDetail_VC_every_minute")];
                                break;
                            case 6:         // 同步频率360分钟
                                detailString = [NSString stringWithFormat:@"%@360%@",
                                                kLoadStringWithKey(@"DeviceSettingDetail_VC_every"),
                                                kLoadStringWithKey(@"DeviceSettingDetail_VC_every_minute")];
                                break;
                            case 11:         // 同步频率720分钟
                                detailString = [NSString stringWithFormat:@"%@720%@",
                                                kLoadStringWithKey(@"DeviceSettingDetail_VC_every"),
                                                kLoadStringWithKey(@"DeviceSettingDetail_VC_every_minute")];
                                break;
                                
                            case 33:         // 同步频率30分钟
                                detailString = [NSString stringWithFormat:@"%@30%@",
                                                kLoadStringWithKey(@"DeviceSettingDetail_VC_every"),
                                                kLoadStringWithKey(@"DeviceSettingDetail_VC_every_minute")];
                                break;
                                
                            case 49:         // 同步频率20分钟
                                detailString = [NSString stringWithFormat:@"%@20%@",
                                                kLoadStringWithKey(@"DeviceSettingDetail_VC_every"),
                                                kLoadStringWithKey(@"DeviceSettingDetail_VC_every_minute")];
                                break;
                                
                            case 65:         // 同步频率15分钟
                                detailString = [NSString stringWithFormat:@"%@15%@",
                                                kLoadStringWithKey(@"DeviceSettingDetail_VC_every"),
                                                kLoadStringWithKey(@"DeviceSettingDetail_VC_every_minute")];
                                break;
                            case 81:         // 同步频率12分钟
                                detailString = [NSString stringWithFormat:@"%@12%@",
                                                kLoadStringWithKey(@"DeviceSettingDetail_VC_every"),
                                                kLoadStringWithKey(@"DeviceSettingDetail_VC_every_minute")];
                                break;
                            case 97:         // 同步频率10分钟
                                detailString = [NSString stringWithFormat:@"%@10%@",
                                                kLoadStringWithKey(@"DeviceSettingDetail_VC_every"),
                                                kLoadStringWithKey(@"DeviceSettingDetail_VC_every_minute")];
                                break;
                            case 161:         // 同步频率6分钟
                                detailString = [NSString stringWithFormat:@"%@6%@",
                                                kLoadStringWithKey(@"DeviceSettingDetail_VC_every"),
                                                kLoadStringWithKey(@"DeviceSettingDetail_VC_every_minute")];
                                break;
                            case 177:         // 同步频率5分钟
                                detailString = [NSString stringWithFormat:@"%@5%@",
                                                kLoadStringWithKey(@"DeviceSettingDetail_VC_every"),
                                                kLoadStringWithKey(@"DeviceSettingDetail_VC_every_minute")];
                                break;
                                
                        }
                    }
                        break;
                }
                
            }else
            {
                switch (indexPath.row)
                {
                    case 0:         // GPS启动频率
                    {
                        switch (m.echoGpsT)
                        {
                            case 0:         // GPS关闭
                                detailString = kLoadStringWithKey(@"DeviceSettingDetail_VC_shutdown");
                                break;
                            default:
                                detailString = [NSString stringWithFormat:@"%@%d%@",
                                                kLoadStringWithKey(@"DeviceSettingDetail_VC_every"),
                                                m.echoGpsT,
                                                kLoadStringWithKey(@"DeviceSettingDetail_VC_every_minute")];
                                break;
                        }
                    } break;
                    case 1:         // 定期上传间隔频率
                    {
                        switch (m.echoPrT)
                        {
                            case 0:         // GPS关闭
                                detailString = kLoadStringWithKey(@"DeviceSettingDetail_VC_shutdown");
                                break;
                            default:
                                detailString = [NSString stringWithFormat:@"%@%d%@",
                                                kLoadStringWithKey(@"DeviceSettingDetail_VC_every"),
                                                m.echoPrT,
                                                kLoadStringWithKey(@"DeviceSettingDetail_VC_every_minute")];
                                break;
                        }
                    } break;
                    default:
                        break;
                }
            }
            
            newCell.detailLabel.text = detailString;
            
        }
    }else{      // 电子围栏
        // 初始化cell
        cell = [tableView dequeueReusableCellWithIdentifier:@"cell2"];
        if (cell == nil)
        {
            cell = [[KMDeviceSettingEditCell alloc] initWithStyle:UITableViewCellStyleDefault
                                                  reuseIdentifier:@"cell2"];
        }
        KMDeviceSettingEditCell *newCell = (KMDeviceSettingEditCell *)cell;
        // cell 赋值
        newCell.titleLabel.text = self.texts3[indexPath.row];
        
        switch (indexPath.row) {
            case 0:         // 电子围栏 状态
            {
                if (_geofenceModel && _geofenceModel.enable == 1) {
                    newCell.detailLabel.text = kLoadStringWithKey(@"Geofence_VC_ON_notes");
                } else if (_geofenceModel && _geofenceModel.enable == 0) {
                    newCell.detailLabel.text = kLoadStringWithKey(@"Geofence_VC_OFF_notes");
                } else {
                    newCell.detailLabel.text = kLoadStringWithKey(@"Geofence_VC_not_setting");
                }
            } break;
            case 1:         // 定时定位
            {
                if (_geofenceModel != nil) {
                    NSString *start = nil;
                    NSString *end = nil;
                    NSRange range = [_geofenceModel.starttime rangeOfString:@":" options:NSBackwardsSearch];
                    if (range.location != NSNotFound) {
                        start = [_geofenceModel.starttime substringToIndex:range.location];
                    }
                    
                    range = [_geofenceModel.endtime rangeOfString:@":" options:NSBackwardsSearch];
                    if (range.location != NSNotFound) {
                        end = [_geofenceModel.endtime substringToIndex:range.location];
                    }
                    
                    if (start && end) {
                        newCell.detailLabel.text = [NSString stringWithFormat:@"%@ ~ %@, %@: %d%@",
                                                    start, end,
                                                    kLoadStringWithKey(@"Geofence_VC_time_interval"),
                                                    _geofenceModel.interval,
                                                    kLoadStringWithKey(@"DeviceEdit_VC_setting_title_call_min")];
                    } else {
                        newCell.detailLabel.text = kLoadStringWithKey(@"Geofence_VC_not_setting");
                    }
                } else {
                    newCell.detailLabel.text = kLoadStringWithKey(@"Geofence_VC_not_setting");
                }
            } break;
            default:
                break;
        }
    }
    
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 70;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    // 关闭cell 选中效果
    [tableView deselectRowAtIndexPath:indexPath animated:NO];
    
    if ([self.type isEqualToString:@"85"] && indexPath.section == 0 && indexPath.row == 0) {
        return;
    }
    
    // 获取点击的cell 准备赋值；
    UITableViewCell *cell = [tableView cellForRowAtIndexPath:indexPath];
    // 拿到数据模型；
    KMDeviceManagerDetailModel *m = [self.deviceManagerModel.list objectAtIndex:0];
    
    // 进行选中操作
    if (indexPath.section == 1)
    {
        switch (indexPath.row)
        {
            case 0:     // GPS启动频率
            {
                if ([self.type isEqualToString:@"20"]){
                    
                    KMDeviceSettingCheckTiemVC * vc = [[KMDeviceSettingCheckTiemVC alloc] init];
                    vc.imei = self.imei;
                    vc.title = kLoadStringWithKey(@"DeviceManager_HealthSetting_position_section_setting");
                    vc.model = self.checkTiemModel;
                    [self.navigationController pushViewController:vc animated:YES];
                    
                }else{
                    
                    int gpsValue = 0;
                    
                    if ([self.type isEqualToString:@"1"])
                    {
                        gpsValue = m.echoGpsT;
                    }else
                    {
                        switch (m.echoGpsT)
                        {
                            case 0:
                                gpsValue = 0;
                                break;
                            case 5:
                                gpsValue = 1;
                                break;
                            case 15:
                                gpsValue = 2;
                                break;
                            case 30:
                                gpsValue = 3;
                                break;
                            case 60:
                                gpsValue = 4;
                                break;
                            default:
                                break;
                        }
                    }
                    
                    NSArray *actions;
                    if ([self.type isEqualToString:@"1"])
                    {
                        actions = @[NSLocalizedStringFromTable(@"DeviceSettingDetail_VC_shutdown", APP_LAN_TABLE, nil),
                                    /*[NSString stringWithFormat:@"%@5%@",
                                     NSLocalizedStringFromTable(@"DeviceSettingDetail_VC_every", APP_LAN_TABLE, nil),
                                     NSLocalizedStringFromTable(@"DeviceSettingDetail_VC_every_minute", APP_LAN_TABLE, nil)],*/
                                    [NSString stringWithFormat:@"%@10%@",
                                     NSLocalizedStringFromTable(@"DeviceSettingDetail_VC_every", APP_LAN_TABLE, nil),
                                     NSLocalizedStringFromTable(@"DeviceSettingDetail_VC_every_minute", APP_LAN_TABLE, nil)],
                                    [NSString stringWithFormat:@"%@15%@",
                                     NSLocalizedStringFromTable(@"DeviceSettingDetail_VC_every", APP_LAN_TABLE, nil),
                                     NSLocalizedStringFromTable(@"DeviceSettingDetail_VC_every_minute", APP_LAN_TABLE, nil)],
                                    [NSString stringWithFormat:@"%@20%@",
                                     NSLocalizedStringFromTable(@"DeviceSettingDetail_VC_every", APP_LAN_TABLE, nil),
                                     NSLocalizedStringFromTable(@"DeviceSettingDetail_VC_every_minute", APP_LAN_TABLE, nil)],
                                   /* [NSString stringWithFormat:@"%@30%@",
                                     NSLocalizedStringFromTable(@"DeviceSettingDetail_VC_every", APP_LAN_TABLE, nil),
                                     NSLocalizedStringFromTable(@"DeviceSettingDetail_VC_every_minute", APP_LAN_TABLE, nil)]*/];
                    }else
                    {
                        actions = @[NSLocalizedStringFromTable(@"DeviceSettingDetail_VC_shutdown", APP_LAN_TABLE, nil),
                                    [NSString stringWithFormat:@"%@5%@",
                                     NSLocalizedStringFromTable(@"DeviceSettingDetail_VC_every", APP_LAN_TABLE, nil),
                                     NSLocalizedStringFromTable(@"DeviceSettingDetail_VC_every_minute", APP_LAN_TABLE, nil)],
                                    [NSString stringWithFormat:@"%@15%@",
                                     NSLocalizedStringFromTable(@"DeviceSettingDetail_VC_every", APP_LAN_TABLE, nil),
                                     NSLocalizedStringFromTable(@"DeviceSettingDetail_VC_every_minute", APP_LAN_TABLE, nil)],
                                    [NSString stringWithFormat:@"%@30%@",
                                     NSLocalizedStringFromTable(@"DeviceSettingDetail_VC_every", APP_LAN_TABLE, nil),
                                     NSLocalizedStringFromTable(@"DeviceSettingDetail_VC_every_minute", APP_LAN_TABLE, nil)],
                                    [NSString stringWithFormat:@"%@60%@",
                                     NSLocalizedStringFromTable(@"DeviceSettingDetail_VC_every", APP_LAN_TABLE, nil),
                                     NSLocalizedStringFromTable(@"DeviceSettingDetail_VC_every_minute", APP_LAN_TABLE, nil)]];
                    }
                    [self presentTimeChooseWithTitle:self.texts2[indexPath.row] actions:actions chooseIndex:gpsValue cell:cell];
                    
                }
                
            } break;
            case 1:     // 上传间隔频率
            {
                int uploadValue;
                if ([self.type isEqualToString:@"1"])
                {
                    uploadValue = m.echoPrT;
                }else
                {
                    if ([self.type isEqualToString:@"85"]){
                        switch (m.echoPrT)
                        {
                            case 30:
                                uploadValue = 0;
                                break;
                            case 60:
                                uploadValue = 1;
                                break;
                            case 90:
                                uploadValue = 2;
                                break;
                            case 120:
                                uploadValue = 3;
                            default:
                                break;
                        }
                    }else{
                        switch (m.echoPrT)
                        {
                            case 0:
                                uploadValue = 0;
                                break;
                            case 30:
                                uploadValue = 1;
                                break;
                            case 60:
                                uploadValue = 2;
                                break;
                            case 90:
                                uploadValue = 3;
                                break;
                            case 120:
                                uploadValue = 4;
                            default:
                                break;
                        }
                    }
                    
                }
                
                NSArray *actions;
                
                if ([self.type isEqualToString:@"1"])
                {
                    actions = @[NSLocalizedStringFromTable(@"DeviceSettingDetail_VC_shutdown", APP_LAN_TABLE, nil),
                                [NSString stringWithFormat:@"%@5%@",
                                 NSLocalizedStringFromTable(@"DeviceSettingDetail_VC_every", APP_LAN_TABLE, nil),
                                 NSLocalizedStringFromTable(@"DeviceSettingDetail_VC_every_minute", APP_LAN_TABLE, nil)],
                                
                                [NSString stringWithFormat:@"%@6%@",
                                 NSLocalizedStringFromTable(@"DeviceSettingDetail_VC_every", APP_LAN_TABLE, nil),
                                 NSLocalizedStringFromTable(@"DeviceSettingDetail_VC_every_minute", APP_LAN_TABLE, nil)],
                                
                                [NSString stringWithFormat:@"%@10%@",
                                 NSLocalizedStringFromTable(@"DeviceSettingDetail_VC_every", APP_LAN_TABLE, nil),
                                 NSLocalizedStringFromTable(@"DeviceSettingDetail_VC_every_minute", APP_LAN_TABLE, nil)],
                                
                                [NSString stringWithFormat:@"%@12%@",
                                 NSLocalizedStringFromTable(@"DeviceSettingDetail_VC_every", APP_LAN_TABLE, nil),
                                 NSLocalizedStringFromTable(@"DeviceSettingDetail_VC_every_minute", APP_LAN_TABLE, nil)],
                                
                                [NSString stringWithFormat:@"%@15%@",
                                 NSLocalizedStringFromTable(@"DeviceSettingDetail_VC_every", APP_LAN_TABLE, nil),
                                 NSLocalizedStringFromTable(@"DeviceSettingDetail_VC_every_minute", APP_LAN_TABLE, nil)],
                                [NSString stringWithFormat:@"%@20%@",
                                 NSLocalizedStringFromTable(@"DeviceSettingDetail_VC_every", APP_LAN_TABLE, nil),
                                 NSLocalizedStringFromTable(@"DeviceSettingDetail_VC_every_minute", APP_LAN_TABLE, nil)],
                                [NSString stringWithFormat:@"%@30%@",
                                 NSLocalizedStringFromTable(@"DeviceSettingDetail_VC_every", APP_LAN_TABLE, nil),
                                 NSLocalizedStringFromTable(@"DeviceSettingDetail_VC_every_minute", APP_LAN_TABLE, nil)],
                                [NSString stringWithFormat:@"%@60%@",
                                 NSLocalizedStringFromTable(@"DeviceSettingDetail_VC_every", APP_LAN_TABLE, nil),
                                 NSLocalizedStringFromTable(@"DeviceSettingDetail_VC_every_minute", APP_LAN_TABLE, nil)],
                                [NSString stringWithFormat:@"%@120%@",
                                 NSLocalizedStringFromTable(@"DeviceSettingDetail_VC_every", APP_LAN_TABLE, nil),
                                 NSLocalizedStringFromTable(@"DeviceSettingDetail_VC_every_minute", APP_LAN_TABLE, nil)],
                                [NSString stringWithFormat:@"%@180%@",
                                 NSLocalizedStringFromTable(@"DeviceSettingDetail_VC_every", APP_LAN_TABLE, nil),
                                 NSLocalizedStringFromTable(@"DeviceSettingDetail_VC_every_minute", APP_LAN_TABLE, nil)],
                                [NSString stringWithFormat:@"%@240%@",
                                 NSLocalizedStringFromTable(@"DeviceSettingDetail_VC_every", APP_LAN_TABLE, nil),
                                 NSLocalizedStringFromTable(@"DeviceSettingDetail_VC_every_minute", APP_LAN_TABLE, nil)],
                                [NSString stringWithFormat:@"%@360%@",
                                 NSLocalizedStringFromTable(@"DeviceSettingDetail_VC_every", APP_LAN_TABLE, nil),
                                 NSLocalizedStringFromTable(@"DeviceSettingDetail_VC_every_minute", APP_LAN_TABLE, nil)],
                                [NSString stringWithFormat:@"%@720%@",
                                 NSLocalizedStringFromTable(@"DeviceSettingDetail_VC_every", APP_LAN_TABLE, nil),
                                 NSLocalizedStringFromTable(@"DeviceSettingDetail_VC_every_minute", APP_LAN_TABLE, nil)],
                                ];
                    
                    
                }else
                {
                    actions = @[NSLocalizedStringFromTable(@"DeviceSettingDetail_VC_shutdown", APP_LAN_TABLE, nil),
                                [NSString stringWithFormat:@"%@30%@",
                                 NSLocalizedStringFromTable(@"DeviceSettingDetail_VC_every", APP_LAN_TABLE, nil),
                                 NSLocalizedStringFromTable(@"DeviceSettingDetail_VC_every_minute", APP_LAN_TABLE, nil)],
                                [NSString stringWithFormat:@"%@60%@",
                                 NSLocalizedStringFromTable(@"DeviceSettingDetail_VC_every", APP_LAN_TABLE, nil),
                                 NSLocalizedStringFromTable(@"DeviceSettingDetail_VC_every_minute", APP_LAN_TABLE, nil)],
                                [NSString stringWithFormat:@"%@90%@",
                                 NSLocalizedStringFromTable(@"DeviceSettingDetail_VC_every", APP_LAN_TABLE, nil),
                                 NSLocalizedStringFromTable(@"DeviceSettingDetail_VC_every_minute", APP_LAN_TABLE, nil)],
                                [NSString stringWithFormat:@"%@120%@",
                                 NSLocalizedStringFromTable(@"DeviceSettingDetail_VC_every", APP_LAN_TABLE, nil),
                                 NSLocalizedStringFromTable(@"DeviceSettingDetail_VC_every_minute", APP_LAN_TABLE, nil)]];
                }
                
                //8010 删除 上传频率 <关闭> 选项
                //------------------ 改 --------------------
                if ([self.type isEqualToString:@"85"]) {
                    NSMutableArray *mArr = actions.mutableCopy;
                    //删除关闭
                    [mArr removeObjectAtIndex:0];
                    actions = mArr.copy;
                }
                //------------------ end --------------------
                
                
                [self presentTimeChooseWithTitle:self.texts2[indexPath.row]
                                         actions:actions
                                     chooseIndex:uploadValue
                                            cell:cell];
            } break;
            default:
                break;
        }
    } else {        // 电子围栏
        if (indexPath.row == 0) {       // 电子围栏
            KMGeofenceVC *geofenceVC = [KMGeofenceVC new];
            geofenceVC.imei = self.imei;
            [self.navigationController pushViewController:geofenceVC animated:YES];
        } else {                        // 定时定位
            KMGeofenceSettingVC *vc = [[KMGeofenceSettingVC alloc] init];
            vc.imei = self.imei;
            [self.navigationController pushViewController:vc animated:YES];
        }
    }
}

- (void)presentTimeChooseWithTitle:(NSString *)title
                           actions:(NSArray *)actions
                       chooseIndex:(NSInteger)index
                              cell:(UITableViewCell *)cell
{
    WS(ws);
    KMDeviceManagerDetailModel *m = [self.deviceManagerModel.list objectAtIndex:0];
    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:title message:@"" preferredStyle:UIAlertControllerStyleActionSheet];
    UIAlertActionStyle style = UIAlertActionStyleDefault;
    
    
    // 操作选择
    if ([self.type isEqualToString:@"1"])
    {
        
        for (int i = 0; i < actions.count; i++)
        {
            if ([title isEqualToString:kLoadStringWithKey(@"DeviceSettingDetail_VC_gps_on")])
            {
                switch (i)
                {
                    case 0:
                    {
                        if (index == 0)
                        {
                            style = UIAlertActionStyleDestructive;
                        }else
                        {
                            style = UIAlertActionStyleDefault;
                        }
                    }
                        break;
                    case 1:
                    {
                        if (index == 1)
                        {
                            style = UIAlertActionStyleDestructive;
                        }else
                        {
                            style = UIAlertActionStyleDefault;
                        }
                    }
                        break;
                    case 2:
                    {
                        if (index == 2)
                        {
                            style = UIAlertActionStyleDestructive;
                        }else
                        {
                            style = UIAlertActionStyleDefault;
                        }
                    }
                        break;
                    case 3:
                    {
                        if (index == 3)
                        {
                            style = UIAlertActionStyleDestructive;
                        }else
                        {
                            style = UIAlertActionStyleDefault;
                        }
                    }
                        break;
                    /*case 4:
                    {
                        if (index == 4)
                        {
                            style = UIAlertActionStyleDestructive;
                        }else
                        {
                            style = UIAlertActionStyleDefault;
                        }
                    }
                        break;
                    case 5:
                    {
                        if (index == 5)
                        {
                            style = UIAlertActionStyleDestructive;
                        }else
                        {
                            style = UIAlertActionStyleDefault;
                        }
                    }
                        break;*/
                }
            }else
            {
                switch (i)
                {
                    case 0:
                    {
                        if (index == 0)
                        {
                            style = UIAlertActionStyleDestructive;
                        }else
                        {
                            style = UIAlertActionStyleDefault;
                        }
                    }
                        break;
                    case 1:
                    {
                        if (index == 177)
                        {
                            style = UIAlertActionStyleDestructive;
                        }else
                        {
                            style = UIAlertActionStyleDefault;
                        }
                    }
                        break;
                    case 2:
                    {
                        if (index == 161)
                        {
                            style = UIAlertActionStyleDestructive;
                        }else
                        {
                            style = UIAlertActionStyleDefault;
                        }
                    }
                        break;
                    case 3:
                    {
                        if (index == 97)
                        {
                            style = UIAlertActionStyleDestructive;
                        }else
                        {
                            style = UIAlertActionStyleDefault;
                        }
                    }
                        break;
                    case 4:
                    {
                        if (index == 81)
                        {
                            style = UIAlertActionStyleDestructive;
                        }else
                        {
                            style = UIAlertActionStyleDefault;
                        }
                    }
                        break;
                    case 5:
                    {
                        if (index == 65)
                        {
                            style = UIAlertActionStyleDestructive;
                        }else
                        {
                            style = UIAlertActionStyleDefault;
                        }
                    }
                        break;
                    case 6:
                    {
                        if (index == 49)
                        {
                            style = UIAlertActionStyleDestructive;
                        }else
                        {
                            style = UIAlertActionStyleDefault;
                        }
                    }
                        break;
                        
                    case 7:
                    {
                        if (index == 33)
                        {
                            style = UIAlertActionStyleDestructive;
                        }else
                        {
                            style = UIAlertActionStyleDefault;
                        }
                    }
                        break;
                        
                    case 8:
                    {
                        if (index == 1)
                        {
                            style = UIAlertActionStyleDestructive;
                        }else
                        {
                            style = UIAlertActionStyleDefault;
                        }
                    }
                        break;
                        
                    case 9:
                    {
                        if (index == 2)
                        {
                            style = UIAlertActionStyleDestructive;
                        }else
                        {
                            style = UIAlertActionStyleDefault;
                        }
                    }
                        break;
                    case 10:
                    {
                        if (index == 3)
                        {
                            style = UIAlertActionStyleDestructive;
                        }else
                        {
                            style = UIAlertActionStyleDefault;
                        }
                    }
                        break;
                    case 11:
                    {
                        if (index == 4)
                        {
                            style = UIAlertActionStyleDestructive;
                        }else
                        {
                            style = UIAlertActionStyleDefault;
                        }
                    }
                        break;
                    case 12:
                    {
                        if (index == 6)
                        {
                            style = UIAlertActionStyleDestructive;
                        }else
                        {
                            style = UIAlertActionStyleDefault;
                        }
                    }
                        break;
                    case 13:
                    {
                        if (index == 11)
                        {
                            style = UIAlertActionStyleDestructive;
                        }else
                        {
                            style = UIAlertActionStyleDefault;
                        }
                    }
                        break;
                        
                }
            }
            
            
            UIAlertAction *action = [UIAlertAction actionWithTitle:actions[i] style:style handler:^(UIAlertAction *action) {
                
                // TODO: 添加网络请求
                if ([title isEqualToString:kLoadStringWithKey(@"DeviceSettingDetail_VC_gps_on")])
                {
                    // GPS启动时间设置
                    switch (i)
                    {
                        case 0:
                        {
                            m.echoGpsT = 0;
                            m.phoneLimitOnoff=0;
                            m.phoneLimitTime = 0;
                            
                        }break;
                        /*case 1:
                        {
                            m.echoGpsT = 4;
                            m.phoneLimitOnoff=1;
                            
                        }break;*/
                        case 1:
                        {
                            m.echoGpsT = 1;
                            m.phoneLimitOnoff=1;
                            
                        }break;
                        case 2:
                        {
                            m.echoGpsT = 2;
                            m.phoneLimitOnoff=1;
                        }break;
                        case 3:
                        {
                            m.echoGpsT = 3;
                            m.phoneLimitOnoff=1;
                        }break;
                        /*case 5:
                        {
                            m.echoGpsT = 5;
                            m.phoneLimitOnoff=1;
                        }break;*/
                        default:
                            break;
                    }
                }
                else if ([title isEqualToString:kLoadStringWithKey(@"DeviceSettingDetail_VC_upload")])
                {
                    // 上传时间设置
                    switch (i)
                    {
                        case 0:
                            m.echoPrT = 0;
                            break;
                        case 1:
                            m.echoPrT = 177;
                            break;
                        case 2:
                            m.echoPrT = 161;
                            break;
                        case 3:
                            m.echoPrT = 97;
                            break;
                        case 4:
                            m.echoPrT = 81;
                            break;
                            
                        case 5:
                            m.echoPrT = 65;
                            break;
                            
                        case 6:
                            m.echoPrT = 49;
                            break;
                            
                        case 7:
                            m.echoPrT = 33;
                            break;
                            
                        case 8:
                            m.echoPrT = 1;
                            break;
                            
                        case 9:
                            m.echoPrT = 2;
                            break;
                            
                        case 10:
                            m.echoPrT = 3;
                            break;
                            
                        case 11:
                            m.echoPrT = 4;
                            break;
                            
                        case 12:
                            m.echoPrT = 6;
                            break;
                            
                        case 13:
                            m.echoPrT = 11;
                            break;
                            
                        default:
                            break;
                    }
                }
                [ws updateDeviceSettingWithBody:[m mj_JSONString]];
            }];
            [alertController addAction:action];
        }
    }else
    {
        for (int i = 0; i < actions.count; i++)
        {
            
            if (i == index)
            {
                style = UIAlertActionStyleDestructive;
            } else
            {
                style = UIAlertActionStyleDefault;
            }
            
            UIAlertAction *action = [UIAlertAction actionWithTitle:actions[i] style:style handler:^(UIAlertAction *action)
                                     {
                                         // TODO: 添加网络请求
                                         if ([title isEqualToString:kLoadStringWithKey(@"DeviceSettingDetail_VC_gps_on")])
                                         {
                                             // GPS启动时间设置
                                             switch (i)
                                             {
                                                 case 0:
                                                 {
                                                     m.echoGpsT = 0;
                                                     m.phoneLimitOnoff=0;
                                                     m.phoneLimitTime = 0;
                                                     
                                                 }break;
                                                 case 1:
                                                 {
                                                     m.echoGpsT = 5;
                                                     m.phoneLimitOnoff=1;
                                                     
                                                 }break;
                                                 case 2:
                                                 {
                                                     m.echoGpsT = 15;
                                                     m.phoneLimitOnoff=1;
                                                     
                                                 }break;
                                                 case 3:
                                                 {
                                                     m.echoGpsT = 30;
                                                     m.phoneLimitOnoff=1;
                                                 }break;
                                                 case 4:
                                                 {
                                                     m.echoGpsT = 60;
                                                     m.phoneLimitOnoff=1;
                                                 }break;
                                                 default:
                                                     break;
                                             }
                                         } else if ([title isEqualToString:kLoadStringWithKey(@"DeviceSettingDetail_VC_upload")]&&[self.type isEqualToString:@"85"]){
                                             // 上传时间设置
                                             switch (i) {
                                                 case 0:
                                                     m.echoPrT = 30;
                                                     break;
                                                 case 1:
                                                     m.echoPrT = 60;
                                                     break;
                                                 case 2:
                                                     m.echoPrT = 90;
                                                     break;
                                                 case 3:
                                                     m.echoPrT = 120;
                                                     break;
                                                 default:
                                                     break;
                                             }
                                         }else if ([title isEqualToString:kLoadStringWithKey(@"DeviceSettingDetail_VC_upload")]){
                                             // 上传时间设置
                                             switch (i) {
                                                 case 0:
                                                     m.echoPrT = 0;
                                                     break;
                                                 case 1:
                                                     m.echoPrT = 30;
                                                     break;
                                                 case 2:
                                                     m.echoPrT = 60;
                                                     break;
                                                 case 3:
                                                     m.echoPrT = 90;
                                                     break;
                                                 case 4:
                                                     m.echoPrT = 120;
                                                     break;
                                                 default:
                                                     break;
                                             }
                                         }
                                         [ws updateDeviceSettingWithBody:[m mj_JSONString]];
                                     }];
            [alertController addAction:action];
        }
    }
    
    // 取消
    UIAlertAction *action1 = [UIAlertAction actionWithTitle:kLoadStringWithKey(@"Common_cancel")
                                                      style:UIAlertActionStyleCancel
                                                    handler:nil];
    [alertController addAction:action1];
    alertController.modalPresentationStyle = UIModalPresentationPopover;
    UIPopoverPresentationController *popPresenter = alertController.popoverPresentationController;
    popPresenter.sourceView = cell;
    popPresenter.sourceRect = cell.bounds;
    [self presentViewController:alertController animated:YES completion:nil];
}

#pragma mark - UISwitch-更新设定
- (void)switchDidClick:(UISwitch *)mSwitch
{
    BOOL state = mSwitch.isOn;
    KMDeviceManagerDetailModel *m = [self.deviceManagerModel.list objectAtIndex:0];
    
    switch (mSwitch.tag)
    {
            //        case 0:         // 跌倒侦测
            //            m.fallDetect = state;
            //            break;
        case 0:         // 抬手亮屏
            m.autoread = state;
            break;
        default:
            break;
    }
    //    [self updateDeviceSettingWithBody:[m mj_JSONString]];
    
    NSString *body = [m mj_JSONString];
    WS(ws);
    NSString *request = [NSString stringWithFormat:@"deviceManager/%@/%@",
                         member.loginAccount,
                         self.imei];
    [SVProgressHUD show];
    [[KMNetAPI manager] commonPOSTRequestWithURL:request jsonBody:body Block:^(int code, NSString *res)
     {
         KMNetworkResModel *resModel = [KMNetworkResModel mj_objectWithKeyValues:res];
         if (code == 0 && resModel.errorCode <= kNetReqSuccess)
         {
             [SVProgressHUD dismiss];
             [ws requestDeviceSetting];
         } else
         {
             mSwitch.on = !mSwitch.isOn;
             [SVProgressHUD showErrorWithStatus:kNetReqFailWithCode(resModel.errorCode)];
         }
     }];
}

@end
