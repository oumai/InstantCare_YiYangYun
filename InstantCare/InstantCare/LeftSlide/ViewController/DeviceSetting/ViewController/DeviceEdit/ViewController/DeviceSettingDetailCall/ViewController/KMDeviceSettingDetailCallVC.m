//
//  KMDeviceSettingDetailCallVC.m
//  InstantCare
//
//  Created by bruce-zhu on 15/12/11.
//  Copyright © 2015年 omg. All rights reserved.
//

#import "KMDeviceSettingDetailCallVC.h"
#import "KMDeviceSettingResModel.h"
#import "KMDeviceSettingEditCell.h"
#import "KMImageTitleButton.h"
#import "CustomIOSAlertView.h"
#import "KMCommonAlertView.h"
#import "KMSilentSettingVC.h"
#import "MJRefresh.h"
#import "KMNetAPI.h"
#import "MJExtension.h"

#define KM_DEVICE_SETTING_KEEP_QUIT_MASK    0x0004  // 防打扰开关
#define kBottomBtnHeight    50


@interface KMDeviceSettingDetailCallVC () <UITableViewDataSource, UITableViewDelegate,UITextFieldDelegate,UIPickerViewDataSource,UIPickerViewDelegate>

@property (nonatomic, strong) UITableView *tableView;

@property (nonatomic, strong) KMDeviceManagerModel *deviceManagerModel;

@property (nonatomic, strong) NSArray *dataArray1;      // 第一组的row标题
@property (nonatomic, strong) NSArray *dataArray2;      // 第二组亲情号码row标题
@property (nonatomic, strong) NSArray *dataArray3;      // 第三组紧急号码row标题

@property (nonatomic, strong) CustomIOSAlertView *alertView;        // 填写新的号码
@property (nonatomic, strong) NSIndexPath *currentIndexPath;        // 当前选择的路径
@property (nonatomic, assign) NSInteger currentRow;

/** 8020  类型分组NumberCount */
@property (nonatomic, strong) NSArray * numberCount_8020;

/** 8000  分区标题 */
@property (nonatomic, strong) NSArray * titles_8020;
/** 8010 ~ 8000  分区标题 */
@property (nonatomic, strong) NSArray * titles_8010;

/** cellModel */
@property (nonatomic, strong) KMDeviceSettingDetailCallModel *cellModel;

/** postFamilyModel */
@property (nonatomic, strong) KMDeviceSettingCallFamilyModel *postFamilyModel;

/** postSosModel */
@property (nonatomic, strong) KMDeviceSettingCallSosModel *postSosModel;

/** postSosSmsModel */
@property (nonatomic, strong) KMDeviceSettingCallSosSmsModel *postSosSmsModel;

/** 提示框 */
@property (nonatomic, strong) CustomIOSAlertView * alert;

/** cell 高度 */
@property (nonatomic, assign) NSInteger smsHeight;

/** 8010通话显示 */
@property (nonatomic, strong) NSArray *limitTimes;


@end

@implementation KMDeviceSettingDetailCallVC
// limitTimes
- (NSArray *)limitTimes
{
    if(_limitTimes == nil)
    {
        _limitTimes = @[@0,@5,@15,@30,@60];
    }
    return _limitTimes;
}

// postFamilyModel
-(KMDeviceSettingCallFamilyModel *)postFamilyModel
{
    if (_postFamilyModel == nil) {
        
        _postFamilyModel = [[KMDeviceSettingCallFamilyModel alloc] init];
        _postFamilyModel.number1 =  _cellModel.fmy1;
        _postFamilyModel.number2 =  _cellModel.fmy2;
        _postFamilyModel.number3 =  _cellModel.fmy3;
        _postFamilyModel.number4 =  _cellModel.fmy4;
    }
    return _postFamilyModel;
}

//  postSosModel
- (KMDeviceSettingCallSosModel *)postSosModel
{
    if(_postSosModel == nil)
    {
        _postSosModel = [[KMDeviceSettingCallSosModel alloc] init];
        _postSosModel.number1 =  _cellModel.sos1;
        _postSosModel.number2 =  _cellModel.sos2;
        _postSosModel.number3 =  _cellModel.sos3;
    }
    return _postSosModel;
}

// postSosSmsModel
- (KMDeviceSettingCallSosSmsModel *)postSosSmsModel
{
    if(_postSosSmsModel == nil)
    {
        _postSosSmsModel = [[KMDeviceSettingCallSosSmsModel alloc] init];
        _postSosSmsModel.sms = _cellModel.sosSms;
    }
    return _postSosSmsModel;
}

//  numberCount_8020
- (NSArray *)numberCount_8020
{
    if(_numberCount_8020 == nil)
    {
        _numberCount_8020 = @[@0,@4,@3,@1];
    }
    return _numberCount_8020;
}

//  titles_8020
- (NSArray *)titles_8020
{
    if(_titles_8020 == nil)
    {
        _titles_8020 = @[
                         //kLoadStringWithKey(@"DeviceManager_HealthSetting_alert_call_setting"),
                         @"",kLoadStringWithKey(@"DeviceSettingDetailCall_VC_call_family_number"),
                         kLoadStringWithKey(@"DeviceSettingDetailCall_VC_call_sos_number"),
                         kLoadStringWithKey(@"DeviceSettingDetailCall_VC_call_sos_sms")];
    }
    return _titles_8020;
}
//  titles_8010
- (NSArray *)titles_8010
{
    if(_titles_8010 == nil)
    {
        _titles_8010 = @[kLoadStringWithKey(@"DeviceSettingDetailCall_VC_call_set"),kLoadStringWithKey(@"DeviceSettingDetailCall_VC_call_family_number"),kLoadStringWithKey(@"DeviceSettingDetailCall_VC_call_sos_number"),@""];
    }
    return _titles_8010;
}

// 视图加载完成
- (void)viewDidLoad
{
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor whiteColor];
    
    [self initDataArray];
    [self configNavBar];
    [self configView];
}

// 视图将要显示
- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    if (self.is3DTouchLoad == 1) {
        [SVProgressHUD show];
        if ([self.type isEqualToString:@"20"]) {
            
            [self loadPhoneNumber];
        }else{
            
            [self requestDeviceSetting];
        }
        self.is3DTouchLoad = 2;
    }else if (self.is3DTouchLoad == 2){
        return ;
    }
    else{
        [SVProgressHUD show];
        if ([self.type isEqualToString:@"20"]) {
            
            [self loadPhoneNumber];
        }else{
            
            [self requestDeviceSetting];
        }
    }
    
}

// 初始化数据
- (void)initDataArray
{
    self.dataArray1 = @[kLoadStringWithKey(@"DeviceSettingDetailCall_VC_call_limit")];
    //    self.dataArray1 = @[@"静音时间段设置"];
    
    
    self.dataArray2 = @[kLoadStringWithKey(@"DeviceSettingDetailCall_VC_call_first_group"),
                        kLoadStringWithKey(@"DeviceSettingDetailCall_VC_call_second_group"),
                        kLoadStringWithKey(@"DeviceSettingDetailCall_VC_call_third_group"),
                        kLoadStringWithKey(@"DeviceSettingDetailCall_VC_call_fourth_group")];
    
    self.dataArray3 = @[kLoadStringWithKey(@"DeviceSettingDetailCall_VC_call_first_group"),
                        kLoadStringWithKey(@"DeviceSettingDetailCall_VC_call_second_group"),
                        kLoadStringWithKey(@"DeviceSettingDetailCall_VC_call_third_group")];
}

#pragma mark - 设置导航栏
- (void)configNavBar
{
    self.navigationItem.title = kLoadStringWithKey(@"DeviceSettingDetailCall_VC_title");
    
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

#pragma mark - 设置视图
- (void)configView
{
    self.tableView = [[UITableView alloc] init];
    self.tableView.dataSource = self;
    self.tableView.delegate = self;
    self.tableView.rowHeight = 70;
    self.tableView.tableFooterView = [UIView new];
    [self.view addSubview:self.tableView];
    [self.tableView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.equalTo(self.view);
    }];
    
    WS(ws);
    // 下拉刷新
    self.tableView.mj_header = [MJRefreshNormalHeader headerWithRefreshingBlock:^{
        [ws requestDeviceSetting];
        [ws loadPhoneNumber];
    }];
}

#pragma mark - 网络请求
/**
 *   请求设备信息
 */
- (void)requestDeviceSetting
{
    // deviceManager/{account}/{imei}
    // 1.URL
    NSString *request = [NSString stringWithFormat:@"deviceManager/%@/%@", member.loginAccount,self.imei];
    
    // 2.开始网络请求
    [[KMNetAPI manager] commonGetRequestWithURL:request Block:^(int code, NSString *res)
     {
         [_tableView.mj_header endRefreshing];
         KMNetworkResModel *resModel = [KMNetworkResModel mj_objectWithKeyValues:res];
         if (code == 0 && resModel.errorCode <= kNetReqSuccess)
         {
             [SVProgressHUD dismiss];
             _deviceManagerModel = [KMDeviceManagerModel mj_objectWithKeyValues:resModel.content];
             [_tableView reloadData];
         } else
         {
             [SVProgressHUD showErrorWithStatus:kNetReqFailWithCode(resModel.errorCode)];
         }
     }];
}


/**
 *   请求电话号码
 */
- (void)loadPhoneNumber
{
    // 开始更改操作
    [SVProgressHUD show];
    
    // URL
    NSString * reuqest = [NSString stringWithFormat:@"deviceManager/%@/%@?type=contactInfo",member.loginAccount,self.imei];
    
    // 网络请求
    [[KMNetAPI manager] commonGetRequestWithURL:reuqest Block:^(int code, NSString *res) {
        
        [SVProgressHUD dismiss];
        KMNetworkResModel * resModel = [KMNetworkResModel mj_objectWithKeyValues:res];
        
        if (code == 0 && resModel.errorCode <= kNetReqSuccess)
        {
            // 解析数据模型
            NSDictionary * dic = (NSDictionary *)resModel.content;
            NSArray * list = dic[@"list"];
            
            self.cellModel = [KMDeviceSettingDetailCallModel mj_objectWithKeyValues:[list lastObject]];
            
            NSDictionary * dic2 = @{NSFontAttributeName:[UIFont systemFontOfSize:14]};
            CGSize size = CGSizeMake(SCREEN_WIDTH-40,0);
            CGSize retSize = [self.cellModel.sosSms boundingRectWithSize:size options:NSStringDrawingUsesLineFragmentOrigin attributes:dic2 context:nil].size;
            self.smsHeight = retSize.height;
            // 刷新表视图
            [self.tableView reloadData];
        }else
        {
            [SVProgressHUD showErrorWithStatus:kNetReqFailWithCode(resModel.errorCode)];
        }
    }];
    
}

/**
 *   上传设备信息
 */
- (void)updateDeviceSettingWithBody:(NSString *)body
{
    // deviceManager/{account}/{imei}
    WS(ws);
    NSString *request = [NSString stringWithFormat:@"deviceManager/%@/%@",member.loginAccount, self.imei];
    [[KMNetAPI manager] commonPOSTRequestWithURL:request jsonBody:body Block:^(int code, NSString *res)
     {
         
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

#pragma mark - <UITableViewDataSource>
/**
 *   返回分区
 */
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    // 20160813去掉跌倒号码
    return 4;
}

/**
 *   返回分组
 */
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if ([self.type isEqualToString:@"20"]) {
        
        return [self.numberCount_8020[section] integerValue];
    }
    
    NSInteger number = 0;
    switch (section)
    {
        case 0:         // 来电静音
        {
            if ([self.type isEqualToString:@"85"]) {
                number = 1;
            }else{
                number = 2;
            }
        }
            break;
        case 1:         // 亲情号码
            number = self.dataArray2.count-1	;
            break;
        case 2:         // 紧急号码
            number = self.dataArray3.count;
            break;
        case 3:         // 跌倒号码
            number = 0;
            break;
        default:
            break;
    }
    return number;
}

/**
 *   返回实例对象
 */
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell;
    
    KMDeviceManagerDetailModel *m = [self.deviceManagerModel.list objectAtIndex:0];
    switch (indexPath.section)
    {
        case 0:         // 来电静音
        {
            if (indexPath.row == 0)
            {
                cell = [tableView dequeueReusableCellWithIdentifier:@"cell1"];
                if (cell == nil)
                {
                    cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault
                                                  reuseIdentifier:@"cell1"];
                }
                
                cell.textLabel.text = [self.type isEqualToString:@"20"]?kLoadStringWithKey(@"DeviceManager_HealthSetting_time_muteSetting"):kLoadStringWithKey(@"DeviceSettingDetailCall_VC_call_mute");
                
                
                if ([self.type isEqualToString:@"20"]) {
                    
                    cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
                }else{
                    UISwitch *mSwitch = [[UISwitch alloc] init];
                    mSwitch.tag = indexPath.row;
                    [mSwitch addTarget:self
                                action:@selector(switchDidClick:)
                      forControlEvents:UIControlEventValueChanged];
                    cell.accessoryView = mSwitch;
                    
                    if (m.nonDistrub)
                    {
                        mSwitch.on = YES;
                    } else {
                        mSwitch.on = NO;
                    }
                }
                
            } else if (indexPath.row == 1)   // 通话限时
            {
                cell = [tableView dequeueReusableCellWithIdentifier:@"cell3"];
                if (cell == nil)
                {
                    cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault
                                                  reuseIdentifier:@"cell3"];
                }
                UITableViewCell * newCell = cell;
                newCell.textLabel.text = self.dataArray1[0];
                newCell.textLabel.textColor = [UIColor blackColor];
                UILabel * label  = [[UILabel alloc] initWithFrame:CGRectMake(0, 0,100,30)];
                label.textAlignment = NSTextAlignmentCenter;
                newCell.accessoryView = label;
                
                NSString *detailString = nil;
                switch (m.phoneLimitTime)
                {
                    case 0:     // 关闭
                    {
                        detailString = kLoadStringWithKey(@"DeviceSettingDetail_VC_shutdown");
                    } break;
                    default:
                        detailString = [NSString stringWithFormat:@"%d%@",
                                        m.phoneLimitTime,
                                        kLoadStringWithKey(@"DeviceSettingDetail_VC_every_minute")];
                        break;
                }
                label.text = detailString;
                
            } break;
        case 1:         // 亲情号码
            {
                cell = [tableView dequeueReusableCellWithIdentifier:@"cell2"];
                if (cell == nil)
                {
                    cell = [[KMDeviceSettingEditCell alloc] initWithStyle:UITableViewCellStyleDefault
                                                          reuseIdentifier:@"cell2"];
                }
                KMDeviceSettingEditCell *newCell = (KMDeviceSettingEditCell *)cell;
                newCell.titleLabel.textColor = [UIColor blackColor];
                newCell.titleLabel.text = self.dataArray2[indexPath.row];
                
                NSString * test;
                if ([self.type isEqualToString:@"20"]) {
                    
                    switch (indexPath.row)
                    {
                            
                        case 0:
                            test = _cellModel.fmy1;
                            break;
                        case 1:
                            test = _cellModel.fmy2;
                            break;
                        case 2:
                            test = _cellModel.fmy3;
                            break;
                        case 3:
                            test = _cellModel.fmy4;
                            break;
                        default:
                            break;
                    }
                    if ([test isEqualToString:@"0"]|| test.length == 0) {
                        test = kLoadStringWithKey(@"Geofence_VC_not_setting");
                    }
                    newCell.detailLabel.text = test;
                }else{
                    
                    switch (indexPath.row)
                    {
                        case 0:
                            test = m.fmlyPhoneNo1;
                            break;
                        case 1:
                            test = m.fmlyPhoneNo2;
                            break;
                        case 2:
                            test = m.fmlyPhoneNo3;
                            break;
                        default:
                            break;
                    }
                    if ([test isEqualToString:@"0"] || test.length == 0 ) {
                        test = kLoadStringWithKey(@"Geofence_VC_not_setting");
                    }
                    newCell.detailLabel.text = test;
                }
            }
        } break;
        case 2:         // 紧急号码
        {
            cell = [tableView dequeueReusableCellWithIdentifier:@"cell2"];
            if (cell == nil) {
                cell = [[KMDeviceSettingEditCell alloc] initWithStyle:UITableViewCellStyleDefault
                                                      reuseIdentifier:@"cell2"];
            }
            
            KMDeviceSettingEditCell *newCell = (KMDeviceSettingEditCell *)cell;
            newCell.titleLabel.textColor = [UIColor blackColor];
            newCell.titleLabel.text = self.dataArray3[indexPath.row];
            
            NSString * test;
            if ([self.type isEqualToString:@"20"]) {
                
                switch (indexPath.row)
                {
                    case 0:
                        test = _cellModel.sos1;
                        break;
                    case 1:
                        test = _cellModel.sos2;
                        break;
                    case 2:
                        test = _cellModel.sos3;
                        break;
                    default:
                        break;
                }
                if ([test isEqualToString:@"0"] || test.length == 0 ) {
                    test = kLoadStringWithKey(@"Geofence_VC_not_setting");
                }
                newCell.detailLabel.text = test;
                
            }else{
                
                NSString * test;
                switch (indexPath.row)
                {
                    case 0:
                        test = m.sosPhoneNo1;
                        break;
                    case 1:
                        test = m.sosPhoneNo2;
                        break;
                    case 2:
                        test = m.sosPhoneNo3;
                        break;
                    default:
                        break;
                }
                if ([test isEqualToString:@"0"]|| test.length == 0) {
                    test = kLoadStringWithKey(@"Geofence_VC_not_setting");
                }
                /*if ( indexPath.section == 2 && indexPath.row == 2 && [self.type isEqualToString:@"85"]){
                 test = @"预设号码";
                 }*/
                newCell.detailLabel.text = test;
            }
            
        } break;
        case 3:         // 求救短信
        {
            cell = [tableView dequeueReusableCellWithIdentifier:@"cell2"];
            if (cell == nil)
            {
                cell = [[KMDeviceSettingEditCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"cell2"];
            }
            
            [cell.accessoryView removeFromSuperview];
            KMDeviceSettingEditCell *newCell = (KMDeviceSettingEditCell *)cell;
            newCell.titleLabel.textColor = [UIColor blackColor];
            newCell.titleLabel.text = self.dataArray3[indexPath.row];
            if ([self.type isEqualToString:@"20"]) {
                newCell.titleLabel.text = @"";
            }
            newCell.detailLabel.numberOfLines = 0;
            if ([self.type isEqualToString:@"20"]) {
                newCell.detailLabel.text = _cellModel.sosSms;
            }else{
                
                NSString * test;
                switch (indexPath.row)
                {
                    case 0:
                        test = m.fallPhoneNo1;
                        break;
                    case 1:
                        test = m.fallPhoneNo2;
                        break;
                    case 2:
                        test = m.fallPhoneNo3;
                        break;
                    default:
                        break;
                }
                if ([test isEqualToString:@"0"]|| test.length == 0) {
                    test = kLoadStringWithKey(@"Geofence_VC_not_setting");
                }
                
                newCell.detailLabel.text = test;
            }
            
        } break;
            
        default:
            break;
    }
    return cell;
}

/**
 *   返回分区标题
 */
- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    if ([self.type isEqualToString:@"20"])
    {
        return self.titles_8020[section];
    }else{
        return self.titles_8010[section];
    }
}
/**
 *   返回cell高度
 */

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if ([self.type isEqualToString:@"20"] && indexPath.section == 3)
    {
        return 70+_smsHeight;
    }else{
        
        return 70;
    }
}

/**
 *   点击事件
 */
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:NO];
    DMLog(@"%zd--%zd",indexPath.row,indexPath.section);
    switch (indexPath.section)
    {
        case 0:             // 通话设置
            if (indexPath.row == 1)
            {       // 通话限制
                [self showPickerView];
            }else if (indexPath.row == 0 && [self.type isEqualToString:@"20"])
            {
                KMSilentSettingVC * vc = [[KMSilentSettingVC alloc] init];
                vc.title =  kLoadStringWithKey(@"DeviceManager_HealthSetting_time_muteSetting");
                vc.imei = self.imei;
                [self.navigationController pushViewController:vc animated:YES];
            }
            break;
        case 1:             // 亲情号码
        case 3:             // 跌倒号码
        case 2:             // 紧急号码
        {
            self.alertView = [[CustomIOSAlertView alloc] init];
            NSString *title2 = nil;
            switch (indexPath.row) {
                case 0:
                    title2 = kLoadStringWithKey(@"DeviceSettingDetailCall_VC_call_first_group");
                    break;
                case 1:
                    title2 = kLoadStringWithKey(@"DeviceSettingDetailCall_VC_call_second_group");
                    break;
                case 2:
                    title2 = kLoadStringWithKey(@"DeviceSettingDetailCall_VC_call_third_group");
                    break;
                case 3:
                    title2 = kLoadStringWithKey(@"DeviceSettingDetailCall_VC_call_fourth_group");
                    break;
                default:
                    break;
            }
            NSString *title1;
            if (indexPath.section == 1)
            {
                title1 = kLoadStringWithKey(@"DeviceSettingDetailCall_VC_call_family_number");
            } else if (indexPath.section == 2)
            {
                title1 = kLoadStringWithKey(@"DeviceSettingDetailCall_VC_call_sos_number");
            }else
            {
                title1 = kLoadStringWithKey(@"DeviceSettingDetailCall_VC_call_sos_sms");
            }
            NSString *title;
            if ([title1 isEqualToString:kLoadStringWithKey(@"DeviceSettingDetailCall_VC_call_sos_sms")])
            {
                title = title1;
            }else{
                title = [NSString stringWithFormat:@"%@ - %@", title1, title2];
                
            }
            
            self.alertView.containerView = [self createNumberInputAlertViewWithTitle:title indexPath:indexPath];
            self.alertView.buttonTitles = nil;
            [self.alertView setUseMotionEffects:NO];
            [self.alertView show];
            
        } break;
        default:
            break;
    }
}


#pragma mark - PickerView
-(void)showPickerView
{
    self.alertView = [[CustomIOSAlertView alloc] init];
    KMCommonAlertView * contentView = [[KMCommonAlertView alloc] initWithFrame:CGRectMake(0, 0,SCREEN_WIDTH*0.8,240)];
    contentView.titleLabel.text = kLoadStringWithKey(@"DeviceEdit_VC_setting_title_call_time");
    contentView.buttonsArray = @[kLoadStringWithKey(@"Reg_VC_birthday_OK")];
    UIButton * okButton = contentView.realButtons[0];
    [okButton addTarget:self action:@selector(confirmButtonDidClickedAction:) forControlEvents:UIControlEventTouchDown];
    
    //datepicker
    UIPickerView * pickerView = [[UIPickerView alloc] init];
    [contentView.customerView  addSubview:pickerView];
    [pickerView mas_makeConstraints:^(MASConstraintMaker *make)
     {
         make.center.equalTo(contentView);
         make.left.right.mas_equalTo(0);
         make.height.mas_equalTo(100);
     }];
    pickerView.delegate = self;
    pickerView.dataSource = self;
    KMDeviceManagerDetailModel *m = [self.deviceManagerModel.list objectAtIndex:0];
    if (m != nil)
    {
        [pickerView selectRow:m.phoneLimitTime inComponent:0 animated:YES];
    }
    
    //设置可选时间范围；
    self.alertView.containerView = contentView;
    [self.alertView setButtonTitles:nil];
    [self.alertView setUseMotionEffects:NO];
    [self.alertView show];
}


#pragma mark - UIPickerViewDataSource
/**
 *   返回列
 */
-(NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView{
    return 1;
}

/**
 *   返回行
 */
-(NSInteger)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component
{
    if ([self.type isEqualToString:@"85"]) {
        
        return self.limitTimes.count;
    }else{
        return 100;
    }
}

/**
 *   返回内容
 */
-(NSString *)pickerView:(UIPickerView *)pickerView titleForRow:(NSInteger)row forComponent:(NSInteger)component
{
    if ([self.type isEqualToString:@"85"]) {
        if (row == 0)
        {
            return  kLoadStringWithKey(@"DeviceSettingDetail_VC_shutdown");
        }else
        {
            NSInteger number = [self.limitTimes[row] integerValue];
            NSString * rowString = [NSString stringWithFormat:@"%ld%@",number,kLoadStringWithKey(@"DeviceEdit_VC_setting_title_call_min")];
            return rowString;
        }
        
    }else{
        
        if (row == 0)
        {
            return  kLoadStringWithKey(@"DeviceSettingDetail_VC_shutdown");
        }else
        {
            NSString * rowString = [NSString stringWithFormat:@"%ld%@",row,kLoadStringWithKey(@"DeviceEdit_VC_setting_title_call_min")];
            return rowString;
        }
        
    }
}

/**
 *   选中事件
 */
-(void)pickerView:(UIPickerView *)pickerView didSelectRow:(NSInteger)row inComponent:(NSInteger)component
{
    if ([self.type isEqualToString:@"85"]) {
        
        self.currentRow = [self.limitTimes[row] integerValue];
    }else{
        self.currentRow = row;
    }
}

/**
 *   确定选择按钮
 */
-(void)confirmButtonDidClickedAction:(UIButton *)sender
{
    [self.alertView close];
    KMDeviceManagerDetailModel *m = [self.deviceManagerModel.list objectAtIndex:0];
    
    if (self.currentRow != 0)
    {
        m.phoneLimitTime = (int)self.currentRow;
        m.phoneLimitOnoff =1;
        [self updateDeviceSettingWithBody:[m mj_JSONString]];
    }else
    {
        m.phoneLimitOnoff = 0;
        m.phoneLimitTime = 0;
        [self updateDeviceSettingWithBody:[m mj_JSONString]];
    }
}

/**
 *  创建一个自定义choose框
 */
- (UIView *)createNumberInputAlertViewWithTitle:(NSString *)title
                                      indexPath:(NSIndexPath *)indexPath
{
    self.currentIndexPath = [indexPath copy];
    KMDeviceManagerDetailModel *m = [self.deviceManagerModel.list objectAtIndex:0];
    KMCommonAlertView *view = [[KMCommonAlertView alloc] initWithFrame:CGRectMake(0, 0, 300, 180)];
    view.titleLabel.text = title;
    view.buttonsArray = @[kLoadStringWithKey(@"DeviceSetting_VC_add_cancel"),
                          kLoadStringWithKey(@"DeviceSetting_VC_add_OK")];
    // cancel
    UIButton *btn = view.realButtons[0];
    btn.tag = 200;
    [btn addTarget:self action:@selector(numberSelectBtnDidClicked:) forControlEvents:UIControlEventTouchUpInside];
    // OK
    UIButton *OKBtn = view.realButtons[1];
    OKBtn.tag = 201;
    [OKBtn addTarget:self action:@selector(numberSelectBtnDidClicked:) forControlEvents:UIControlEventTouchUpInside];
    
    // number field
    NSString *number = nil;
    if ([self.type isEqualToString:@"20"])
    {
        switch (indexPath.section) {
            case 1:         // 亲情号码
            {
                switch (indexPath.row)
                {
                    case 0:     // 第一组
                        number = _cellModel.fmy1;
                        break;
                    case 1:     // 第二组
                        number = _cellModel.fmy2;
                        break;
                    case 2:     // 第三组
                        number = _cellModel.fmy3;
                        break;
                    case 3:     // 第四组
                        number = _cellModel.fmy4;
                        break;
                    default:
                        break;
                }
            } break;
            case 2:         // 紧急号码
            {
                switch (indexPath.row)
                {
                    case 0:     // 第一组
                        number = _cellModel.sos1;
                        break;
                    case 1:     // 第二组
                        number = _cellModel.sos2;
                        break;
                    case 2:     // 第三组
                        number = _cellModel.sos3;
                        break;
                    default:
                        break;
                }
            } break;
            case 3:         // 求救短息
            {
                number = _cellModel.sosSms;
                
            } break;
        }
        
        
    }else
    {
        switch (indexPath.section) {
            case 1:         // 亲情号码
            {
                switch (indexPath.row)
                {
                    case 0:     // 第一组
                        number = m.fmlyPhoneNo1;
                        break;
                    case 1:     // 第二组
                        number = m.fmlyPhoneNo2;
                        break;
                    case 2:     // 第三组
                        number = m.fmlyPhoneNo3;
                        break;
                    default:
                        break;
                }
            } break;
            case 2:         // 紧急号码
            {
                switch (indexPath.row)
                {
                    case 0:     // 第一组
                        number = m.sosPhoneNo1;
                        break;
                    case 1:     // 第二组
                        number = m.sosPhoneNo2;
                        break;
                    case 2:     // 第三组
                        number = m.sosPhoneNo3;
                        break;
                    default:
                        break;
                }
            } break;
            case 3:         // 跌倒号码
            {
                switch (indexPath.row)
                {
                    case 0:     // 第一组
                        number = m.fallPhoneNo1;
                        break;
                    case 1:     // 第二组
                        number = m.fallPhoneNo2;
                        break;
                    case 2:     // 第三组
                        number = m.fallPhoneNo3;
                        break;
                    default:
                        break;
                }
            } break;
                
            default:
                break;
        }
    }
    
    if ([number isEqualToString:@"0"]) {
        number = @"";
    }
    
    UITextField *numberTextField = [[UITextField alloc] init];
    numberTextField.delegate = self;
    numberTextField.tag = 100;
    numberTextField.textAlignment = NSTextAlignmentCenter;
    numberTextField.text = number;
    numberTextField.borderStyle = UITextBorderStyleRoundedRect;
    numberTextField.keyboardType = UIKeyboardTypeNumberPad;
    numberTextField.placeholder = kLoadStringWithKey(@"Call_VC_getdevices_phone_number_not_set");
    if ([self.type isEqualToString:@"20"] && indexPath.section == 3 ) {
        
        numberTextField.keyboardType = UIKeyboardTypeDefault;
        numberTextField.placeholder = kLoadStringWithKey(@"DeviceManager_HealthSetting_sos_message");
    }
    
    [view.customerView addSubview:numberTextField];
    [numberTextField becomeFirstResponder];
    [numberTextField mas_makeConstraints:^(MASConstraintMaker *make) {
        make.width.equalTo(@200);
        make.center.equalTo(view);
        make.height.equalTo(@35);
    }];
    
    return view;
}

#pragma mark - UITextFieldDelegate
/**
 *   文字替换代理
 */
-(BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string
{
    if (string.length == 0)  return YES;
    
    if ([self.type isEqualToString:@"20"] &&  self.currentIndexPath.section == 3)
    {
        if (textField.text.length >=170)
        {
            return NO;
        }
        
        NSInteger existedLength = textField.text.length;
        NSInteger selectedLength = range.length;
        NSInteger replaceLength = string.length;
        if (existedLength - selectedLength + replaceLength >170)
        {
            return NO;
        }
        
        return YES;
    }
    
    if (textField.text.length >=15)
    {
        if (string.length == 0)  return YES;
        return NO;
        
    }
    return YES;
}

/**
 *   按钮点击
 */
- (void)numberSelectBtnDidClicked:(UIButton *)sender
{
    [self.alertView endEditing:YES];
    KMDeviceManagerDetailModel *m = [self.deviceManagerModel.list objectAtIndex:0];
    // 进行赋值
    switch (sender.tag) {
        case 200:       // Cancel
        {
            
            
        } break;
        case 201:       // 完成
        {
            
            KMCommonAlertView *commView = (KMCommonAlertView *)self.alertView.containerView;
            UITextField *textField = [commView.customerView viewWithTag:100];
            if ([self.type isEqualToString:@"20"])
            {
                switch (self.currentIndexPath.section)
                {
                    case 1:         // 亲情号码
                        switch (self.currentIndexPath.row)
                    {
                        case 0:
                            self.postFamilyModel.number1 = textField.text;
                            break;
                        case 1:
                            self.postFamilyModel.number2 = textField.text;
                            break;
                        case 2:
                            self.postFamilyModel.number3 = textField.text;
                            break;
                        case 3:
                            self.postFamilyModel.number4 = textField.text;
                            break;
                    }
                        [self updateFamilyNumber];
                        break;
                        
                    case 2:         // 紧急号码
                        switch (self.currentIndexPath.row)
                    {
                        case 0:
                            self.postSosModel.number1 = textField.text;
                            break;
                        case 1:
                            self.postSosModel.number2 = textField.text;
                            break;
                        case 2:
                            self.postSosModel.number3 = textField.text;
                            break;
                    }
                        [self updateSosNumber];
                        break;
                        
                    case 3:         // 求救短信
                        self.postSosSmsModel.sms = textField.text;
                        if (![self checkChangeData])
                        {
                            return;
                        }
                        [self updateSosSms];
                        break;
                }
            }else
            {
                switch (self.currentIndexPath.section)
                {
                    case 1:         // 亲情号码
                        switch (self.currentIndexPath.row) {
                            case 0:
                                m.fmlyPhoneNo1 = textField.text;
                                break;
                            case 1:
                                m.fmlyPhoneNo2 = textField.text;
                                break;
                            case 2:
                                m.fmlyPhoneNo3 = textField.text;
                                break;
                            default:
                                break;
                        }
                        break;
                    case 2:         // 紧急号码
                        switch (self.currentIndexPath.row)
                    {
                        case 0:
                            m.sosPhoneNo1 = textField.text;
                            break;
                        case 1:
                            m.sosPhoneNo2 = textField.text;
                            break;
                        case 2:
                            m.sosPhoneNo3 = textField.text;
                            break;
                        default:
                            break;
                    }
                        break;
                    case 3:         // 紧急号码
                        switch (self.currentIndexPath.row)
                    {
                        case 0:
                            m.fallPhoneNo1 = textField.text;
                            break;
                        case 1:
                            m.fallPhoneNo2 = textField.text;
                            break;
                        case 2:
                            m.fallPhoneNo3 = textField.text;
                            break;
                        default:
                            break;
                    }
                        break;
                    default:
                        break;
                }
                // 更新数据
                [self updateDeviceSettingWithBody:[m mj_JSONString]];
                
            }
            
            
            
        } break;
    }
    
    [self.alertView close];
    self.alertView = nil;
}

/**
 *   设置亲情号码网络请求
 */
- (void)updateFamilyNumber
{
    // 创建请求连接
    NSString * URL = [NSString stringWithFormat:@"deviceManager/fmy/%@/%@",member.loginAccount,self.imei];
    // 开始进行网络请求
    [SVProgressHUD show];
    if (_postFamilyModel.number1 == nil) {
        _postFamilyModel.number1 = @"";
    }
    if (_postFamilyModel.number2 == nil){
        _postFamilyModel.number2 = @"";
    }
    if (_postFamilyModel.number3 == nil){
        _postFamilyModel.number3 = @"";
    }
    if (_postFamilyModel.number4 == nil){
        _postFamilyModel.number4 = @"";
    }
    [[KMNetAPI manager] commonPOSTRequestWithURL:URL jsonBody:[_postFamilyModel mj_JSONString] Block:^(int code, NSString *res)
     {
         KMNetworkResModel *resModel = [KMNetworkResModel mj_objectWithKeyValues:res];
         if (code == 0 && resModel.errorCode <= kNetReqSuccess)
         {
             
             dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(5 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                 
                 [SVProgressHUD dismiss];
                 [self loadPhoneNumber];
             });
         } else
         {
             [SVProgressHUD showErrorWithStatus:kNetReqFailWithCode(resModel.errorCode)];
         }
     }];
    
}
/**
 *   设置紧急号码网络请求
 */
- (void)updateSosNumber
{
    //     http://120.25.225.5:8090/kmhc-modem-restful/services/member/deviceManager/sos/13823641029/865946021011109
    // 创建请求连接
    NSString * URL = [NSString stringWithFormat:@"deviceManager/sos/%@/%@",member.loginAccount,self.imei];
    // 开始进行网络请求
    [SVProgressHUD show];
    if (_postSosModel.number1 == nil) {
        _postSosModel.number1 = @"";
    }
    if (_postSosModel.number2 == nil){
        _postSosModel.number2 = @"";
    }
    if (_postSosModel.number3 == nil){
        _postSosModel.number3 = @"";
    }
    
    [[KMNetAPI manager] commonPOSTRequestWithURL:URL jsonBody:[_postSosModel mj_JSONString] Block:^(int code, NSString *res)
     {
         KMNetworkResModel *resModel = [KMNetworkResModel mj_objectWithKeyValues:res];
         if (code == 0 && resModel.errorCode <= kNetReqSuccess)
         {
             
             dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(5 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                 [SVProgressHUD dismiss];
                 [self loadPhoneNumber];
             });
             
         } else
         {
             [SVProgressHUD showErrorWithStatus:kNetReqFailWithCode(resModel.errorCode)];
         }
     }];
}
/**
 *   设置求救短信网络请求
 */
- (void)updateSosSms
{
    // 创建请求连接
    NSString * URL = [NSString stringWithFormat:@"deviceManager/sos/%@/%@",member.loginAccount,self.imei];
    // 开始进行网络请求
    [SVProgressHUD show];
    [[KMNetAPI manager] commonPOSTRequestWithURL:URL jsonBody:[_postSosSmsModel mj_JSONString] Block:^(int code, NSString *res)
     {
         KMNetworkResModel *resModel = [KMNetworkResModel mj_objectWithKeyValues:res];
         NSLog(@"content ----- %@",resModel.content);
         if (code == 0 && resModel.errorCode <= kNetReqSuccess)
         {
             
             dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(5 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                 [SVProgressHUD dismiss];
                 [self loadPhoneNumber];
             });
             
         } else
         {
             [SVProgressHUD showErrorWithStatus:kNetReqFailWithCode(resModel.errorCode)];
         }
     }];
}


/**
 *  显示用户操作提示框
 */
#pragma mark --- 信息提示框显示
//显示信息提示框
-(void)customAlertViewShowWithMessage:(NSString *)message withStatus:(BOOL)status
{
    // 提示框
    self.alert = [[CustomIOSAlertView alloc] init];
    self.alert.buttonTitles = nil;
    [self.alert setUseMotionEffects:NO];
    
    UIView * alertView = [[UIView alloc] initWithFrame:CGRectMake(0,0,SCREEN_WIDTH*0.9,220)];
    alertView.backgroundColor = [UIColor whiteColor];
    self.alert.containerView = alertView;
    
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
    [self.alert show];
}


/**
 *   检查保存信息
 */
- (BOOL)checkChangeData{
    
    if (self.postSosSmsModel.sms.length >170) {
        
        // 显示提示框
        [self customAlertViewShowWithMessage:kLoadStringWithKey(@"DeviceManager_HealthSetting_alert_message_length") withStatus:NO];
        return NO;
    }
    
    if (![self checkAffirString:self.postSosSmsModel.sms]) {
        
        // 显示提示框
        [self customAlertViewShowWithMessage:kLoadStringWithKey(@"DeviceManager_HealthSetting_alert_message_limit") withStatus:NO];
        return NO;
    }
    
    NSUInteger bytes = [self.postSosSmsModel.sms lengthOfBytesUsingEncoding:NSUTF8StringEncoding];
    if (bytes > 140) {
        
        // 显示提示框
        [self customAlertViewShowWithMessage:kLoadStringWithKey(@"DeviceManager_HealthSetting_alert_message_bytes") withStatus:NO];
        return NO;
    }
    
    NSCharacterSet *set = [NSCharacterSet characterSetWithCharactersInString:@" "];
    NSString * test = [self.postSosSmsModel.sms stringByTrimmingCharactersInSet:set];
    if (test.length <= 0) {
        // 显示提示框
        [self customAlertViewShowWithMessage:kLoadStringWithKey(@"KMCommon_alert_Content_null") withStatus:NO];
        return NO;
    }
    
    return YES;
}




/**
 *   系统提示框
 */
- (void)presentTimeChooseWithTitle:(NSString *)title
                           actions:(NSArray *)actions
                       chooseIndex:(NSInteger)index
                              cell:(UITableViewCell *)cell
{
    WS(ws);
    KMDeviceManagerDetailModel *m = [self.deviceManagerModel.list objectAtIndex:0];
    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:title
                                                                             message:@""
                                                                      preferredStyle:UIAlertControllerStyleActionSheet];
    UIAlertActionStyle style = UIAlertActionStyleDefault;
    for (int i = 0; i < actions.count; i++) {
        if (i == index) {
            style = UIAlertActionStyleDestructive;
        } else {
            style = UIAlertActionStyleDefault;
        }
        UIAlertAction *action = [UIAlertAction actionWithTitle:actions[i]
                                                         style:style
                                                       handler:^(UIAlertAction *action) {
                                                           switch (i) {
                                                               case 0:      // 关闭
                                                                   m.phoneLimitTime = 0;
                                                                   break;
                                                               case 1:      // 5分钟
                                                                   m.phoneLimitTime = 5;
                                                                   break;
                                                               case 2:      // 15分钟
                                                                   m.phoneLimitTime = 15;
                                                                   break;
                                                               case 3:      // 30分钟
                                                                   m.phoneLimitTime = 30;
                                                                   break;
                                                               case 4:      // 60分钟
                                                                   m.phoneLimitTime = 60;
                                                                   break;
                                                               default:
                                                                   break;
                                                           }
                                                           [ws updateDeviceSettingWithBody:[m mj_JSONString]];
                                                       }];
        [alertController addAction:action];
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

/**
 *   开关触发事件
 */
- (void)switchDidClick:(UISwitch *)mSwitch
{
    BOOL state = mSwitch.isOn;
    
    KMDeviceManagerDetailModel *m = [self.deviceManagerModel.list objectAtIndex:0];
    
    switch (mSwitch.tag) {
        case 0:         // 跌倒侦测
            m.nonDistrub = state;
            break;
        case 1:         // 抬手亮屏
            m.autoread = state;
            break;
        default:
            break;
    }
    
    //    [self updateDeviceSettingWithBody:[m mj_JSONString]];
    NSString * body = [m mj_JSONString];
    WS(ws);
    NSString *request = [NSString stringWithFormat:@"deviceManager/%@/%@",member.loginAccount, self.imei];
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


// 正则匹配密码
-(BOOL)checkAffirString:(NSString *)affir
{
    NSString * pattern = @"^[A-Za-z0-9\u4e00-\u9fa5.，,。!！？?“”‘’''~ ]*$";
    NSPredicate *pred = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", pattern];
    BOOL isMatch = [pred evaluateWithObject:affir];
    return isMatch;
}

@end




