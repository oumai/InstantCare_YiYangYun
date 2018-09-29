//
//  KMHealthRecordVC.m
//  InstantCare
//
//  Created by bruce-zhu on 15/12/1.
//  Copyright © 2015年 omg. All rights reserved.
//
#import "KMHealthRecordVC.h"
#import "PNChart.h"
#import "KMNetworkResModel.h"
#import "KMBPModel.h"
#import "KMBSModel.h"
#import "KMHRModel.h"
#import "KMBOModel.h"
#import "KMStepModel.h"
#import "KMSleepQAModel.h"
#import "KMChangeDateVC.h"
#import "KMBundleDevicesModel.h"
#import "KMBindDeviceListVC.h"
#import "KMCircleTextView.h"
#import "KMHealthRecordsDateModel.h"
#import "KMDeviceSettingVC.h"
#import "KMCommonAlertView.h"
#import "KMImageTwoRightTextView.h"
#import "KMChangeSingleDateVC.h"
#import <MapKit/MapKit.h>
#import "KMPNBarChart.h"
#import "MJExtension.h"
#import "UIImage+Extension.h"
#import "NSString+Extension.h"
#import "UIImageView+SDWebImage.h"
#import "KMNetAPI.h"


// 数字字体大小
#define kDigitalFontSize    15
#define kReferenceFontSize    11

#define kButtonHeight       40
//#define kButtonWidth        (SCREEN_WIDTH/6.0)
#define kEdgeOffset         10

// 收缩压上限(mmHg)
#define khPressMaxValue     139
// 收缩压下限(mmHg)
#define khPressMinValue     90

// 舒张压上限(mmHg)
#define klPressMaxValue     89
// 舒张压下限(mmHg)
#define klPressMinValue     60

// 脉搏
#define kPluseMinValue      60
#define kPluseMaxValue      100

// 每个图表最多显示几笔数据
#define kMaxShowNum         7

// 血糖正常范围（72~124mg/dl）
#define kBSMinValue         72
#define kBSMaxValue         124

// 心率范围(60-100次/分钟)
#define kHRMinValue         60
#define kHRMaxValue         100

// 血氧(94~100%)
#define kBOMinValue         94
#define kBOMaxValue         100

// 7493dc
#define khPressColor        RGB(0x74, 0x93, 0xdc)
// 2dc0cb
#define klPressColor        RGB(0x2d, 0xc0, 0xcb)

//3F52DF
#define deepSleepColor  RGB(0x3F,0x52,0xDF)

//描述点颜色
#define kdescriptionColor  RGB(0x74, 0x93, 0xdc)

// 数据曲线数字字体大小
#define kPointsLabelFontSize      10

typedef NS_ENUM(NSInteger, KMHealthRecordType) {
    KM_HEALTH_BP = 1000,    // 血压
    KM_HEALTH_BS,           // 血糖
    KM_HEALTH_HR,           // 心率
    KM_HEALTH_BO,           // 血氧
    KM_HEALTH_STEP,         // 记步
    KM_HEALTH_SLEEPANALYSE  //睡眠质量分析
};

typedef NS_ENUM(NSInteger, KMBSUnitType) {
    KM_BS_UNIT_MMOL,        // mmol/L
    KM_BS_UNIT_MG           // mg/dL
};

@interface KMHealthRecordVC() <PNChartDelegate, KMChangeDateDelegate,KMChangeSingleDateDelegate,KMBindDeviceListVCDelegate, UIScrollViewDelegate>
/**
 *  用户头像
 */
@property (nonatomic, strong) UIImageView *userImageView;
/**
 *  用户名
 */
@property (nonatomic, strong) UILabel *userNameLabel;
/**
 *  最后测量时间
 */
@property (nonatomic, strong) UILabel *lastTimeLabel;
/**
 *  iPhone 4s需要滑动显示
 */
@property (nonatomic, strong) UIScrollView *scrollView;
/**
 *  设备列表模型
 */
@property (nonatomic, strong) KMBundleDevicesModel *deviceListModel;
/**
 *  进入此VC默认选择第一个设备
 */
@property (nonatomic, strong) KMBundleDevicesDetailModel *deviceDetailModel;
/**
 *  血压
 */
@property (nonatomic, strong) KMBPModel *BPModel;
/**
 *  血糖
 */
@property (nonatomic, strong) KMBSModel *BSModel;
/**
 *  心率
 */
@property (nonatomic, strong) KMHRModel *HRModel;
/**
 *  血氧
 */
@property (nonatomic, strong) KMBOModel *BOModel;
/**
 *  记步
 */
@property (nonatomic, strong) KMStepModel *stepModel;

/**
 *  睡眠质量分析
 */
@property (nonatomic, strong) KMSleepQAModel* sleepQAModel;

/**
 *  血压
 */
@property (nonatomic, strong) UIScrollView *BPView;

/**
 *  血糖
 */
@property (nonatomic, strong) UIScrollView *BSView;

/**
 *  心率
 */
@property (nonatomic, strong) UIScrollView *HRView;

/**
 *  计步
 */
@property (nonatomic, strong) UIView *StepView;

/**
 *  睡眠质量分析
 */
@property (nonatomic, strong) UIView *SleepAnalysisView;

/**
 *  血氧
 */
@property (nonatomic, strong) UIScrollView *BOView;

// BP h
@property (nonatomic, strong) KMCircleTextView *BPhTextView;

@property (nonatomic, strong) UILabel *BPhCurrentLabel;

// BP l
@property (nonatomic, strong) KMCircleTextView *BPlTextView;

@property (nonatomic, strong) UILabel *BPlCurrentLabel;

@property (nonatomic, strong) UILabel *pluseCurrentLabel;

/**
 *  血糖BS
 */
@property (nonatomic, assign) KMBSUnitType BSUnitType;

@property (nonatomic, strong) KMCircleTextView *BSTextView;

@property (nonatomic, strong) UILabel *BSCurrentLabel;

@property (nonatomic, strong) UILabel *BSRangeLabel;

@property (nonatomic, strong) UILabel *BSUnitLabel;

/**
 *  心率HR
 */
@property (nonatomic, strong) KMCircleTextView *HRTextView;

@property (nonatomic, strong) UILabel *HRCurrentLabel;

/**
 *  记步
 */
@property (nonatomic, strong) KMCircleTextView *stepTextView;
@property (nonatomic, strong) UILabel *stepCurrentLabel;
@property (nonatomic, strong) UILabel *calCurrentLabel;
@property (nonatomic, strong) UILabel *disCurrentLabel;

/**
 *  血氧
 */
@property (nonatomic, strong) KMCircleTextView *boTextView;
@property (nonatomic, strong) UILabel *boCurrentLabel;

/**
 *  切换设备按钮
 */
@property (nonatomic, strong) UIButton *rightNavBtn;
/**
 *  最后量测时间
 */
@property (nonatomic, copy) NSString * bpLastMeasureDate;
@property (nonatomic, strong) NSString * bsLastMeasureDate;
@property (nonatomic, strong) NSString * hrLastMeasureDate;
@property (nonatomic, strong) NSString * stepLastMeasureDate;
@property (nonatomic, strong) NSString * boLastMeasureDate;
@property (nonatomic, strong) NSString * sleepQAMeasureDate;

/**
 *  通过日期来拉取数据
 */
@property (nonatomic, strong) KMHealthRecordsDateModel *dateModel;

@property (nonatomic,strong) CustomIOSAlertView *addNewDeviceAlertView;

// 导航按钮数目
@property (nonatomic,assign) NSUInteger navigationButtonCount ;
@property (nonatomic,strong) NSArray* defaultTitleArray;

/**
 *  提示框
 */
@property(nonatomic,strong)CustomIOSAlertView * userAction;
/**
 *  x轴View
 */
@property (nonatomic,weak) UIView *xLineView;
/**
 *  y轴View
 */
@property (nonatomic,weak) UIView *yLineView;
/**
 *  XY轴显示的视图
 */
@property (nonatomic,weak) PNLineChart *lineChart;
/**
 *  XY轴的坐标
 */
@property (nonatomic,assign) CGPoint point;

@property (nonatomic,copy) NSString *currentLanguage;

@end

@implementation KMHealthRecordVC

-(void)dealloc{
    [[NSNotificationCenter defaultCenter] removeObserver:self name:@"kmIMHRNotification" object:nil];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    
    self.defaultTitleArray = @[kLoadStringWithKey(@"HealthRecord_VC_blood_pressure"),
                               kLoadStringWithKey(@"HealthRecord_VC_blood_sugar"),
                               kLoadStringWithKey(@"HealthRecord_VC_heart_rate"),
                               kLoadStringWithKey(@"HealthRecord_VC_bo"),
                               kLoadStringWithKey(@"HealthRecord_VC_pedometer")];
    
    [self updateDeviceListFromServer];
    
    [self configNavBar];
    [self configView];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(updateDeviceListFromServerForNotifaction:) name:@"kmIMHRNotification" object:nil];
    
}

-(void)updateDeviceListFromServerForNotifaction:(NSNotification*)notify{
    NSDictionary *userInfo = notify.object;
    
    if (userInfo) {
        self.pushModel = [KMPushMsgModel mj_objectWithKeyValues:userInfo];
    }
    [self updateDeviceListFromServer];
}

- (void)configNavBar
{
    UIButton *leftBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    [leftBtn setBackgroundImage:[UIImage imageNamed:@"return_normal"]
                       forState:UIControlStateNormal];
    [leftBtn addTarget:self
                action:@selector(backBarButtonDidClicked:)
      forControlEvents:UIControlEventTouchUpInside];
    leftBtn.frame = CGRectMake(0, 0, 30, 30);
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:leftBtn];
    
    self.rightNavBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    self.rightNavBtn.layer.cornerRadius = 15;
    self.rightNavBtn.clipsToBounds = YES;
    [self.rightNavBtn setBackgroundImage:[UIImage imageNamed:@"pick_normal"]
                                forState:UIControlStateNormal];
    [self.rightNavBtn addTarget:self
                         action:@selector(rightBarButtonDidClicked:)
               forControlEvents:UIControlEventTouchUpInside];
    self.rightNavBtn.frame = CGRectMake(0, 0, 30, 30);
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:self.rightNavBtn];
    
    self.navigationItem.title = kLoadStringWithKey(@"MAIN_VC_health_btn");
}

- (void)configView
{
    self.view.backgroundColor = [UIColor whiteColor];
    
    // 头像
    self.userImageView = [UIImageView new];
    self.userImageView.backgroundColor = [UIColor grayColor];
    self.userImageView.layer.cornerRadius = 25;
    self.userImageView.clipsToBounds = YES;
    [self.view addSubview:self.userImageView];
    [self.userImageView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.view).offset(20);
        make.top.equalTo(self.view).offset(IS_IPHONE_X ? 103 : 79 );
        make.width.height.equalTo(@50);
    }];
    
    // 最后更新时间
    self.lastTimeLabel = [UILabel new];
    [self.view addSubview:self.lastTimeLabel];
    [self.lastTimeLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.view.mas_centerX).offset(10);
        make.top.equalTo(self.userImageView.mas_centerY).offset(2);
        make.right.mas_equalTo(-5);
    }];
    self.lastTimeLabel.adjustsFontSizeToFitWidth = YES;
    
    // 用户名
    self.userNameLabel = [UILabel new];
    [self.view addSubview:self.userNameLabel];
    [self.userNameLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.userImageView.mas_right).offset(10);
        make.right.equalTo(_lastTimeLabel.mas_left).offset(-5);
        make.centerY.equalTo(self.userImageView);
    }];
    
    // 没有请求到数据时显示当前时间
    NSDate *newdate = [NSDate date];
    NSDateFormatter *dateFormatter = [NSDateFormatter new];
    [dateFormatter setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
    self.lastTimeLabel.text = [dateFormatter stringFromDate:newdate];
    
    UILabel *lastLabel = [UILabel new];
    lastLabel.text = kLoadStringWithKey(@"HealthRecord_VC_last_time");
    lastLabel.textColor = kGrayContextColor;
    [self.view addSubview:lastLabel];
    [lastLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(_lastTimeLabel);
        make.bottom.equalTo(self.userImageView.mas_centerY).offset(-2);
        make.right.mas_equalTo(0);
    }];
    [lastLabel setAdjustsFontSizeToFitWidth:YES];
    MASViewAttribute *tempViewAttribute = self.view.mas_left;
    
    NSMutableArray* titleMutableArray = [NSMutableArray arrayWithArray:self.defaultTitleArray ];
    if([_deviceDetailModel.type isEqualToString:@"20"]){
        [titleMutableArray addObject:kLoadStringWithKey(@"HealthRecord_VC_sleepAnalysis")];
    }
    
    self.navigationButtonCount = titleMutableArray.count;
    
    for (int i = 0; i < self.navigationButtonCount; i++) {
        UIButton *bpBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        
        bpBtn.tag = KM_HEALTH_BP + i;
        if (i == 0) bpBtn.selected = YES;
        bpBtn.titleLabel.font = [UIFont systemFontOfSize:15];
        [bpBtn setBackgroundImage:[UIImage imageWithColor:kGrayBackColor] forState:UIControlStateNormal];
        [bpBtn setBackgroundImage:[UIImage imageWithColor:kBuleColor] forState:UIControlStateSelected];
        [bpBtn setTitle: titleMutableArray [i] forState:UIControlStateNormal];
        [bpBtn setTitle: titleMutableArray [i] forState:UIControlStateSelected];
        [bpBtn setTitleColor:kGrayTipColor forState:UIControlStateNormal];
        [bpBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateSelected];
        [bpBtn addTarget:self action:@selector(healthBtnDidClicked:) forControlEvents:UIControlEventTouchUpInside];
        [self.view addSubview:bpBtn];
        NSUInteger buttonWidth = (SCREEN_WIDTH/self.navigationButtonCount);
        [bpBtn mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.equalTo(tempViewAttribute);
            make.width.equalTo(@(buttonWidth));
            make.height.equalTo(@(kButtonHeight));
            make.top.equalTo(self.userImageView.mas_bottom).offset(15);
        }];
        
        tempViewAttribute = bpBtn.mas_right;
    }
    
    NSUInteger navigationButtonCount = titleMutableArray.count;
    
    CGFloat startY = (IS_IPHONE_X ? 88 : 64)+15+50+15+kButtonHeight;
    CGFloat scrollViewHeight = (SCREEN_HEIGHT- startY -kButtonHeight);
    CGRect frame = CGRectMake(0, startY, SCREEN_WIDTH, scrollViewHeight);
    _scrollView = [[UIScrollView alloc] initWithFrame:frame];
    _scrollView.contentSize = CGSizeMake(SCREEN_WIDTH*navigationButtonCount, 0);
    _scrollView.showsVerticalScrollIndicator = YES;
    _scrollView.showsHorizontalScrollIndicator = YES;
    _scrollView.scrollEnabled = NO;
    _scrollView.pagingEnabled = YES;
    _scrollView.delegate = self;
    [self.view addSubview:_scrollView];
    
    // 底部改变日期按钮
    UIButton *bottomChangeDateButton = [UIButton buttonWithType:UIButtonTypeCustom];
    bottomChangeDateButton.tag = 10000;
    [bottomChangeDateButton setTitle:kLoadStringWithKey(@"HealthRecord_VC_change_date")
                            forState:UIControlStateNormal];
    bottomChangeDateButton.titleLabel.font = [UIFont systemFontOfSize:18];
    [bottomChangeDateButton setBackgroundImage:[UIImage imageWithColor:kMainColor] forState:UIControlStateNormal];
    [bottomChangeDateButton addTarget:self
                               action:@selector(changeMeasureDateWithIndex:)
                     forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:bottomChangeDateButton];
    [bottomChangeDateButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.right.bottom.equalTo(self.view);
        make.height.equalTo(@(IS_IPHONE_X ? 74 : 40));
    }];
}

-(void)refreshView{
    [self removeAllSubviews];
    [self configView];
}

- (void)removeAllSubviews {
    while (self.view.subviews.count) {
        UIView* child = self.view.subviews.lastObject;
        [child removeFromSuperview];
    }
}

- (KMHealthRecordsDateModel *)dateModel {
    if (_dateModel) return _dateModel;
    
    _dateModel = [[KMHealthRecordsDateModel alloc] init];
    return _dateModel;
}

#pragma mark - 血压
- (UIView *)BPView {
    [_BPView removeFromSuperview];
    
    _BPView = [[UIScrollView alloc] initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, _scrollView.frame.size.height)];
    _BPView.pagingEnabled = YES;
    
    CGFloat viewWidth = SCREEN_WIDTH-2*kEdgeOffset;
    CGRect frame = CGRectMake(kEdgeOffset, kEdgeOffset, viewWidth, _scrollView.frame.size.height - kEdgeOffset);
    UIView *contentView = [[UIView alloc] initWithFrame:frame];
    
    [_BPView addSubview:contentView];
    
    // 如果没有信息，提示
    if (_BPModel.list.count == 0) {
        UILabel *noDataLabel = [UILabel new];
        noDataLabel.text = kLoadStringWithKey(@"HealthRecord_VC_no_records");
        noDataLabel.font = [UIFont systemFontOfSize:22];
        noDataLabel.textAlignment = NSTextAlignmentCenter;
        noDataLabel.numberOfLines = 0;
        [contentView addSubview:noDataLabel];
        [noDataLabel mas_makeConstraints:^(MASConstraintMaker *make) {
            make.edges.equalTo(contentView).insets(UIEdgeInsetsMake(0, 20, 40, 20));
        }];
        return _BPView;
    }
    
    _BPView.contentSize = CGSizeMake(SCREEN_WIDTH*2, 0);
    
    UILabel *BPUnitLabel = [UILabel new];
    BPUnitLabel.textColor = kGrayContextColor;
    BPUnitLabel.font = [UIFont systemFontOfSize:13];
    BPUnitLabel.text = kLoadStringWithKey(@"HealthRecord_VC_blood_pressure_unit");
    [contentView addSubview:BPUnitLabel];
    [BPUnitLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.top.equalTo(contentView);
    }];
    
    NSMutableArray *dateArrayString = @[].mutableCopy;
    NSMutableArray *hPressArray = @[].mutableCopy;
    NSMutableArray *lPressArray = @[].mutableCopy;
    NSMutableArray *hPressColorArray = @[].mutableCopy;
    NSMutableArray *lPressColorArray = @[].mutableCopy;
    CGFloat yValueMax = khPressMaxValue;
    
    int maxCount = _BPModel.list.count > kMaxShowNum ? kMaxShowNum : (int)(_BPModel.list.count);
    
    for (int i = maxCount - 1; i >= 0; i--) {
        KMBPDetailModel *m = _BPModel.list[i];
        [dateArrayString addObject:[NSString stringWithDate:m.bpTime format:@"MM-dd\nHH:mm"]];
        
        [hPressArray addObject:@(m.hPressure)];
        [lPressArray addObject:@(m.lPressure)];
        
        if (m.hPressure > yValueMax) {
            yValueMax = m.hPressure;
        }
        
        if (m.hPressure >= khPressMinValue &&
            m.hPressure <= khPressMaxValue) {       // 正常
            [hPressColorArray addObject:khPressColor];
        } else {
            [hPressColorArray addObject:[UIColor redColor]];
        }
        
        if (m.lPressure >= klPressMinValue &&
            m.lPressure <= klPressMaxValue) {
            [lPressColorArray addObject:klPressColor];
        } else {
            [lPressColorArray addObject:[UIColor redColor]];
        }
    }
    
    yValueMax += 20;
    
    // For Line Chart
    PNLineChart * lineChart = [[PNLineChart alloc] initWithFrame:CGRectMake(0, 25, viewWidth, SCREEN_HEIGHT*0.4)];
    lineChart.tag = KM_HEALTH_BP;
    lineChart.dottedLines = @[@(khPressMaxValue), @(klPressMaxValue)];      // 两条虚线
    lineChart.showCoordinateAxis = YES;
    lineChart.delegate = self;
    lineChart.legendStyle = PNLegendItemStyleSerial;
    lineChart.legendFont = [UIFont systemFontOfSize:14];
    lineChart.yFixedValueMax = yValueMax;
    
    [lineChart setXLabels:dateArrayString];
    
    // Line Chart No.1
    PNLineChartData *data01 = [PNLineChartData new];
    data01.color = khPressColor;
    data01.inflexionPointStyle = PNLineChartPointStyleCircle;
    data01.inflexionPointWidth = 4;
    data01.itemCount = lineChart.xLabels.count;
    data01.showPointLabel = YES;
    data01.pointLabelFont = [UIFont systemFontOfSize:kPointsLabelFontSize];
    data01.getData = ^(NSUInteger index) {
        CGFloat yValue = [hPressArray[index] floatValue];
        PNLineChartDataItem *item = [PNLineChartDataItem dataItemWithY:yValue pointColor:hPressColorArray[index]];
        return item;
    };
    
    // Line Chart No.2
    PNLineChartData *data02 = [PNLineChartData new];
    data02.color = klPressColor;
    data02.inflexionPointStyle = PNLineChartPointStyleCircle;
    data02.inflexionPointWidth = 4;
    data02.itemCount = lineChart.xLabels.count;
    data02.showPointLabel = YES;
    data02.pointLabelFont = [UIFont systemFontOfSize:kPointsLabelFontSize];
    data02.getData = ^(NSUInteger index) {
        CGFloat yValue = [lPressArray[index] floatValue];
        return [PNLineChartDataItem dataItemWithY:yValue pointColor:lPressColorArray[index]];
    };
    
    lineChart.chartData = @[data01, data02];
    [lineChart strokeChart];
    [contentView addSubview:lineChart];
    
    UIView *bottomContainerView = [UIView new];
    [contentView addSubview:bottomContainerView];
    [bottomContainerView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.right.bottom.equalTo(contentView);
        make.top.equalTo(lineChart.mas_bottom);
    }];
    
    UIView *containView = [[UIView alloc] init];
    [contentView addSubview:containView];
    
    // 高压
    _BPhCurrentLabel = [UILabel new];
    _BPhCurrentLabel.font = [UIFont systemFontOfSize:kDigitalFontSize];
    [containView addSubview:_BPhCurrentLabel];
    [_BPhCurrentLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.equalTo(containView).multipliedBy(0.5).offset(-20);
        make.bottom.equalTo(containView).offset(-5);
    }];
    
    UILabel *BPhRangeLabel = [UILabel new];
    BPhRangeLabel.text = [NSString stringWithFormat:@"%@:%d~%d", kLoadStringWithKey(@"healthrecord_vc_reference_value"),khPressMinValue, khPressMaxValue];
    BPhRangeLabel.font = [UIFont systemFontOfSize:kReferenceFontSize];
    [containView addSubview:BPhRangeLabel];
    [BPhRangeLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.equalTo(_BPhCurrentLabel);
        make.bottom.equalTo(_BPhCurrentLabel.mas_top).offset(-5);
    }];
    
    _BPhTextView = [[KMCircleTextView alloc] init];
    _BPhTextView.text = [NSString stringWithFormat:@"%@(mmHg)",
                         kLoadStringWithKey(@"HealthRecord_VC_sbp_title")];
    //    _BPhTextView.circleColor = hPressColorArray[0];
    _BPhTextView.circleColor = khPressColor;
    [containView addSubview:_BPhTextView];
    [_BPhTextView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.equalTo(_BPhCurrentLabel);
        make.bottom.equalTo(BPhRangeLabel.mas_top).offset(-5);
        make.width.equalTo(@(_BPhTextView.frame.size.width));
        make.height.equalTo(@(_BPhTextView.frame.size.height));
    }];
    
    // 低压
    _BPlTextView = [[KMCircleTextView alloc] init];
    _BPlTextView.text = [NSString stringWithFormat:@"%@(mmHg)",
                         kLoadStringWithKey(@"HealthRecord_VC_dbp_title")] ;
    //    _BPlTextView.circleColor = lPressColorArray[0];
    _BPlTextView.circleColor = klPressColor;
    [containView addSubview:_BPlTextView];
    [_BPlTextView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.equalTo(containView);
        make.top.equalTo(_BPhTextView);
        make.width.equalTo(@(_BPlTextView.frame.size.width));
        make.height.equalTo(@(_BPlTextView.frame.size.height));
    }];
    
    UILabel *BPlRangeLabel = [UILabel new];
    BPlRangeLabel.text = [NSString stringWithFormat:@"%@:%d~%d", kLoadStringWithKey(@"healthrecord_vc_reference_value"), klPressMinValue, klPressMaxValue];
    BPlRangeLabel.font = [UIFont systemFontOfSize:kReferenceFontSize];
    [containView addSubview:BPlRangeLabel];
    [BPlRangeLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.equalTo(_BPlTextView);
        make.top.equalTo(_BPlTextView.mas_bottom).offset(5);
    }];
    
    _BPlCurrentLabel = [UILabel new];
    _BPlCurrentLabel.font = [UIFont systemFontOfSize:kDigitalFontSize];
    [containView addSubview:_BPlCurrentLabel];
    [_BPlCurrentLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.equalTo(_BPlTextView);
        make.centerY.equalTo(_BPhCurrentLabel);
    }];
    
    // 脉搏
    _pluseCurrentLabel = [UILabel new];
    _pluseCurrentLabel.font = [UIFont systemFontOfSize:kDigitalFontSize];
    [containView addSubview:_pluseCurrentLabel];
    [_pluseCurrentLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.equalTo(containView).multipliedBy(1.5).offset(20);
        make.centerY.equalTo(_BPhCurrentLabel);
    }];
    
    UILabel *pluseLabel = [UILabel new];
    pluseLabel.text = [NSString stringWithFormat:@"%@(%@)",
                       kLoadStringWithKey(@"HealthRecord_VC_pluse_title"),
                       kLoadStringWithKey(@"HealthRecord_VC_pluse_unit")];
    pluseLabel.font = [UIFont systemFontOfSize:11];
    [containView addSubview:pluseLabel];
    [pluseLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.equalTo(_pluseCurrentLabel);
        make.top.equalTo(_BPhTextView);
    }];
    
    UILabel *pluseRangeLabel = [UILabel new];
    // 60 - 100
    pluseRangeLabel.text = [NSString stringWithFormat:@"%@:%d~%d", kLoadStringWithKey(@"healthrecord_vc_reference_value"),
                            kPluseMinValue,
                            kPluseMaxValue];
    pluseRangeLabel.font = [UIFont systemFontOfSize:kReferenceFontSize];
    [containView addSubview:pluseRangeLabel];
    [pluseRangeLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.equalTo(pluseLabel);
        make.top.equalTo(BPlRangeLabel);
    }];
    
    KMBPDetailModel *m = _BPModel.list[0];
    [self BPLabelUpdateWithModel:m];
    
    [containView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.right.equalTo(contentView);
        make.top.equalTo(_BPhTextView);
        make.centerY.equalTo(bottomContainerView);
    }];
    
    // 第二页显示内容
    frame = CGRectMake(SCREEN_WIDTH + kEdgeOffset, kEdgeOffset, viewWidth, _scrollView.frame.size.height - kEdgeOffset*2);
    UIView *secContainerView = [[UIView alloc] initWithFrame:frame];
    [_BPView addSubview:secContainerView];
    
    NSString *bpTip = nil;
    NSString *bpSuggestTip = nil;
    
    // 判断血压范围
    KMBPDetailModel *detail = _BPModel.list[0];
    if (detail.hPressure > khPressMaxValue ||
        detail.lPressure > klPressMaxValue) {                            // 高血压
        bpTip = kLoadStringWithKey(@"HealthRecord_VC_hBP");
        bpSuggestTip = kLoadStringWithKey(@"HealthRecord_VC_hBP_Suggest");
    } else if (detail.hPressure < khPressMinValue ||
               detail.lPressure < klPressMinValue) {                     // 低血压
        bpTip = kLoadStringWithKey(@"HealthRecord_VC_lBP");
        bpSuggestTip = kLoadStringWithKey(@"HealthRecord_VC_lBP_Suggest");
    } else {                                                // 正常血压
        bpTip = kLoadStringWithKey(@"HealthRecord_VC_okBP");
        bpSuggestTip = kLoadStringWithKey(@"HealthRecord_VC_okBP_Suggest");
    }
    
    // 第二页标题
    UILabel *bpTipLabel = [[UILabel alloc] init];
    bpTipLabel.text = bpTip;
    bpTipLabel.backgroundColor = [UIColor whiteColor];
    bpTipLabel.numberOfLines = 0;
    bpTipLabel.font = [UIFont boldSystemFontOfSize:18];
    [secContainerView addSubview:bpTipLabel];
    [bpTipLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.right.top.equalTo(secContainerView).insets(UIEdgeInsetsMake(20, 30, 20, 30));
    }];
    
    UIScrollView *bpSuggestScrollView = [[UIScrollView alloc] init];
    bpSuggestScrollView.backgroundColor = kGrayBackColor;
    [secContainerView addSubview:bpSuggestScrollView];
    [bpSuggestScrollView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.right.bottom.equalTo(secContainerView).insets(UIEdgeInsetsMake(0, -kEdgeOffset, -kEdgeOffset, -kEdgeOffset));
        make.top.equalTo(bpTipLabel.mas_bottom).offset(30);
    }];
    
    // 可以滑动的Label，文字可能比较多，需要加在UIScrollView上面
    UILabel *bpSuggestTipLabel = [[UILabel alloc] init];
    bpSuggestTipLabel.text = bpSuggestTip;
    bpSuggestTipLabel.numberOfLines = 0;
    bpSuggestTipLabel.font = [UIFont systemFontOfSize:18];
    [bpSuggestScrollView addSubview:bpSuggestTipLabel];
    [bpSuggestTipLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(bpSuggestScrollView).offset(2*kEdgeOffset);
        make.top.equalTo(bpSuggestScrollView).offset(kEdgeOffset);
        make.width.equalTo(@(SCREEN_WIDTH-4*kEdgeOffset));
    }];
    CGRect textRect = [bpSuggestTipLabel textRectForBounds:CGRectMake(0, 0, SCREEN_WIDTH-4*kEdgeOffset, MAXFLOAT) limitedToNumberOfLines:0];
    
    bpSuggestScrollView.contentSize = CGSizeMake(textRect.size.width, textRect.size.height + 2*kEdgeOffset);
    
    return _BPView;
}

#pragma mark 生成富文本
- (void)getAttriStrWithInt:(UILabel *)lab{
    NSMutableAttributedString *AttrStr = lab.attributedText.mutableCopy;
    NSDictionary *attributeDict = @{NSFontAttributeName: [UIFont systemFontOfSize:kDigitalFontSize],
                                    NSForegroundColorAttributeName: [UIColor redColor]};
    
    NSDictionary *attributeDict1 = @{NSFontAttributeName: [UIFont systemFontOfSize:kDigitalFontSize],
                                     NSForegroundColorAttributeName: [UIColor blackColor]};
    if ([self.currentLanguage isEqualToString:@"en"]) {
        [AttrStr setAttributes:attributeDict range:NSMakeRange(8, AttrStr.length -8)];
    }else{
        [AttrStr setAttributes:attributeDict range:NSMakeRange(4, AttrStr.length -4)];
    }
    
    [AttrStr setAttributes:attributeDict1 range:NSMakeRange(0, 4)];
    lab.attributedText = AttrStr;
    //    return AttrStr;
}

#pragma mark 更新血压标签
- (void)BPLabelUpdateWithModel:(KMBPDetailModel *)model {
    
    
    _BPhCurrentLabel.attributedText =[[NSMutableAttributedString alloc] initWithString:[NSString stringWithFormat:@"%@:%@",kLoadStringWithKey(@"healthrecord_vc_measure_value"), @(model.hPressure)]];
    
    _BPlCurrentLabel.attributedText =[[NSMutableAttributedString alloc] initWithString:[NSString stringWithFormat:@"%@:%@",kLoadStringWithKey(@"healthrecord_vc_measure_value"), @(model.lPressure)]];
    _pluseCurrentLabel.attributedText = [[NSMutableAttributedString alloc] initWithString:[NSString stringWithFormat:@"%@:%ld",kLoadStringWithKey(@"healthrecord_vc_measure_value"), model.puls]];
    if (model.hPressure >= khPressMinValue &&
        model.hPressure <= khPressMaxValue) {       // 正常
        _BPhTextView.circleColor = khPressColor;
        _BPhCurrentLabel.textColor = [UIColor blackColor];
    } else {
        //        _BPhTextView.circleColor = [UIColor redColor];
        _BPhTextView.circleColor = khPressColor;
        //        _BPhCurrentLabel.textColor = [UIColor redColor];
        [self getAttriStrWithInt:_BPhCurrentLabel];
    }
    
    if (model.lPressure >= klPressMinValue &&
        model.lPressure <= klPressMaxValue) {
        _BPlTextView.circleColor = klPressColor;
        _BPlCurrentLabel.textColor = [UIColor blackColor];
    } else {
        //        _BPlTextView.circleColor = [UIColor redColor];
        _BPlTextView.circleColor = klPressColor;
        //        _BPlCurrentLabel.textColor = [UIColor redColor];
        [self getAttriStrWithInt:_BPlCurrentLabel];
    }
    
    if (model.puls >= kPluseMinValue &&
        model.puls <= kPluseMaxValue) {
        _pluseCurrentLabel.textColor = [UIColor blackColor];
    } else {
        //        _pluseCurrentLabel.textColor = [UIColor redColor];
        [self getAttriStrWithInt:_pluseCurrentLabel];
    }
    
    // 动态效果
    _BPhCurrentLabel.alpha = 0;
    _BPlCurrentLabel.alpha = 0;
    _pluseCurrentLabel.alpha = 0;
    [UIView animateWithDuration:0.8 animations:^{
        _BPhCurrentLabel.alpha = 1;
        _BPlCurrentLabel.alpha = 1;
        _pluseCurrentLabel.alpha = 1;
    }];
}

#pragma mark - 血糖
- (UIScrollView *)BSView {
    [_BSView removeFromSuperview];
    
    CGFloat x = SCREEN_WIDTH;
    _BSView = [[UIScrollView alloc] initWithFrame:CGRectMake(x, 0, SCREEN_WIDTH, _scrollView.frame.size.height)];
    _BSView.pagingEnabled = YES;
    
    CGFloat viewWidth = SCREEN_WIDTH-2*kEdgeOffset;
    CGRect frame = CGRectMake(kEdgeOffset,
                              kEdgeOffset,
                              viewWidth,
                              _scrollView.frame.size.height - kEdgeOffset);
    UIView *contentView = [[UIView alloc] initWithFrame:frame];
    [_BSView addSubview:contentView];
    
    // 如果没有信息，提示
    if (_BSModel.list.count == 0) {
        UILabel *noDataLabel = [UILabel new];
        noDataLabel.text = kLoadStringWithKey(@"HealthRecord_VC_no_records");
        noDataLabel.font = [UIFont systemFontOfSize:22];
        noDataLabel.textAlignment = NSTextAlignmentCenter;
        noDataLabel.numberOfLines = 0;
        [contentView addSubview:noDataLabel];
        [noDataLabel mas_makeConstraints:^(MASConstraintMaker *make) {
            make.edges.equalTo(contentView).insets(UIEdgeInsetsMake(0, 20, 40, 20));
        }];
        return _BSView;
    };
    
    _BSView.contentSize = CGSizeMake(SCREEN_WIDTH*2, 0);
    
    // 血糖单位提示
    _BSUnitLabel = [UILabel new];
    _BSUnitLabel.textColor = kGrayContextColor;
    _BSUnitLabel.font = [UIFont systemFontOfSize:13];
    if (_BSUnitType == KM_BS_UNIT_MMOL) {
        _BSUnitLabel.text = kLoadStringWithKey(@"HealthRecord_VC_blood_sugar_unit_mmol");
    } else {
        _BSUnitLabel.text = kLoadStringWithKey(@"HealthRecord_VC_blood_sugar_unit_mg");
    }
    [contentView addSubview:_BSUnitLabel];
    
    [_BSUnitLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.top.equalTo(contentView);
        make.height.equalTo(@25);
    }];
    
    // 单位切换按钮
    UIButton *bsUnitChangeBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    bsUnitChangeBtn.layer.cornerRadius = 3;
    bsUnitChangeBtn.clipsToBounds = YES;
    bsUnitChangeBtn.titleLabel.font = [UIFont systemFontOfSize:14];
    [bsUnitChangeBtn setBackgroundImage:[UIImage imageWithColor:kMainColor] forState:UIControlStateNormal];
    [bsUnitChangeBtn setTitle:kLoadStringWithKey(@"HealthRecord_VC_blood_sugar_unit_change")
                     forState:UIControlStateNormal];
    [bsUnitChangeBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [bsUnitChangeBtn addTarget:self
                        action:@selector(BSUnitChangeBtnDidClick:)
              forControlEvents:UIControlEventTouchUpInside];
    [contentView addSubview:bsUnitChangeBtn];
    [bsUnitChangeBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.right.top.equalTo(contentView);
        make.width.equalTo(@90);
        make.height.equalTo(_BSUnitLabel);
    }];
    
    NSMutableArray *dateArrayString = @[].mutableCopy;
    NSMutableArray *bsArray = @[].mutableCopy;
    NSMutableArray *bsColorArray = @[].mutableCopy;
    CGFloat yValueMax = kBSMaxValue;
    CGFloat yValueMin = kBSMinValue;
    if (_BSUnitType == KM_BS_UNIT_MMOL) {
        yValueMax = kBSMaxValue / 18.00 + 0.05;
        yValueMin = kBSMinValue / 18.00 + 0.05;
    }
    
    int maxCount = _BSModel.list.count > kMaxShowNum ? kMaxShowNum : (int)(_BSModel.list.count);
    for (int i = maxCount-1; i >= 0; i--) {
        KMBSDetailModel *m = _BSModel.list[i];
        float glu = m.glu;
        if (_BSUnitType == KM_BS_UNIT_MMOL) {
            glu = (m.glu / 18.00) + 0.05;
        }
        [dateArrayString addObject:[NSString stringWithDate:m.bsTime format:@"MM-dd\nHH:mm"]];
        
        [bsArray addObject:@(glu)];
        
        if (glu > yValueMax) {
            yValueMax = glu;
        }
        
        if (glu < yValueMin) {
            yValueMin = glu;
        }
        
        if (m.glu >= kBSMinValue &&
            m.glu <= kBSMaxValue) {       // 正常
            [bsColorArray addObject:klPressColor];
        } else {
            [bsColorArray addObject:[UIColor redColor]];
            
        }
    }
    
    // 如果是坐标最大，为了显示上更合理，Y轴再+20或者-20
    if (_BSUnitType == KM_BS_UNIT_MMOL) {
        yValueMax +=5;
        yValueMin = 0;
    } else {
        yValueMax += 20;
        yValueMin -= 20;
        if (yValueMin < 0) {
            yValueMin = 0;
        }
    }
    
    // For Line Chart
    PNLineChart * lineChart = [[PNLineChart alloc] initWithFrame:CGRectMake(0, 25, viewWidth, SCREEN_HEIGHT*0.4)];
    lineChart.tag = KM_HEALTH_BS;
    if (_BSUnitType == KM_BS_UNIT_MMOL) {
        lineChart.dottedLines = @[@(kBSMaxValue/18.00 + 0.05), @(kBSMinValue/18.00 + 0.05)];      // 两条虚线
    } else {
        lineChart.dottedLines = @[@(kBSMaxValue), @(kBSMinValue)];      // 两条虚线
    }
    lineChart.showCoordinateAxis = YES;
    lineChart.delegate = self;
    lineChart.legendStyle = PNLegendItemStyleSerial;
    lineChart.legendFont = [UIFont systemFontOfSize:14];
    lineChart.yFixedValueMax = yValueMax;
    lineChart.yFixedValueMin = yValueMin;
    
    [lineChart setXLabels:dateArrayString];
    
    // Line Chart No.1
    PNLineChartData *data01 = [PNLineChartData new];
    data01.color = khPressColor;
    data01.inflexionPointStyle = PNLineChartPointStyleCircle;
    data01.inflexionPointWidth = 4;
    data01.itemCount = lineChart.xLabels.count;
    data01.showPointLabel = YES;
    if (_BSUnitType == KM_BS_UNIT_MMOL) {
        data01.pointLabelFormat = @"%.1f";
    }
    data01.pointLabelFont = [UIFont systemFontOfSize:kPointsLabelFontSize];
    data01.getData = ^(NSUInteger index) {
        // 直接截断，不需要四舍五入
        CGFloat yValue = floor([bsArray[index] floatValue]*10)/10.0;
        return  [PNLineChartDataItem dataItemWithY:yValue pointColor:bsColorArray[index]];
    };
    
    lineChart.chartData = @[data01];
    [lineChart strokeChart];
    [contentView addSubview:lineChart];
    
    UIView *bottomContainerView = [UIView new];
    [contentView addSubview:bottomContainerView];
    [bottomContainerView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.right.bottom.equalTo(contentView);
        make.top.equalTo(lineChart.mas_bottom);
    }];
    
    UIView *containView = [[UIView alloc] init];
    [bottomContainerView addSubview:containView];
    
    // 血糖
    _BSCurrentLabel = [UILabel new];
    _BSCurrentLabel.font = [UIFont systemFontOfSize:kDigitalFontSize];
    [containView addSubview:_BSCurrentLabel];
    [_BSCurrentLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.equalTo(containView);
        make.bottom.equalTo(containView).offset(-5);
    }];
    
    _BSRangeLabel = [UILabel new];
    _BSRangeLabel.font = [UIFont systemFontOfSize:kReferenceFontSize];
    [containView addSubview:_BSRangeLabel];
    [_BSRangeLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.equalTo(_BSCurrentLabel);
        make.bottom.equalTo(_BSCurrentLabel.mas_top).offset(-5);
    }];
    
    _BSTextView = [[KMCircleTextView alloc] init];
    if (_BSUnitType == KM_BS_UNIT_MMOL) {
        _BSTextView.text = [NSString stringWithFormat:@"%@(mmol/L)",
                            kLoadStringWithKey(@"HealthRecord_VC_blood_sugar")];
    } else {
        _BSTextView.text = [NSString stringWithFormat:@"%@(mg/dL)",
                            kLoadStringWithKey(@"HealthRecord_VC_blood_sugar")];
    }
    //    _BSTextView.circleColor = bsColorArray[0];
    _BSTextView.circleColor = kdescriptionColor;
    [containView addSubview:_BSTextView];
    [_BSTextView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.equalTo(_BSCurrentLabel);
        make.bottom.equalTo(_BSRangeLabel.mas_top).offset(-5);
        make.width.equalTo(@(_BSTextView.frame.size.width + 10));
        make.height.equalTo(@(_BSTextView.frame.size.height));
    }];
    
    // 默认显示第一个点的详细信息
    KMBSDetailModel *m = _BSModel.list[0];
    [self BSLabelUpdateWithModel:m];
    
    [containView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.right.equalTo(contentView);
        make.top.equalTo(_BSTextView);
        make.centerY.equalTo(bottomContainerView);
    }];
    
    // 第二页显示内容
    frame = CGRectMake(SCREEN_WIDTH + kEdgeOffset, kEdgeOffset, viewWidth, _scrollView.frame.size.height - kEdgeOffset*2);
    UIView *secContainerView = [[UIView alloc] initWithFrame:frame];
    [_BSView addSubview:secContainerView];
    
    NSString *bsTip = nil;
    NSString *bsSuggestTip = nil;
    
    // 判断血糖范围
    KMBSDetailModel *detail = _BSModel.list[0];
    if (detail.glu > kBSMaxValue) {                   // 高血糖
        bsTip = kLoadStringWithKey(@"HealthRecord_VC_hBS");
        bsSuggestTip = kLoadStringWithKey(@"HealthRecord_VC_hBS_Suggest");
    } else if (detail.glu < kBSMinValue) {          // 低血糖
        bsTip = kLoadStringWithKey(@"HealthRecord_VC_lBS");
        bsSuggestTip = kLoadStringWithKey(@"HealthRecord_VC_lBS_Suggest");
    } else {                                      // 正常血糖
        bsTip = kLoadStringWithKey(@"HealthRecord_VC_okBS");
        bsSuggestTip = kLoadStringWithKey(@"HealthRecord_VC_okBS_Suggest");
    }
    
    // 第二页标题
    UILabel *bpTipLabel = [[UILabel alloc] init];
    bpTipLabel.text = bsTip;
    bpTipLabel.backgroundColor = [UIColor whiteColor];
    bpTipLabel.numberOfLines = 0;
    bpTipLabel.font = [UIFont boldSystemFontOfSize:18];
    [secContainerView addSubview:bpTipLabel];
    [bpTipLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.right.top.equalTo(secContainerView).insets(UIEdgeInsetsMake(20, 30, 20, 30));
    }];
    
    UIScrollView *bpSuggestScrollView = [[UIScrollView alloc] init];
    bpSuggestScrollView.backgroundColor = kGrayBackColor;
    [secContainerView addSubview:bpSuggestScrollView];
    [bpSuggestScrollView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.right.bottom.equalTo(secContainerView).insets(UIEdgeInsetsMake(0, -kEdgeOffset, -kEdgeOffset, -kEdgeOffset));
        make.top.equalTo(bpTipLabel.mas_bottom).offset(30);
    }];
    
    // 可以滑动的Label，文字可能比较多，需要加在UIScrollView上面
    UILabel *bpSuggestTipLabel = [[UILabel alloc] init];
    bpSuggestTipLabel.text = bsSuggestTip;
    bpSuggestTipLabel.numberOfLines = 0;
    bpSuggestTipLabel.font = [UIFont systemFontOfSize:18];
    [bpSuggestScrollView addSubview:bpSuggestTipLabel];
    [bpSuggestTipLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(bpSuggestScrollView).offset(2*kEdgeOffset);
        make.top.equalTo(bpSuggestScrollView).offset(kEdgeOffset);
        make.width.equalTo(@(SCREEN_WIDTH-4*kEdgeOffset));
    }];
    CGRect textRect = [bpSuggestTipLabel textRectForBounds:CGRectMake(0, 0, SCREEN_WIDTH-4*kEdgeOffset, MAXFLOAT) limitedToNumberOfLines:0];
    
    bpSuggestScrollView.contentSize = CGSizeMake(textRect.size.width, textRect.size.height + 2*kEdgeOffset);
    
    
    return _BSView;
}

/// 保留小数一位, 直接截断，不要四舍五入
- (double)fixValueWithoutRound:(double)value {
    return floor(value*10.0)/10.0;
}

#pragma mark 更新血糖标签
- (void)BSLabelUpdateWithModel:(KMBSDetailModel *)model {
    
    if (_BSUnitType == KM_BS_UNIT_MMOL) {
        //        _BSTextView.text = [NSString stringWithFormat:@"%@(mmol/L)",kLoadStringWithKey(@"HealthRecord_VC_blood_sugar")];
        _BSCurrentLabel.attributedText = [[NSMutableAttributedString alloc] initWithString:[NSString stringWithFormat:@"%@:%.1f",kLoadStringWithKey(@"healthrecord_vc_measure_value"), [self fixValueWithoutRound:model.glu/18.00 + 0.05]]];
        _BSRangeLabel.text = [NSString stringWithFormat:@"%@:%.1f~%.1f",kLoadStringWithKey(@"healthrecord_vc_reference_value"), kBSMinValue/18.00 + 0.05, kBSMaxValue/18.00 + 0.05];
    } else {
        //        _BSTextView.text = [NSString stringWithFormat:@"%@(mg/dL)",kLoadStringWithKey(@"HealthRecord_VC_blood_sugar")];
        _BSCurrentLabel.attributedText = [[NSMutableAttributedString alloc] initWithString:[NSString stringWithFormat:@"%@:%@",kLoadStringWithKey(@"healthrecord_vc_measure_value"),@(model.glu)]];
        _BSRangeLabel.text = [NSString stringWithFormat:@"%@:%d~%d",kLoadStringWithKey(@"healthrecord_vc_reference_value"), kBSMinValue, kBSMaxValue];
    }
    
    // 服务器中统一以mg/dL为单位
    if (model.glu >= kBSMinValue &&
        model.glu <= kBSMaxValue) {       // 正常
        _BSTextView.circleColor = kdescriptionColor;
        _BSCurrentLabel.textColor = [UIColor blackColor];
    } else {
        //        _BSTextView.circleColor = [UIColor redColor];
        _BSTextView.circleColor = kdescriptionColor;
        //        _BSCurrentLabel.textColor = [UIColor redColor];
        [self getAttriStrWithInt:_BSCurrentLabel];
    }
    
    // 更新_BSTextView会改变frame，这里必须重新加入约束
    //    [_BSTextView mas_remakeConstraints:^(MASConstraintMaker *make) {
    //        make.centerX.equalTo(_BSCurrentLabel);
    //        make.bottom.equalTo(_BSRangeLabel.mas_top).offset(-5);
    //        make.width.equalTo(@(_BSTextView.frame.size.width + 10));
    //        make.height.equalTo(@(_BSTextView.frame.size.height));
    //    }];
    
    _BSCurrentLabel.alpha = .3;
    [UIView animateWithDuration:0.8 animations:^{
        _BSCurrentLabel.alpha = 1.0;
    }];
}

#pragma mark 血糖单位切换
- (void)BSUnitChangeBtnDidClick:(UIButton *)sender {
    if (_BSUnitType == KM_BS_UNIT_MMOL) {
        _BSUnitType = KM_BS_UNIT_MG;
    } else {
        _BSUnitType = KM_BS_UNIT_MMOL;
    }
    
    [_scrollView addSubview:self.BSView];
}

#pragma mark - 心率
- (UIScrollView *)HRView {
    [_HRView removeFromSuperview];
    
    CGFloat x = SCREEN_WIDTH*2;
    _HRView = [[UIScrollView alloc] initWithFrame:CGRectMake(x, 0, SCREEN_WIDTH, _scrollView.frame.size.height)];
    _HRView.pagingEnabled = YES;
    
    
    CGFloat viewWidth = SCREEN_WIDTH-2*kEdgeOffset;
    CGRect frame = CGRectMake(kEdgeOffset,
                              kEdgeOffset,
                              viewWidth,
                              _scrollView.frame.size.height - kEdgeOffset);
    UIView *contentView = [[UIView alloc] initWithFrame:frame];
    [_HRView addSubview:contentView];
    
    //过滤心率0或1
    NSMutableArray *mArr = _HRModel.list.mutableCopy;
    for (int i = 0; i < mArr.count; i++) {
        KMHRDetailModel *m = mArr[i];
        if (m.heartRate == 0 || m.heartRate == 1) {
            [mArr removeObjectAtIndex:i];
            --i;
        }
    }
    _HRModel.list = mArr.copy;
    
    // 如果没有数据记录, 显示提示信息
    if (_HRModel.list.count == 0) {
        UILabel *noDataLabel = [UILabel new];
        noDataLabel.text = kLoadStringWithKey(@"HealthRecord_VC_no_records");
        noDataLabel.font = [UIFont systemFontOfSize:22];
        noDataLabel.textAlignment = NSTextAlignmentCenter;
        noDataLabel.numberOfLines = 0;
        [contentView addSubview:noDataLabel];
        [noDataLabel mas_makeConstraints:^(MASConstraintMaker *make) {
            make.edges.equalTo(contentView).insets(UIEdgeInsetsMake(0, 20, 40, 20));
        }];
        return _HRView;
    };
    
    _HRView.contentSize = CGSizeMake(SCREEN_WIDTH*2, 0);
    
    // 心率单位
    UILabel *HRUnitLabel = [UILabel new];
    HRUnitLabel.textColor = kGrayContextColor;
    HRUnitLabel.font = [UIFont systemFontOfSize:13];
    HRUnitLabel.text = [NSString stringWithFormat:@"%@(%@)",
                        kLoadStringWithKey(@"HealthRecord_VC_heart_rate"),kLoadStringWithKey(@"HealthRecord_VC_heart_rate_unit")];
    [contentView addSubview:HRUnitLabel];
    [HRUnitLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.top.equalTo(contentView);
        make.height.equalTo(@25);
    }];
    
    //立即测试心率
    UIButton* immediateTestHRButton = [UIButton buttonWithType:UIButtonTypeSystem];
    [immediateTestHRButton setTitle:kLoadStringWithKey(@"HealthRecord_VC_heart_rate_test") forState:UIControlStateNormal];
    immediateTestHRButton.hidden = ([_deviceDetailModel.type isEqualToString:@"85"] || [_deviceDetailModel.type isEqualToString:@"1"]);
    immediateTestHRButton.layer.cornerRadius = 3;
    immediateTestHRButton.clipsToBounds = YES;
    immediateTestHRButton.titleLabel.font = [UIFont systemFontOfSize:13];
    [immediateTestHRButton setBackgroundImage:[UIImage imageWithColor:kMainColor] forState:UIControlStateNormal];
    [immediateTestHRButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [immediateTestHRButton addTarget:self action:@selector(immediateTestHR) forControlEvents:UIControlEventTouchUpInside];
    [contentView addSubview:immediateTestHRButton];
    [immediateTestHRButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.right.top.equalTo(contentView);
        make.width.equalTo(@100);
        make.height.equalTo(@25);
    }];
    
    
    NSMutableArray *dateArrayString = @[].mutableCopy;
    NSMutableArray *hrArray = @[].mutableCopy;
    NSMutableArray *hrColorArray = @[].mutableCopy;
    CGFloat yValueMax = kHRMaxValue;
    CGFloat yValueMin = kHRMinValue;
    
    
    
    int maxCount = _HRModel.list.count > kMaxShowNum ? kMaxShowNum : (int)(_HRModel.list.count);
    for (int i = maxCount - 1; i >= 0; i--) {
        KMHRDetailModel *m = _HRModel.list[i];
        if (m.bsTime > 0) {
            [dateArrayString addObject:[NSString stringWithDate:m.bsTime format:@"MM-dd\nHH:mm"]];
        } else {
            [dateArrayString addObject:[NSString stringWithDate:m.createDate format:@"MM-dd\nHH:mm"]];
        }
        
        //        DMLog(@"test == HR == %zd",m.heartRate);
        
        [hrArray addObject:@(m.heartRate)];
        
        if (m.heartRate > yValueMax) {
            yValueMax = m.heartRate;
        }
        
        if (m.heartRate < yValueMin) {
            yValueMin = m.heartRate;
        }
        
        if (m.heartRate >= kHRMinValue &&
            m.heartRate <= kHRMaxValue) {  // 正常
            [hrColorArray addObject:klPressColor];
        } else {
            [hrColorArray addObject:[UIColor redColor]];
        }
    }
    
    // 为了显示上更合理，Y轴再+20或者-20
    yValueMax += 20;
    yValueMin -= 20;
    if (yValueMin < 0) {
        yValueMin = 0;
    }
    
    // For Line Chart
    PNLineChart * lineChart = [[PNLineChart alloc] initWithFrame:CGRectMake(0, 25, viewWidth, SCREEN_HEIGHT*0.4)];
    lineChart.tag = KM_HEALTH_HR;
    lineChart.dottedLines = @[@(kHRMaxValue), @(kHRMinValue)];      // 两条虚线
    lineChart.showCoordinateAxis = YES;
    lineChart.delegate = self;
    lineChart.legendStyle = PNLegendItemStyleSerial;
    lineChart.legendFont = [UIFont systemFontOfSize:14];
    lineChart.yFixedValueMax = yValueMax;
    lineChart.yFixedValueMin = yValueMin;
    
    [lineChart setXLabels:dateArrayString];
    
    // Line Chart No.1
    PNLineChartData *data01 = [PNLineChartData new];
    data01.color = khPressColor;
    data01.inflexionPointStyle = PNLineChartPointStyleCircle;
    data01.inflexionPointWidth = 4;
    data01.itemCount = lineChart.xLabels.count;
    data01.showPointLabel = YES;
    data01.pointLabelFont = [UIFont systemFontOfSize:kPointsLabelFontSize];
    data01.getData = ^(NSUInteger index) {
        CGFloat yValue = [hrArray[index] floatValue];
        return  [PNLineChartDataItem dataItemWithY:yValue pointColor:hrColorArray[index]];
    };
    
    lineChart.chartData = @[data01];
    [lineChart strokeChart];
    [contentView addSubview:lineChart];
    
    UIView *bottomContainerView = [UIView new];
    [contentView addSubview:bottomContainerView];
    [bottomContainerView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.right.bottom.equalTo(contentView);
        make.top.equalTo(lineChart.mas_bottom);
    }];
    
    UIView *containView = [[UIView alloc] init];
    [bottomContainerView addSubview:containView];
    
    // 当前心率的值
    _HRCurrentLabel = [UILabel new];
    _HRCurrentLabel.font = [UIFont systemFontOfSize:kDigitalFontSize];
    [containView addSubview:_HRCurrentLabel];
    [_HRCurrentLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.equalTo(containView);
        make.bottom.equalTo(containView).offset(-5);
    }];
    
    UILabel *HRRangeLabel = [UILabel new];
    HRRangeLabel.text = [NSString stringWithFormat:@"%@:%d~%d", kLoadStringWithKey(@"healthrecord_vc_reference_value"), kHRMinValue, kHRMaxValue];
    HRRangeLabel.font = [UIFont systemFontOfSize:kReferenceFontSize];
    [containView addSubview:HRRangeLabel];
    [HRRangeLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.equalTo(_HRCurrentLabel);
        make.bottom.equalTo(_HRCurrentLabel.mas_top).offset(-5);
    }];
    
    _HRTextView = [[KMCircleTextView alloc] init];
    _HRTextView.text = [NSString stringWithFormat:@"%@(%@)",
                        kLoadStringWithKey(@"HealthRecord_VC_heart_rate"),
                        kLoadStringWithKey(@"HealthRecord_VC_heart_rate_unit")];
    //    _HRTextView.circleColor = hrColorArray[0];
    _HRTextView.circleColor = kdescriptionColor;
    [containView addSubview:_HRTextView];
    [_HRTextView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.equalTo(_HRCurrentLabel);
        make.bottom.equalTo(HRRangeLabel.mas_top).offset(-5);
        make.width.equalTo(@(_HRTextView.frame.size.width));
        make.height.equalTo(@(_HRTextView.frame.size.height));
    }];
    
    // 默认显示第一个点的详细信息
    KMHRDetailModel *m = _HRModel.list[0];
    [self HRLabelUpdateWithModel:m];
    
    [containView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.right.equalTo(contentView);
        make.top.equalTo(_HRTextView);
        make.centerY.equalTo(bottomContainerView);
    }];
    
    // 第二页显示内容
    frame = CGRectMake(SCREEN_WIDTH + kEdgeOffset, kEdgeOffset, viewWidth, _scrollView.frame.size.height - kEdgeOffset*2);
    UIView *secContainerView = [[UIView alloc] initWithFrame:frame];
    [_HRView addSubview:secContainerView];
    
    NSString *hrTip = nil;
    NSString *hrSuggestTip = nil;
    
    // 判断心率范围
    KMHRDetailModel *detail = _HRModel.list[0];
    if (detail.heartRate > 100) {               // 心率过快
        hrTip = kLoadStringWithKey(@"HealthRecord_VC_hHR");
        hrSuggestTip = kLoadStringWithKey(@"HealthRecord_VC_hHR_Suggest");
    } else if (detail.heartRate < 60) {        // 低心率
        hrTip = kLoadStringWithKey(@"HealthRecord_VC_lHR");
        hrSuggestTip = kLoadStringWithKey(@"HealthRecord_VC_lHR_Suggest");
    } else {                                            // 正常心率
        hrTip = kLoadStringWithKey(@"HealthRecord_VC_okHR");
        hrSuggestTip = kLoadStringWithKey(@"HealthRecord_VC_okHR_Suggest");
    }
    
    // 第二页标题
    UILabel *bpTipLabel = [[UILabel alloc] init];
    bpTipLabel.text = hrTip;
    bpTipLabel.backgroundColor = [UIColor whiteColor];
    bpTipLabel.numberOfLines = 0;
    bpTipLabel.font = [UIFont boldSystemFontOfSize:18];
    [secContainerView addSubview:bpTipLabel];
    [bpTipLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.right.top.equalTo(secContainerView).insets(UIEdgeInsetsMake(20, 30, 20, 30));
    }];
    
    UIScrollView *bpSuggestScrollView = [[UIScrollView alloc] init];
    bpSuggestScrollView.backgroundColor = kGrayBackColor;
    [secContainerView addSubview:bpSuggestScrollView];
    [bpSuggestScrollView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.right.bottom.equalTo(secContainerView).insets(UIEdgeInsetsMake(0, -kEdgeOffset, -kEdgeOffset, -kEdgeOffset));
        make.top.equalTo(bpTipLabel.mas_bottom).offset(30);
    }];
    
    // 可以滑动的Label，文字可能比较多，需要加在UIScrollView上面
    UILabel *bpSuggestTipLabel = [[UILabel alloc] init];
    bpSuggestTipLabel.text = hrSuggestTip;
    bpSuggestTipLabel.numberOfLines = 0;
    bpSuggestTipLabel.font = [UIFont systemFontOfSize:18];
    [bpSuggestScrollView addSubview:bpSuggestTipLabel];
    [bpSuggestTipLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(bpSuggestScrollView).offset(2*kEdgeOffset);
        make.top.equalTo(bpSuggestScrollView).offset(kEdgeOffset);
        make.width.equalTo(@(SCREEN_WIDTH-4*kEdgeOffset));
    }];
    CGRect textRect = [bpSuggestTipLabel textRectForBounds:CGRectMake(0, 0, SCREEN_WIDTH-4*kEdgeOffset, MAXFLOAT) limitedToNumberOfLines:0];
    
    bpSuggestScrollView.contentSize = CGSizeMake(textRect.size.width, textRect.size.height + 2*kEdgeOffset);
    
    return _HRView;
}

#pragma mark 更新心率标签
- (void)HRLabelUpdateWithModel:(KMHRDetailModel *)model {
    
    
    _HRCurrentLabel.attributedText = [[NSMutableAttributedString alloc] initWithString:[NSString stringWithFormat:@"%@:%@",kLoadStringWithKey(@"healthrecord_vc_measure_value"), @(model.heartRate)]];
    
    _HRCurrentLabel.alpha = 0.0;
    [UIView animateWithDuration:0.8 animations:^{
        _HRCurrentLabel.alpha = 1.0;
    }];
    
    if (model.heartRate >= kHRMinValue &&
        model.heartRate <= kHRMaxValue) {       // 正常
        _HRTextView.circleColor = kdescriptionColor;
        _HRCurrentLabel.textColor = [UIColor blackColor];
    } else {
        //        _HRTextView.circleColor = [UIColor redColor];
        _HRTextView.circleColor = kdescriptionColor;
        //        _HRCurrentLabel.textColor = [UIColor redColor];
        [self getAttriStrWithInt:_HRCurrentLabel];
    }
}

#pragma mark - 睡眠质量分析
- (UIView*)SleepAnalysisView{
    [_SleepAnalysisView removeFromSuperview];
    
    CGFloat viewWidth = SCREEN_WIDTH-2*kEdgeOffset;
    CGRect frame = CGRectMake(SCREEN_WIDTH*5+kEdgeOffset, kEdgeOffset, viewWidth, _scrollView.frame.size.height - kEdgeOffset);
    _SleepAnalysisView = [[UIView alloc] initWithFrame:frame];
    
    if(!_sleepQAModel){
        UILabel *noDataLabel = [UILabel new];
        noDataLabel.text = kLoadStringWithKey(@"HealthRecord_VC_no_records");
        noDataLabel.font = [UIFont systemFontOfSize:22];
        noDataLabel.textAlignment = NSTextAlignmentCenter;
        noDataLabel.numberOfLines = 0;
        [_SleepAnalysisView addSubview:noDataLabel];
        [noDataLabel mas_makeConstraints:^(MASConstraintMaker *make) {
            make.edges.equalTo(_SleepAnalysisView).insets(UIEdgeInsetsMake(0, 20, 40, 20));
        }];
        return _SleepAnalysisView;
    }
    
    UILabel *totalSleepTimeLabel = [UILabel new];
    totalSleepTimeLabel.textColor = kGrayContextColor;
    totalSleepTimeLabel.font = [UIFont systemFontOfSize:15];
    totalSleepTimeLabel.textAlignment = NSTextAlignmentCenter;
    totalSleepTimeLabel.text = _sleepQAModel.durationTime;
    [_SleepAnalysisView addSubview:totalSleepTimeLabel];
    totalSleepTimeLabel.adjustsFontSizeToFitWidth = YES;
    [totalSleepTimeLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.equalTo(_SleepAnalysisView);
        make.top.equalTo(_SleepAnalysisView);
        make.width.equalTo(@200);
        make.height.equalTo(@15);
    }];
    
    UILabel *totalSleepQualityLabel = [UILabel new];
    totalSleepQualityLabel.textColor = kGrayContextColor;
    totalSleepQualityLabel.font = [UIFont systemFontOfSize:15];
    totalSleepQualityLabel.textAlignment = NSTextAlignmentCenter;
    totalSleepQualityLabel.text = [NSString stringWithFormat:@"%@%lld%@",kLoadStringWithKey(@"HealthRecord_VC_sleepAVGQuality"),_sleepQAModel.todayQualityPercent,@"%"];
    [_SleepAnalysisView addSubview:totalSleepQualityLabel];
    [totalSleepQualityLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.equalTo(_SleepAnalysisView);
        make.top.equalTo(totalSleepTimeLabel.mas_bottom).offset(10);
        make.width.equalTo(@150);
        make.height.equalTo(@15);
    }];
    
    //Bar Chart
    static NSNumberFormatter *barChartFormatter;
    if (!barChartFormatter){
        barChartFormatter = [[NSNumberFormatter alloc] init];
        barChartFormatter.numberStyle = NSNumberFormatterNoStyle;
        barChartFormatter.allowsFloats = YES;
        barChartFormatter.maximumFractionDigits = 2;
    }
    
    //bar chart 1
    KMPNBarChart* barChart = [[KMPNBarChart alloc] initWithFrame:CGRectMake(0, 50, viewWidth, SCREEN_HEIGHT*0.3)];
    barChart.duration =_sleepQAModel.duration;
    barChart.backgroundColor = [UIColor clearColor];
    barChart.yLabelFormatter = ^(CGFloat yValue){
        return [barChartFormatter stringFromNumber:[NSNumber numberWithFloat:yValue]];
    };
    
    barChart.labelFont = [UIFont systemFontOfSize:14];
    barChart.yChartLabelWidth = 0;
    barChart.chartMarginLeft = 15.0;
    barChart.chartMarginRight = 15.0;
    barChart.chartMarginTop = 5.0;
    barChart.chartMarginBottom = 10.0;
    
    barChart.labelMarginTop = 5.0;
    barChart.showChartBorder = YES;
    barChart.isShowNumbers = NO;
    barChart.isGradientShow = NO;
    barChart.barBackgroundColor = [UIColor clearColor];
    [barChart setXLabels:_sleepQAModel.sleepQulityTimes];
    [barChart setYLabels:@[@"1",@"1.5"]];
    [barChart setYValues:_sleepQAModel.sleepQulityStates];
    
    NSMutableArray * strokeColors = [NSMutableArray array];
    for (NSObject* value in _sleepQAModel.sleepQulityStates) {
        if([value isEqual:@"1"]){
            [strokeColors addObject:klPressColor];
        }else if([value isEqual:@"1.5"]){
            [strokeColors addObject:deepSleepColor];
        }
    }
    barChart.strokeColors = strokeColors;
    
    [barChart strokeChart];
    [_SleepAnalysisView addSubview:barChart];
    
    float sleepAnalysisViewWidth = _SleepAnalysisView.frame.size.width;
    float buttonWidth = (sleepAnalysisViewWidth -5-5)*0.3;
    
    //deep sleep
    UIImage* sleepDeepImageView = [UIImage imageNamed:@"circleDeepBlue"];
    NSString* sleepDeepTitle = kLoadStringWithKey(@"HealthRecord_VC_sleepTypeDeep");
    NSString* sleepDeepPercentText =_sleepQAModel.deepSleepTotalTime;
    KMImageTwoRightTextView* sleepDeepView = [[KMImageTwoRightTextView alloc] initWithImage:sleepDeepImageView rightTopText:sleepDeepTitle topFont:12 rightBottomText:sleepDeepPercentText bottomFont:14];
    [_SleepAnalysisView addSubview:sleepDeepView];
    [sleepDeepView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(barChart.mas_bottom).offset(10);
        make.left.equalTo(_SleepAnalysisView).offset(5);
        make.width.equalTo(@(buttonWidth));
        make.height.equalTo(@50);
    }];
    
    
    //quiet sleep
    UIImage* quietDeepImageView = [UIImage imageNamed:@"circleLightBlue"];
    NSString* sleepQuietTitle = [NSString stringWithFormat:@"%@",kLoadStringWithKey(@"HealthRecord_VC_sleepTypeQuiet")];
    NSString* sleepQuietPercentText =_sleepQAModel.quietSleepTotalTime;
    KMImageTwoRightTextView* sleepQuietView = [[KMImageTwoRightTextView alloc] initWithImage:quietDeepImageView rightTopText:sleepQuietTitle topFont:12 rightBottomText:sleepQuietPercentText bottomFont:14];
    [_SleepAnalysisView addSubview:sleepQuietView];
    [sleepQuietView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(sleepDeepView);
        make.top.equalTo(sleepDeepView.mas_bottom).offset(10);
        make.width.equalTo(@(buttonWidth));
        make.height.equalTo(@50);
    }];
    
    
    //active count
    UIImage* activeCountImage = [UIImage imageNamed:@"sleepqa_activecount"];
    NSString* activeCountTitle = kLoadStringWithKey(@"HealthRecord_VC_sleepActiveCount");
    NSString* activeCountText = [NSString stringWithFormat:@"%ld %@",
                                 (long)_sleepQAModel.activeCount,kLoadStringWithKey(@"HealthRecord_VC_sleepActiveCountTime")];
    KMImageTwoRightTextView* activeCountView = [[KMImageTwoRightTextView alloc] initWithImage:activeCountImage rightTopText:activeCountTitle topFont:12 rightBottomText:activeCountText bottomFont:14];
    [_SleepAnalysisView addSubview:activeCountView];
    [activeCountView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(barChart.mas_bottom).offset(10);
        make.centerX.equalTo(_SleepAnalysisView);
        make.width.equalTo(@(buttonWidth));
        make.height.equalTo(@50);
    }];
    
    //active time
    UIImage* activeTimeImage = [UIImage imageNamed:@"sleepqa_activetime"];
    NSString* activeTimeTitle = kLoadStringWithKey(@"HealthRecord_VC_sleepActiveTime");
    NSString* activeTimeText = _sleepQAModel.activeTime;
    
    KMImageTwoRightTextView* activeTimeView = [[KMImageTwoRightTextView alloc] initWithImage:activeTimeImage rightTopText:activeTimeTitle topFont:12 rightBottomText:activeTimeText bottomFont:14];
    [_SleepAnalysisView addSubview:activeTimeView];
    [activeTimeView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(activeCountView.mas_bottom).offset(10);
        make.centerX.equalTo(_SleepAnalysisView);
        make.width.equalTo(@(buttonWidth));
        make.height.equalTo(@50);
    }];
    
    //heath rate
    UIImage* heathRateImage = [UIImage imageNamed:@"sleepqa_heartrate"];
    NSString* heathRateTitle =kLoadStringWithKey(@"HealthRecord_VC_sleepHeartRate");
    NSString* heathRateText = [NSString stringWithFormat:@"%@ %lld,%@ %lld",kLoadStringWithKey(@"HealthRecord_VC_sleepMinHeartRate"),
                               _sleepQAModel.minHeartRate,kLoadStringWithKey(@"HealthRecord_VC_sleepMaxHeartRate"),_sleepQAModel.maxHeartRate];
    
    KMImageTwoRightTextView* heathRateView = [[KMImageTwoRightTextView alloc] initWithImage:heathRateImage rightTopText:heathRateTitle topFont:12 rightBottomText:heathRateText bottomFont:13];
    [_SleepAnalysisView addSubview:heathRateView];
    [heathRateView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(barChart.mas_bottom).offset(10);
        make.right.equalTo(_SleepAnalysisView).offset(-5);
        make.width.equalTo(@(buttonWidth));
        make.height.equalTo(@50);
    }];
    
    //heath avg rate
    UIImage* heathAvgRateImage = [UIImage imageNamed:@"sleepqa_heartrate"];
    NSString* heathAvgRateTitle = kLoadStringWithKey(@"HealthRecord_VC_sleepAvgHeartRate");
    NSString* heathAvgRateText = [NSString stringWithFormat:@"%lld %@",_sleepQAModel.avgHeartRate, kLoadStringWithKey(@"HealthRecord_VC_sleepHeartRateCPM")];
    
    KMImageTwoRightTextView* heathAvgRateView = [[KMImageTwoRightTextView alloc] initWithImage:heathAvgRateImage rightTopText:heathAvgRateTitle topFont:12 rightBottomText:heathAvgRateText bottomFont:14];
    [_SleepAnalysisView addSubview:heathAvgRateView];
    [heathAvgRateView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.right.equalTo(heathRateView);
        make.top.equalTo(heathRateView.mas_bottom).offset(10);
        make.width.equalTo(@(buttonWidth));
        make.height.equalTo(@50);
    }];
    
    return  _SleepAnalysisView;
}

#pragma mark - 记步

- (UIView *)StepView {
    [_StepView removeFromSuperview];
    
    CGFloat viewWidth = SCREEN_WIDTH-2*kEdgeOffset;
    CGRect frame = CGRectMake(SCREEN_WIDTH*4+kEdgeOffset, kEdgeOffset, viewWidth, _scrollView.frame.size.height - kEdgeOffset);
    _StepView = [[UIView alloc] initWithFrame:frame];
    
    // 如果没有信息，提示
    if (_stepModel.list.count == 0) {
        UILabel *noDataLabel = [UILabel new];
        noDataLabel.text = kLoadStringWithKey(@"HealthRecord_VC_no_records");
        noDataLabel.font = [UIFont systemFontOfSize:22];
        noDataLabel.textAlignment = NSTextAlignmentCenter;
        noDataLabel.numberOfLines = 0;
        [_StepView addSubview:noDataLabel];
        [noDataLabel mas_makeConstraints:^(MASConstraintMaker *make) {
            make.edges.equalTo(_StepView).insets(UIEdgeInsetsMake(0, 20, 40, 20));
        }];
        return _StepView;
    }
    
    UILabel *StepUnitLabel = [UILabel new];
    StepUnitLabel.textColor = kGrayContextColor;
    StepUnitLabel.font = [UIFont systemFontOfSize:13];
    StepUnitLabel.text = [NSString stringWithFormat:@"%@",
                          kLoadStringWithKey(@"HealthRecord_VC_pedometer_numbers")] ;
    [_StepView addSubview:StepUnitLabel];
    [StepUnitLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.top.equalTo(_StepView);
    }];
    
    NSMutableArray *dateArrayString = @[].mutableCopy;
    NSMutableArray *stepArray = @[].mutableCopy;
    NSMutableArray *stepColorArray = @[].mutableCopy;
    int maxCount = _stepModel.list.count > kMaxShowNum ? kMaxShowNum : (int)(_stepModel.list.count);
    for (int i = maxCount - 1; i >= 0; i--) {
        KMStepDetailModel *m = _stepModel.list[i];
        [dateArrayString addObject:[NSString stringWithDate:m.eTime format:@"MM-dd\nHH:mm"]];
        [stepArray addObject:@(m.steps)];
        [stepColorArray addObject:khPressColor];
    }
    
    // For Line Chart
    PNLineChart * lineChart = [[PNLineChart alloc] initWithFrame:CGRectMake(0, 25, viewWidth, SCREEN_HEIGHT*0.4)];
    lineChart.tag = KM_HEALTH_STEP;
    lineChart.showCoordinateAxis = YES;
    lineChart.delegate = self;
    lineChart.legendStyle = PNLegendItemStyleSerial;
    lineChart.legendFont = [UIFont systemFontOfSize:14];
    
    [lineChart setXLabels:dateArrayString];
    
    // Line Chart No.1
    PNLineChartData *data01 = [PNLineChartData new];
    data01.color = khPressColor;
    data01.inflexionPointStyle = PNLineChartPointStyleCircle;
    data01.inflexionPointWidth = 4;
    data01.itemCount = lineChart.xLabels.count;
    data01.showPointLabel = YES;
    data01.pointLabelFont = [UIFont systemFontOfSize:kPointsLabelFontSize];
    data01.getData = ^(NSUInteger index) {
        CGFloat yValue = [stepArray[index] floatValue];
        return [PNLineChartDataItem dataItemWithY:yValue pointColor:stepColorArray[index]];
    };
    
    lineChart.chartData = @[data01];
    [lineChart strokeChart];
    [_StepView addSubview:lineChart];
    
    UIView *bottomContainerView = [UIView new];
    [_StepView addSubview:bottomContainerView];
    [bottomContainerView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.right.bottom.equalTo(_StepView);
        make.top.equalTo(lineChart.mas_bottom);
    }];
    
    UIView *containView = [[UIView alloc] init];
    [_StepView addSubview:containView];
    
    // 当前步数
    _stepCurrentLabel = [UILabel new];
    _stepCurrentLabel.text = [NSString stringWithFormat:@"%@", stepArray[0]];
    _stepCurrentLabel.font = [UIFont systemFontOfSize:kDigitalFontSize];
    [containView addSubview:_stepCurrentLabel];
    [_stepCurrentLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.equalTo(containView).multipliedBy(0.5).offset(-20);
        make.bottom.equalTo(containView).offset(-5);
    }];
    
    // 计步
    _stepTextView = [[KMCircleTextView alloc] init];
    _stepTextView.text = kLoadStringWithKey(@"HealthRecord_VC_pedometer_numbers");
    _stepTextView.circleColor = stepColorArray[0];
    [containView addSubview:_stepTextView];
    [_stepTextView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.equalTo(_stepCurrentLabel);
        make.bottom.equalTo(_stepCurrentLabel.mas_top).offset(-5);
        make.width.equalTo(@(_stepTextView.frame.size.width));
        make.height.equalTo(@(_stepTextView.frame.size.height));
    }];
    
    // cal
    UILabel *calLabel = [UILabel new];
    calLabel.text = [NSString stringWithFormat:@"%@(%@)",
                     kLoadStringWithKey(@"HealthRecord_VC_pedometer_cal"),
                     kLoadStringWithKey(@"HealthRecord_VC_pedometer_cal_unit")];
    calLabel.font = [UIFont systemFontOfSize:13];
    [containView addSubview:calLabel];
    [calLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.equalTo(containView);
        make.centerY.equalTo(_stepTextView);
    }];
    
    // 当前cal
    _calCurrentLabel = [UILabel new];
    _calCurrentLabel.font = [UIFont systemFontOfSize:kDigitalFontSize];
    [containView addSubview:_calCurrentLabel];
    [_calCurrentLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.equalTo(containView);
        make.centerY.equalTo(_stepCurrentLabel);
    }];
    
    // 当前距离
    _disCurrentLabel = [UILabel new];
    _disCurrentLabel.font = [UIFont systemFontOfSize:kDigitalFontSize];
    [containView addSubview:_disCurrentLabel];
    [_disCurrentLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.equalTo(containView).multipliedBy(1.5).offset(20);
        make.centerY.equalTo(_stepCurrentLabel);
    }];
    
    UILabel *disLabel = [UILabel new];
    disLabel.text = [NSString stringWithFormat:@"%@(%@)",
                     kLoadStringWithKey(@"HealthRecord_VC_pedometer_dis"),
                     kLoadStringWithKey(@"HealthRecord_VC_pedometer_dis_unit")];
    disLabel.font = [UIFont systemFontOfSize:13];
    [containView addSubview:disLabel];
    [disLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.equalTo(_disCurrentLabel);
        make.centerY.equalTo(_stepTextView);
    }];
    
    KMStepDetailModel *m = _stepModel.list[0];
    [self stepLableUpdateWithModel:m];
    
    [containView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.right.equalTo(_StepView);
        make.top.equalTo(_stepCurrentLabel);
        make.centerY.equalTo(bottomContainerView);
    }];
    
    return _StepView;
}

- (void)stepLableUpdateWithModel:(KMStepDetailModel *)model {
    _stepCurrentLabel.text = [NSString stringWithFormat:@"%@", @(model.steps)];
    _calCurrentLabel.text = [NSString stringWithFormat:@"%@", @(model.cal)];
    _disCurrentLabel.text = [NSString stringWithFormat:@"%@", @(model.distance)];
    
    _stepCurrentLabel.alpha = 0;
    _calCurrentLabel.alpha = 0;
    _disCurrentLabel.alpha = 0;
    [UIView animateWithDuration:0.8 animations:^{
        _stepCurrentLabel.alpha = 1;
        _calCurrentLabel.alpha = 1;
        _disCurrentLabel.alpha = 1;
    }];
}

#pragma mark - 血氧

- (UIScrollView *)BOView {
    [_BOView removeFromSuperview];
    
    _BOView = [[UIScrollView alloc] initWithFrame:CGRectMake(SCREEN_WIDTH*3, 0, SCREEN_WIDTH, _scrollView.frame.size.height)];
    _BOView.pagingEnabled = YES;
    
    CGFloat viewWidth = SCREEN_WIDTH-2*kEdgeOffset;
    CGRect frame = CGRectMake(kEdgeOffset, kEdgeOffset, viewWidth, _scrollView.frame.size.height - kEdgeOffset);
    UIView *contentView = [[UIView alloc] initWithFrame:frame];
    
    [_BOView addSubview:contentView];
    
    // 如果没有数据记录, 显示提示信息
    if (_BOModel.list.count == 0) {
        UILabel *noDataLabel = [UILabel new];
        noDataLabel.text = kLoadStringWithKey(@"HealthRecord_VC_no_records");
        noDataLabel.font = [UIFont systemFontOfSize:22];
        noDataLabel.textAlignment = NSTextAlignmentCenter;
        noDataLabel.numberOfLines = 0;
        [contentView addSubview:noDataLabel];
        [noDataLabel mas_makeConstraints:^(MASConstraintMaker *make) {
            make.edges.equalTo(contentView).insets(UIEdgeInsetsMake(0, 20, 40, 20));
        }];
        return _BOView;
    };
    
    _BOView.contentSize = CGSizeMake(SCREEN_WIDTH*2, 0);
    
    // 心率单位
    UILabel *BOUnitLabel = [UILabel new];
    BOUnitLabel.textColor = kGrayContextColor;
    BOUnitLabel.font = [UIFont systemFontOfSize:13];
    BOUnitLabel.text = [NSString stringWithFormat:@"%@(%%)",
                        kLoadStringWithKey(@"HealthRecord_VC_bo")];
    [contentView addSubview:BOUnitLabel];
    [BOUnitLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.top.equalTo(contentView);
        make.height.equalTo(@25);
    }];
    
    NSMutableArray *dateArrayString = @[].mutableCopy;
    NSMutableArray *boArray = @[].mutableCopy;
    NSMutableArray *boColorArray = @[].mutableCopy;
    CGFloat yValueMax = kBOMaxValue;
    CGFloat yValueMin = kBOMinValue;
    
    int maxCount = _BOModel.list.count > kMaxShowNum ? kMaxShowNum : (int)(_BOModel.list.count);
    for (int i = maxCount - 1; i >= 0; i--) {
        KMBODetailModel *m = _BOModel.list[i];
        [dateArrayString addObject:[NSString stringWithDate:m.oxyTime format:@"MM-dd\nHH:mm"]];
        [boArray addObject:@(m.spo2)];
        
        if (m.spo2 > yValueMax) {
            yValueMax = m.spo2;
        }
        
        if (m.spo2 < yValueMin) {
            yValueMin = m.spo2;
        }
        
        if (m.spo2 >= kBOMinValue &&
            m.spo2 <= kBOMaxValue) {  // 正常
            [boColorArray addObject:klPressColor];
        } else {
            [boColorArray addObject:[UIColor redColor]];
        }
    }
    
    // 为了显示上更合理，Y轴再+20或者-20
    yValueMax += 20;
    yValueMin -= 20;
    if (yValueMin < 0) {
        yValueMin = 0;
    }
    
    // For Line Chart
    PNLineChart * lineChart = [[PNLineChart alloc] initWithFrame:CGRectMake(0, 25, viewWidth, SCREEN_HEIGHT*0.4)];
    lineChart.tag = KM_HEALTH_BO;
    lineChart.dottedLines = @[@(kBOMinValue), @(kBOMaxValue)];      // 两条虚线
    lineChart.showCoordinateAxis = YES;
    lineChart.delegate = self;
    lineChart.legendStyle = PNLegendItemStyleSerial;
    lineChart.legendFont = [UIFont systemFontOfSize:14];
    lineChart.yFixedValueMax = yValueMax;
    lineChart.yFixedValueMin = yValueMin;
    
    [lineChart setXLabels:dateArrayString];
    
    // Line Chart No.1
    PNLineChartData *data01 = [PNLineChartData new];
    data01.color = khPressColor;
    data01.inflexionPointStyle = PNLineChartPointStyleCircle;
    data01.inflexionPointWidth = 4;
    data01.itemCount = lineChart.xLabels.count;
    data01.showPointLabel = YES;
    data01.pointLabelFont = [UIFont systemFontOfSize:kPointsLabelFontSize];
    data01.getData = ^(NSUInteger index) {
        CGFloat yValue = [boArray[index] floatValue];
        return  [PNLineChartDataItem dataItemWithY:yValue pointColor:boColorArray[index]];
    };
    
    lineChart.chartData = @[data01];
    [lineChart strokeChart];
    [contentView addSubview:lineChart];
    
    UIView *bottomContainerView = [UIView new];
    [contentView addSubview:bottomContainerView];
    [bottomContainerView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.right.bottom.equalTo(contentView);
        make.top.equalTo(lineChart.mas_bottom);
    }];
    
    UIView *containView = [[UIView alloc] init];
    [bottomContainerView addSubview:containView];
    
    // 当前血氧的值
    _boCurrentLabel = [UILabel new];
    _boCurrentLabel.font = [UIFont systemFontOfSize:kDigitalFontSize];
    [containView addSubview:_boCurrentLabel];
    [_boCurrentLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.equalTo(containView);
        make.bottom.equalTo(containView).offset(-5);
    }];
    
    UILabel *boRangeLabel = [UILabel new];
    boRangeLabel.text = [NSString stringWithFormat:@"%@:%d~%d", kLoadStringWithKey(@"healthrecord_vc_reference_value"), kBOMinValue, kBOMaxValue];
    boRangeLabel.font = [UIFont systemFontOfSize:kReferenceFontSize];
    [containView addSubview:boRangeLabel];
    [boRangeLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.equalTo(_boCurrentLabel);
        make.bottom.equalTo(_boCurrentLabel.mas_top).offset(-5);
    }];
    
    _boTextView = [[KMCircleTextView alloc] init];
    _boTextView.text = [NSString stringWithFormat:@"%@(%%)",
                        kLoadStringWithKey(@"HealthRecord_VC_bo")];
    //    _boTextView.circleColor = boColorArray[0];
    _boTextView.circleColor = kdescriptionColor;
    [containView addSubview:_boTextView];
    [_boTextView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.equalTo(_boCurrentLabel);
        make.bottom.equalTo(boRangeLabel.mas_top).offset(-5);
        make.width.equalTo(@(_boTextView.frame.size.width));
        make.height.equalTo(@(_boTextView.frame.size.height));
    }];
    
    // 默认显示第一个点的详细信息
    KMBODetailModel *m = _BOModel.list[0];
    [self BOLabelUpdateWithModel:m];
    
    [containView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.right.equalTo(contentView);
        make.top.equalTo(_boTextView);
        make.centerY.equalTo(bottomContainerView);
    }];
    
    // 第二页健康提示
    frame = CGRectMake(SCREEN_WIDTH + kEdgeOffset, kEdgeOffset, viewWidth, _scrollView.frame.size.height - kEdgeOffset*2);
    UIView *secContainerView = [[UIView alloc] initWithFrame:frame];
    [_BOView addSubview:secContainerView];
    
    NSString *boTip = nil;
    NSString *boSuggestTip = nil;
    
    // 判断血压范围
    KMBODetailModel *detail = _BOModel.list[0];
    if (detail.spo2 >= 100) {               // 高血氧100
        boTip = kLoadStringWithKey(@"HealthRecord_VC_hBO");
        boSuggestTip = kLoadStringWithKey(@"HealthRecord_VC_h100BO_Suggest");
    } else if (detail.spo2 >= 98 && detail.spo2 < 100) {
        boTip = kLoadStringWithKey(@"HealthRecord_VC_hBO");
        boSuggestTip = kLoadStringWithKey(@"HealthRecord_VC_h98_100BO_Suggest");
    } else if (detail.spo2 >= 90 && detail.spo2 < 95) {        // 低血氧
        boTip = kLoadStringWithKey(@"HealthRecord_VC_lBO");
        boSuggestTip = kLoadStringWithKey(@"HealthRecord_VC_lBO_Suggest");
    } else if (detail.spo2 >= 95 && detail.spo2 < 98) {         // 血氧正常
        boTip = kLoadStringWithKey(@"HealthRecord_VC_okBO");
        boSuggestTip = kLoadStringWithKey(@"HealthRecord_VC_okBO_Suggest");
    } else if (detail.spo2 < 90) {                                       // 血氧严重偏低
        boTip = kLoadStringWithKey(@"HealthRecord_VC_verylow_BO");
        boSuggestTip = kLoadStringWithKey(@"HealthRecord_VC_veryLow_BO_Suggest");
    }
    
    // 第二页标题
    UILabel *bpTipLabel = [[UILabel alloc] init];
    bpTipLabel.text = boTip;
    bpTipLabel.backgroundColor = [UIColor whiteColor];
    bpTipLabel.numberOfLines = 0;
    bpTipLabel.font = [UIFont boldSystemFontOfSize:18];
    [secContainerView addSubview:bpTipLabel];
    [bpTipLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.right.top.equalTo(secContainerView).insets(UIEdgeInsetsMake(20, 30, 20, 30));
    }];
    
    UIScrollView *bpSuggestScrollView = [[UIScrollView alloc] init];
    bpSuggestScrollView.backgroundColor = kGrayBackColor;
    [secContainerView addSubview:bpSuggestScrollView];
    [bpSuggestScrollView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.right.bottom.equalTo(secContainerView).insets(UIEdgeInsetsMake(0, -kEdgeOffset, -kEdgeOffset, -kEdgeOffset));
        make.top.equalTo(bpTipLabel.mas_bottom).offset(30);
    }];
    
    // 可以滑动的Label，文字可能比较多，需要加在UIScrollView上面
    UILabel *bpSuggestTipLabel = [[UILabel alloc] init];
    bpSuggestTipLabel.text = boSuggestTip;
    bpSuggestTipLabel.numberOfLines = 0;
    bpSuggestTipLabel.font = [UIFont systemFontOfSize:18];
    [bpSuggestScrollView addSubview:bpSuggestTipLabel];
    [bpSuggestTipLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(bpSuggestScrollView).offset(2*kEdgeOffset);
        make.top.equalTo(bpSuggestScrollView).offset(kEdgeOffset);
        make.width.equalTo(@(SCREEN_WIDTH-4*kEdgeOffset));
    }];
    CGRect textRect = [bpSuggestTipLabel textRectForBounds:CGRectMake(0, 0, SCREEN_WIDTH-4*kEdgeOffset, MAXFLOAT) limitedToNumberOfLines:0];
    
    bpSuggestScrollView.contentSize = CGSizeMake(textRect.size.width, textRect.size.height + 2*kEdgeOffset);
    
    return _BOView;
}

- (void)BOLabelUpdateWithModel:(KMBODetailModel *)model {
    
    _boCurrentLabel.attributedText = [[NSMutableAttributedString alloc] initWithString:[NSString stringWithFormat:@"%@:%@",kLoadStringWithKey(@"healthrecord_vc_measure_value"), @(model.spo2)]];
    _boCurrentLabel.alpha = 0;
    [UIView animateWithDuration:0.8 animations:^{
        _boCurrentLabel.alpha = 1;
    }];
    if (model.spo2 >= kBOMinValue &&
        model.spo2 <= kBOMaxValue) {       // 正常
        _boTextView.circleColor = kdescriptionColor;
        _boCurrentLabel.textColor = [UIColor blackColor];
    } else {
        //        _boTextView.circleColor = [UIColor redColor];
        _boTextView.circleColor = kdescriptionColor;
        //        _boCurrentLabel.textColor = [UIColor redColor];
        [self getAttriStrWithInt:_boCurrentLabel];
    }
}

#pragma mark - PNChartDelegate

- (void)userClickedOnChart:(PNLineChart *)lineChart
                 lineIndex:(NSInteger)lineIndex
                pointIndex:(NSInteger)pointIndex {
    CGPoint point = [lineChart.pathPoints[lineIndex][pointIndex] CGPointValue];
    //十坐标线
    if ((CGPointEqualToPoint(point,self.point)) && [self.lineChart isEqual:lineChart]) {
        [self.xLineView removeFromSuperview];
        [self.yLineView removeFromSuperview];
        self.point = CGPointZero;
        self.lineChart = nil;
    }else{
        self.point = point;
        self.lineChart = lineChart;
        [self.xLineView removeFromSuperview];
        [self.yLineView removeFromSuperview];
        //y軸線
        UIView *xlineView = [[UIView alloc]initWithFrame:CGRectMake((SCREEN_WIDTH - lineChart.chartCavanWidth) * 0.5, point.y,lineChart.chartCavanWidth, 1)];
        
        xlineView.backgroundColor = klPressColor;
        self.xLineView = xlineView;
        [lineChart insertSubview:xlineView atIndex:1];
        //x軸線
        UIView *ylineView = [[UIView alloc]initWithFrame:CGRectMake(point.x - 1, lineChart.chartMarginBottom, 1, lineChart.chartCavanHeight)];
        
        ylineView.backgroundColor = klPressColor;
        self.yLineView = ylineView;
        [lineChart insertSubview:ylineView atIndex:1];
    }
    
    switch (lineChart.tag) {
        case KM_HEALTH_BP:      // 血压
        {
            int maxCount = _BPModel.list.count > kMaxShowNum ? kMaxShowNum : (int)(_BPModel.list.count);
            KMBPDetailModel *m = _BPModel.list[maxCount - pointIndex - 1];
            [self BPLabelUpdateWithModel:m];
        } break;
        case KM_HEALTH_BS:      // 血糖
        {
            int maxCount = _BSModel.list.count > kMaxShowNum ? kMaxShowNum : (int)(_BSModel.list.count);
            KMBSDetailModel *m = _BSModel.list[maxCount - pointIndex - 1];
            [self BSLabelUpdateWithModel:m];
        } break;
        case KM_HEALTH_HR:      // 心率
        {
            int maxCount = _HRModel.list.count > kMaxShowNum ? kMaxShowNum : (int)(_HRModel.list.count);
            KMHRDetailModel *m = _HRModel.list[maxCount - pointIndex - 1];
            [self HRLabelUpdateWithModel:m];
        } break;
        case KM_HEALTH_STEP:    // 计步
        {
            int maxCount = _stepModel.list.count > kMaxShowNum ? kMaxShowNum : (int)(_stepModel.list.count);
            [self stepLableUpdateWithModel:_stepModel.list[maxCount - pointIndex - 1]];
        } break;
        case KM_HEALTH_BO:      // 血氧
        {
            int maxCount = _BOModel.list.count > kMaxShowNum ? kMaxShowNum : (int)(_BOModel.list.count);
            [self BOLabelUpdateWithModel:_BOModel.list[maxCount - pointIndex - 1]];
        } break;
        case KM_HEALTH_SLEEPANALYSE: //睡眠质量分析
            break;
        default:
            break;
    }
}

#pragma mark - 切换设备
- (void)rightBarButtonDidClicked:(UIBarButtonItem *)sender
{
    KMBindDeviceListVC *vc = [[KMBindDeviceListVC alloc] init];
    vc.detailModel = _deviceDetailModel;
    vc.delegate = self;
    UINavigationController *nav = [[UINavigationController alloc] initWithRootViewController:vc];
    
    [self presentViewController:nav animated:YES completion:nil];
}

#pragma mark KMBindDeviceListVCDelegate
- (void)didSelectBindDeviceWithModel:(KMBundleDevicesDetailModel *)deviceListDetailModel {
    
    if ([KMMemberManager sharedInstance].netStatus < 1 ) {
        
        [SVProgressHUD showErrorWithStatus:kNetError];
        return;
    }
    
    _deviceDetailModel = deviceListDetailModel;
    
    
    if (!_deviceDetailModel.accept){
        // 用户没有确认手表提示
        [self customAlertViewShowWithMessage:kLoadStringWithKey(@"DeviceSetting_VC_alert_select") withStatus:NO];
        return ;
    }
    
    
    [self refreshView];
    [_userImageView sdImageWithIMEI:_deviceDetailModel.imei];
    _userNameLabel.text = _deviceDetailModel.realName;
    
    [self clearRecordDate];
    [self requestAllHealthInfo];
}

#pragma mark 清除日期
- (void)clearRecordDate {
    // 清除最后更新时间
    self.bpLastMeasureDate = nil;
    self.bsLastMeasureDate = nil;
    self.stepLastMeasureDate = nil;
    self.hrLastMeasureDate = nil;
    self.boLastMeasureDate = nil;
    self.sleepQAMeasureDate = nil;
    
    // 清除当前限定的日期
    self.dateModel.bpStartDate = nil;
    self.dateModel.bpEndDate = nil;
    
    self.dateModel.bsEndDate = nil;
    self.dateModel.bsStartDate = nil;
    
    self.dateModel.hrStartDate = nil;
    self.dateModel.hrEndDate = nil;
    
    self.dateModel.stepStartDate = nil;
    self.dateModel.stepEndDate = nil;
    
    self.dateModel.boEndDate = nil;
    self.dateModel.boStartDate = nil;
    
    self.dateModel.sleepDate = nil;
}

#pragma mark - 血压血糖心率计步按钮点击事件
- (void)healthBtnDidClicked:(UIButton *)sender
{
    // 如果这个按钮已经被选中，直接返回
    if (sender.selected) return;
    
    // 如果之前请求的网络错误，需要重新获取设备列表
    if (_deviceDetailModel == nil) {
        [self updateDeviceListFromServer];
        [self selectHealthBtnWithIndex:sender.tag - KM_HEALTH_BP];
    } else {
        [self selectHealthBtnWithIndex:sender.tag - KM_HEALTH_BP];
        [SVProgressHUD show];
        [self requestHealthInfoWithType:sender.tag];
        [self reloadLineChartWithType:sender.tag];
    }
}

#pragma mark 当前选中的按钮序号
- (KMHealthRecordType)currentSelectBtnIndex {
    for (int i = 0; i < self.navigationButtonCount; i++) {
        UIButton *button = [self.view viewWithTag:KM_HEALTH_BP + i];
        if (button.isSelected) {
            return button.tag;
        }
    }
    
    return KM_HEALTH_BP;
}

#pragma mark 更新底部按钮的文字
- (void)updateBottomButtonTitle {
    KMHealthRecordType type = [self currentSelectBtnIndex];
    NSString *btnTitle = nil;
    switch (type) {
        case KM_HEALTH_BP:
            if (_dateModel.bpStartDate && _dateModel.bpEndDate) {
                btnTitle = [NSString stringWithFormat:@"%@ %@ %@",
                            [NSString stringWithNSDate:_dateModel.bpStartDate],kLoadStringWithKey(@"HealthRecord_VC_change_date_to"),
                            [NSString stringWithNSDate:_dateModel.bpEndDate]];
            } else {
                btnTitle = kLoadStringWithKey(@"HealthRecord_VC_change_date");
            }
            break;
        case KM_HEALTH_BS:
            if (_dateModel.bsStartDate && _dateModel.bsEndDate) {
                btnTitle = [NSString stringWithFormat:@"%@ %@ %@",
                            [NSString stringWithNSDate:_dateModel.bsStartDate],kLoadStringWithKey(@"HealthRecord_VC_change_date_to"),
                            [NSString stringWithNSDate:_dateModel.bsEndDate]];
            } else {
                btnTitle = kLoadStringWithKey(@"HealthRecord_VC_change_date");
            }
            break;
        case KM_HEALTH_HR:
            if (_dateModel.hrStartDate && _dateModel.hrEndDate) {
                btnTitle = [NSString stringWithFormat:@"%@ %@ %@",
                            [NSString stringWithNSDate:_dateModel.hrStartDate],
                            kLoadStringWithKey(@"HealthRecord_VC_change_date_to"),
                            [NSString stringWithNSDate:_dateModel.hrEndDate]];
            } else {
                btnTitle = kLoadStringWithKey(@"HealthRecord_VC_change_date");
            }
            break;
        case KM_HEALTH_STEP:
            if (_dateModel.stepStartDate && _dateModel.stepEndDate) {
                btnTitle = [NSString stringWithFormat:@"%@ %@ %@",
                            [NSString stringWithNSDate:_dateModel.stepStartDate],
                            kLoadStringWithKey(@"HealthRecord_VC_change_date_to"),
                            [NSString stringWithNSDate:_dateModel.stepEndDate]];
            } else {
                btnTitle = kLoadStringWithKey(@"HealthRecord_VC_change_date");
            }
            break;
        case KM_HEALTH_BO:
            if (_dateModel.boStartDate && _dateModel.boEndDate) {
                btnTitle = [NSString stringWithFormat:@"%@ %@ %@",
                            [NSString stringWithNSDate:_dateModel.boStartDate],
                            kLoadStringWithKey(@"HealthRecord_VC_change_date_to"),
                            [NSString stringWithNSDate:_dateModel.boEndDate]];
            } else {
                btnTitle = kLoadStringWithKey(@"HealthRecord_VC_change_date");
            }
            break;
        case KM_HEALTH_SLEEPANALYSE:
            if (_dateModel.sleepDate) {
                btnTitle = [NSString stringWithFormat:@"%@",[NSString stringWithNSDate:_dateModel.sleepDate]];
            } else {
                btnTitle = kLoadStringWithKey(@"HealthRecord_VC_change_date");
            }
            break;
        default:
            break;
    }
    
    UIButton *bottomChangeDateButton = [self.view viewWithTag:10000];
    [bottomChangeDateButton setTitle:btnTitle forState:UIControlStateNormal];
}

#pragma mark 调整当前视图状态
- (void)reloadLineChartWithType:(KMHealthRecordType)type {
    switch (type) {
        case KM_HEALTH_BP:      // 血压
        {
            [UIView animateWithDuration:0.3 animations:^{
                _scrollView.contentOffset = CGPointZero;
            }];
        } break;
        case KM_HEALTH_BS:      // 血糖
        {
            [UIView animateWithDuration:0.3 animations:^{
                _scrollView.contentOffset = CGPointMake(SCREEN_WIDTH, 0);
            }];
        } break;
        case KM_HEALTH_HR:      // 心率
        {
            [UIView animateWithDuration:0.3 animations:^{
                _scrollView.contentOffset = CGPointMake(SCREEN_WIDTH*2, 0);
            }];
        } break;
        case KM_HEALTH_BO:      // 血氧
        {
            [UIView animateWithDuration:0.3 animations:^{
                _scrollView.contentOffset = CGPointMake(SCREEN_WIDTH*3, 0);
            }];
        } break;
        case KM_HEALTH_STEP:    // 记步
        {
            [UIView animateWithDuration:0.3 animations:^{
                _scrollView.contentOffset = CGPointMake(SCREEN_WIDTH*4, 0);
            }];
        } break;
        case KM_HEALTH_SLEEPANALYSE:    // 睡眠
        {
            [UIView animateWithDuration:0.3 animations:^{
                _scrollView.contentOffset = CGPointMake(SCREEN_WIDTH*5, 0);
            }];
        } break;
        default:
            break;
    }
}

#pragma mark - UIScrollViewDelegate

- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView {
    if (scrollView == self.scrollView) {
        CGFloat scrollviewW =  scrollView.frame.size.width;
        CGFloat x = scrollView.contentOffset.x;
        int page = (x + scrollviewW / 2) / scrollviewW;
        [self selectHealthBtnWithIndex:page];
        [self updateBottomButtonTitle];
    }
}

- (void)selectHealthBtnWithIndex:(NSInteger)btnIndex {
    for (int i = 0; i <self.navigationButtonCount ; i++) {
        UIButton *button = (UIButton *)[self.view viewWithTag:KM_HEALTH_BP + i];
        if (i == btnIndex) {
            button.selected = YES;
            button.alpha = 0.6;
            [UIView animateWithDuration:0.6 animations:^{
                button.alpha = 1;
            }];
        } else {
            button.selected = NO;
        }
    }
    
    // 更新最后更新时间
    switch (btnIndex) {
        case 0:         // 血压
            if (self.dateModel.bpStartDate == nil ||
                [self.bpLastMeasureDate isEqualToString:kLoadStringWithKey(@"HealthRecord_VC_no_records")]) {
                if (_BPModel.list.count > 0) {
                    KMBPDetailModel *bp = _BPModel.list[0];
                    self.bpLastMeasureDate = [NSString stringWholeWithDate:bp.bpTime];
                } else {
                    self.bpLastMeasureDate = kLoadStringWithKey(@"HealthRecord_VC_no_records");
                }
            }
            self.lastTimeLabel.text = self.bpLastMeasureDate;
            break;
        case 1:         // 血糖
            if (self.dateModel.bsStartDate == nil ||
                [self.bsLastMeasureDate isEqualToString:kLoadStringWithKey(@"HealthRecord_VC_no_records")]) {
                if (_BSModel.list.count > 0) {
                    KMBSDetailModel *bs = _BSModel.list[0];
                    self.bsLastMeasureDate = [NSString stringWholeWithDate:bs.bsTime > 0 ? bs.bsTime : bs.createDate];
                } else {
                    self.bsLastMeasureDate = kLoadStringWithKey(@"HealthRecord_VC_no_records");
                }
            }
            self.lastTimeLabel.text = self.bsLastMeasureDate;
            break;
        case 2:         // 心率
            if (self.dateModel.hrStartDate == nil ||
                [self.hrLastMeasureDate isEqualToString:kLoadStringWithKey(@"HealthRecord_VC_no_records")]) {
                if (_HRModel.list.count > 0) {
                    KMHRDetailModel *hr = [_HRModel.list objectAtIndex:0];
                    self.hrLastMeasureDate = [NSString stringWholeWithDate:hr.bsTime > 0 ? hr.bsTime : hr.createDate];
                } else {
                    self.hrLastMeasureDate = kLoadStringWithKey(@"HealthRecord_VC_no_records");
                }
            }
            self.lastTimeLabel.text = self.hrLastMeasureDate;
            break;
        case 3:         // 血氧
            if (self.dateModel.boStartDate == nil ||
                [self.boLastMeasureDate isEqualToString:kLoadStringWithKey(@"HealthRecord_VC_no_records")]) {
                if (_BOModel.list.count > 0) {
                    KMBODetailModel *bo = _BOModel.list[0];
                    self.boLastMeasureDate = [NSString stringWholeWithDate:bo.oxyTime];
                } else {
                    self.boLastMeasureDate = kLoadStringWithKey(@"HealthRecord_VC_no_records");
                }
            }
            self.lastTimeLabel.text = self.boLastMeasureDate;
            break;
        case 4:         // 计步
            if (self.dateModel.stepStartDate == nil ||
                [self.stepLastMeasureDate isEqualToString:kLoadStringWithKey(@"HealthRecord_VC_no_records")]) {
                if (_stepModel.list.count > 0) {
                    KMStepDetailModel *step = _stepModel.list[0];
                    self.stepLastMeasureDate = [NSString stringWholeWithDate:step.sTime];
                } else {
                    self.stepLastMeasureDate = kLoadStringWithKey(@"HealthRecord_VC_no_records");
                }
            }
            self.lastTimeLabel.text = self.stepLastMeasureDate;
            break;
        case 5: //睡眠
            if(self.dateModel.sleepDate == nil ||
               [self.sleepQAMeasureDate isEqualToString:kLoadStringWithKey(@"HealthRecord_VC_no_records")]){
                if(_sleepQAModel){
                    self.sleepQAMeasureDate = [NSString stringWholeWithDate:_sleepQAModel.collectTime];
                }else{
                    self.sleepQAMeasureDate = kLoadStringWithKey(@"HealthRecord_VC_no_records");
                }
            }
            self.lastTimeLabel.text = self.sleepQAMeasureDate;
            break;
        default:
            break;
    }
}

#pragma mark - 网络请求

#pragma mark 设备列表
- (void)updateDeviceListFromServer {
    WS(ws);
    [SVProgressHUD show];
    [[KMNetAPI manager] getDevicesListWithAccount:member.loginAccount Block:^(int code, NSString *res) {
        KMNetworkResModel *resModel = [KMNetworkResModel mj_objectWithKeyValues:res];
        if (code == 0 && resModel.errorCode <= kNetReqSuccess) {
            [SVProgressHUD dismiss];
            _deviceListModel = [KMBundleDevicesModel mj_objectWithKeyValues:resModel.content];
            //如果没有绑定设备条状到添加设备页面
            if (_deviceListModel.list.count == 0) {
                [ws jumpToBundleDeviceVC];
                return;
            }

            // 处理推送信息：如果传了imei则默认显示这个imei的信息
            if (_pushModel.content.imei.length > 0) {
                for (int i = 0; i < _deviceListModel.list.count; i++) {
                    KMBundleDevicesDetailModel *m = [_deviceListModel.list objectAtIndex:i];
                    if ([_pushModel.content.imei isEqualToString:m.imei]) {
                        _deviceDetailModel = m;
                        break;
                    }
                }
            } else {
                // 使用当前使用的设备
                _deviceDetailModel = nil;
                for (int i = 0; i < _deviceListModel.list.count; i++) {
                    KMBundleDevicesDetailModel *detail = _deviceListModel.list[i];
                    if (detail.myWear == 1) {
                        _deviceDetailModel = detail;
                        break;
                    }
                }
                
                // 如果没有正在使用的设备，选择第一个设备作为当前使用设备
                if (_deviceDetailModel == nil) {
                    _deviceDetailModel = _deviceListModel.list[0];
                }
            }
            
            [ws refreshView];
            
            [_userImageView sdImageWithIMEI:_deviceDetailModel.imei];
            _userNameLabel.text = _deviceDetailModel.realName;
            
            [ws requestAllHealthInfo];
        } else {
            [SVProgressHUD showErrorWithStatus:kNetReqFailWithCode(resModel.errorCode)];
            DMLog(@"*** DeviceList: %@", resModel.msg);
            // 这里有个问题，由于没有选定的IMEI，后面的健康记录请求全部失败
        }
    }];
}

#pragma mark 如果没有绑定设备，直接跳转到设备管理页面
- (void)jumpToBundleDeviceVC {
    self.addNewDeviceAlertView = [[CustomIOSAlertView alloc] init];
    KMCommonAlertView *view = [[KMCommonAlertView alloc] initWithFrame:CGRectMake(0, 0,300, 200)];
    view.titleLabel.text = kLoadStringWithKey(@"DeviceSetting_VC_select");
    view.titleLabel.backgroundColor = kRedColor;
    view.msgLabel.text = kLoadStringWithKey(@"DeviceSetting_VC_no_device_bind");
    view.buttonsArray = @[kLoadStringWithKey(@"DeviceSetting_VC_YES")];
    
    UIButton *cancelButton = view.realButtons[0];
    cancelButton.tag = 100;
    [cancelButton addTarget:self action:@selector(jumpToRealBundleDeviceVC:) forControlEvents:UIControlEventTouchUpInside];
    
    self.addNewDeviceAlertView.containerView = view;
    self.addNewDeviceAlertView.buttonTitles = nil;
    [self.addNewDeviceAlertView setUseMotionEffects:NO];
    
    [self.addNewDeviceAlertView show];
}

- (void)jumpToRealBundleDeviceVC:(UIButton *)sender {
    [self.addNewDeviceAlertView close];
    KMDeviceSettingVC *vc = [KMDeviceSettingVC new];
    [self.navigationController pushViewController:vc animated:YES];
}

#pragma mark 获取所有的健康记录
- (void)requestAllHealthInfo {
    [self requestHealthInfoWithType:KM_HEALTH_BP];
    [self requestHealthInfoWithType:KM_HEALTH_BS];
    [self requestHealthInfoWithType:KM_HEALTH_HR];
    [self requestHealthInfoWithType:KM_HEALTH_STEP];
    [self requestHealthInfoWithType:KM_HEALTH_BO];
    [self requestHealthInfoWithType:KM_HEALTH_SLEEPANALYSE];
}

- (void)requestHealthInfoWithType:(KMHealthRecordType)type
{
    NSString *request;
    
    switch (type) {
        case KM_HEALTH_BP:           // 血压
            if (_dateModel.bpStartDate && _dateModel.bpEndDate) {
                
                NSString *start = [[NSString stringWithNSDate:_dateModel.bpStartDate] stringByAppendingString:@" 00:00"];
                
                NSString *end = [[NSString stringWithNSDate:_dateModel.bpEndDate] stringByAppendingString:@" 23:59"];
                request = [NSString stringWithFormat:@"bp/during/%@/%@/%@",
                           _deviceDetailModel.imei,
                           start, end];
            } else {
                request = [NSString stringWithFormat:@"bp/count/%@/0/10", _deviceDetailModel.imei];
            }
            break;
        case KM_HEALTH_BS:           // 血糖
            if (_dateModel.bsStartDate && _dateModel.bsEndDate) {
                NSString *start = [[NSString stringWithNSDate:_dateModel.bsStartDate] stringByAppendingString:@" 00:00"];
                NSString *end = [[NSString stringWithNSDate:_dateModel.bsEndDate] stringByAppendingString:@" 23:59"];
                request = [NSString stringWithFormat:@"bs/during/%@/%@/%@",
                           _deviceDetailModel.imei,
                           start, end];
            } else {
                request = [NSString stringWithFormat:@"bs/count/%@/0/10", _deviceDetailModel.imei];
            }
            break;
        case KM_HEALTH_HR:           // 心率
            if (_dateModel.hrStartDate && _dateModel.hrEndDate) {
                NSString *start = [[NSString stringWithNSDate:_dateModel.hrStartDate] stringByAppendingString:@" 00:00"];
                NSString *end = [[NSString stringWithNSDate:_dateModel.hrEndDate] stringByAppendingString:@" 23:59"];
                request = [NSString stringWithFormat:@"hr/during/%@/%@/%@",_deviceDetailModel.imei,start, end];
            } else {
                request = [NSString stringWithFormat:@"hr/count/%@/0/10", _deviceDetailModel.imei];
            }
            break;
        case KM_HEALTH_STEP:         // 计步
            if (_dateModel.stepStartDate && _dateModel.stepEndDate) {
                NSString *start = [[NSString stringWithNSDate:_dateModel.stepStartDate] stringByAppendingString:@" 00:00"];
                NSString *end = [[NSString stringWithNSDate:_dateModel.stepEndDate] stringByAppendingString:@" 23:59"];
                request = [NSString stringWithFormat:@"step/during/%@/%@/%@",
                           _deviceDetailModel.imei,
                           start, end];
            } else {
                request = [NSString stringWithFormat:@"step/count/%@/0/10", _deviceDetailModel.imei];
            }
            break;
        case KM_HEALTH_BO:           // 血氧
            if (_dateModel.boStartDate && _dateModel.boEndDate) {
                NSString *start = [[NSString stringWithNSDate:_dateModel.boStartDate] stringByAppendingString:@" 00:00"];
                NSString *end = [[NSString stringWithNSDate:_dateModel.boEndDate] stringByAppendingString:@" 23:59"];
                request = [NSString stringWithFormat:@"bo/during/%@/%@/%@",
                           _deviceDetailModel.imei,
                           start, end];
            } else {
                request = [NSString stringWithFormat:@"bo/count/%@/0/10", _deviceDetailModel.imei];
            }
            break;
        case KM_HEALTH_SLEEPANALYSE:{
            
            NSString* sleepDateString = nil;
            
            if (_dateModel.sleepDate) {
                sleepDateString = [NSString stringWithNSDate:_dateModel.sleepDate];
            } else {
                sleepDateString = [NSString stringWithNSDate:[NSDate date]];
            }
            
            request = [NSString stringWithFormat:@"data/sleep/%@/%@",_deviceDetailModel.imei,sleepDateString];
        }
            break;
            
        default:
            return;
    }
    
    WS(ws);
    
    [[KMNetAPI manager] commonGetRequestWithURL:request Block:^(int code, NSString *res) {
        KMNetworkResModel *resModel = [KMNetworkResModel mj_objectWithKeyValues:res];
        if (code == 0 && resModel.errorCode <= kNetReqSuccess) {
            [SVProgressHUD dismiss];
            switch (type) {
                case KM_HEALTH_BP:          // 血压
                    _BPModel = [KMBPModel mj_objectWithKeyValues:resModel.content];
                    [_scrollView addSubview:ws.BPView];
                    break;
                case KM_HEALTH_BS:          // 血糖
                    _BSModel = [KMBSModel mj_objectWithKeyValues:resModel.content];
                    [_scrollView addSubview:ws.BSView];
                    break;
                case KM_HEALTH_HR:          // 心率
                    _HRModel = [KMHRModel mj_objectWithKeyValues:resModel.content];
                    [_scrollView addSubview:self.HRView];
                    break;
                case KM_HEALTH_STEP:        // 记步
                    _stepModel = [KMStepModel mj_objectWithKeyValues:resModel.content];
                    [_scrollView addSubview:self.StepView];
                    break;
                case KM_HEALTH_BO:          // 血氧
                    _BOModel = [KMBOModel mj_objectWithKeyValues:resModel.content];
                    [_scrollView addSubview:self.BOView];
                    break;
                case KM_HEALTH_SLEEPANALYSE: // 睡眠质量分析
                    _sleepQAModel = [KMSleepQAModel mj_objectWithKeyValues:resModel.content];
                    [_scrollView addSubview:self.SleepAnalysisView];
                    break;
                default:
                    break;
            }
            if (type == [self currentSelectBtnIndex]) {
                [self selectHealthBtnWithIndex:[self currentSelectBtnIndex] - KM_HEALTH_BP];
                [self updateBottomButtonTitle];
            }
        } else {
            [SVProgressHUD showErrorWithStatus:kNetReqFailWithCode(resModel.errorCode)];
        }
    }];
}

#pragma mark - 立即测试心率
-(void)immediateTestHR{
    NSString* request = [NSString stringWithFormat:@"immediate/hr/%@/%@",member.loginAccount,_deviceDetailModel.imei];
    
    [[KMNetAPI manager] commonGetRequestWithURL:request Block:^(int code, NSString *res) {
        
        KMNetworkResModel * resModel = [KMNetworkResModel mj_objectWithKeyValues:res];
        if (code == 0 && resModel.errorCode <= kNetReqSuccess)
        {
            // 提示成功
            [SVProgressHUD showSuccessWithStatus:kLoadStringWithKey(@"Common_network_request_OK")];
        }else
        {
            [SVProgressHUD showErrorWithStatus:kNetReqFailWithCode(resModel.errorCode)];
        }
        
    }];
}

#pragma mark - 切换日期
- (void)changeMeasureDateWithIndex:(NSInteger)index {
    
    NSInteger currentIndex = [self currentSelectBtnIndex];
    //睡眠质量分析
    if(currentIndex == KM_HEALTH_SLEEPANALYSE){
        
        KMChangeSingleDateVC *vc = [[KMChangeSingleDateVC alloc] init];
        vc.delegate = self;
        vc.currentIndex = [self currentSelectBtnIndex];
        vc.chooseDate = self.dateModel.sleepDate;
        
        UINavigationController *nav = [[UINavigationController alloc] initWithRootViewController:vc];
        [self presentViewController:nav animated:YES completion:nil];
        return;
    }
    
    KMChangeDateVC *vc = [[KMChangeDateVC alloc] init];
    vc.delegate = self;
    vc.currentIndex = [self currentSelectBtnIndex];
    switch (currentIndex) {
        case KM_HEALTH_BP:      // 血压
        {
            vc.startDate = self.dateModel.bpStartDate;
            vc.endDate = self.dateModel.bpEndDate;
        } break;
        case KM_HEALTH_BS:      // 血糖
        {
            vc.startDate = self.dateModel.bsStartDate;
            vc.endDate = self.dateModel.bsEndDate;
        } break;
        case KM_HEALTH_HR:      // 心率
        {
            vc.startDate = self.dateModel.hrStartDate;
            vc.endDate = self.dateModel.hrEndDate;
        } break;
        case KM_HEALTH_STEP:    // 计步
        {
            vc.startDate = self.dateModel.stepStartDate;
            vc.endDate = self.dateModel.stepEndDate;
        } break;
        case KM_HEALTH_BO:      // 血氧
        {
            vc.startDate = self.dateModel.boStartDate;
            vc.endDate = self.dateModel.boEndDate;
        } break;
        default:
            break;
    }
    
    UINavigationController *nav = [[UINavigationController alloc] initWithRootViewController:vc];
    [self presentViewController:nav animated:YES completion:nil];
}

#pragma mark - KMChangeDateDelegate
- (void)changeDateComplete:(NSDate *)startDate endDate:(NSDate *)endDate Index:(NSInteger)index
{
    //修改人:钟，修改时间:16-11-22，修改说明:4.8.1 需求:健康记录——选择日期：查看健康记录时，在血压记录选择了一个时间段，那么切换查看其他记录时建议都显示前面已选择的日期
    //修改前代码行开始
    /*switch (index) {
     case KM_HEALTH_BP:      // 血压
     {
     self.dateModel.bpStartDate = startDate;
     self.dateModel.bpEndDate = endDate;
     } break;
     case KM_HEALTH_BS:      // 血糖
     {
     self.dateModel.bsStartDate = startDate;
     self.dateModel.bsEndDate = endDate;
     } break;
     case KM_HEALTH_HR:      // 心率
     {
     self.dateModel.hrStartDate = startDate;
     self.dateModel.hrEndDate = endDate;
     } break;
     case KM_HEALTH_STEP:    // 计步
     {
     self.dateModel.stepStartDate = startDate;
     self.dateModel.stepEndDate  = endDate;
     } break;
     case KM_HEALTH_BO:      // 血氧
     {
     self.dateModel.boStartDate = startDate;
     self.dateModel.boEndDate = endDate;
     } break;
     default:
     break;
     }*/
    // 血压
    self.dateModel.bpStartDate = startDate;
    self.dateModel.bpEndDate = endDate;
    
    // 血糖
    self.dateModel.bsStartDate = startDate;
    self.dateModel.bsEndDate = endDate;
    
    // 心率
    self.dateModel.hrStartDate = startDate;
    self.dateModel.hrEndDate = endDate;
    
    // 计步
    self.dateModel.stepStartDate = startDate;
    self.dateModel.stepEndDate  = endDate;
    
    // 血氧
    self.dateModel.boStartDate = startDate;
    self.dateModel.boEndDate = endDate;
    //修改前代码行结束
    // 重新请求数据
    [SVProgressHUD show];
    [self requestHealthInfoWithType:index];
}

- (void)changeDateComplete:(NSDate *)currentDate Index:(NSInteger)index{
    if(index == KM_HEALTH_SLEEPANALYSE) //睡眠质量分析
    {
        self.dateModel.sleepDate = currentDate;
    }
    [self requestHealthInfoWithType:index];
}

#pragma mark - 返回
- (void)backBarButtonDidClicked:(UIButton *)sender {
    [self.navigationController popViewControllerAnimated:YES];
}

#pragma mark --- 信息提示框显示
//显示信息提示框
-(void)customAlertViewShowWithMessage:(NSString *)message withStatus:(BOOL)status
{
    // 提示框
    self.userAction = [[CustomIOSAlertView alloc] init];
    self.userAction.buttonTitles = nil;
    [self.userAction setUseMotionEffects:NO];
    
    UIView * alertView = [[UIView alloc] initWithFrame:CGRectMake(0,0,SCREEN_WIDTH*0.9,220)];
    alertView.backgroundColor = [UIColor whiteColor];
    self.userAction.containerView = alertView;
    
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
    [self.userAction show];
}

//获取当前语音环境
- (NSString*)getPreferredLanguage
{
    
    NSUserDefaults * defaults = [NSUserDefaults standardUserDefaults];
    
    NSArray * allLanguages = [defaults objectForKey:@"AppleLanguages"];
    
    NSString * preferredLang = [allLanguages objectAtIndex:0];
    
    DMLog(@"当前语言:%@", preferredLang);
    
    return [preferredLang substringToIndex:2];
    
}

- (NSString *)currentLanguage{
    if (_currentLanguage != nil) {
        return _currentLanguage;
    }
    
    _currentLanguage = [self getPreferredLanguage];
    return _currentLanguage;
}



@end
