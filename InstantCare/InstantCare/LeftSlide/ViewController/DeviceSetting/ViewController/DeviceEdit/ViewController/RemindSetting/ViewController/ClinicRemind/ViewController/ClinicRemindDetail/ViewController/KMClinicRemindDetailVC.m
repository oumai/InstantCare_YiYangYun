//
//  KMClinicRemindDetailVC.m
//  InstantCare
//
//  Created by bruce-zhu on 16/2/2.
//  Copyright © 2016年 omg. All rights reserved.
//

#import "KMClinicRemindDetailVC.h"
#import "KMImageTitleButton.h"
#import "CustomIOSAlertView.h"
#import "KMRemindUpdateModel.h"
#import "KMRemindModel.h"
#import "MJExtension.h"
#define kEdgeOffset         10      // 控制边距
#define kTextFieldHeight    35      // 中间每个控件的高度
#define KButtonHeight       50      // 最下面两个按钮的高度

@interface KMClinicRemindDetailVC ()
/**
 *  回诊功能开关
 */
@property (nonatomic, strong) UISwitch *mySwitch;
/**
 *  周一 ~ 周日
 */
@property (nonatomic, strong) NSArray *repeatTitle;
/**
 *  日期和时间弹出窗口
 */
@property (nonatomic, strong) CustomIOSAlertView *alertView;
/**
 *  提醒时间
 */
@property (nonatomic, strong) NSDate *remindTime;

@end

@implementation KMClinicRemindDetailVC

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor whiteColor];
    
    [self initDataArray];
    [self configNavBar];
    [self configView];
}

- (void)initDataArray
{
    self.remindTime = [NSDate dateWithTimeIntervalSince1970:self.remindModel.remindTime/1000.0];

    self.repeatTitle = @[kLoadStringWithKey(@"Remind_week_week1"),
                         kLoadStringWithKey(@"Remind_week_week2"),
                         kLoadStringWithKey(@"Remind_week_week3"),
                         kLoadStringWithKey(@"Remind_week_week4"),
                         kLoadStringWithKey(@"Remind_week_week5"),
                         kLoadStringWithKey(@"Remind_week_week6"),
                         kLoadStringWithKey(@"Remind_week_week7")];
}

- (void)configNavBar
{
    if ([self.key isEqualToString:@"clinic"]) {
        self.navigationItem.title = kLoadStringWithKey(@"RemindSettingVC_clinic");
    } else {
        self.navigationItem.title = kLoadStringWithKey(@"RemindSettingVC_medical");
    }
}

- (void)configView
{
    WS(ws);

    UIScrollView *scrollView = [UIScrollView new];
    scrollView.showsVerticalScrollIndicator = NO;
    scrollView.showsHorizontalScrollIndicator = NO;
    scrollView.backgroundColor = [UIColor whiteColor];
    [self.view addSubview:scrollView];
    [scrollView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.equalTo(ws.view).with.insets(UIEdgeInsetsMake(kEdgeOffset, kEdgeOffset, KButtonHeight + kEdgeOffset, kEdgeOffset));
    }];

    UIView *container = [UIView new];
    container.tag = 1000;
    [scrollView addSubview:container];
    [container mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.equalTo(scrollView);
        make.width.equalTo(scrollView);
    }];
    
    UILabel *startLabel = [[UILabel alloc] init];
    startLabel.text = kLoadStringWithKey(@"Remind_Start");
    startLabel.font = [UIFont boldSystemFontOfSize:18];
    [container addSubview:startLabel];
    [startLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(@(kEdgeOffset*2));
        make.top.equalTo(@kEdgeOffset);
    }];
    
    self.mySwitch = [[UISwitch alloc] init];
    self.mySwitch.on = self.remindModel.enable;
    [self.mySwitch addTarget:self
                      action:@selector(switchDidClick:)
            forControlEvents:UIControlEventValueChanged];
    [container addSubview:self.mySwitch];
    [self.mySwitch mas_makeConstraints:^(MASConstraintMaker *make) {
        make.right.equalTo(@(-kEdgeOffset*2));
        make.centerY.equalTo(startLabel);
    }];
    
    UIView *grayLineView = [UIView new];
    grayLineView.backgroundColor = [UIColor grayColor];
    [container addSubview:grayLineView];
    [grayLineView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(@kEdgeOffset);
        make.height.equalTo(@1);
        make.right.equalTo(@(-kEdgeOffset));
        make.top.equalTo(startLabel.mas_bottom).offset(kEdgeOffset*2);
    }];

    // 时间标签
    UILabel *timeLabel = [[UILabel alloc] init];
    timeLabel.text = kLoadStringWithKey(@"Remind_Time");
    timeLabel.font = [UIFont boldSystemFontOfSize:18];
    [container addSubview:timeLabel];
    [timeLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(@(kEdgeOffset*2));
        make.top.equalTo(grayLineView.mas_bottom).offset(kEdgeOffset*2);
    }];
    //设置label1的content hugging 为1000
    [timeLabel setContentHuggingPriority:UILayoutPriorityRequired
                                 forAxis:UILayoutConstraintAxisHorizontal];
    //设置label1的content compression 为1000
    [timeLabel setContentCompressionResistancePriority:UILayoutPriorityRequired
                                               forAxis:UILayoutConstraintAxisHorizontal];

    // 日期选择按钮
    UIButton *dateButton = [UIButton buttonWithType:UIButtonTypeCustom];
    dateButton.tag = 200;
    NSDate *date = [NSDate dateWithTimeIntervalSince1970:self.remindModel.remindTime/1000.0];
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    [formatter setDateFormat:@"yyyy-MM-dd E a h:mm"];
    NSString *dateString = [formatter stringFromDate:date];
    [dateButton setTitle:dateString forState:UIControlStateNormal];
    [dateButton setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    [dateButton addTarget:self action:@selector(dateBtnDidClicked:) forControlEvents:UIControlEventTouchUpInside];
    [container addSubview:dateButton];
    [dateButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(timeLabel.mas_right);
        make.right.equalTo(container);
        make.centerY.equalTo(timeLabel);
    }];

    UIView *grayLineView1 = [UIView new];
    grayLineView1.backgroundColor = [UIColor grayColor];
    [container addSubview:grayLineView1];
    [grayLineView1 mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(@kEdgeOffset);
        make.height.equalTo(@1);
        make.right.equalTo(@(-kEdgeOffset));
        make.top.equalTo(timeLabel.mas_bottom).offset(kEdgeOffset*2);
    }];

    // 重复提醒标签
    UILabel *repeatLabel = [[UILabel alloc] init];
    repeatLabel.text = kLoadStringWithKey(@"Remind_repeat");
    repeatLabel.font = [UIFont boldSystemFontOfSize:18];
    [container addSubview:repeatLabel];
    [repeatLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(startLabel);
        make.top.equalTo(grayLineView1.mas_bottom).offset(kEdgeOffset*2);
    }];

    UIView *grayLineView2 = [UIView new];
    grayLineView2.backgroundColor = [UIColor grayColor];
    [container addSubview:grayLineView2];
    [grayLineView2 mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(@kEdgeOffset);
        make.height.equalTo(@1);
        make.right.equalTo(@(-kEdgeOffset));
        make.top.equalTo(repeatLabel.mas_bottom).offset(kEdgeOffset*2);
    }];

    UIView *tempView = grayLineView2;
    for (int i = 0; i < self.repeatTitle.count; i++) {
        UIButton *selectButton = [UIButton buttonWithType:UIButtonTypeCustom];
        selectButton.tag = 2000+i;
        [selectButton setImage:[UIImage imageNamed:@"omg_login_btn_circle"] forState:UIControlStateNormal];
        [selectButton setImage:[UIImage imageNamed:@"omg_login_btn_circle_onclick"] forState:UIControlStateSelected];
        selectButton.imageView.contentMode = UIViewContentModeScaleAspectFit;
        selectButton.imageEdgeInsets = UIEdgeInsetsMake(5, 0, 5, 0);
        [selectButton setTitle:self.repeatTitle[i] forState:UIControlStateNormal];
        [selectButton setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
        [selectButton addTarget:self action:@selector(weekButtonDidClicked:) forControlEvents:UIControlEventTouchUpInside];
        // 设置按钮的默认状态
        selectButton.selected = [self buttonStateWithIndex:i];
        [container addSubview:selectButton];
        [selectButton mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.equalTo(startLabel).offset(-5);
            make.height.equalTo(@30);
            if (i == 0) {
                make.top.equalTo(tempView.mas_bottom).offset(kEdgeOffset*2);
            } else {
                make.top.equalTo(tempView.mas_bottom).offset(5);
            }
        }];

        tempView = selectButton;
    }

    [container mas_makeConstraints:^(MASConstraintMaker *make) {
        make.bottom.equalTo(tempView.mas_bottom);
    }];

    UIView *view = [[UIView alloc] init];
    view.backgroundColor = [UIColor grayColor];
    [self.view addSubview:view];
    [view mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.right.bottom.equalTo(ws.view);
        make.height.equalTo(@(KButtonHeight + 1));
    }];

    // 最下面的确认和取消
    KMImageTitleButton *OKBtn = [[KMImageTitleButton alloc] initWithImage:[UIImage imageNamed:@"omg_login_btn_confirm_icon"]
                                                                    title:NSLocalizedStringFromTable(@"Reg_VC_birthday_OK", APP_LAN_TABLE, nil)];
    OKBtn.tag = 100;
    OKBtn.label.font = [UIFont systemFontOfSize:25];
    [OKBtn setBackgroundImage:[UIImage imageNamed:@"omg_login_btn_confirm"]
                     forState:UIControlStateNormal];
    [OKBtn addTarget:self
              action:@selector(okAndCancelBtnDidClicked:)
    forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:OKBtn];
    [OKBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(ws.view);
        make.bottom.equalTo(ws.view);
        make.right.equalTo(ws.view.mas_centerX).offset(-.5);
        make.height.equalTo(@KButtonHeight);
    }];

    KMImageTitleButton *CancelBtn = [[KMImageTitleButton alloc] initWithImage:[UIImage imageNamed:@"omg_register_btn_cancel_icon"]
                                                                        title:NSLocalizedStringFromTable(@"Reg_VC_birthday_cancel", APP_LAN_TABLE, nil)];
    CancelBtn.tag = 101;
    CancelBtn.label.font = [UIFont systemFontOfSize:25];
    [CancelBtn setBackgroundImage:[UIImage imageNamed:@"omg_login_btn_register"]
                         forState:UIControlStateNormal];
    [CancelBtn addTarget:self
                  action:@selector(okAndCancelBtnDidClicked:)
        forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:CancelBtn];
    [CancelBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.right.equalTo(ws.view);
        make.bottom.equalTo(ws.view);
        make.left.equalTo(ws.view.mas_centerX).offset(0.5);
        make.height.equalTo(@(KButtonHeight));
    }];
}

/**
 *  bit0为周日
 *  bit1 ~ bit6 -> 周一到周六
 *
 *  @param index 周一到周日(0-6)
 *
 *  @return 是否选中
 */
- (BOOL)buttonStateWithIndex:(int)index
{
    if (index < 6) {        // 周一到周六
        return (self.remindModel.repeat & (1 << (index + 1))) == 0 ? NO : YES;
    } else {
        return (self.remindModel.repeat & 0x01) == 0 ? NO : YES;
    }
}

/**
 *  根据index取出对应的button
 *
 *  @param index 序号（0-6）
 *
 *  @return UIButton对象
 */
- (UIButton *)choseButtonWithIndex:(int)index
{
    UIView *container = [self.view viewWithTag:1000];
    return [container viewWithTag:2000+index];
}

- (void)switchDidClick:(UISwitch *)mSwitch
{
    BOOL state = mSwitch.isOn;
    NSLog(@"state = %d", state);
}

#pragma mark - 重复提醒选择按钮
- (void)weekButtonDidClicked:(UIButton *)sender
{
    sender.selected = !sender.selected;
}

#pragma mark - 完成和取消(100- OK, 101 - Cancel)
- (void)okAndCancelBtnDidClicked:(UIButton *)sender
{
    switch (sender.tag) {
        case 100:           // 确认
        {
            KMRemindModel *remindModel = [[KMRemindModel alloc] init];
            remindModel.enable = self.mySwitch.isOn;
            remindModel.sequence = self.sequence;
            remindModel.updateTime = (long long)([NSDate date].timeIntervalSince1970*1000);
            remindModel.remindTime = (long long)(self.remindTime.timeIntervalSince1970*1000);
            for (int i = 0; i < 6; i++) {
                if ([self choseButtonWithIndex:i].selected) {
                    remindModel.repeat |= (1 << (i + 1));
                }
            }
            if ([self choseButtonWithIndex:6].selected) {
                remindModel.repeat |= 0x01;
            }

            KMRemindUpdateModel *updateModel = [[KMRemindUpdateModel alloc] init];
            updateModel.id = member.userModel.id;
            updateModel.key = member.userModel.key;
            updateModel.target = self.imei;
            if ([self.key isEqualToString:@"clinic"]) {
                updateModel.clinic = @[remindModel];
            } else {
                updateModel.medical = @[remindModel];
            }

            NSString *json = [updateModel mj_JSONString];
            [self updateInfoToServer:json];
            // 发送请求
        } break;
        case 101:           // 取消
        {
            [self.navigationController popViewControllerAnimated:YES];
        } break;
        default:
            break;
    }
}

- (void)updateInfoToServer:(NSString *)content
{
    WS(ws);

    [SVProgressHUD showWithStatus:kLoadStringWithKey(@"Common_network_request_now")];
    NSString *key = nil;
    if ([self.key isEqualToString:@"clinic"]) {
        key = @"updateClinic";
    } else {
        key = @"updateMedical";
    }
//    [[KMNetAPI manager] updateRemindInfoWithKey:key
//                                        Content:content
//                                          block:^(int code, NSString *res) {
//                                              KMNetworkResModel *resModel = [KMNetworkResModel mj_objectWithKeyValues:res];
//                                              if (code == 0 && resModel.errorCode == kNetReqSuccess) {
//                                                  [SVProgressHUD showSuccessWithStatus:kLoadStringWithKey(@"Common_save_success")];
//                                                  dispatch_after(dispatch_time(DISPATCH_TIME_NOW, 1.0*NSEC_PER_SEC), dispatch_get_main_queue(), ^{
//                                                      [ws.navigationController popViewControllerAnimated:YES];
//                                                  });
//                                              } else {
//                                                  [SVProgressHUD showSuccessWithStatus:kLoadStringWithKey(@"Common_network_request_fail")];
//                                              }
//                                          }];
}

#pragma mark - 提醒的日期和时间选择
- (void)dateBtnDidClicked:(UIButton *)sender
{
    UIView *view = [[UIView alloc] initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, 250)];
    UILabel *titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, 40)];
    titleLabel.textAlignment = NSTextAlignmentCenter;

    titleLabel.text = kLoadStringWithKey(@"Remind_date");

    titleLabel.font = [UIFont boldSystemFontOfSize:20];
    [view addSubview:titleLabel];

    UIDatePicker *datePicker = [[UIDatePicker alloc] initWithFrame:CGRectMake(0, 40, SCREEN_WIDTH, 210)];
    datePicker.tag = 1000;
    datePicker.datePickerMode = UIDatePickerModeDateAndTime;

    datePicker.minimumDate = [NSDate date];
    [view addSubview:datePicker];
    self.alertView = [[CustomIOSAlertView alloc] init];
    self.alertView.containerView = view;
    self.alertView.containerView.backgroundColor = [UIColor whiteColor];
    // 取消 确认
    self.alertView.buttonTitles = @[kLoadStringWithKey(@"Common_cancel"), kLoadStringWithKey(@"Common_OK")];
    WS(ws);
    [self.alertView setOnButtonTouchUpInside:^(CustomIOSAlertView *alertView, int buttonIndex) {
        if (buttonIndex == 1) {
            [ws updateTimeButtonsWithDate:datePicker.date];
        }
    }];
    [self.alertView setUseMotionEffects:NO];
    [self.alertView show];
}

- (void)updateTimeButtonsWithDate:(NSDate *)date
{
    self.remindTime = date;
    UIView *container = [self.view viewWithTag:1000];
    UIButton *dateButton = [container viewWithTag:200];

    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    [formatter setDateFormat:@"yyyy-MM-dd EEE a h:mm"];
    NSString *dateString = [formatter stringFromDate:date];
    [dateButton setTitle:dateString forState:UIControlStateNormal];
}

@end
