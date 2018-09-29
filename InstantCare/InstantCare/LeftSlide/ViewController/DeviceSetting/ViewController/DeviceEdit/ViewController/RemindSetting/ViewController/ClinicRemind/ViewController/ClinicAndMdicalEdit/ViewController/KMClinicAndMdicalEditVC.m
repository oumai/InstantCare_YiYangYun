//
//  KMClinicAndMdicalEditVC.m
//  InstantCare
//
//  Created by km on 16/6/16.
//  Copyright © 2016年 omg. All rights reserved.
//

#import "KMClinicAndMdicalEditVC.h"
#import "CustomIOSAlertView.h"
#import "KMCommonAlertView.h"
#import "KMRemindEditModel.h"
#import "MJExtension.h"
#import "KMNetAPI.h"
@interface KMClinicAndMdicalEditVC ()<UITableViewDelegate,UITableViewDataSource>
@property(nonatomic,strong)UITableView * tableView;

@property(nonatomic,strong)NSArray * titleArray;


@property(nonatomic,strong)CustomIOSAlertView * timeSelected;

@property(nonatomic,strong)UIDatePicker * dataPicker;

@property(nonatomic,strong)UILabel * timeLabel;

@property(nonatomic,strong)NSMutableString * weekString;

@property(nonatomic,strong)CustomIOSAlertView *messageView;

@end

@implementation KMClinicAndMdicalEditVC

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor whiteColor];
    
    [self initData];
    [self configNavigation];
    [self configViews];
    
}
#pragma mark - 初始化数据
-(void)initData
{
    self.titleArray  = @[kLoadStringWithKey(@"Remind_week_week1"),
                         kLoadStringWithKey(@"Remind_week_week2"),
                         kLoadStringWithKey(@"Remind_week_week3"),
                         kLoadStringWithKey(@"Remind_week_week4"),
                         kLoadStringWithKey(@"Remind_week_week5"),
                         kLoadStringWithKey(@"Remind_week_week6"),
                         kLoadStringWithKey(@"Remind_week_week7")];
}


#pragma mark - 配置导航栏
-(void)configNavigation
{
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
    KMRemindEditModel * model = [[KMRemindEditModel alloc] init];
    [model setValueWithModel:self.model];
    
    NSString * body = [model mj_JSONString];
    [self saveUserChangeInfomatioinWithJsonString:body];
}



// 保存数据
-(void)saveUserChangeInfomatioinWithJsonString:(NSString *)body
{
    // 开始更改操作
    [SVProgressHUD showWithStatus:kLoadStringWithKey(@"Common_network_request_now")];
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



#pragma mark - 配置视图
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
    if ([self.type isEqualToString:@"1"] && [self.key isEqualToString:@"02"])
    {
        return 1;
    }
    return 2;
}
// row
-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if (section == 0)
    {
        return 2;
    }else
    {
        return 7;
    }
    
}
// cell
-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell * cell = [tableView dequeueReusableCellWithIdentifier:@"cell"];
    if (cell == nil)
    {
      cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:@"cell"];
    }
    
    cell.imageView.image = nil;
// 分组一
    if (indexPath.section == 0 && indexPath.row == 0)
    {
        cell.textLabel.text = kLoadStringWithKey(@"Remind_Start");
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
        UILabel    * timeLabel  = [[UILabel alloc] initWithFrame:CGRectMake(0, 0,140,35)];
        cell.accessoryView = timeLabel;
        [timeLabel setTextAlignment:NSTextAlignmentCenter];
        [timeLabel setFont:[UIFont systemFontOfSize:14]];
        
        if ([self.type isEqualToString:@"1"]&&[self.key isEqualToString:@"01"])
        {
            NSString * time = [NSString stringWithFormat:@"%@:%@",self.model.sHour,self.model.sMin];
            time = [time stringByReplacingOccurrencesOfString:@"null" withString:@""];
            timeLabel.frame = CGRectMake(0, 0, 60, 35);
            timeLabel.text = time;
        }else
        {
            // 日期转换
            NSString * day = [NSString stringWithFormat:@"%@/%@/%@",self.model.sYear,self.model.sMon,self.model.sDay];
            NSString * hour = [NSString stringWithFormat:@"%@:%@",self.model.sHour,self.model.sMin];
            day = [day containsString:@"null"]?@"":day;
            hour = [hour containsString:@"null"]?@"":hour;
            
            NSString * time = [NSString stringWithFormat:@"%@ %@",day,hour];
            time = [time stringByReplacingOccurrencesOfString:@"null" withString:@""];
            timeLabel.text = time;
        }
        
        // 添加手势
        timeLabel.userInteractionEnabled = YES;
        UITapGestureRecognizer * tapGR = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(timeSelectedAction:)];
        [timeLabel addGestureRecognizer:tapGR];
        self.timeLabel = timeLabel;
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
    return cell;
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
    if ([self.type isEqualToString:@"1"] && [self.key isEqualToString:@"01"])
    {
        datePicker.datePickerMode = UIDatePickerModeTime;
    }else
    {
        datePicker.datePickerMode = UIDatePickerModeDateAndTime;
        datePicker.minimumDate = [NSDate date];
    }
    
    
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
        NSDateFormatter * dateFormatter = [[NSDateFormatter alloc] init];

        
        // 动态获取年月日
           NSCalendar *calendar = [NSCalendar currentCalendar];
            NSUInteger unitFlags = NSYearCalendarUnit | NSMonthCalendarUnit | NSDayCalendarUnit | NSHourCalendarUnit | NSMinuteCalendarUnit | NSSecondCalendarUnit;
            NSDateComponents *dateComponent = [calendar components:unitFlags fromDate:self.dataPicker.date];

        if ([self.type isEqualToString:@"1"] && [self.key isEqualToString:@"01"])
        {
            self.model.sHour = [NSString stringWithFormat:@"%ld",[dateComponent hour]];
            self.model.sMin  = [NSString stringWithFormat:@"%ld",[dateComponent minute]];
            self.model.sYear = @"";
            self.model.sMon = @"";
            self.model.sDay = @"";
            dateFormatter.dateFormat = @"HH:mm";
            self.timeLabel.text = [dateFormatter stringFromDate:self.dataPicker.date];
        }else
        {
            self.model.sYear = [NSString stringWithFormat:@"%ld",[dateComponent year]];
            self.model.sMon  = [NSString stringWithFormat:@"%ld",[dateComponent month]];
            self.model.sDay  = [NSString stringWithFormat:@"%ld",[dateComponent day]];
            self.model.sHour = [NSString stringWithFormat:@"%ld",[dateComponent hour]];
            self.model.sMin  = [NSString stringWithFormat:@"%ld",[dateComponent minute]];
            dateFormatter.dateFormat = @"yyyy/MM/dd HH:mm";
            self.timeLabel.text = [dateFormatter stringFromDate:self.dataPicker.date];
        }
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
