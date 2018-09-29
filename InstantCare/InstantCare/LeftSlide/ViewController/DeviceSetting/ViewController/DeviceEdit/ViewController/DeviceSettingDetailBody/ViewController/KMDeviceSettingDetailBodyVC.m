//
//  KMDeviceSettingDetailBodyVC.m
//  InstantCare
//
//  Created by bruce-zhu on 15/12/11.
//  Copyright © 2015年 omg. All rights reserved.
//

#import "KMDeviceSettingDetailBodyVC.h"
#import "KMDeviceSettingResModel.h"
#import "KMDeviceSettingEditCell.h"
#import "KMImageTitleButton.h"
#import "CustomIOSAlertView.h"
#import "KMDeviceSettingResModel.h"
#import "KMCommonAlertView.h"
#import "KMCheckHeartRateModel.h"
#import "KMStepSettingVC.h"
#import "MJRefresh.h"
#import "KMNetAPI.h"
#import "MJExtension.h"

#define kBottomBtnHeight        50
#define kStepHeight             170

@interface KMDeviceSettingDetailBodyVC () <UITableViewDataSource, UITableViewDelegate,UITextFieldDelegate>

@property (nonatomic, strong) UITableView *tableView;

@property (nonatomic, strong) NSArray *dataArray;

@property (nonatomic, strong) CustomIOSAlertView *alertView;        // 填写新的号码
@property (nonatomic, strong) NSIndexPath *currentIndexPath;        // 当前选择的路径

@property (nonatomic, strong) KMDeviceManagerModel *deviceManagerModel;  // 8000 8010 模型
/** 8020模型 */
@property (nonatomic, strong) KMDeviceSettingPhysiqueModel *physiqueModel;

/** 分段定时计步 */
@property (nonatomic, strong) KMCheckHeartRateModel *stepModel;


@property(nonatomic,assign)BOOL  status;

/** 标题 */
@property (nonatomic, strong) NSMutableArray *titles;

/** 数据字典 */
@property (nonatomic, strong) NSDictionary *textDic;

/** 身高Label  */
@property (nonatomic, weak) UILabel *heightLabel;

/** 身高Label  */
@property (nonatomic, weak) UILabel *stepLabel;

/** 身高滑动条  */
@property (nonatomic, weak) UISlider *mSlider;

@property (nonatomic, weak) UITextField *numberTextField;

@end

@implementation KMDeviceSettingDetailBodyVC

// 分组标题
- (NSDictionary *)textDic
{
    if (_textDic == nil)
    {
        /** 分组一  */
        NSMutableArray * section0 = @[kLoadStringWithKey(@"DeviceSettingDetailBody_VC_step"),
                               kLoadStringWithKey(@"DeviceSettingDetailBody_VC_height"),
                               kLoadStringWithKey(@"DeviceSettingDetailBody_VC_weight"),
                               kLoadStringWithKey(@"DeviceManager_HealthSetting_sex_setting"),
                               kLoadStringWithKey(@"DeviceManager_HealthSetting_age_setting")].mutableCopy;
        if (![self.type isEqualToString:@"20"]) {
            
            [section0 removeLastObject];
            [section0 removeLastObject];
        }
        
        /** 分组二  */
        NSArray * section1 = @[@""];
        _textDic = @{@0:section0,@1:section1};
    }
    return _textDic;
}


//  分区标题
- (NSMutableArray *)titles
{
    if(_titles == nil)
    {
        _titles = @[@"",kLoadStringWithKey(@"DeviceManager_HealthSetting_step")].mutableCopy;
        if (![self.type isEqualToString:@"20"])
        {
            [self.titles removeLastObject];
        }
    }
    return _titles;
}



// 视图加载完成
- (void)viewDidLoad
{
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor whiteColor];

    // 配置导航栏
    [self configNavBar];
    
    NSLog(@"------------");
    // 配置视图
    [self configView];
    
}


#pragma mark - 设置导航栏
- (void)configNavBar
{
    self.navigationItem.title = kLoadStringWithKey(@"DeviceEdit_VC_setting_title_body_set");
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

/**
 *   配置视图
 */
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
        
        if ([self.type isEqualToString:@"20"])
        {
            [ws request];
            [ws requestSetup];
        }else{
            
            [ws requestDeviceSetting];
        }
    }];
    
}

/** 视图将要显示  */
-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    if (self.is3DTouchLoad == 1) {
        [SVProgressHUD show];
        if ([self.type isEqualToString:@"20"])
        {
            [self request];
            [self requestSetup];
        }else{
            
            [self requestDeviceSetting];
        }
        self.is3DTouchLoad = 2;
    }else if (self.is3DTouchLoad == 2){
        return;
    }else{
        [SVProgressHUD show];
        if ([self.type isEqualToString:@"20"])
        {
            [self request];
            [self requestSetup];
        }else{
            
            [self requestDeviceSetting];
        }
    }
    
}


#pragma mark - 8020 网络请求
/**
 *   8020网络请求
 */
- (void)request
{
    NSString *request = [NSString stringWithFormat:@"deviceManager/%@/%@?type=body",
                         member.loginAccount,
                         self.imei];
    [[KMNetAPI manager] commonGetRequestWithURL:request Block:^(int code, NSString *res)
    {
        [_tableView.mj_header endRefreshing];
        KMNetworkResModel *resModel = [KMNetworkResModel mj_objectWithKeyValues:res];
        
        NSLog(@"resModel:%@",res);
        if (code == 0 && resModel.errorCode <= kNetReqSuccess)
        {
            [SVProgressHUD dismiss];
            // 解析数据模型
            NSDictionary * dic = (NSDictionary *)resModel.content;
            NSArray * list = dic[@"list"];
            self.physiqueModel = [KMDeviceSettingPhysiqueModel mj_objectWithKeyValues:[list lastObject]];
            
            [_tableView reloadData];
        } else {
            
            [SVProgressHUD showErrorWithStatus:kNetReqFailWithCode(resModel.errorCode)];
        }
    }];
}

/**
 *   请求计步信息
 */
- (void)requestSetup
{
    // 创建网络请求地址
    NSString *request = [NSString stringWithFormat:@"deviceManager/%@/%@?type=step",member.loginAccount,self.imei];
    
    // 进行网络请求
    [SVProgressHUD show];
    [[KMNetAPI manager] commonGetRequestWithURL:request Block:^(int code, NSString *res)
     {
         [SVProgressHUD dismiss];
         [_tableView.mj_header endRefreshing];
         KMNetworkResModel *resModel = [KMNetworkResModel mj_objectWithKeyValues:res];
         
         NSLog(@"resModel:%@",res);
         if (code == 0 && resModel.errorCode <= kNetReqSuccess)
         {
             [SVProgressHUD dismiss];
             // 解析数据模型
             NSDictionary * dic = (NSDictionary *)resModel.content;
             NSArray * list = dic[@"list"];
             self.stepModel = [KMCheckHeartRateModel mj_objectWithKeyValues:[list lastObject]];
             [_tableView reloadData];
         } else {
             
             [SVProgressHUD showErrorWithStatus:kNetReqFailWithCode(resModel.errorCode)];
         }
     }];
    
}

#pragma mark - 网络请求设置
/**
 *   8000 8010请求数据
 */
- (void)requestDeviceSetting
{
    // deviceManager/{account}/{imei}
    NSString *request = [NSString stringWithFormat:@"deviceManager/%@/%@",
                         member.loginAccount,
                         self.imei];
    [[KMNetAPI manager] commonGetRequestWithURL:request Block:^(int code, NSString *res) {
        [_tableView.mj_header endRefreshing];
        KMNetworkResModel *resModel = [KMNetworkResModel mj_objectWithKeyValues:res];
        if (code == 0 && resModel.errorCode <= kNetReqSuccess) {
            [SVProgressHUD dismiss];
            _deviceManagerModel = [KMDeviceManagerModel mj_objectWithKeyValues:resModel.content];
            [_tableView reloadData];
        } else {
            [SVProgressHUD showErrorWithStatus:kNetReqFailWithCode(resModel.errorCode)];
        }
    }];
}

/**
 *   8000 8010更新数据
 */
- (void)updateDeviceSettingWithBody:(NSString *)body
{
    // deviceManager/{account}/{imei}
    WS(ws);
    NSString *request = [NSString stringWithFormat:@"deviceManager/%@/%@",
                         member.loginAccount,
                         self.imei];
    NSString * request2 = [NSString stringWithFormat:@"deviceManager/body/%@/%@", member.loginAccount, self.imei];
    NSString * URL = ([self.type isEqualToString:@"20"])? request2:request;
    [SVProgressHUD show];
    [[KMNetAPI manager] commonPOSTRequestWithURL:URL jsonBody:body Block:^(int code, NSString *res)
    {
        KMNetworkResModel *resModel = [KMNetworkResModel mj_objectWithKeyValues:res];
        if (code == 0 && resModel.errorCode <= kNetReqSuccess) {
        
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(2.5 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^
            {
                [SVProgressHUD dismiss];
                if ([ws.type isEqualToString:@"20"])
                {
                    [ws request];
                }else{
                    
                    [ws requestDeviceSetting];
                }
            });
            
        } else {
            
            [SVProgressHUD showErrorWithStatus:kNetReqFailWithCode(resModel.errorCode)];
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
    NSArray * array = self.textDic[@(section)];
    return array.count;
}

/**
 *   设置显示对象
 */
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell;
    
    KMDeviceManagerDetailModel *m = [_deviceManagerModel.list objectAtIndex:0];
    cell = [tableView dequeueReusableCellWithIdentifier:@"cell"];
    if (cell == nil) {
        cell = [[KMDeviceSettingEditCell alloc] initWithStyle:UITableViewCellStyleDefault
                                              reuseIdentifier:@"cell"];
    }
    KMDeviceSettingEditCell *newCell = (KMDeviceSettingEditCell *)cell;
    newCell.titleLabel.textColor = [UIColor blackColor];
    newCell.titleLabel.text = self.textDic[@(indexPath.section)][indexPath.row];
    
    if ([self.type isEqualToString:@"20"])// 8020
    {
        NSString *detailString = nil;
        switch (indexPath.row) {
            case 0:
                detailString = [NSString stringWithFormat:@"%zd",self.physiqueModel.step];
                break;
            case 1:
                 detailString = [NSString stringWithFormat:@"%.1f",self.physiqueModel.height];
                break;
            case 2:
                 detailString = [NSString stringWithFormat:@"%.1f",self.physiqueModel.weight];
                break;
            case 3:
            {
                detailString = self.physiqueModel.sex > 0? kLoadStringWithKey(@"DeviceManager_HealthSetting_sex_woman"):kLoadStringWithKey(@"DeviceManager_HealthSetting_sex_man");
                if (detailString.length == 0) detailString = kLoadStringWithKey(@"DeviceManager_HealthSetting_sex_unknown");
            }
                break;
            case 4:
                  detailString = [NSString stringWithFormat:@"%zd",self.physiqueModel.age];
                break;
            default:
                break;
        }
        if (detailString.length == 0) {
            
            detailString = @"0";
        }
        newCell.detailLabel.text = detailString;
        
    }else
    {
        if (indexPath.section == 0)
        {
            NSString *detailString = nil;
            switch (indexPath.row) {
                case 0:
                    detailString = [NSString stringWithFormat:@"%d", m.uStep];
                    break;
                case 1:
                    detailString = [NSString stringWithFormat:@"%.1f", m.uHeight];
                    break;
                case 2:
                    detailString = [NSString stringWithFormat:@"%.1f", m.uWeight];
                    break;
                default:
                    break;
            }
            if (detailString.length == 0) {
                
                detailString = @"0";
            }
            newCell.detailLabel.text = detailString;
        }else{
            
            newCell.titleLabel.text = self.textDic[@(indexPath.section)][indexPath.row];
        }
    }
    
    if (indexPath.section > 0) {
        
        NSString * text = [NSString stringWithFormat:@"%@ ~ %@,%@:%zd%@",[self.stepModel.starttime substringWithRange:NSMakeRange(0, 5)],[self.stepModel.endtime substringWithRange:NSMakeRange(0, 5)],kLoadStringWithKey(@"DeviceManager_HealthSetting_time_interval"),self.stepModel.span,kLoadStringWithKey(@"DeviceManager_HealthSetting_time_minute")];
        newCell.textLabel.text = text;
        newCell.detailLabel.text = nil;
    }
    
    return cell;
}

/**
 *   返回分区标题
 */
- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    return self.titles[section];
}

/**
 *   选中事件
 */
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:NO];
    
    if (indexPath.section == 0) {
        
        switch (indexPath.row) {
            case 0:{
                self.currentIndexPath = indexPath.copy;
                [self didClickStepBtn];
            }
            break;
            case 3:
            {
                NSInteger sex  = self.physiqueModel.sex > 0 ?0:1;
                self.physiqueModel.sex  = sex;
                // 更新数据
                [self updateDeviceSettingWithBody:[self.physiqueModel mj_JSONString]];
            }
            break;
            default:
            {
                self.alertView = [[CustomIOSAlertView alloc] init];
                NSMutableArray * array = self.textDic[@(indexPath.section)];
                NSString *title = array[indexPath.row];
                self.alertView.containerView = [self createNumberInputAlertViewWithTitle:title indexPath:(NSIndexPath *)indexPath];
                self.alertView.buttonTitles = nil;
                [self.alertView setUseMotionEffects:NO];
                [self.alertView show];
                
            }break;
        }
    }else{
        
        KMStepSettingVC * vc = [[KMStepSettingVC alloc] init];
        vc.title = kLoadStringWithKey(@"DeviceEdit_VC_setting_title_body_set");
        vc.imei = self.imei;
        vc.model = self.stepModel;
        [self.navigationController pushViewController:vc animated:YES];
    }
}

#pragma mark - 选择身高提示框
- (void)didClickStepBtn{
    //获取身高
    CGFloat height = kStepHeight;
    int step = 0;
    //默认3
    KMDeviceManagerDetailModel *m = [_deviceManagerModel.list objectAtIndex:0];
    if ([self.type isEqualToString:@"20"])
    {
//        height = (CGFloat)self.physiqueModel.step / 0.414 + 0.5;
        step = (int)self.physiqueModel.step;
    }
    else{
        
        if (m) {
//            height = (CGFloat)m.uStep / 0.414 + 0.5;
            step = m.uStep;
        }
    }
    
    
    //选择语言提示框
    self.alertView = [[CustomIOSAlertView alloc] init];
    KMCommonAlertView *view = [[KMCommonAlertView alloc] initWithFrame:CGRectMake(0, 0,SCREEN_WIDTH*0.8, 250)];
    view.titleLabel.text = kLoadStringWithKey(@"DeviceSettingDetailBody_VC_step");
    
    //身高Label
    UILabel *heightLabel = [[UILabel alloc]init];
    self.heightLabel = heightLabel;
    heightLabel.text = [NSString stringWithFormat:@"%@ : %zd%@",kLoadStringWithKey(@"DeviceSettingDetailBody_VC_height_description"),(NSInteger)height,@"(cm)"];
    heightLabel.font = [UIFont systemFontOfSize:14];
    [view addSubview:heightLabel];
    [heightLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.right.equalTo(view.mas_centerX).offset(-8);
        make.top.equalTo(view).offset(72);
    }];
    
    //步距Label
    UILabel *stepLabel = [[UILabel alloc]init];
    self.stepLabel = stepLabel;
    stepLabel.text = [NSString stringWithFormat:@"%@ : %zd%@",kLoadStringWithKey(@"DeviceSettingDetailBody_VC_Reference_steps"),70,@"(cm)"];
    stepLabel.font = [UIFont systemFontOfSize:14];
    [view addSubview:stepLabel];
    [stepLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(view.mas_centerX).offset(8);
        make.top.equalTo(view).offset(72);
    }];
    
    //身高滑动条
    UISlider *mSlider = [[UISlider alloc]init];
    self.mSlider = mSlider;
    mSlider.maximumValue = 300;
    mSlider.minimumValue = 40;
    mSlider.value = height;
    [view addSubview:mSlider];
    [mSlider mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.equalTo(view);
        make.top.equalTo(heightLabel.mas_bottom).offset(8);
        make.width.equalTo(view).multipliedBy(0.8);
    }];
    [mSlider addTarget:self action:@selector(changeSlider:) forControlEvents:UIControlEventValueChanged];
    
    UITextField *numberTextField = [[UITextField alloc] init];
    [numberTextField becomeFirstResponder];
    self.numberTextField = numberTextField;
    numberTextField.delegate = self;
    numberTextField.tag = 100;
    numberTextField.textAlignment = NSTextAlignmentCenter;
    numberTextField.text = [NSString stringWithFormat:@"%zd",step];
    numberTextField.borderStyle = UITextBorderStyleRoundedRect;
    numberTextField.keyboardType = UIKeyboardTypeNumberPad;
    [view addSubview:numberTextField];
    [numberTextField mas_makeConstraints:^(MASConstraintMaker *make) {
        make.width.equalTo(@200);
        make.centerX.equalTo(view);
        make.top.equalTo(self.mSlider.mas_bottom).offset(16);
        make.height.equalTo(@35);
    }];
    
    view.buttonsArray = @[kLoadStringWithKey(@"Reg_VC_birthday_cancel"),
                          kLoadStringWithKey(@"Reg_VC_birthday_OK")];
    // cancelButton;
    UIButton *cancelButton = view.realButtons[0];
    cancelButton.tag = 200;
    [cancelButton addTarget:self action:@selector(changeButtonDidClicked:) forControlEvents:UIControlEventTouchUpInside];
    
    // okButton;
    UIButton * okButton = view.realButtons[1];
    okButton.tag = 201;
    [okButton addTarget:self action:@selector(changeButtonDidClicked:) forControlEvents:UIControlEventTouchUpInside];
    
    self.alertView.containerView = view;
    self.alertView.buttonTitles = nil;
    [self.alertView setUseMotionEffects:NO];
    
    [self.alertView show];
}

/**
 *   音量滑动条触发事件
 */
- (void)changeSlider:(UISlider *)mSlider{
    self.heightLabel.text = [NSString stringWithFormat:@"%@ : %zd%@",kLoadStringWithKey(@"DeviceSettingDetailBody_VC_height_description"),(int)(mSlider.value + 0.5),@"(cm)"];
    
    self.stepLabel.text = [NSString stringWithFormat:@"%@ : %zd%@",kLoadStringWithKey(@"DeviceSettingDetailBody_VC_Reference_steps"),(int)(mSlider.value * 0.414 + 0.5),@"(cm)"];

    self.numberTextField.text = [NSString stringWithFormat:@"%zd",(int)(mSlider.value * 0.414 + 0.5)];
}

#pragma mark - 警告框
- (UIView *)createNumberInputAlertViewWithTitle:(NSString *)title
                                      indexPath:(NSIndexPath *)indexPath
{
    KMDeviceManagerDetailModel *m = [_deviceManagerModel.list objectAtIndex:0];
    
    KMCommonAlertView *view = [[KMCommonAlertView alloc] initWithFrame:CGRectMake(0, 0, 300, 200)];
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

    self.currentIndexPath = [indexPath copy];

    // number field
    NSString *number = nil;
    if ([self.type isEqualToString:@"20"])
    {
        switch (indexPath.row)
        {
            case 0:
                number = [NSString stringWithFormat:@"%zd", self.physiqueModel.step];
                break;
            case 1:
                number = [NSString stringWithFormat:@"%.1f", self.physiqueModel.height];
                break;
            case 2:
                number = [NSString stringWithFormat:@"%.1f", self.physiqueModel.weight];
                break;
            case 4:
                number = [NSString stringWithFormat:@"%zd", self.physiqueModel.age];
                break;
            default:
                break;
        }
    }else
    {
        
        switch (indexPath.row)
        {
            case 0:
                number = [NSString stringWithFormat:@"%d", m.uStep];
                break;
            case 1:
                number = [NSString stringWithFormat:@"%.1f", m.uHeight];
                break;
            case 2:
                number = [NSString stringWithFormat:@"%.1f", m.uWeight];
                break;
            default:
                break;
        }
    }
   
    UITextField *numberTextField = [[UITextField alloc] init];
    
    [numberTextField becomeFirstResponder];
    numberTextField.delegate = self;
    numberTextField.tag = 100;
    numberTextField.textAlignment = NSTextAlignmentCenter;
    numberTextField.text = number;
    numberTextField.borderStyle = UITextBorderStyleRoundedRect;
    if ([title isEqualToString:kLoadStringWithKey(@"DeviceSettingDetailBody_VC_step")] || [title isEqualToString:kLoadStringWithKey(@"DeviceManager_HealthSetting_age_setting")]) {
        numberTextField.keyboardType = UIKeyboardTypeNumberPad;
    } else {
        numberTextField.keyboardType = UIKeyboardTypeDecimalPad;
    }
    [view.customerView addSubview:numberTextField];
    [numberTextField mas_makeConstraints:^(MASConstraintMaker *make) {
        make.width.equalTo(@200);
        make.center.equalTo(view.customerView);
        make.height.equalTo(@35);
    }];
    
    return view;
}

#pragma mark - UITextFieldDelegate
/**
 *   文本替换
 */
-(BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string
{
    if (string.length == 0) return YES;
    NSString * alertString = kLoadStringWithKey(@"DeviceSettingDetailBody_VC_alert");
    switch (self.currentIndexPath.row)
    {
        case 0:
        {
            switch (textField.text.length)
            {
                case 0:
                {
                    if ([self cheackFirstInputString:string])
                    {
                        return YES;
                    }else
                    {
                        alertString = [alertString stringByAppendingString:@"1~999"];
                        [SVProgressHUD showErrorWithStatus:alertString];
                        return NO;
                    }
                }
                    break;
                case 1:
                {
                    if ([self cheackInputString:string])
                    {
                        return YES;
                    }else
                    {
                        alertString = [alertString stringByAppendingString:@"1~999"];
                        [SVProgressHUD showErrorWithStatus:alertString];
                        return NO;
                    }
                }
                    break;
                case 2:
                {
                    if ([self cheackInputString:string])
                    {
                        return YES;
                    }else
                    {
                        alertString = [alertString stringByAppendingString:@"1~999"];
                        [SVProgressHUD showErrorWithStatus:alertString];
                        return NO;
                    }
                }
                    break;
                default:
                {
                    alertString = [alertString stringByAppendingString:@"1~999"];
                    [SVProgressHUD showErrorWithStatus:alertString];
                    return NO;
                }
            }
        }
           break;
        case 1:
        {
            switch (textField.text.length)
            {
                case 0:
                {
                    if ([string isEqualToString:@"1"] || [string isEqualToString:@"2"])
                    {
                        return YES;
                    }else
                    {
                        alertString = [alertString stringByAppendingString:@"100.0~299.9"];
                        [SVProgressHUD showErrorWithStatus:alertString];
                        return NO;
                    }
                }
                    break;
                case 1:
                {
                    if ([self cheackInputString:string])
                    {
                        return YES;
                    }else
                    {
                        alertString = [alertString stringByAppendingString:@"100.0~299.9"];
                        [SVProgressHUD showErrorWithStatus:alertString];
                        return NO;
                    }
                }
                    break;
                case 2:
                {
                    if ([self cheackInputString:string])
                    {
                        return YES;
                    }else
                    {
                        alertString = [alertString stringByAppendingString:@"100.0~299.9"];
                        [SVProgressHUD showErrorWithStatus:alertString];
                        return NO;
                    }
                }
                    break;
                case 3:
                {
                    if ([string isEqualToString:@"."])
                    {
                        return YES;
                    }else
                    {
                        alertString = [alertString stringByAppendingString:@"100.0~299.9"];
                        [SVProgressHUD showErrorWithStatus:alertString];
                        return NO;
                    }
                }
                    break;
                case 4:
                {
                    if ([self cheackInputString:string])
                    {
                        return YES;
                    }else
                    {
                        alertString = [alertString stringByAppendingString:@"100.0~299.9"];
                        [SVProgressHUD showErrorWithStatus:alertString];
                        return NO;
                    }
                }
                    break;
                default:
                {
                    alertString = [alertString stringByAppendingString:@"100.0~299.9"];
                    [SVProgressHUD showErrorWithStatus:alertString];
                    return NO;
                }
            }
        }
            break;
        case 2:
        {
            switch (textField.text.length)
            {
                case 0:
                {
                    if ([self cheackFirstInputString:string])
                    {
                        return YES;
                    }else
                    {
                        alertString = [alertString stringByAppendingString:@"1.0~999.9"];
                        [SVProgressHUD showErrorWithStatus:alertString];
                        return NO;
                    }
                    
                }break;
                case 1:
                {
                    if ([self cheackInputString:string]|| [string isEqualToString:@"."])
                    {
                        return YES;
                    }else
                    {
                        alertString = [alertString stringByAppendingString:@"1.0~999.9"];
                        [SVProgressHUD showErrorWithStatus:alertString];
                        return NO;
                    }
                    
                } break;
                    
                case 2:
                {
                    BOOL result = [[textField.text substringWithRange:NSMakeRange(1,1)] isEqualToString:@"."];
                    BOOL result2 = [string isEqualToString:@"."];
                    if (result)
                    {
                        if (result2)
                        {
                            return NO;
                        }else
                        {
                            if ([self cheackInputString:string])
                            {
                                return YES;
                            }else
                            {
                                alertString = [alertString stringByAppendingString:@"1.0~999.9"];
                                [SVProgressHUD showErrorWithStatus:alertString];
                                return NO;
                            }
                        }
                    }else
                    {
                        if (result2)
                        {
                            return  YES;
                        }else
                        {
                            if ([self cheackInputString:string])
                            {
                                return YES;
                            }else
                            {
                                alertString = [alertString stringByAppendingString:@"1.0~999.9"];
                                [SVProgressHUD showErrorWithStatus:alertString];
                                return NO;
                            }
                        }
                    }
                    
                }break;
                case 3:
                {
                    if ([textField.text rangeOfString:@"."].location != NSNotFound)
                    {
                         BOOL result = [[textField.text substringWithRange:NSMakeRange(2,1)] isEqualToString:@"."];
                        if (result) {
                            
                            if ([self cheackInputString:string])
                            {
                                return YES;
                            }else
                            {
                                alertString = [alertString stringByAppendingString:@"1.0~999.9"];
                                [SVProgressHUD showErrorWithStatus:alertString];
                                return NO;
                            }
                            
                        }else
                        {
                            return  NO;
                        }
                        
                    }else
                    {
                        return [string isEqualToString:@"."];
                    }
                    
                }break;
                    
                case 4:
                {
                    BOOL result = [[textField.text substringWithRange:NSMakeRange(3,1)] isEqualToString:@"."];
                    if (result)
                    {
                        if ([self cheackInputString:string])
                        {
                            return YES;
                        }else
                        {
                            alertString = [alertString stringByAppendingString:@"1.0~999.9"];
                            [SVProgressHUD showErrorWithStatus:alertString];
                            return NO;
                        }
                        
                    }else
                    {
                        return  NO;
                    }
                } break;
                    
                default:
                {
                    alertString = [alertString stringByAppendingString:@"1.0~999.9"];
                    [SVProgressHUD showErrorWithStatus:alertString];
                    return NO;
                }
                    break;
            }
        }
            case 4:
            {
            if (textField.text.length >2) {
                return NO;
            }
            
        }break;

            break;
    }

    
    if (textField.text.length >= 6)
    {
        if (string.length == 0) return YES;
        return NO;
    }
    return YES;
}

// 正则匹配输入的内容
-(BOOL)cheackInputString:(NSString *)string
{
    NSString * pattern = @"[0-9]{1}";
    NSPredicate *pred = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", pattern];
    BOOL isMatch = [pred evaluateWithObject:string];
    return isMatch;
}
// 正则匹配输入的内容
-(BOOL)cheackFirstInputString:(NSString *)string
{
    NSString * pattern = @"[0-9]{1}";
    NSPredicate *pred = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", pattern];
    BOOL isMatch = [pred evaluateWithObject:string];
    return isMatch;
}

/**
 *   选择按钮点击事件
 */
- (void)numberSelectBtnDidClicked:(UIButton *)sender
{
    KMDeviceManagerDetailModel *m = [_deviceManagerModel.list objectAtIndex:0];
    [self.alertView endEditing:YES];
    switch (sender.tag)
    {
        case 200:       // 取消
        {

        } break;
        case 201:       // 完成
        {
            KMCommonAlertView *commView = (KMCommonAlertView *)self.alertView.containerView;
            UITextField *textField = [commView.customerView viewWithTag:100];
            
            if ([self.type isEqualToString:@"20"])
            {
                switch (self.currentIndexPath.row)
                {
                    case 0:
                        self.physiqueModel.step = [textField.text integerValue];
                        break;
                    case 1:
                        self.physiqueModel.height = [textField.text floatValue];
                        break;
                    case 2:
                        self.physiqueModel.weight = [textField.text floatValue];
                        break;
                    case 4:
                        self.physiqueModel.age = [textField.text integerValue];
                        break;
                    default:
                        break;
                }
                // 更新数据
                [self updateDeviceSettingWithBody:[self.physiqueModel mj_JSONString]];
                
            }else
            {
                switch (self.currentIndexPath.row)
                {
                    case 0:
                        m.uStep = [textField.text intValue];
                        break;
                    case 1:
                        m.uHeight = [textField.text doubleValue];
                        break;
                    case 2:
                        m.uWeight = [textField.text doubleValue];
                        break;
                    default:
                        break;
                }
                // 更新数据
                [self updateDeviceSettingWithBody:[m mj_JSONString]];
            }
        } break;
        default:
            break;
    }
    
    [self.alertView close];
    self.alertView = nil;
}

/**
 *   选择按钮点击事件
 */
- (void)changeButtonDidClicked:(UIButton *)sender
{
    KMDeviceManagerDetailModel *m = [_deviceManagerModel.list objectAtIndex:0];
    [self.alertView endEditing:YES];
    switch (sender.tag)
    {
        case 200:       // 取消
        {
            
        } break;
        case 201:       // 完成
        {
            if ([self.type isEqualToString:@"20"])
            {
                self.physiqueModel.step = [self.numberTextField.text integerValue];
                // 更新数据
                [self updateDeviceSettingWithBody:[self.physiqueModel mj_JSONString]];
            }else
            {
                m.uStep = [self.numberTextField.text intValue];
                // 更新数据
                [self updateDeviceSettingWithBody:[m mj_JSONString]];
            }
        } break;
        default:
            break;
    }
    
    [self.alertView close];
    self.alertView = nil;
}


@end
