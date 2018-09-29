
//
//  KM8020RemindEditVC.m
//  InstantCare
//
//  Created by km on 16/9/9.
//  Copyright © 2016年 omg. All rights reserved.
//

#import "KM8020RemindEditVC.h"
#import "KMRemindModel.h"
#import "CustomIOSAlertView.h"
#import "KMCommonAlertView.h"
#import "MJExtension.h"
#import "KMNetAPI.h"
@interface KM8020RemindEditVC ()<UITextFieldDelegate>

/** 分区标题 */
@property (nonatomic, strong) NSArray *sections;

/**  分组标题*/
@property (nonatomic, strong) NSDictionary *rowDic;

/** UITextField */
@property (nonatomic, strong) UITextField *textField;

/** 时间选择提示框  */
@property(nonatomic,strong)CustomIOSAlertView * timeSelected;

/** 日期选择器  */
@property(nonatomic,strong)UIDatePicker * dataPicker;




@end

@implementation KM8020RemindEditVC

//  分区标题
- (NSArray *)sections
{
    if(_sections == nil)
    {
        _sections = @[@"",
                      kLoadStringWithKey(@"Remind_info"),
                      kLoadStringWithKey(@"Remind_repeat")];
    }
    return _sections;
}

//  分区标题
- (NSDictionary *)rowDic
{
    if(_rowDic == nil)
    {
        NSArray * section0 = @[kLoadStringWithKey(@"DeviceManager_HealthSetting_time")];
        NSArray * section1 = @[kLoadStringWithKey(@"DeviceManager_HealthSetting_alert_remind_content")];
        NSArray * section2 = @[kLoadStringWithKey(@"Remind_week_week1"),
                               kLoadStringWithKey(@"Remind_week_week2"),
                               kLoadStringWithKey(@"Remind_week_week3"),
                               kLoadStringWithKey(@"Remind_week_week4"),
                               kLoadStringWithKey(@"Remind_week_week5"),
                               kLoadStringWithKey(@"Remind_week_week6"),
                               kLoadStringWithKey(@"Remind_week_week7")];
        
        _rowDic = @{@0:section0,@1:section1,@2:section2};;
    }
    return _rowDic;
}

// 数据模型
- (KMRemindDetailModel *)model
{
    if (_model == nil) {
        
        _model = [[KMRemindDetailModel alloc] init];
        _model.t1Hex = @"0";
        _model.t2Hex = @"0";
        _model.t3Hex = @"0";
        _model.t4Hex = @"0";
        _model.t5Hex = @"0";
        _model.t6Hex = @"0";
        _model.t7Hex = @"0";
        _model.attribute1 = @"";
        _model.sYear = @"";
        _model.sMon = @"";
        _model.sDay = @"";
        _model.sMin = @"";
        _model.sHour= @"";
    }
    
    return _model;
}

// 视图加载完成
- (void)viewDidLoad {
    [super viewDidLoad];
    
    // 设置tableView
    self.tableView.tableFooterView = [UIView new];
    
    /** 设置导航栏  */
    [self configNavigation];
}

#pragma mark - 配置导航栏
-(void)configNavigation
{
    self.title = kLoadStringWithKey(@"DeviceManager_HealthSetting_alert_remind_title");
    // 自定义按钮
    UIButton * leftButton = [UIButton buttonWithType:UIButtonTypeCustom];
    leftButton.frame = CGRectMake(0, 0, 30, 30);
    [leftButton setBackgroundImage:[UIImage imageNamed:@"return_normal"] forState:UIControlStateNormal];
    [leftButton setBackgroundImage:[UIImage imageNamed:@"return_sel"] forState:UIControlStateSelected];
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:leftButton];
    
    // 添加事件处理
    [leftButton addTarget:self action:@selector(leftBarButtonDidClickedAction:) forControlEvents:UIControlEventTouchDown];
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:kLoadStringWithKey(@"Personal_info_save") style:UIBarButtonItemStyleDone target:self action:@selector(rightButtonDidClickedAction:)];
    
}

// leftButton 按钮点击事件
-(void)leftBarButtonDidClickedAction:(UIButton *)sender
{
    [self.navigationController popViewControllerAnimated:YES];
}

// rightButton 按钮点击事件
-(void)rightButtonDidClickedAction:(UIBarButtonItem *)item
{
    [self.view endEditing:YES];
    /** 保存用户信息  */
    if (self.editStatus == KM8020RemindStatusEdit) {
        
        [self saveEditUserInfomation];
    }else{
        
        [self saveAddUserInfomation];
    }
}

// 视图点击方法
- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event
{
    [self.view endEditing:YES];
}
#pragma mark - 保存用户信息
/**
 *   编辑信息
 */
- (void)saveEditUserInfomation
{
//    WS(ws);
    // 创建网络请求连接
    NSString * request = [NSString stringWithFormat:@"updateRemind/t9/%@/%ld/%ld",self.model.sImei,[self.model.sTeam integerValue],[self.model.sType integerValue]];
    
    NSDictionary * body;
    
    if ([self.model.sType isEqualToString:@"00"]||[self.model.sType isEqualToString:@"01"]) {
        
        body = @{@"attribute1":self.model.attribute1,
                     @"year":self.model.sYear,
                     @"mon":self.model.sMon,
                     @"day":self.model.sDay,
                     @"hour":self.model.sHour,
                     @"min":self.model.sMin};
    }else{
        body = @{@"attribute1":self.model.attribute1,
                 @"t1Hex":self.model.t1Hex,
                 @"t2Hex":self.model.t2Hex,
                 @"t3Hex":self.model.t3Hex,
                 @"t4Hex":self.model.t4Hex,
                 @"t5Hex":self.model.t5Hex,
                 @"t6Hex":self.model.t6Hex,
                 @"t7Hex":self.model.t7Hex,
                 @"year":self.model.sYear,	
                 @"mon":self.model.sMon,
                 @"day":self.model.sDay,
                 @"hour":self.model.sHour,
                 @"min":self.model.sMin};
    }
    
    // 开始网络请求
    [SVProgressHUD show];
    [[KMNetAPI manager] commonPOSTRequestWithURL:request jsonBody:[body mj_JSONString] Block:^(int code, NSString *res)
     {
         KMNetworkResModel * resModel = [KMNetworkResModel mj_objectWithKeyValues:res];
         NSLog(@"%@",res);
         if (code == 0 && resModel.errorCode <= kNetReqSuccess)
         {
             [SVProgressHUD showSuccessWithStatus:nil];
             [self.navigationController popViewControllerAnimated:YES];
         }else
         {
             [SVProgressHUD dismiss];
             [SVProgressHUD showErrorWithStatus:kNetReqFailWithCode(resModel.errorCode)];
         }
     }];
}

/**
 *   添加信息
 */
- (void)saveAddUserInfomation
{
    
    // 创建网络请求连接
    NSString * repart  = [NSString stringWithFormat:@"%@%@%@%@%@%@%@",self.model.t1Hex,self.model.t2Hex,self.model.t3Hex,self.model.t4Hex,self.model.t5Hex,self.model.t6Hex,self.model.t7Hex];
    
    NSInteger type;
    if ([repart isEqualToString:@"0000000"]) {
        
         type = 0;
    }else if ([repart isEqualToString:@"1111111"]){
         type = 1;
    }else{
        type = 2;
    }
    
    NSDictionary * body;
    if (type == 0 || type == 1) {
        
        body = @{@"year":self.model.sYear,
                 @"mon":self.model.sMon,
                 @"day":self.model.sDay,
                 @"hour":self.model.sHour,
                 @"min":self.model.sMin,
                 @"attribute1":self.model.attribute1};
    }else{
        body = @{@"year":self.model.sYear,
                 @"mon":self.model.sMon,
                 @"day":self.model.sDay,
                 @"hour":self.model.sHour,
                 @"min":self.model.sMin,
                 @"attribute1":self.model.attribute1,
                 @"t1Hex":self.model.t1Hex,
                 @"t2Hex":self.model.t2Hex,
                 @"t3Hex":self.model.t3Hex,
                 @"t4Hex":self.model.t4Hex,
                 @"t5Hex":self.model.t5Hex,
                 @"t6Hex":self.model.t6Hex,
                 @"t7Hex":self.model.t7Hex};
        
    }
    
    NSString * request = [NSString stringWithFormat:@"addRemind/t9/%@/%zd",self.imei,type];
    
    
    // 开始网络请求
    [SVProgressHUD show];
    [[KMNetAPI manager] commonPOSTRequestWithURL:request jsonBody:[body mj_JSONString] Block:^(int code, NSString *res)
     {
         KMNetworkResModel * resModel = [KMNetworkResModel mj_objectWithKeyValues:res];
         NSLog(@"%@",res);
         if (code == 0 && resModel.errorCode <= kNetReqSuccess)
         {
             [SVProgressHUD showSuccessWithStatus:nil];
             [self.navigationController popViewControllerAnimated:YES];
         }else
         {
             [SVProgressHUD dismiss];
             [SVProgressHUD showErrorWithStatus:kNetReqFailWithCode(resModel.errorCode)];
         }
     }];
    
    
    
}

#pragma mark - UITableViewDataSource
/**
 *    分区
 */
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    if (self.editStatus == KM8020RemindStatusAdd||[self.model.sType isEqualToString:@"02"]) {
        
        return self.sections.count;
    }else{
        
        return 2;
    }
}

/**
 *    分组
 */
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    NSArray * array = self.rowDic[@(section)];
    return array.count;
}

/**
 *    数据对象
 */
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    //1.创建cell
    NSString * identifer = indexPath.section == 2? @"section2":@"section0";;
    UITableViewCell * cell = [tableView dequeueReusableCellWithIdentifier:identifer];
    if (cell == nil) {
        
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:identifer];
    }
    
    //2.赋值cell
    if (indexPath.section == 2){
        
        // 标题
        cell.textLabel.text = self.rowDic[@(indexPath.section)][indexPath.row];
        cell.imageView.image = [self buttonImageFromColor:[UIColor clearColor]];
        
        // 辅助视图
        UIButton * checkButton = [UIButton buttonWithType:UIButtonTypeCustom];
        checkButton.frame = CGRectMake(0, 0,30, 30);
        [checkButton setBackgroundImage:[UIImage imageNamed:@"set_button_choose_normal"]
        forState:UIControlStateNormal];
        [checkButton setBackgroundImage:[UIImage imageNamed:@"set_button_choose_sel"]
        forState:UIControlStateSelected];
        
        // 设置cell
        cell.accessoryView = checkButton;
        checkButton.tag = indexPath.row;
        [checkButton addTarget:self action:@selector(repeatRemindAction:)
        forControlEvents:UIControlEventTouchDown];
        if (!(self.editStatus == KM8020RemindStatusAdd)) {
            
            checkButton.selected = [self returnButtonSelectedStautsWithindex:indexPath.row];
        }
    }else if (indexPath.section == 1){
      
        [self.textField removeFromSuperview]; 
        // 输入视图
        UITextField * textField = [[UITextField alloc] init];
        [cell.contentView addSubview:textField];
        [textField mas_makeConstraints:^(MASConstraintMaker *make)
         {
             make.top.mas_offset(0);
             make.left.mas_equalTo(10);
             make.right.mas_equalTo(-10);
             make.bottom.mas_equalTo(0);
         }];
        self.textField = textField;
        textField.delegate = self;
        
        if (self.model.attribute1.length>0) {
            
            textField.text = self.model.attribute1;
        }else{
            
            textField.placeholder = self.rowDic[@(indexPath.section)][indexPath.row];
        }
        
    }else if (indexPath.section == 0){
        
        cell.textLabel.text = self.rowDic[@(indexPath.section)][indexPath.row];
        // 日期转换
        if (_model != nil) {
            
            NSString * time;
            if ([self.model.sType isEqualToString:@"00"]) {
                
             time = [NSString stringWithFormat:@"%@/%@/%@ %@:%@",
                 self.model.sYear,self.model.sMon,self.model.sDay,self.model.sHour,self.model.sMin];
            }else{
                
                time = [NSString stringWithFormat:@"%@:%@",self.model.sHour,self.model.sMin];
            }
            cell.detailTextLabel.text = time;
        }
    }
    
    //3.返回cell
    return cell;
}

/**
 *   重复提醒事件
 */
- (void)repeatRemindAction:(UIButton *)sender
{
    BOOL result = !sender.selected;
    sender.selected  = result;
    NSString * status = result?@"1":@"0";
    
    switch (sender.tag) {
        case 0:
        {
            self.model.t1Hex = status;
        }break;
        case 1:
        {
            self.model.t2Hex = status;
        }break;
        case 2:
        {
            self.model.t3Hex = status;

        }break;
        case 3:
        {
            self.model.t4Hex = status;

        }break;
        case 4:
        {
            self.model.t5Hex = status;

        }break;
        case 5:
        {
            self.model.t6Hex = status;

        }break;
        case 6:
        {
            self.model.t7Hex = status;

        }break;
    }
    
}

// 返回Button选中状态
-(BOOL)returnButtonSelectedStautsWithindex:(NSInteger)row
{
    switch (row) {
        case 0:
        {
            return [self.model.t1Hex isEqualToString:@"1"];
        }break;
        case 1:
        {
            return [self.model.t2Hex isEqualToString:@"1"];
        }break;
        case 2:
        {
           return [self.model.t3Hex isEqualToString:@"1"];
        }break;
        case 3:
        {
           return [self.model.t4Hex isEqualToString:@"1"];
        }break;
        case 4:
        {
            return [self.model.t5Hex isEqualToString:@"1"];
        }break;
        case 5:
        {
            return [self.model.t6Hex isEqualToString:@"1"];
        }break;
        case 6:
        {
           return [self.model.t7Hex  isEqualToString:@"1"];
        }break;
    }
    return NO;
}

/**
 *   取消选中
 */
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    if (indexPath.section == 0 && self.editStatus == KM8020RemindStatusAdd) {
        
        [self showTimeSelectedAlertView];
    }
}


#pragma mark - UITableViewDelegate
/**
 *   返回高度
 */
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 70;
}

/**
 *   返回分区标题
 */
- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    return self.sections[section];
}

#pragma mark --- 颜色生成图片
- (UIImage *)buttonImageFromColor:(UIColor *)color
{
    CGRect rect = CGRectMake(0, 0,30,30);
    UIGraphicsBeginImageContext(rect.size);
    CGContextRef context = UIGraphicsGetCurrentContext();
    CGContextSetFillColorWithColor(context, [color CGColor]);
    CGContextFillRect(context, rect);
    UIImage *img = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return img;
}

#pragma mark - UITextFieldDelegate
-(void)textFieldDidEndEditing:(UITextField *)textField
{
    self.model.attribute1 = textField.text;
}

// 启动选择时间对话框
-(void)showTimeSelectedAlertView
{
    [self.view endEditing:YES];
    // 提示框
    self.timeSelected = [[CustomIOSAlertView alloc] init];
    self.timeSelected.buttonTitles = nil;
    [self.timeSelected setUseMotionEffects:NO];
    
    
    //提示框自定义视图；
    KMCommonAlertView * view = [[KMCommonAlertView alloc] initWithFrame:CGRectMake(0, 0,SCREEN_WIDTH-40,240)];
    view.titleLabel.text = kLoadStringWithKey(@"DeviceSetting_VC_select");
    view.buttonsArray = @[kLoadStringWithKey(@"Reg_VC_birthday_OK"),kLoadStringWithKey(@"Reg_VC_birthday_cancel")];
    //按钮点击事件；
    UIButton *btn = view.realButtons[0];
    btn.tag = 3001;
    [btn addTarget:self action:@selector(timeAlertSelectedAction:) forControlEvents:UIControlEventTouchUpInside];
    btn = view.realButtons[1];
    btn.tag = 3002;
    [btn addTarget:self action:@selector(timeAlertSelectedAction:) forControlEvents:UIControlEventTouchUpInside];
    
    //设置内容视图
    UIDatePicker * datePicker = [[UIDatePicker alloc] init];
    [view.customerView addSubview:datePicker];
    [datePicker mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.right.mas_equalTo(0);
        make.center.equalTo(view);
        make.height.mas_equalTo(140);
    }];
    datePicker.locale = [NSLocale currentLocale];
    datePicker.datePickerMode = UIDatePickerModeDateAndTime;
    datePicker.minimumDate = [NSDate date];
    self.dataPicker = datePicker;
    
    //提示框显示
    self.timeSelected.containerView = view;
    [self.timeSelected show];
}


/**
 *   事件选择
 */
-(void)timeAlertSelectedAction:(UIButton *)sender
{
    NSInteger index = sender.tag - 3000;
    if (index == 1)
    {
        // 设置标签内容；
        NSDateFormatter * dateFormatter = [[NSDateFormatter alloc] init];
        dateFormatter.dateFormat = @"yyyy/MM/dd HH:mm";
        
        // 动态获取年月日
        NSCalendar *calendar = [NSCalendar currentCalendar];
        NSUInteger unitFlags = NSYearCalendarUnit | NSMonthCalendarUnit | NSDayCalendarUnit | NSHourCalendarUnit | NSMinuteCalendarUnit | NSSecondCalendarUnit;
        NSDateComponents *dateComponent = [calendar components:unitFlags fromDate:self.dataPicker.date];
        
        // 设置时间戳
        self.model.sYear = [NSString stringWithFormat:@"%ld",[dateComponent year]];
        self.model.sMon  = [NSString stringWithFormat:@"%ld",[dateComponent month]];
        self.model.sDay  = [NSString stringWithFormat:@"%ld",[dateComponent day]];
        self.model.sHour = [NSString stringWithFormat:@"%ld",[dateComponent hour]];
        self.model.sMin  = [NSString stringWithFormat:@"%ld",[dateComponent minute]];
        [self.tableView reloadData];
    }
    [self.timeSelected close];
}

@end













