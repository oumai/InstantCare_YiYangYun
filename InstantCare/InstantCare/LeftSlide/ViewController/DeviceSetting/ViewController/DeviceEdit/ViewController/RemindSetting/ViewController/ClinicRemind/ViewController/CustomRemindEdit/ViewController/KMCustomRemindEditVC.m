//
//  KMCustomRemindEditVC.m
//  InstantCare
//
//  Created by km on 16/6/16.
//  Copyright © 2016年 omg. All rights reserved.
//

#import "KMCustomRemindEditVC.h"
#import "CustomIOSAlertView.h"
#import "KMCommonAlertView.h"
#import "KMRemindEditModel.h"
#import "MJExtension.h"
#import "KMNetAPI.h"
@interface KMCustomRemindEditVC ()<UITableViewDataSource,UITableViewDelegate,UITextViewDelegate>

@property(nonatomic,strong)UITableView * tableView;

@property(nonatomic,strong)NSArray * titleArray;


@property(nonatomic,strong)CustomIOSAlertView * timeSelected;

@property(nonatomic,strong)UIDatePicker * dataPicker;

@property(nonatomic,strong)UILabel * timeLabel;

@property(nonatomic,strong)CustomIOSAlertView *messageView;

@property(nonatomic,strong)UITextView * textView;

@property(nonatomic,strong)UILabel * titleLabel;

/** time */
@property (nonatomic, copy) NSString *time;



@end

@implementation KMCustomRemindEditVC

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor whiteColor];
    
    self.time = kLoadStringWithKey(@"HealthRecord_VC_change_date");
    [self initData];
    [self configNavigation];
    [self configViews];
    
}

#pragma mark - 初始化数据源
-(void)initData
{
    self.titleArray  = @[kLoadStringWithKey(@"Remind_week_week1"),
                         kLoadStringWithKey(@"Remind_week_week2"),
                         kLoadStringWithKey(@"Remind_week_week3"),
                         kLoadStringWithKey(@"Remind_week_week4"),
                         kLoadStringWithKey(@"Remind_week_week5"),
                         kLoadStringWithKey(@"Remind_week_week6"),
                         kLoadStringWithKey(@"Remind_week_week7")];
    
    if (self.stauts == remindStatusAdd)
    {
        self.model  = [[KMRemindDetailModel alloc] init];
        
        // 重复周期
        self.model.t1Hex = @"0";
        self.model.t2Hex = @"0";
        self.model.t3Hex = @"0";
        self.model.t4Hex = @"0";
        self.model.t5Hex = @"0";
        self.model.t6Hex = @"0";
        self.model.t7Hex = @"0";
        // 提醒事件
        self.model.attribute1 = @"";
        // 日期
        self.model.sYear = @"";
        self.model.sMon = @"";
        self.model.sDay = @"";
        self.model.sHour = @"";
        self.model.sMin = @"";
        // 类型
        self.model.sType = @"04";
        // 开启
        self.model.isvalid = @"N";
        
        //Imei
        self.model.sImei = self.imei;
     
    }
}

#pragma mark - 配置导航栏
-(void)configNavigation
{
    self.title =  kLoadStringWithKey(@"RemindSettingVC_remind");
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
    KMRemindEditModel * model = [[KMRemindEditModel alloc] init];
    [model setValueWithModel:self.model];
    
    if (self.stauts == remindStatusEdit)
    {
        [self saveUserChangeInfomatioinWithJsonString:[model mj_JSONString]];
    }else
    {
        [self addRemindWithBody:[model mj_JSONString]];
    }
}

#pragma mark - 添加方法
-(void)addRemindWithBody:(NSString *)body
{
    [SVProgressHUD show];
    NSString * request = [NSString stringWithFormat:@"addRemind/%@",self.imei];
    [[KMNetAPI manager] commonPOSTRequestWithURL:request jsonBody:body Block:^(int code, NSString *res)
     {
         KMNetworkResModel * resModel = [KMNetworkResModel mj_objectWithKeyValues:res];
         if (code == 0 && resModel.errorCode <= kNetReqSuccess)
         {
             [SVProgressHUD showWithStatus:kLoadStringWithKey(@"Addremind_success")];
             [self.navigationController popViewControllerAnimated:YES];
         }else
         {
             [SVProgressHUD dismiss];
             [self customAlertViewShowWithMessage:kNetReqFailWithCode(resModel.errorCode)
                                        withImage:@"pop_icon_fail"];
        }
     }];

    
}

#pragma mark - 更新方法
-(void)saveUserChangeInfomatioinWithJsonString:(NSString *)body
{
    [SVProgressHUD show];
    NSString * request = [NSString stringWithFormat:@"updateRemind/%@/%ld/%ld",self.model.sImei,self.team,[self.model.sType integerValue]];
    [[KMNetAPI manager] commonPOSTRequestWithURL:request jsonBody:body Block:^(int code, NSString *res)
     {
         KMNetworkResModel * resModel = [KMNetworkResModel mj_objectWithKeyValues:res];
         if (code == 0 && resModel.errorCode <= kNetReqSuccess)
         {
             [SVProgressHUD dismiss];
             [self.navigationController popViewControllerAnimated:YES];
         }else
         {
             [SVProgressHUD dismiss];
             [self customAlertViewShowWithMessage:kNetReqFailWithCode(resModel.errorCode)
                                        withImage:@"pop_icon_fail"];
         }
     }];
}


#pragma mark - 配置子视图
-(void)configViews
{
    WS(ws);
    self.tableView = [[UITableView alloc] init];
    self.tableView.tableFooterView = [[UIView alloc] init];
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    self.tableView.rowHeight = 70;
    [self.view addSubview:self.tableView];
    [self.tableView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.equalTo(ws.view);
    }];
}

#pragma mark - UITableViewDataSource 模块
// Section;
-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 2;
}
// row
-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if (section == 0)
    {
        return 3;
    }else
    {
        return 7;
    }
    
}
// cell
-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSString * identfier ;
    if (indexPath.section == 0) {
        identfier = @"1";
        if (indexPath.row == 1) {
            identfier = @"2";
        }
        
    }else{
        identfier = @"3";
    }
    
    
    UITableViewCell * cell = [tableView dequeueReusableCellWithIdentifier:identfier];
    if (cell == nil)
    {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:identfier];
    }
    cell.imageView.image = nil;
    if (self.stauts == remindStatusEdit)
    {
        // 分组一
        if (indexPath.section == 0 && indexPath.row == 0)
        {
            cell.textLabel.text =kLoadStringWithKey(@"Remind_Start");
            // 辅助视图
            UISwitch * mySwitch = [[UISwitch alloc] init];
            cell.accessoryView = mySwitch;
            if ([self.model.isvalid isEqualToString:@"Y"])
            {
                mySwitch.on = YES;
            }else
            {
                mySwitch.on = NO;
            }
            [mySwitch addTarget:self action:@selector(mySwitchClickedAction:) forControlEvents:UIControlEventValueChanged];
            
        }else if (indexPath.section == 0 && indexPath.row ==1)
        {
            cell.textLabel.text = kLoadStringWithKey(@"Remind_Time");
            // 辅助视图
            UILabel    * timeLabel  = [[UILabel alloc] initWithFrame:CGRectMake(0, 0,160,35)];
            cell.accessoryView = timeLabel;
            [timeLabel setTextAlignment:NSTextAlignmentCenter];
            [timeLabel setFont:[UIFont systemFontOfSize:14]];
            
            // 日期转换
            NSString * time = [NSString stringWithFormat:@"%@/%@/%@ %@:%@",self.model.sYear,self.model.sMon,self.model.sDay,self.model.sHour,self.model.sMin];
            
            NSString * date = [NSString stringWithFormat:@"%@%@",kLoadStringWithKey(@"Geofence_VC_not_setting"),kLoadStringWithKey(@"DeviceManager_HealthSetting_time")];
            if ([time hasPrefix:@"0"]||[time hasPrefix:@"/"]) {
                time = date;
            }
            
            timeLabel.text = time;
            
            // 添加手势
            timeLabel.userInteractionEnabled = YES;
            UITapGestureRecognizer * tapGR = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(timeSelectedAction:)];
            [timeLabel addGestureRecognizer:tapGR];
            if (!self.timeLabel) {
                 self.timeLabel = timeLabel;
            }
           
        }else if (indexPath.section == 0 && indexPath.row ==2)
        {
            [self.titleLabel removeFromSuperview];
            self.titleLabel = nil;
            // 标题视图
            self.titleLabel = [[UILabel alloc] init];
            [cell.contentView addSubview:self.titleLabel];
            [self.titleLabel mas_makeConstraints:^(MASConstraintMaker *make) {
                make.height.mas_equalTo(35);
                make.top.mas_equalTo(0);
                make.left.mas_equalTo(15);
                make.right.mas_equalTo(0);
            }];
            self.titleLabel.textAlignment = NSTextAlignmentLeft;
            self.titleLabel.text = kLoadStringWithKey(@"Remind_info");
            
            // 输入视图
            UITextView * textField = [[UITextView alloc] init];
            textField.delegate = self;
            [cell.contentView addSubview:textField];
            [textField mas_makeConstraints:^(MASConstraintMaker *make)
             {
                 make.top.equalTo(cell.mas_centerY).offset(0);
                 make.left.mas_equalTo(30);
                 make.right.mas_equalTo(-10);
                 make.bottom.mas_equalTo(0);
             }];
            textField.text = self.model.attribute1;
            self.textView = textField;
        }
        
        // 分组二
        if (indexPath.section == 1)
        {
            cell.textLabel.text = self.titleArray[indexPath.row];
            cell.imageView.image = [self buttonImageFromColor:[UIColor clearColor]];
            UIButton * checkButton = [UIButton buttonWithType:UIButtonTypeCustom];
            checkButton.frame = CGRectMake(0, 0,30, 30);
            [checkButton setBackgroundImage:[UIImage imageNamed:@"set_button_choose_normal"] forState:UIControlStateNormal];
            [checkButton setBackgroundImage:[UIImage imageNamed:@"set_button_choose_sel"] forState:UIControlStateSelected];
            cell.accessoryView = checkButton;
            checkButton.tag = 3000+indexPath.row;
            [checkButton addTarget:self action:@selector(repeatRemindAction:) forControlEvents:UIControlEventTouchDown];
            checkButton.selected = [self returnButtonSelectedStautsWithindex:indexPath.row];
        }
    }else
    {
        // 分组一
        if (indexPath.section == 0 && indexPath.row == 0)
        {
            cell.textLabel.text =kLoadStringWithKey(@"Remind_Start");

            // 辅助视图
            UISwitch * mySwitch = [[UISwitch alloc] init];
            cell.accessoryView = mySwitch;
            mySwitch.on = NO;
            
            [mySwitch addTarget:self action:@selector(mySwitchClickedAction:) forControlEvents:UIControlEventValueChanged];
            
        }else if (indexPath.section == 0 && indexPath.row ==1)
        {
            [self.timeLabel removeFromSuperview];
            cell.textLabel.text =kLoadStringWithKey(@"Remind_Time");            // 辅助视图
            UILabel    * timeLabel  = [[UILabel alloc] init];
            [cell addSubview:timeLabel];
            [timeLabel mas_makeConstraints:^(MASConstraintMaker *make) {
                make.centerY.equalTo(cell);
                make.width.mas_equalTo(SCREEN_WIDTH*0.65);
                make.height.mas_equalTo(50);
                make.right.equalTo(cell).offset(-15);
            }];
            [timeLabel setTextAlignment:NSTextAlignmentCenter];
            [timeLabel setFont:[UIFont systemFontOfSize:13]];
            timeLabel.userInteractionEnabled = YES;
            timeLabel.text = self.time;
            UITapGestureRecognizer * tapGR = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(timeSelectedAction:)];
            [timeLabel addGestureRecognizer:tapGR];
            self.timeLabel = timeLabel;
    
        }else if (indexPath.section == 0 && indexPath.row ==2)
        {
            [self.titleLabel removeFromSuperview];
            self.titleLabel = nil;
            // 标题视图
            self.titleLabel = [[UILabel alloc] init];
            [cell.contentView addSubview:self.titleLabel];
            [self.titleLabel mas_makeConstraints:^(MASConstraintMaker *make) {
                make.height.mas_equalTo(35);
                make.top.mas_equalTo(0);
                make.left.mas_equalTo(15);
                make.right.mas_equalTo(0);
            }];
            self.titleLabel.textAlignment = NSTextAlignmentLeft;
            self.titleLabel.text = kLoadStringWithKey(@"Remind_info");

            // 输入视图
            UITextView * textField = [[UITextView alloc] init];
            textField.delegate = self;
            [cell.contentView addSubview:textField];
            [textField mas_makeConstraints:^(MASConstraintMaker *make)
             {
                 make.top.equalTo(self.titleLabel.mas_bottom).offset(0);
                 make.left.mas_equalTo(30);
                 make.right.mas_equalTo(-10);
                 make.bottom.mas_equalTo(0);
             }];
            self.textView = textField;
        }
        
        // 分组二
        if (indexPath.section == 1)
        {
            cell.textLabel.text = self.titleArray[indexPath.row];
            cell.imageView.image = [self buttonImageFromColor:[UIColor clearColor]];
            UIButton * checkButton = [UIButton buttonWithType:UIButtonTypeCustom];
            checkButton.frame = CGRectMake(0, 0,30, 30);
            [checkButton setBackgroundImage:[UIImage imageNamed:@"set_button_choose_normal"] forState:UIControlStateNormal];
            [checkButton setBackgroundImage:[UIImage imageNamed:@"set_button_choose_sel"] forState:UIControlStateSelected];
            cell.accessoryView = checkButton;
            checkButton.tag = 3000+indexPath.row;
            [checkButton addTarget:self action:@selector(repeatRemindAction:) forControlEvents:UIControlEventTouchDown];
            checkButton.selected = NO;
        }
    }
    return cell;
}


#pragma mark - UITextViewDelegate
-(BOOL)textView:(UITextView *)textView shouldChangeTextInRange:(NSRange)range replacementText:(NSString *)text
{
    // 判断如果是删除按键
    if (text.length == 0)  return YES;
    // 判断字符格式
    if (![self checkAffirString:text])
    {
        return NO;
    }
    // 判断字符长度；
    if (textView.text.length >= 255)
    {
        return NO;
    }
    // 判断替换后的字符长度
    NSInteger existedLength = textView.text.length;
    NSInteger selectedLength = range.length;
    NSInteger replaceLength = text.length;
    if (existedLength - selectedLength + replaceLength >255)
    {
        return NO;
    }

    return YES;
}

// 正则匹配密码
-(BOOL)checkAffirString:(NSString *)affir
{
    NSString *other = @"➋➌➍➎➏➐➑➒";
    unsigned long len=affir.length;
    for(int i=0;i<len;i++)
    {
        unichar a=[affir characterAtIndex:i];
        if(!((isalpha(a))
             ||(isalnum(a))
             ||((a=='_') || (a == '-'))
             ||((a >= 0x4e00 && a <= 0x9fa6))
             ||([other rangeOfString:affir].location != NSNotFound)
             )){
            return NO;
        }
        else{
            return YES;
        }
    }
    
    NSString * pattern = @"^[A-Za-z0-9\u4e00-\u9fa5 .]+$";
    NSPredicate *pred = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", pattern];
    BOOL isMatch = [pred evaluateWithObject:affir];
    return isMatch;
}


// MYSwitch 点击事件
-(void)mySwitchClickedAction:(UISwitch *)mySwitch
{
    BOOL result = mySwitch.on;
    if (result)
    {
        self.model.isvalid = @"Y";
    }else
    {
        self.model.isvalid = @"N";
    }
}

// UITextViewDelegate
-(void)textViewDidEndEditing:(UITextView *)textView
{
    self.model.attribute1 = textView.text;
}
// 时间选择事件
-(void)timeSelectedAction:(UITapGestureRecognizer *)sender
{
    [self showTimeSelectedAlertView];
}

// 重复提醒事件
-(void)repeatRemindAction:(UIButton *)sender
{
    sender.selected = !sender.selected;
    BOOL result = sender.selected;
    NSInteger tag = sender.tag - 3000;
    switch (tag)
    {
        case 0:
        {
            if (result)
            {
                self.model.t1Hex = @"1";
            }else
            {
                self.model.t1Hex = @"0";
            }
        }break;
        case 1:
        {
            if (result)
            {
                self.model.t2Hex = @"1";
            }else
            {
                self.model.t2Hex = @"0";
            }
            
        }break;
        case 2:
        {
            if (result)
            {
                self.model.t3Hex = @"1";
            }else
            {
                self.model.t3Hex = @"0";
            }
            
        }break;
        case 3:
        {
            if (result)
            {
                self.model.t4Hex = @"1";
            }else
            {
                self.model.t4Hex = @"0";
            }
            
        }break;
        case 4:
        {
            if (result)
            {
                self.model.t5Hex = @"1";
            }else
            {
                self.model.t5Hex = @"0";
            }
            
        }break;
        case 5:
        {
            if (result)
            {
                self.model.t6Hex = @"1";
            }else
            {
                self.model.t6Hex = @"0";
            }
            
        }break;
        case 6:
        {
            if (result)
            {
                self.model.t7Hex = @"1";
            }else
            {
                self.model.t7Hex = @"0";
            }
        }break;
    }
}


// 启动选择时间对话框
-(void)showTimeSelectedAlertView
{
    // 提示框
    self.timeSelected = [[CustomIOSAlertView alloc] init];
    self.timeSelected.buttonTitles = nil;
    [self.timeSelected setUseMotionEffects:NO];
    
    
    //提示框自定义视图；
    KMCommonAlertView * view = [[KMCommonAlertView alloc] initWithFrame:CGRectMake(0, 0,SCREEN_WIDTH,300)];
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
        make.height.mas_equalTo(200);
    }];
    datePicker.locale = [NSLocale currentLocale];
    datePicker.datePickerMode = UIDatePickerModeDateAndTime;
    datePicker.minimumDate = [NSDate date];
    self.dataPicker = datePicker;
    
    //提示框显示
    self.timeSelected.containerView = view;
    [self.timeSelected show];
}

-(void)timeAlertSelectedAction:(UIButton *)sender
{
    NSInteger index = sender.tag - 3000;
    if (index == 1)
    {
        
        
        // 设置标签内容；
        NSDateFormatter * dateFormatter = [[NSDateFormatter alloc] init];
        dateFormatter.dateFormat = @"yyyy/MM/dd HH:mm";
        self.timeLabel.text = [dateFormatter stringFromDate:self.dataPicker.date];
        
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
        self.time = [NSString stringWithFormat:@"%@/%@/%@ %@:%@",self.model.sYear,self.model.sMon,self.model.sDay,self.model.sHour,self.model.sMin];
  
    }
    [self.timeSelected close];
}


// 返回Button选中状态
-(BOOL)returnButtonSelectedStautsWithindex:(NSInteger)row
{
    switch (row) {
        case 0:
        {
            if ([self.model.t1Hex isEqualToString:@"0"])
            {
                return NO;
            }else
            {
                return YES;
            }
        }break;
        case 1:
        {
            if ([self.model.t2Hex isEqualToString:@"0"])
            {
                return NO;
            }else
            {
                return YES;
            }
        }break;
        case 2:
        {
            if ([self.model.t3Hex isEqualToString:@"0"])
            {
                return NO;
            }else
            {
                return YES;
            }
        }break;
        case 3:
        {
            if ([self.model.t4Hex isEqualToString:@"0"])
            {
                return NO;
            }else
            {
                return YES;
            }
        }break;
        case 4:
        {
            if ([self.model.t5Hex isEqualToString:@"0"])
            {
                return NO;
            }else
            {
                return YES;
            }
        }break;
        case 5:
        {
            if ([self.model.t6Hex isEqualToString:@"0"])
            {
                return NO;
            }else
            {
                return YES;
            }
        }break;
        case 6:
        {
            if ([self.model.t7Hex isEqualToString:@"0"])
            {
                return NO;
            }else
            {
                return YES;
            }
        }break;
    }
    return NO;
}


// 返回日期字符串
- (NSString *)weekStringWithDetaiModel:(KMRemindDetailModel *)model
{
    
    NSMutableString *mutableString = [NSMutableString string];
    if ([model.t1Hex isEqualToString:@"1"]) {
        [mutableString appendString:kLoadStringWithKey(@"Remind_week_1")];
    }
    
    if ([model.t2Hex isEqualToString:@"1"]) {
        [mutableString appendString:kLoadStringWithKey(@"Remind_week_2")];
    }
    
    if ([model.t3Hex isEqualToString:@"1"]) {
        [mutableString appendString:kLoadStringWithKey(@"Remind_week_3")];
    }
    
    if ([model.t4Hex isEqualToString:@"1"]) {
        [mutableString appendString:kLoadStringWithKey(@"Remind_week_4")];
    }
    
    if ([model.t5Hex isEqualToString:@"1"]) {
        [mutableString appendString:kLoadStringWithKey(@"Remind_week_5")];
    }
    
    if ([model.t6Hex isEqualToString:@"1"]) {
        [mutableString appendString:kLoadStringWithKey(@"Remind_week_6")];
    }
    
    if ([model.t7Hex isEqualToString:@"1"]) {
        [mutableString appendString:kLoadStringWithKey(@"Remind_week_7")];
    }
    
    return mutableString;
}


#pragma mark - UITableViewDelegate 模块
// cell 选中方法
-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:NO];
}

// 分区标题
-(NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    if (section == 1)
    {
        return kLoadStringWithKey(@"Remind_repeat");
    }
    return nil;
}



#pragma mark --- 信息提示框显示
//显示信息提示框
-(void)customAlertViewShowWithMessage:(NSString *)message withImage:(NSString *)imageString
{
    // 提示框
    self.messageView = [[CustomIOSAlertView alloc] init];
    self.messageView.buttonTitles = nil;
    [self.messageView setUseMotionEffects:NO];
    
    UIView * alertView = [[UIView alloc] initWithFrame:CGRectMake(0,0,SCREEN_WIDTH*0.9,180)];
    alertView.backgroundColor = [UIColor whiteColor];
    self.messageView.containerView = alertView;
    
    // 图标
    UIImageView * fail = [[UIImageView alloc] init];
    [alertView addSubview:fail];
    [fail mas_makeConstraints:^(MASConstraintMaker *make)
     {
         make.centerX.equalTo(alertView);
         make.width.height.mas_equalTo(70);
         make.bottom.equalTo(alertView.mas_centerY);
     }];
    fail.image = [UIImage imageNamed:imageString];
    
    //信息
    UILabel * massage = [[UILabel alloc] init];
    [alertView addSubview:massage];
    [massage mas_makeConstraints:^(MASConstraintMaker *make)
     {
         make.left.right.mas_equalTo(0);
         make.height.mas_equalTo(30);
         make.top.equalTo(alertView.mas_centerY).offset(15);
     }];
    massage.textAlignment = NSTextAlignmentCenter;
    massage.numberOfLines = 0;
    massage.text = message;
    [self.messageView show];
}

#pragma mark --- 信息提示框显示隐藏
-(void)customAlertViewClose
{
    //1.移除提示框
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.8 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^
    {
                       [self.messageView close];
                       [self.navigationController popViewControllerAnimated:YES];
        });
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

@end



