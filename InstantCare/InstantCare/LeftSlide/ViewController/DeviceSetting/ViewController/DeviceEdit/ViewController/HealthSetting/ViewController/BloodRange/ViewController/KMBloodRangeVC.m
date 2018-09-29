//
//  KMBloodRangeVC.m
//  Temp
//
//  Created by km on 16/8/11.
//  Copyright © 2016年 km. All rights reserved.
//

#import "KMBloodRangeVC.h"
#import "KMBloodRangeModel.h"
#import "CustomIOSAlertView.h"
#import "KMCommonAlertView.h"
#import "KMNetAPI.h"
#import "MJExtension.h"
@interface KMBloodRangeVC ()<UITableViewDelegate,UITableViewDataSource,UITextFieldDelegate>

/** tableView */
@property (nonatomic, strong) UITableView *tableView;

/** 标题数组 */
@property (nonatomic, strong) NSArray  *titles;

/** 标题数组 */
@property (nonatomic, strong) NSDictionary  *titleDic;

/** post模型 */
@property (nonatomic, strong) KMBloodRangeModel *postModel;

/** 提示框 */
@property (nonatomic, strong) CustomIOSAlertView * alert;

@end



@implementation KMBloodRangeVC


// tableView
- (UITableView *)tableView
{
    
    if (_tableView == nil)
    {
        _tableView = [[UITableView alloc] init];
        _tableView.frame = self.view.bounds;
        _tableView.tableFooterView = [UIView new];
        _tableView.delegate   = self;
        _tableView.dataSource = self;
    }
    return _tableView;
}

// titles
- (NSArray *)titles
{
    if (_titles == nil)
    {
        _titles = @[kLoadStringWithKey(@"DeviceManager_HealthSetting_DBP"),
                    kLoadStringWithKey(@"DeviceManager_HealthSetting_SBP")];
    }
    return _titles;
}

// titleDic
- (NSDictionary *)titleDic
{
    if (_titleDic == nil)
    {
        NSString * upper = kLoadStringWithKey(@"DeviceManager_HealthSetting_limit_upper");
        NSString * lower = kLoadStringWithKey(@"DeviceManager_HealthSetting_limit_lower");
        _titleDic = @{kLoadStringWithKey(@"DeviceManager_HealthSetting_DBP"):@[lower,upper],
                      kLoadStringWithKey(@"DeviceManager_HealthSetting_SBP"):@[lower,upper]};
    }
    return _titleDic;
}

// 视图加载完成
- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor colorWithRed:247/255.0 green:247/255.0 blue:247/255.0 alpha:1.0];
    [self.view addSubview:self.tableView];
    
    // 设置导航栏
    [self configNavigationBar];
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
    
    // right 右
    UIButton *rightButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [rightButton setTitle:kLoadStringWithKey(@"Common_save") forState:UIControlStateNormal];
    [rightButton setTitleColor:[UIColor grayColor] forState:UIControlStateHighlighted];
    rightButton.frame = CGRectMake(0, 0, 60, 30);
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:rightButton];
    [rightButton addTarget:self
                    action:@selector(saveUserOperation)
          forControlEvents:UIControlEventTouchUpInside];
}

/**
 *   返回上一级界面
 */
- (void)backLastView
{
    [self.navigationController popViewControllerAnimated:YES];
}
/**
 *   保存数据
 */
- (void)saveUserOperation
{
    // 保存用户数据
    [self.view endEditing:YES];
    
    // 检查数据
    if (![self checkChangeData]) {
    
        return;
    }
    
    // 创建请求连接
    NSString * URL = [NSString stringWithFormat:@"healthRange/bp/%@/%@",member.loginAccount,self.imei];
    // 开始进行网络请求
    [SVProgressHUD show];
    [[KMNetAPI manager] commonPOSTRequestWithURL:URL jsonBody:[_postModel mj_JSONString] Block:^(int code, NSString *res)
     {
         KMNetworkResModel *resModel = [KMNetworkResModel mj_objectWithKeyValues:res];
         if (code == 0 && resModel.errorCode <= kNetReqSuccess)
         {
             [SVProgressHUD dismiss];
             [self.navigationController popViewControllerAnimated:YES];
         } else
         {
             [SVProgressHUD showErrorWithStatus:kNetReqFailWithCode(resModel.errorCode)];
         }
     }];
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
    static NSString * ID = @"default";
    
    // 1.创建Cell对象
    UITableViewCell * cell = [tableView dequeueReusableCellWithIdentifier:ID];
    if (cell == nil) {
         cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:ID];
    }
    
    
    // 辅助视图
    UITextField * textField =[[UITextField alloc] initWithFrame:CGRectMake(0, 0, 60, 30)];
    cell.accessoryView = textField;
    textField.keyboardType = UIKeyboardTypeNumberPad;
    textField.tag = 1000+indexPath.section*2+indexPath.row;
    textField.delegate = self;

    // 2.设置Cell数据
    cell.textLabel.text = texts[indexPath.row];
    NSString * text ;
    switch (indexPath.section)
    {
        case 0:
        {
            switch (indexPath.row)
            {
                case 0:
                {
                    text = [NSString stringWithFormat:@"%zd",_model.bpdL];
                }break;
                case 1:
                {
                    text = [NSString stringWithFormat:@"%zd",_model.bpdH];
                }break;
            }
            
        }break;
        case 1:
        {
            switch (indexPath.row)
            {
                case 0:
                {
                   text = [NSString stringWithFormat:@"%zd",_model.bpsL];
                }break;
                case 1:
                {
                    text = [NSString stringWithFormat:@"%zd",_model.bpsH];
                }break;
            }
            
        }break;
    }
    textField.text = text;
    
    // 3.返回Cell对象
    return cell;
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
    // 1.取消选中状态
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    NSInteger tag = 1000+indexPath.section*2+indexPath.row;
    UITextField * textField = (UITextField *)[tableView viewWithTag:tag];
    [textField becomeFirstResponder];
}


#pragma mark - UITextFieldDelegate
/**
 *  结束编辑
 */
- (void)textFieldDidEndEditing:(UITextField *)textField
{
    NSInteger tag = textField.tag;
    switch (tag-1000)
    {
        // 低压下限
        case 0:
        {
            self.postModel.bpdL = [textField.text integerValue];
        }break;
        
        // 低压上限
        case 1:
        {
            self.postModel.bpdH = [textField.text integerValue];
            
        }break;
         
        // 高压下限
        case 2:
        {
            self.postModel.bpsL = [textField.text integerValue];
        }break;
          
        // 高压上限
        case 3:
        {
            self.postModel.bpsH = [textField.text integerValue];
        }break;
    }
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
    
    UIView * alertView = [[UIView alloc] initWithFrame:CGRectMake(0,0,SCREEN_WIDTH*0.9,240)];
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
//         make.height.mas_equalTo(120);
         make.top.equalTo(alertView.mas_centerY);
     }];
    massageLabel.textAlignment = NSTextAlignmentCenter;
    massageLabel.text = message;
    massageLabel.numberOfLines = 0;
    [massageLabel sizeToFit];
    [self.alert show];
}


/**
 *   检查保存信息
 */
- (BOOL)checkChangeData
{
    NSLog(@"    上限：%zd 下限：%zd 高压上限：%zd 下限：%zd ",self.postModel.bpsH,self.postModel.bpsL,self.postModel.bpdH,self.postModel.bpdL);
    // 低压上限
    if (self.postModel.bpdH < 30 || self.postModel.bpdH > 250) {
        
        // 显示提示框
        NSString * alert = [NSString stringWithFormat:@"%@\n(%@:30~250)!",kLoadStringWithKey(@"DeviceManager_HealthSetting_alert_range"),kLoadStringWithKey(@"DeviceManager_HealthSetting_alert_range")];
        [self customAlertViewShowWithMessage:alert withStatus:NO];
        return NO;
    }
    // 低压下限
    if (self.postModel.bpdL < 30 || self.postModel.bpdL > 250) {
        
        // 显示提示框
        NSString * alert = [NSString stringWithFormat:@"%@\n(%@:30~250)!",kLoadStringWithKey(@"DeviceManager_HealthSetting_alert_range"),kLoadStringWithKey(@"DeviceManager_HealthSetting_alert_range")];
        [self customAlertViewShowWithMessage:alert withStatus:NO];
        return NO;
    }
    
    // 高压上限
    if (self.postModel.bpsH < 30 || self.postModel.bpsH > 250) {
        
        // 显示提示框
        NSString * alert = [NSString stringWithFormat:@"%@\n(%@:30~250)!",kLoadStringWithKey(@"DeviceManager_HealthSetting_alert_range"),kLoadStringWithKey(@"DeviceManager_HealthSetting_alert_range")];
        [self customAlertViewShowWithMessage:alert withStatus:NO];
        return NO;
    }
    
    // 高压下限
    if (self.postModel.bpsL < 30 || self.postModel.bpsL > 250) {
        
        // 显示提示框
        NSString * alert = [NSString stringWithFormat:@"%@\n(%@:30~250)!",kLoadStringWithKey(@"DeviceManager_HealthSetting_alert_range"),kLoadStringWithKey(@"DeviceManager_HealthSetting_alert_range")];
        [self customAlertViewShowWithMessage:alert withStatus:NO];
        return NO;
    }
    
    // 高压下限大于上限
    if (!(self.postModel.bpdH > self.postModel.bpdL)) {
        
        // 显示提示框
        [self customAlertViewShowWithMessage:kLoadStringWithKey(@"DeviceManager_HealthSetting_alert_limit") withStatus:NO];
        return NO;
    }
    // 低压下限大于上限
    if ( !(self.postModel.bpsH >self.postModel.bpsL)) {
        
        // 显示提示框
        [self customAlertViewShowWithMessage:kLoadStringWithKey(@"DeviceManager_HealthSetting_alert_limit") withStatus:NO];
        return NO;
    }
    
    return YES;
}

/**
 *   设置模型
 */
-(void)setModel:(KMBloodRangeModel *)model
{
    _model = model;
    self.postModel = model;
}


@end







