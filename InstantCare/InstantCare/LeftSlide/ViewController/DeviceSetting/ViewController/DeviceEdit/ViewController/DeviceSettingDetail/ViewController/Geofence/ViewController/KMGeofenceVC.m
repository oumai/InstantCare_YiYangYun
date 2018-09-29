//
//  KMGeofenceVC.m
//  InstantCare
//
//  Created by bruce zhu on 16/8/11.
//  Copyright © 2016年 omg. All rights reserved.
//

#import "KMGeofenceVC.h"
#import <MapKit/MapKit.h>
#import "KMTitleValueView.h"
#import "KMAnnotation.h"
#import "KMLocationManager.h"
#import "KMGeofenceModel.h"
#import "KMPushMsgModel.h"
#import "KMNetAPI.h"
#import "MJExtension.h"
#define kBottomCellHeight       32

#define kMinSliderValue         100
#define kMaxSliderValue         5000

@interface KMGeofenceVC () <MKMapViewDelegate, UITableViewDelegate,CLLocationManagerDelegate,UISearchBarDelegate,UITableViewDelegate,UITableViewDataSource>

/// Geofence模型
@property (nonatomic, strong) KMGeofenceModel *geofenceModel;

/**
 *  iOS自带的地图
 */
@property (nonatomic, strong) MKMapView *mapView;

/**
 *  地图上指示当前点的图标
 */
@property (nonatomic, strong) KMAnnotation *annotation;

/**
 *  用户当前点的图标
 */
@property (nonatomic, strong) KMAnnotation *userAnnotation;

/**
 *  电子围栏的图标
 */
@property (nonatomic, strong) KMAnnotation *blueAnnotation;

/**
 *  用户当前点的图标
 */
@property (nonatomic, strong) KMAnnotation *searchAnnotation;



/// 当前设定的坐标
@property (nonatomic, assign) CLLocationCoordinate2D currentCoord;

/// 当前设定电子围栏半径
@property (nonatomic, assign) CLLocationDistance currentRadius;

/// 滑动条
@property (nonatomic, strong) UISlider *slider;

/// 地址栏
@property (nonatomic, strong) UILabel *topWhiteLabel;

/// 底部设置视图
@property (nonatomic, strong) UIView *bottomSettingView;

/// 当前经度
@property (nonatomic, strong) KMTitleValueView *currentLongView;

/// 当前维度
@property (nonatomic, strong) KMTitleValueView *currentLatView;

/// 围栏半径
@property (nonatomic, strong) KMTitleValueView *geofenceRadiusView;

/// 开启围栏
@property (nonatomic, strong) UISwitch *geofenceSwitchOn;

///定位手机按钮
@property (nonatomic, strong) UIButton *arriveMyLocationButton;

///搜索
@property (nonatomic, strong) UISearchBar* addressSearchBar;

///local manager
@property (nonatomic, strong) CLLocationManager* locationManager;

/** 表视图 */
@property (nonatomic, strong) UITableView *placeTableView;

/** MKPlaceMarks */
@property (nonatomic, strong) NSArray *placeMarks;

/** KMPushMsgModel */
@property (nonatomic, strong) KMPushMsgModel *model;


@end

@implementation KMGeofenceVC

//  placeTableView
- (UITableView *)placeTableView
{
    if(_placeTableView == nil)
    {
        _placeTableView = [[UITableView alloc] initWithFrame:CGRectMake(0, 0,0,0) style:UITableViewStylePlain];
        _placeTableView.delegate   = self;
        _placeTableView.dataSource = self;
        _placeTableView.backgroundColor = [UIColor clearColor];
    }
    return _placeTableView;
}

/**
 *   便利构造器
 */
- (instancetype)initGeofenceWithModel:(KMPushMsgModel *)model
{
    self = [super init];
    if (self) {
        
        self.model = model;
    }
    return self;
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    /// 记录是否在电子围栏页面 (收到电子围栏推送时 如果在电子围栏页面 直接刷新)
    member.isGeofenceAppear = YES;
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    /// 记录是否在电子围栏页面 (收到电子围栏推送时 如果不在电子围栏页面 弹框提示是否跳转到电子围栏)
    member.isGeofenceAppear = NO;
    
}

- (void)dealloc{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}


- (void)viewDidLoad {
    [super viewDidLoad];
    [self configNavBar];
    [self configView];
    
    self.locationManager = [[CLLocationManager alloc] init];
    self.locationManager.delegate = self;
    
    if ([[[UIDevice currentDevice] systemVersion] doubleValue] > 8.0){
        //设置定位权限 仅ios8有意义
        [self.locationManager requestWhenInUseAuthorization];// 前台定位
        //[locationManager requestAlwaysAuthorization];// 前后台同时定位
    }
    
    /// 监听电子围栏通知
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(kmGeofenceRemoteNotification:) name:@"kmGeofenceRemoteNotification" object:nil];
    
    self.addressSearchBar.delegate = self;
    
    if (self.model != nil) {
        
        [self geofencePushHandle];

    }else{
        
        [self updateGeofenceFromServer];
    }
}

#pragma mark - 电子围栏推送处理
- (void)kmGeofenceRemoteNotification:(NSNotification *)notify {
    
    NSDictionary *userInfo = notify.object;
    
    if (userInfo) {
        
        self.model = [KMPushMsgModel mj_objectWithKeyValues:userInfo];
        
        [self geofencePushHandle];
    }
}

- (void)geofencePushHandle{
    // 设置地图中心点, 只在网络请求成功后设置一次
    MKCoordinateRegion region;
    region.span = MKCoordinateSpanMake(0.1, 0.1);
    region.center = CLLocationCoordinate2DMake(self.model.content.lat, self.model.content.lon);
    [_mapView setRegion:region animated:YES];
    /// 地图上添加手表用户位置大头针
    [self addBlueLocationAnnotation:region.center];
    /// 查询imei的电子围栏范围 添加到地图上
    [self updatePushGeofenceFromServer];
}

- (void)configNavBar
{
    UIButton *leftNavButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [leftNavButton setBackgroundImage:[UIImage imageNamed:@"return_normal"] forState:UIControlStateNormal];
    [leftNavButton addTarget:self
                      action:@selector(backBarButtonDidClicked:)
            forControlEvents:UIControlEventTouchUpInside];
    leftNavButton.frame = CGRectMake(0, 0, 30, 30);
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:leftNavButton];
    
    UIButton *rightNarBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    [rightNarBtn setTitle:kLoadStringWithKey(@"Common_save") forState:UIControlStateNormal];
    [rightNarBtn addTarget:self
                    action:@selector(rightBarButtonDidClicked:)
          forControlEvents:UIControlEventTouchUpInside];
    rightNarBtn.frame = CGRectMake(0, 0, 60, 30);
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:rightNarBtn];
    
    self.navigationItem.title = kLoadStringWithKey(@"Geofence_VC_title");
}

#pragma mark - 返回
- (void)backBarButtonDidClicked:(UIButton *)sender {
    [self.navigationController popViewControllerAnimated:YES];
}

#pragma mark - 保存设置
- (void)rightBarButtonDidClicked:(UIButton *)sender {
    
    WS(ws);
    NSString *reqURL;
    if (self.imei != nil) {
        reqURL = [NSString stringWithFormat:@"deviceSettingGfence/%@/%@", member.loginAccount, self.imei];
    }else if (self.model.content.imei != nil){
        reqURL = [NSString stringWithFormat:@"deviceSettingGfence/%@/%@", member.loginAccount, self.model.content.imei];
    }else{
        [SVProgressHUD showErrorWithStatus:@"IMEI号为空"];
    }
    
    [SVProgressHUD show];
    [[KMNetAPI manager] commonPOSTRequestWithURL:reqURL jsonBody:[_geofenceModel mj_JSONString] Block:^(int code, NSString *res) {
        KMNetworkResModel *resModel = [KMNetworkResModel mj_objectWithKeyValues:res];
        if (code == 0 && resModel.errorCode <= kNetReqSuccess) {
            [SVProgressHUD dismiss];
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                [ws.navigationController popViewControllerAnimated:YES];
            });
        } else {
            [SVProgressHUD showErrorWithStatus:resModel.msg.length > 0 ? resModel.msg : kNetError];
        }
    }];
}

- (void)updatePushGeofenceFromServer
{
    WS(ws);
    //[SVProgressHUD show];
    NSString * reqURL = [NSString stringWithFormat:@"deviceSettingGfence/%@/%@", member.loginAccount, self.model.content.imei];
    
    [[KMNetAPI manager] commonGetRequestWithURL:reqURL Block:^(int code, NSString *res) {
        KMNetworkResModel *resModel = [KMNetworkResModel mj_objectWithKeyValues:res];
        if (code == 0 && resModel.errorCode <= kNetReqSuccess) {
            [SVProgressHUD dismiss];
            _geofenceModel = [KMGeofenceModel mj_objectWithKeyValues:resModel.content];
            // 如果模型为空，单独分配一个
            if (_geofenceModel == nil) {
                _geofenceModel = [KMGeofenceModel new];
            }
            
            [ws updateUIWithGeofenceModel:_geofenceModel];
            if (_geofenceModel && _geofenceModel.longitude > 0.0001) {
                // 设置地图中心点, 只在网络请求成功后设置一次
                MKCoordinateRegion region;
                region.span = MKCoordinateSpanMake(0.1, 0.1);
                region.center = CLLocationCoordinate2DMake(_geofenceModel.latitude, _geofenceModel.longitude);
                [self addUserLocationAnnotation:region.center];
            }
        } else {
            [SVProgressHUD showErrorWithStatus:resModel.msg.length > 0 ? resModel.msg : kNetError];
        }
    }];
    
}

- (void)updateGeofenceFromServer {
    
    WS(ws);
    [SVProgressHUD show];
    NSString * reqURL = [NSString stringWithFormat:@"deviceSettingGfence/%@/%@", member.loginAccount, self.imei];
  
    [[KMNetAPI manager] commonGetRequestWithURL:reqURL Block:^(int code, NSString *res) {
        KMNetworkResModel *resModel = [KMNetworkResModel mj_objectWithKeyValues:res];
        if (code == 0 && resModel.errorCode <= kNetReqSuccess) {
            [SVProgressHUD dismiss];
            _geofenceModel = [KMGeofenceModel mj_objectWithKeyValues:resModel.content];
            // 如果模型为空，单独分配一个
            if (_geofenceModel == nil) {
                _geofenceModel = [KMGeofenceModel new];
            }
            
            [ws updateUIWithGeofenceModel:_geofenceModel];
            if (_geofenceModel && _geofenceModel.longitude > 0.0001) {
                // 设置地图中心点, 只在网络请求成功后设置一次
                MKCoordinateRegion region;
                region.span = MKCoordinateSpanMake(0.1, 0.1);
                region.center = CLLocationCoordinate2DMake(_geofenceModel.latitude, _geofenceModel.longitude);
                [_mapView setRegion:region animated:YES];
            }
        } else {
            
            [SVProgressHUD showErrorWithStatus:resModel.msg.length > 0 ? resModel.msg : kNetError];
        }
    }];
}

- (void)updateUIWithGeofenceModel:(KMGeofenceModel *)geofence {
    
    self.currentCoord = CLLocationCoordinate2DMake(geofence.latitude, geofence.longitude);
    self.currentRadius = geofence.radius;
    self.slider.value = geofence.radius;
    self.currentLatView.valueLabel.text = [NSString stringWithFormat:@"%.5f", geofence.latitude];
    self.currentLongView.valueLabel.text = [NSString stringWithFormat:@"%.5f", geofence.longitude];
    self.geofenceSwitchOn.on = geofence.enable == 0 ? NO : YES;
    
    self.geofenceRadiusView.valueLabel.text = [NSString stringWithFormat:@"%d%@", geofence.radius, kLoadStringWithKey(@"Geofence_VC_meter")];
    
    // 电子围栏外面的圈
    [self addGeofenceWithCenterCoordinate:self.currentCoord Radius:self.currentRadius];
    
    // 电子围栏中心点图标
    [self addUserLocationAnnotation:self.currentCoord];

    // 以这个坐标解析地理位置
    CLLocation *location = [[CLLocation alloc] initWithLatitude:self.currentCoord.latitude
                                                      longitude:self.currentCoord.longitude];
    [[KMLocationManager locationManager] startLocationWithLocation:location
                                                       resultBlock:^(NSString *address) {
                                                           _topWhiteLabel.text = [NSString stringWithFormat:@"%@: %@",
                                                                                  kLoadStringWithKey(@"Geofence_VC_address"),
                                                                                  address.length > 0 ? address : @""];
                                                           if (address.length > 0) {
                                                               _geofenceModel.address = address;
                                                           }
                                                       }];
}


- (void)configView {
    self.view.backgroundColor = [UIColor whiteColor];
    
    // 下方设置视图
    _bottomSettingView = [[UIView alloc] init];
    _bottomSettingView.backgroundColor = [[UIColor whiteColor] colorWithAlphaComponent:0.9];
    [self.view addSubview:_bottomSettingView];
    [_bottomSettingView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.right.bottom.equalTo(self.view);
    }];
    
    
    // 文字说明
    UILabel *topTitleLabel = [[UILabel alloc] init];
    topTitleLabel.textColor = kGrayTipColor;
    topTitleLabel.textAlignment = NSTextAlignmentCenter;
    topTitleLabel.font = [UIFont systemFontOfSize:13];
    topTitleLabel.text = kLoadStringWithKey(@"Geofence_VC_click_notes");
    [_bottomSettingView addSubview:topTitleLabel];
    [topTitleLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.right.equalTo(_bottomSettingView).offset(10);
        make.top.equalTo(_bottomSettingView).offset(8);
    }];
    
    // 当前经度
    self.currentLongView = [[KMTitleValueView alloc] initWithTitle:kLoadStringWithKey(@"Geofence_VC_longitude") value:@""];
    [_bottomSettingView addSubview:self.currentLongView];
    [self.currentLongView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(_bottomSettingView).offset(20);
        make.right.equalTo(_bottomSettingView);
        make.top.equalTo(topTitleLabel.mas_bottom).offset(8);
        make.height.equalTo(@kBottomCellHeight);
    }];
    
    // 当前纬度
    self.currentLatView = [[KMTitleValueView alloc] initWithTitle:kLoadStringWithKey(@"Geofence_VC_latitude") value:@""];
    [_bottomSettingView addSubview:self.currentLatView];
    [self.currentLatView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.right.equalTo(_currentLongView);
        make.top.equalTo(_currentLongView.mas_bottom).offset(8);
        make.height.equalTo(@kBottomCellHeight);
    }];
    
    // 围栏半径
    self.geofenceRadiusView = [[KMTitleValueView alloc] initWithTitle:kLoadStringWithKey(@"Geofence_VC_radius") value:@""];
    self.geofenceRadiusView.bottomLineView.hidden = YES;
    [_bottomSettingView addSubview:self.geofenceRadiusView];
    [self.geofenceRadiusView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.right.equalTo(_currentLongView);
        make.top.equalTo(_currentLatView.mas_bottom).offset(8);
        make.height.equalTo(@kBottomCellHeight);
    }];
    
    // 半径调整滑条
    _slider = [[UISlider alloc] init];
    _slider.minimumValue = kMinSliderValue;
    _slider.maximumValue = kMaxSliderValue;
    _slider.minimumTrackTintColor = kMainColor;
    _slider.thumbTintColor = kMainColor;
    [_slider addTarget:self action:@selector(sliderValueChanged:) forControlEvents:UIControlEventValueChanged];
    [_bottomSettingView addSubview:_slider];
    [_slider mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(_bottomSettingView).offset(40);
        make.top.equalTo(_geofenceRadiusView.mas_bottom);
        make.right.equalTo(_bottomSettingView).offset(-40);
        make.height.equalTo(@30);
    }];
    
    UIView *grayLineView = [[UIView alloc] init];
    grayLineView.backgroundColor = kGrayBackColor;
    [_bottomSettingView addSubview:grayLineView];
    [grayLineView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.right.equalTo(_currentLongView);
        make.top.equalTo(_slider.mas_bottom).offset(8);
        make.height.equalTo(@1);
    }];
    
    // 开启围栏标题
    KMTitleValueView *geofenceOnView = [[KMTitleValueView alloc] initWithTitle:kLoadStringWithKey(@"Geofence_VC_Geofence_ON") value:@""];
    geofenceOnView.bottomLineView.hidden = YES;
    [_bottomSettingView addSubview:geofenceOnView];
    [geofenceOnView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.right.height.equalTo(_currentLongView);
        make.top.equalTo(grayLineView).offset(8);
    }];
    
    // 围栏开启开关
    self.geofenceSwitchOn = [[UISwitch alloc] init];
    [self.geofenceSwitchOn addTarget:self action:@selector(openGeofence:) forControlEvents:UIControlEventValueChanged];
    [_bottomSettingView addSubview:self.geofenceSwitchOn];
    [self.geofenceSwitchOn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.right.centerY.equalTo(geofenceOnView.valueLabel);
    }];
    
    [_bottomSettingView mas_updateConstraints:^(MASConstraintMaker *make) {
        make.bottom.equalTo(geofenceOnView).offset(10);
    }];
    
    // 地图视图
    self.mapView = [[MKMapView alloc] init];
    self.mapView.delegate = self;
    [self.view addSubview:self.mapView];
    [self.mapView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.right.equalTo(self.view);
        make.top.equalTo(self.view).offset(64);
        make.bottom.equalTo(_bottomSettingView.mas_top);
    }];
    
    //搜索栏
    self.addressSearchBar = [[UISearchBar alloc]init];
    self.addressSearchBar.barTintColor = [[UIColor whiteColor] colorWithAlphaComponent:0.5];
    [self.mapView addSubview:_addressSearchBar];
    self.addressSearchBar.placeholder = kLoadStringWithKey(@"Geofence_SearchAddress");
    [self.addressSearchBar mas_makeConstraints:^(MASConstraintMaker *make) {
        make.right.equalTo(_mapView).offset(-15);
        make.left.equalTo(_mapView).offset(15);
        make.top.equalTo(_mapView).offset(20);
        make.height.equalTo(@(30));
    }];
  
    // tableView
    [self.view addSubview:self.placeTableView];
    [self.placeTableView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(_addressSearchBar.mas_bottom).offset(5);
        make.width.equalTo(_addressSearchBar);
        make.centerX.equalTo(_addressSearchBar);
        make.height.mas_offset(200);
        
    }];
    self.placeTableView.hidden = !self.placeMarks.count;
    
    // 最上方的显示地址Label
    self.topWhiteLabel = [[UILabel alloc] init];
    self.topWhiteLabel.backgroundColor = [[UIColor whiteColor] colorWithAlphaComponent:0.5];
    self.topWhiteLabel.text = @"";
    self.topWhiteLabel.font = [UIFont systemFontOfSize:10];
    self.topWhiteLabel.textAlignment = NSTextAlignmentCenter;
    [self.view addSubview:self.topWhiteLabel];
    [self.topWhiteLabel mas_makeConstraints:^(MASConstraintMaker *make) {
//        make.right.equalTo(_mapView).offset(-15);
//        make.left.equalTo(_mapView).offset(15);
//        make.top.equalTo(_mapView).offset(10);
        make.top.left.right.equalTo(_mapView);
        make.height.equalTo(@(20));
    }];

    
    ////地图移动手机位置
    self.arriveMyLocationButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [self.arriveMyLocationButton setImage:[UIImage imageNamed:@"myLocation"] forState:UIControlStateNormal];
    [self.arriveMyLocationButton setImage:[UIImage imageNamed:@"myLocationEnable"] forState:UIControlStateHighlighted];
    self.arriveMyLocationButton.backgroundColor = [UIColor whiteColor];
    [self.arriveMyLocationButton addTarget:self action:@selector(arriveMyLocationButtonClick) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:self.arriveMyLocationButton];
    [self.arriveMyLocationButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.width.equalTo(@30);
        make.height.equalTo(@30);
        make.left.equalTo(_mapView).offset(15);
        make.bottom.equalTo(_mapView.mas_bottom).offset(-10);
    }];

    // 地图点击事件, 获取点击点的坐标
    UITapGestureRecognizer *mTap = [[UITapGestureRecognizer alloc] initWithTarget:self
                                                                           action:@selector(mapDidTapWithGesture:)];
    [self.mapView addGestureRecognizer:mTap];
}

#pragma mark - 在地图上添加一个电子围栏圆圈
- (void)addGeofenceWithCenterCoordinate:(CLLocationCoordinate2D)coord Radius:(CLLocationDistance)radius {
    
    // 先移除之前显示的点
    [self.mapView removeOverlays:self.mapView.overlays];
    
    MKCircle *circle = [MKCircle circleWithCenterCoordinate:coord radius:radius];
    [self.mapView addOverlay:circle];
}

#pragma mark - 地图上添加一个图标
- (void)addUserLocationAnnotation:(CLLocationCoordinate2D)coord
{
    // 地图上只会存在一个标签
    if (self.annotation) {
        [self.mapView removeAnnotation:self.annotation];
    }
    self.annotation = [[KMAnnotation alloc] init];
    self.annotation.coordinate = coord;
    self.annotation.image = [UIImage imageNamed:@"pin_red"];
    
    [_mapView addAnnotation:self.annotation];
}

-(void)addUserCurrentLocationAnnotaion:(CLLocationCoordinate2D)coord{
    
    // 地图上只会存在一个标签
    if (self.userAnnotation) {
        [self.mapView removeAnnotation:self.userAnnotation];
    }
    self.userAnnotation = [[KMAnnotation alloc] init];
    self.userAnnotation.coordinate = coord;
    self.userAnnotation.image = [UIImage imageNamed:@"pin_blue"];
    
    [_mapView addAnnotation:self.userAnnotation];
    
}

/**
 *   添加蓝色大头针
 */
- (void)addBlueLocationAnnotation:(CLLocationCoordinate2D)coord
{
    
    [_mapView removeAnnotation:self.blueAnnotation];
    self.blueAnnotation = [[KMAnnotation alloc] init];
    self.blueAnnotation.coordinate = coord;
    self.blueAnnotation.image = [UIImage imageNamed:@"icon_pin_floating"];
    
    [_mapView addAnnotation:self.blueAnnotation];

}

/**
 *   添加红色大头针
 */
- (void)addRedLocationAnnotation:(CLLocationCoordinate2D)coord
{
    KMAnnotation* annotation = [[KMAnnotation alloc] init];
    annotation.coordinate = coord;
    annotation.image = [UIImage imageNamed:@"icon_paopao_waterdrop_streetscape"];
    
    [_mapView addAnnotation:annotation];
}


#pragma mark - MKMapViewDelegate
/**
 *   遮盖层
 */
- (MKOverlayRenderer *)mapView:(MKMapView *)mapView rendererForOverlay:(id<MKOverlay>)overlay
{
    if ([overlay isKindOfClass:[MKCircle class]]) {
        MKCircleRenderer *render = [[MKCircleRenderer alloc] initWithCircle:(MKCircle *)overlay];
        // 填充颜色
        render.fillColor = [kMainColor colorWithAlphaComponent:0.3];
        return render;
    }
    
    return nil;
}

- (MKAnnotationView *)mapView:(MKMapView *)mapView viewForAnnotation:(id<MKAnnotation>)annotation {
    if ([annotation isKindOfClass:[KMAnnotation class]]) {                  // iOS自带地图
        static NSString *key1 = @"AnnotationKey";
        MKAnnotationView *annotationView = [_mapView dequeueReusableAnnotationViewWithIdentifier:key1];
        if (!annotationView) {
            annotationView = [[MKAnnotationView alloc] initWithAnnotation:annotation
                                                          reuseIdentifier:key1];
            annotationView.canShowCallout = YES;
        }
        
        annotationView.annotation = annotation;
        annotationView.selected = YES;
        annotationView.image = ((KMAnnotation *)annotation).image;
        return annotationView;
    }
    
    return nil;
}

#pragma mark - 开启围栏
- (void)openGeofence:(UISwitch *)s {
    _geofenceModel.enable = s.isOn;
}

#pragma mark - 地图点击
- (void)mapDidTapWithGesture:(UIGestureRecognizer*)gestureRecognizer {
    
    CGPoint touchPoint = [gestureRecognizer locationInView:self.mapView];
    
    // 地图真实地理坐标
    CLLocationCoordinate2D touchMapCoordinate = [self.mapView convertPoint:touchPoint toCoordinateFromView:self.mapView];
    
    _geofenceModel.longitude = touchMapCoordinate.longitude;
    _geofenceModel.latitude = touchMapCoordinate.latitude;
    _geofenceModel.radius = (int)self.slider.value;
    
    [self updateUIWithGeofenceModel:_geofenceModel];
}

- (void)sliderValueChanged:(UISlider *)slider {
    
    self.currentRadius = slider.value;
    _geofenceModel.radius = (int)slider.value;
    
    self.geofenceRadiusView.valueLabel.text = [NSString stringWithFormat:@"%d%@", (int)slider.value, kLoadStringWithKey(@"Geofence_VC_meter")];
    
    [self addGeofenceWithCenterCoordinate:self.currentCoord Radius:self.currentRadius];
}

#pragma mark - 地图移动当前手机位置
-(void)arriveMyLocationButtonClick{
    
    if([CLLocationManager locationServicesEnabled]){
        
        [self.locationManager startUpdatingLocation];
        
    }else{
        //alert 开启定位:设置 > 隐私 > 位置 > 定位服务
    }
}

#pragma mark - location manager delegate

- (void)locationManager:(CLLocationManager *)manager didUpdateLocations:(NSArray<CLLocation *> *)locations{
    
    CLLocation* currentlocation = [locations lastObject];
    
    if(currentlocation){
        //获取经纬度
        NSLog(@"当前纬度:%f",currentlocation.coordinate.latitude);
        NSLog(@"当前经度:%f",currentlocation.coordinate.longitude);
        
        MKCoordinateRegion region;
        region.span = MKCoordinateSpanMake(1, 1);
        region.center = CLLocationCoordinate2DMake(currentlocation.coordinate.latitude, currentlocation.coordinate.longitude);
        [_mapView setRegion:region animated:YES];
        [self addUserCurrentLocationAnnotaion:region.center];
    }
    
    //停止位置更新
    [manager stopUpdatingLocation];
}

-(void)locationManager:(CLLocationManager*)manager didFailWithError:(NSError *)error{
    NSLog(@"error:%@",error);
}

- (void)locationManager:(CLLocationManager *)manager didChangeAuthorizationStatus:(CLAuthorizationStatus)status {
    switch (status) {
        case kCLAuthorizationStatusNotDetermined:
            if ([self.locationManager respondsToSelector:@selector(requestWhenInUseAuthorization)]) {
                [self.locationManager requestWhenInUseAuthorization];
            }
            break;
        default:
            break;
    }
}


#pragma  mark - search bar clicked
- (void)searchBarSearchButtonClicked:(UISearchBar *)searchBar{
//    NSString* searchAddressText = searchBar.text;
//    CLGeocoder * geocoder = [[CLGeocoder alloc ] init];
//    [geocoder geocodeAddressString:searchAddressText completionHandler:^(NSArray<CLPlacemark *> * _Nullable placemarks, NSError * _Nullable error)
//    {
//        NSMutableArray * temp = [NSMutableArray array];
//        for (CLPlacemark * placeMark in placemarks) {
//            MKPlacemark * mkPlaceMark = [[MKPlacemark alloc] initWithPlacemark:placeMark];
//            [temp addObject:mkPlaceMark];
//        }
//
//        self.placeMarks = temp;
//        self.placeTableView.hidden = !self.placeMarks.count;
//        CGFloat height = temp.count * 50;
//        if (height < 200) {
//            
//            [self.placeTableView mas_updateConstraints:^(MASConstraintMaker *make) {
//               
//                make.height.mas_offset(height);
//            }];
//        }
//        
//        [self.placeTableView reloadData];
//    }];
    
    
    MKCoordinateRegion region = _mapView.region;
    MKLocalSearchRequest *localSearchRequest = [[MKLocalSearchRequest alloc] init] ;
    localSearchRequest.region = region;
    localSearchRequest.naturalLanguageQuery = searchBar.text;//搜索关键词
    MKLocalSearch *localSearch = [[MKLocalSearch alloc] initWithRequest:localSearchRequest];
    
    [localSearch startWithCompletionHandler:^(MKLocalSearchResponse *response, NSError *error) {
        NSLog(@"the response's count is:%ld",response.mapItems.count);
        if (error)
        {
            NSLog(@"error info：%@",error);
        }
        else
        {
            NSMutableArray * temp = [NSMutableArray array];
            for (MKMapItem *mapItem in response.mapItems)
            {
                //CLLocationCoordinate2D Coordinate2D = mapItem.placemark.coordinate;
                
                //NSLog(@“Coordinate2D:%lf,%lf,\n placeMark,name:%@,thoroughfare:%@,subThoroughfare:%@,locality:%@,subLocality:%@,administrativeArea:%@,subAdministrativeArea:%@,country:%@,inlandWater:%@,ocean:%@,",Coordinate2D.latitude,Coordinate2D.longitude,mapItem.placemark.name);
//                NSLog(@"name:%@,\nthoroughfare:%@,\nsubThoroughfare:%@,\nlocality:%@,\nsubLocality:%@,\nadministrativeArea:%@,\nsubAdministrativeArea:%@,\ncountry:%@,\ninlandWater:%@,\nocean:%@",mapItem.placemark.name,mapItem.placemark.thoroughfare,mapItem.placemark.subThoroughfare,mapItem.placemark.locality,mapItem.placemark.subLocality,mapItem.placemark.administrativeArea,mapItem.placemark.subAdministrativeArea,mapItem.placemark.country,mapItem.placemark.inlandWater,mapItem.placemark.ocean);
                
                //                NSLog(@"addressDictionary:%@",mapItem.placemark.addressDictionary);
                [temp addObject:mapItem];
            }
            
            self.placeMarks = temp;
            self.placeTableView.hidden = !self.placeMarks.count;
            CGFloat height = temp.count * 50;
            if (height < 200) {
                
                [self.placeTableView mas_updateConstraints:^(MASConstraintMaker *make) {
                    
                    make.height.mas_offset(height);
                }];
            }
            
            [self.placeTableView reloadData];

            
        }
    }];
    
}

#pragma mark - UITableViewDataSource
/**
 *    分区
 */
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

/**
 *    分组
 */
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.placeMarks.count;
}

/**
 *    数据对象
 */
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    //1.创建cell
    static NSString * identifer = @"Subtitle";
    UITableViewCell * cell = [tableView dequeueReusableCellWithIdentifier:identifer];
    if (cell == nil) {
        
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:identifer];
    }
    
    //2.赋值cell
//    MKPlacemark * mapitem = self.placeMarks[indexPath.row];
//    ;
//    NSDictionary *addressDic= mapitem.addressDictionary;
//    NSString *addressString = addressDic[@"Name"];
//    cell.textLabel.text = addressString;
//
//    CLLocation *location=mapitem.location;//位置
//    CLRegion *region=mapitem.region;//区域
//    //详细地址信息字典,包含以下部分信息
//    NSLog(@"位置:%@,区域:%@,详细信息:%@",location,region,addressDic);
    
    MKMapItem *mapItem = self.placeMarks[indexPath.row];
//locality:丽水市,
//subLocality:缙云县,
//administrativeArea:浙江省,
    
    cell.textLabel.text = [NSString stringWithFormat:@"%@%@%@",mapItem.placemark.locality? :@"",mapItem.placemark.subLocality? :@"",mapItem.placemark.thoroughfare? :@""];
    cell.textLabel.font = [UIFont systemFontOfSize:14];
    //3.返回cell
    return cell;
}

/**
 *   tableView 点击方法
 */
-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView  deselectRowAtIndexPath:indexPath animated:YES];

    MKMapItem *mapitem =self.placeMarks[indexPath.row];
    MKPlacemark *mkPlaceMark= mapitem.placemark;  //地图的地标
    MKCoordinateRegion region;
    region.span = MKCoordinateSpanMake(0.1,0.1);
    region.center = CLLocationCoordinate2DMake(mkPlaceMark.coordinate.latitude, mkPlaceMark.coordinate.longitude);
    [_mapView setRegion:region animated:YES];
    [self addUserLocationAnnotation:region.center];
    // 电子围栏外面的圈
    [self addGeofenceWithCenterCoordinate:region.center Radius:self.currentRadius];
    self.placeTableView.hidden = YES;

}

-(void)addSearchLocationAnnotaion:(CLLocationCoordinate2D)coord{
    
    // 地图上只会存在一个标签
    if (self.searchAnnotation) {
        [self.mapView removeAnnotation:self.searchAnnotation];
    }
    self.searchAnnotation = [[KMAnnotation alloc] init];
    self.searchAnnotation.coordinate = coord;
    self.searchAnnotation.image = [UIImage imageNamed:@"pin_yellow"];
    
    [_mapView addAnnotation:self.searchAnnotation];
    
}

/**
 *   cell 高度
 */
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 50;
}


/**
 *   界面点击方法
 */
-(void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event
{
    self.placeTableView.hidden = YES;
    [self.addressSearchBar endEditing:YES];
}

@end






