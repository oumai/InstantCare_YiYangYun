//
//  KMSilentRemindVC.m
//  InstantCare
//
//  Created by km on 16/9/2.
//  Copyright © 2016年 omg. All rights reserved.
//

#import "KMSilentRemindVC.h"
#import "KMSilentSettingModel.h"
#import "CustomIOSAlertView.h"
#import "KMCommonAlertView.h"
#import "KMNetAPI.h"
#import "MJExtension.h"
@interface KMSilentRemindVC ()<UITableViewDataSource>

/** 标题 */
@property (nonatomic, strong) NSDictionary * titleDic;

/** 分区标题 */
@property (nonatomic, strong) NSArray *headerTitle;

/** 发送模型 */
@property (nonatomic, strong) KMSilentSettingModel *postModel;

/** 时间选择器 */
@property (nonatomic, strong) UIDatePicker *datePicker;

/** 提示框 */
@property(nonatomic,strong)CustomIOSAlertView *timeAlert;

/** 选中下表 */
@property (nonatomic, assign) NSInteger currentIndex;

/** 日期格式 */
@property (nonatomic, strong) NSDateFormatter *dateFormatter;



@end

@implementation KMSilentRemindVC

//  标题
- (NSDictionary *)titleDic
{
    if(_titleDic == nil)
    {
        NSArray * section0 = @[kLoadStringWithKey(@"DeviceManager_HealthSetting_time_start"),kLoadStringWithKey(@"DeviceManager_HealthSetting_time_end")];
        NSArray * section1 = @[kLoadStringWithKey(@"Remind_week_week1"),
                               kLoadStringWithKey(@"Remind_week_week2"),
                               kLoadStringWithKey(@"Remind_week_week3"),
                               kLoadStringWithKey(@"Remind_week_week4"),
                               kLoadStringWithKey(@"Remind_week_week5"),
                               kLoadStringWithKey(@"Remind_week_week6"),
                               kLoadStringWithKey(@"Remind_week_week7")];
        
        _titleDic = @{@0:section0,@1:section1};
    }
    
    return _titleDic;
}

// 日期格式
- (NSDateFormatter *)dateFormatter{
    
    if (_dateFormatter == nil) {
        
        _dateFormatter  = [[NSDateFormatter alloc] init];
        _dateFormatter.dateFormat = @"HH:mm";
        
    }
    return  _dateFormatter;
}

// 分区标题
- (NSArray *)headerTitle
{
    if (_headerTitle == nil) {
        
        _headerTitle = @[@"",kLoadStringWithKey(@"Remind_repeat")];
    }
    
    return _headerTitle;
}

// 发送模型
- (KMSilentSettingModel *)postModel
{
    if(_postModel == nil)
    {
        _postModel = [[KMSilentSettingModel alloc] init];
    }
    return _postModel;
}

// 模型赋值
- (void)setModel:(KMSilentSettingModel *)model
{
    _model = model;
    // 赋值
    self.postModel.dayflag1 = self.model.dayflag1;
    self.postModel.dayflag2 = self.model.dayflag2;
    self.postModel.dayflag3 = self.model.dayflag3;
    
    self.postModel.starttime1 = self.model.starttime1;
    self.postModel.starttime2 = self.model.starttime2;
    self.postModel.starttime3 = self.model.starttime3;
    
    self.postModel.endtime1 = self.model.endtime1;
    self.postModel.endtime2 = self.model.endtime2;
    self.postModel.endtime3 = self.model.endtime3;
    
}



// 视图加载完成
- (void)viewDidLoad {
    [super viewDidLoad];
    
    // 配置导航栏
    [self configNavigation];
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
    
    // 检查数据
        if (![self checkChangeData]) {
    
            return;
        }
    
    // 创建请求连接
    NSString * URL = [NSString stringWithFormat:@"deviceManager/silent/%@/%@",member.loginAccount,self.imei];
    // 开始进行网络请求
    [SVProgressHUD show];
    [[KMNetAPI manager] commonPOSTRequestWithURL:URL jsonBody:[_postModel mj_JSONString] Block:^(int code, NSString *res)
     {
         KMNetworkResModel *resModel = [KMNetworkResModel mj_objectWithKeyValues:res];
         if (code == 0 && resModel.errorCode <= kNetReqSuccess)
         {
             dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                 [SVProgressHUD dismiss];
                 [self.navigationController popViewControllerAnimated:YES];
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
    self.timeAlert = [[CustomIOSAlertView alloc] init];
    self.timeAlert.buttonTitles = nil;
    [self.timeAlert setUseMotionEffects:NO];
    
    UIView * alertView = [[UIView alloc] initWithFrame:CGRectMake(0,0,SCREEN_WIDTH*0.9,220)];
    alertView.backgroundColor = [UIColor whiteColor];
    self.timeAlert.containerView = alertView;
    
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
    [self.timeAlert show];
}

/**
 *   检查保存信息
 */
- (BOOL)checkChangeData
{
    NSDate * start = [self.dateFormatter  dateFromString:[self currenStartTime]];
    NSDate * end   = [self.dateFormatter  dateFromString:[self  currenEndTime]];
    NSInteger second = [end timeIntervalSinceDate:start];
    if (second < 0) {
        
        // 显示提示框
        [self customAlertViewShowWithMessage:kLoadStringWithKey(@"DeviceManager_HealthSetting_alert_time") withStatus:NO];
        return NO;
    }
    
    return YES;
}


#pragma mark - UITableViewDataSource
/**
 *    分区
 */
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return self.titleDic.allKeys.count;
}

/**
 *    分组
 */
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    NSArray * array = self.titleDic[@(section)];
    return array.count;
}

/**
 *    数据对象
 */
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    //1.创建cell
    static NSString *  time  = @"time";
    static NSString *  week  = @"week";
    NSString * identifer = indexPath.section > 0?week:time;
    UITableViewCell * cell = [tableView dequeueReusableCellWithIdentifier:identifer];
    if (cell == nil) {
        
        UITableViewCellStyle style = indexPath.section==0?UITableViewCellStyleValue1:UITableViewCellStyleSubtitle;
        cell = [[UITableViewCell alloc] initWithStyle:style reuseIdentifier:identifer];
    }

    //2.赋值cell
    // title
        NSArray * array = self.titleDic[@(indexPath.section)];
        cell.textLabel.text = array[indexPath.row];
    
    // image
    cell.imageView.image = nil;
    
    // 模型赋值
    if (indexPath.section) {
        
        cell.imageView.image = [self makeImageFromColor:[UIColor clearColor]];
        UIButton * checkButton = [UIButton buttonWithType:UIButtonTypeCustom];
        checkButton.frame = CGRectMake(0, 0,30, 30);
        [checkButton setBackgroundImage:[UIImage imageNamed:@"set_button_choose_normal"] forState:UIControlStateNormal];
        [checkButton setBackgroundImage:[UIImage imageNamed:@"set_button_choose_sel"] forState:UIControlStateSelected];
        cell.accessoryView = checkButton;
        checkButton.tag = 3000+indexPath.row;
        [checkButton addTarget:self action:@selector(repeatRemindAction:) forControlEvents:UIControlEventTouchUpInside];
        checkButton.selected = [self returnButtonSelectedStautsWithindex:indexPath.row];
        
    }else{
        
        // 设置时间
        cell.detailTextLabel.text = indexPath.row >0? [self currenEndTime]:[self currenStartTime];
    }
    
    //3.返回cell
    return cell;
}

// 重复提醒事件
-(void)repeatRemindAction:(UIButton *)sender
{
    //修改数据
    sender.selected = !sender.selected;
    BOOL result = sender.selected;
    NSInteger tag = sender.tag - 3000;
    
    // 修改数据
    NSString * number = result?@"1":@"0";
    [self setdayFlayWithIndex:tag withString:number];

}

// 返回Button选中状态
-(BOOL)returnButtonSelectedStautsWithindex:(NSInteger)row
{
    return [self getdayFlayWithIndex:row];
}

/**
 *   返回分区标题
 */
- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    
    return self.headerTitle[section];
}

#pragma mark - UITableViewDelegate
/**
 *    cell点击事件
 */
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    self.currentIndex = indexPath.row;
    if (indexPath.section==0) {
        
        [self showTimeSelectedAlertView];
    }
}

// 启动选择时间对话框
-(void)showTimeSelectedAlertView
{
    // 提示框
    self.timeAlert = [[CustomIOSAlertView alloc] init];
    self.timeAlert.buttonTitles = nil;
    [self.timeAlert setUseMotionEffects:NO];
    
    
    //提示框自定义视图；
    KMCommonAlertView * view = [[KMCommonAlertView alloc] initWithFrame:CGRectMake(0, 0,SCREEN_WIDTH-40,260)];
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
        make.height.mas_equalTo(180);
    }];
    datePicker.datePickerMode = UIDatePickerModeTime;
    self.datePicker = datePicker;
    
    // 设置标签内容；
    NSDateFormatter * dateFormatter = [[NSDateFormatter alloc] init];
    dateFormatter.dateFormat = @"HH:mm";
    
    // 指定选择器
    NSString * time;
    if (self.currentIndex) {
        time = [self currenEndTime];
    }else{
        time = [self currenStartTime];
    }
    
    // 获取时间
    NSDate * date = [dateFormatter dateFromString:time];
    if (date != nil) {
        
        [self.datePicker setDate:date];
    }
    
    //提示框显示
    self.timeAlert.containerView = view;
    [self.timeAlert show];
}




// 时间选择事件
-(void)timeAlertSelectedAction:(UIButton *)sender
{
    NSInteger index = sender.tag - 3000;
    if (index == 1)
    {
        // 设置标签内容；
        NSDateFormatter * dateFormatter = [[NSDateFormatter alloc] init];
        dateFormatter.dateFormat = @"HH:mm";
        
        // 获取日期字符串
        NSString * time = [dateFormatter stringFromDate:self.datePicker.date];
        
        // 赋值操作
        NSIndexPath * indexpath = [NSIndexPath indexPathForRow:self.currentIndex inSection:0];
        UITableViewCell * cell = [self.tableView cellForRowAtIndexPath:indexpath];
        cell.detailTextLabel.text = time;
        
        // 保存数据
        if (self.currentIndex == 0) {
            [self setCurrenStartTime:time];
        }else{
            [self setCurrenEndTime:time];
        }
    }
    [self.timeAlert close];
}

/**
 *   返回cell高度
 */
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 70;
}



#pragma mark -  开发工具方法
// 获取开始时间字符串
- (NSString *)currenStartTime
{
    // 获取当前时间数据
    NSString * time;
    switch (self.index) {
        case 0:
            time = self.postModel.starttime1;
            break;
        case 1:
            time = self.postModel.starttime2;
            break;
        case 2:
            time = self.postModel.starttime3;
            break;
    }
    return time;
}
// 获取结束时间字符串
- (NSString *)currenEndTime
{
    // 获取当前时间数据
    NSString * time;
    switch (self.index) {
        case 0:
            time = self.postModel.endtime1;
            break;
        case 1:
            time = self.postModel.endtime2;
            break;
        case 2:
            time = self.postModel.endtime3;
            break;
    }
    
    return time;
}

// 获取重复提醒标识
- (NSString *)currenDayFlay
{
    // 获取当前时间数据
    NSString * time;
    switch (self.index) {
        case 0:
            time = self.postModel.dayflag1;
            break;
        case 1:
            time = self.postModel.dayflag2;
            break;
        case 2:
            time = self.postModel.dayflag3;
            break;
    }
    return time;
}

// 获取dayFlay标识
- (NSInteger)getdayFlayWithIndex:(NSInteger)index
{
    NSString * dayFlay = [self currenDayFlay];
    return [[dayFlay substringWithRange:NSMakeRange(index,1)] integerValue];
}

// 设置当前时间字符串
- (void)setCurrenStartTime:(NSString *)string
{
    switch (self.index) {
        case 0:
            self.postModel.starttime1 = string;
            break;
        case 1:
            self.postModel.starttime2 = string;
            break;
        case 2:
            self.postModel.starttime3 = string;
            break;
    }
}

// 设置当前时间字符串
- (void)setCurrenEndTime:(NSString *)string
{
    switch (self.index) {
        case 0:
            self.postModel.endtime1 = string;
            break;
        case 1:
            self.postModel.endtime2 = string;
            break;
        case 2:
            self.postModel.endtime3 = string;
            break;
    }
}

// 设置当前时间字符串
- (void)setCurrenDayFlay:(NSString *)string
{
    switch (self.index) {
        case 0:
            self.postModel.dayflag1 = string;
            break;
        case 1:
            self.postModel.dayflag2 = string;
            break;
        case 2:
            self.postModel.dayflag3 = string;
            break;
    }
}

// 设置dayFlay标识
- (void)setdayFlayWithIndex:(NSInteger)index withString:(NSString *)string
{
    NSString * dayFlay = [self currenDayFlay];
    dayFlay = [dayFlay stringByReplacingCharactersInRange:NSMakeRange(index,1) withString:string];
    [self setCurrenDayFlay:dayFlay];
}

#pragma mark --- 颜色生成图片
- (UIImage *)makeImageFromColor:(UIColor *)color
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
