 //
//  KMClinicRemindVC.m
//  InstantCare
//
//  Created by bruce-zhu on 16/2/1.
//  Copyright © 2016年 omg. All rights reserved.
//

#import "KMClinicRemindVC.h"
#import "KMClinicRemindDetailVC.h"
#import "KMRemindModel.h"
#import "KMClinicAndMdicalEditVC.h"
#import "KMCustomRemindEditVC.h"
#import "KMRemindEditModel.h"
#import "KMCustomRemindCell.h"
#import "CustomIOSAlertView.h"
#import "KMNetAPI.h"
#import "MJRefresh.h"
#import "MJExtension.h"


@interface KMClinicRemindVC () <UITableViewDataSource, UITableViewDelegate>

@property (nonatomic, strong) UITableView *tableView;

/**
 *  经过处理的提醒模型
 */
@property (nonatomic, strong) NSArray *remindModelArray;

@property(nonatomic,strong)CustomIOSAlertView * messageView;
@property(nonatomic,strong)UILabel *affir;

@end

@implementation KMClinicRemindVC

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor whiteColor];

    [self configNavBar];
    [self configView];
}

- (void)viewWillAppear:(BOOL)animated
{
    [SVProgressHUD showWithStatus:kLoadStringWithKey(@"Common_network_request_now")];
    [self requestClinicRemind];
}

- (void)configNavBar
{
    if ([self.key isEqualToString:@"02"]) {
        self.navigationItem.title = kLoadStringWithKey(@"RemindSettingVC_clinic");
    } else if ([self.key isEqualToString:@"01"]) {
        self.navigationItem.title = kLoadStringWithKey(@"RemindSettingVC_medical");
    } else if ([self.key isEqualToString:@"04"]) {
        self.navigationItem.title = kLoadStringWithKey(@"RemindSettingVC_remind");
        self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAdd target:self action:@selector(rightBarButtonDidClickedAction:)];
    }

    UIButton *leftButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [leftButton setBackgroundImage:[UIImage imageNamed:@"return_normal"] forState:UIControlStateNormal];
    [leftButton setBackgroundImage:[UIImage imageNamed:@"return_sel"] forState:UIControlStateSelected];
    leftButton.frame = CGRectMake(0, 0,30, 30);
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:leftButton];
    
    [leftButton addTarget:self action:@selector(leftBarButtonDidClickedAction:) forControlEvents:UIControlEventTouchDown];
}
// leftItem 按钮点击时间
-(void)leftBarButtonDidClickedAction:(UIButton *)sender
{
    [self.navigationController popViewControllerAnimated:YES];
}
- (void)configView
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
    
    // 下拉刷新
    self.tableView.mj_header = [MJRefreshNormalHeader headerWithRefreshingBlock:^{
        [ws requestClinicRemind];
    }];
}

- (void)requestClinicRemind
{
    // remind/{imei}
    NSString *request = [NSString stringWithFormat:@"remind/%@", self.imei];
    [[KMNetAPI manager] commonGetRequestWithURL:request Block:^(int code, NSString *res) {
        
        KMNetworkResModel *resModel = [KMNetworkResModel mj_objectWithKeyValues:res];
        [_tableView.mj_header endRefreshing];
        
        if (code == 0 && resModel.errorCode <= kNetReqSuccess) {
            
            [SVProgressHUD dismiss];
            NSMutableArray *mutableArray = @[].mutableCopy;
            KMRemindModel *remindM = [KMRemindModel mj_objectWithKeyValues:resModel.content];
            for (KMRemindDetailModel *m in remindM.list) {
                
                if ([m.sType isEqualToString:_key]) {
                    
                    [mutableArray addObject:m];
                }
            }
            
            _remindModelArray = mutableArray;
            [_tableView reloadData];
        } else {
            
            [SVProgressHUD showErrorWithStatus:kNetReqFailWithCode(resModel.errorCode)];
        }
    }];
}

#pragma mark --- UITableView dataSource

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.remindModelArray.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    // 获取赋值模型；
    KMRemindDetailModel *m = _remindModelArray[indexPath.row];
    // 模型赋值
    NSString *timeString = [NSString stringWithFormat:@"%@:%@", m.sHour, m.sMin];
    NSString *dateString = [NSString stringWithFormat:@"%@/%@/%@", m.sYear, m.sMon, m.sDay];
    
    if ([self.type isEqualToString:@"1"] && [self.key isEqualToString:@"02"]) {
        
    }else{
        dateString = [NSString stringWithFormat:@"%@", dateString];
    }
    NSString * date = [NSString stringWithFormat:@"%@%@",kLoadStringWithKey(@"Geofence_VC_not_setting"),kLoadStringWithKey(@"DeviceManager_HealthSetting_time")];
    NSLog(@"------------%@",timeString);
    if ([dateString hasPrefix:@"0"]||[dateString hasPrefix:@"/"]||[dateString containsString:@"null"])
    {
        dateString = @"";
    }
    
    if (timeString.length == 0)
    {
        timeString = date;
    }
    
    // 初始化cell；
    if ([self.key isEqualToString:@"04"])
    {
       KMCustomRemindCell * cell = [tableView dequeueReusableCellWithIdentifier:@"custom"];
        if (cell == nil)
        {
            cell = [[KMCustomRemindCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:@"custom"];
        }
        if (m.attribute1.length == 0)
        {
            cell.affir.text = kLoadStringWithKey(@"DeviceEdit_VC_setting_title_device_remind_customRemind");
        }else
        {
            cell.affir.text = m.attribute1;
        }
        cell.textLabel.text = timeString;
        NSString * weekString  = [self weekStringWithDetaiModel:m];
        if (weekString.length != 0) {
            cell.detailTextLabel.text = [self weekStringWithDetaiModel:m];
        }else{
           cell.detailTextLabel.text = dateString;
        }
        cell.detailTextLabel.textColor = kGrayContextColor;
        // 辅助视图
        UISwitch *mySwitch = [[UISwitch alloc] init];
        if ([m.isvalid isEqualToString:@"Y"])
        {
            mySwitch.on = YES;
        } else
        {
            mySwitch.on = NO;
        }
        mySwitch.tag = 3000+indexPath.row;
        [mySwitch addTarget:self  action:@selector(switchDidClick:)
           forControlEvents:UIControlEventValueChanged];
        cell.accessoryView = mySwitch;
        
        return cell;

    }else if ([self.key isEqualToString:@"01"] && [self.type isEqualToString:@"1"])
    {
      UITableViewCell * cell = [tableView dequeueReusableCellWithIdentifier:@"cell"];
        if (cell == nil)
        {
            cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:@"cell"];
        }
         // cell赋值；
        cell.textLabel.text = timeString;
        cell.detailTextLabel.text = [NSString stringWithFormat:@"%@",[self weekStringWithDetaiModel:m]];
        cell.detailTextLabel.textColor = kGrayContextColor;
        // 辅助视图
        UISwitch *mySwitch = [[UISwitch alloc] init];
        if ([m.isvalid isEqualToString:@"Y"])
        {
            mySwitch.on = YES;
        } else
        {
            mySwitch.on = NO;
        }
        mySwitch.tag = 3000+indexPath.row;
        [mySwitch addTarget:self  action:@selector(switchDidClick:)
           forControlEvents:UIControlEventValueChanged];
        cell.accessoryView = mySwitch;
        
        return cell;
        
  }else
  {
      UITableViewCell * cell = [tableView dequeueReusableCellWithIdentifier:@"cell"];
      if (cell == nil)
      {
          cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:@"cell"];
      }
      

      
      // cell赋值；
      cell.textLabel.text = timeString;
      NSString * weekString  = [self weekStringWithDetaiModel:m];
      if (weekString.length != 0) {
          cell.detailTextLabel.text = [self weekStringWithDetaiModel:m];
      }else{
          cell.detailTextLabel.text = dateString;
      }
      
      if ([self.type isEqualToString:@"1"] && [self.key isEqualToString:@"02"]) {
          
          cell.detailTextLabel.text = dateString;
      }
      
      cell.detailTextLabel.textColor = kGrayContextColor;
      // 辅助视图
      UISwitch *mySwitch = [[UISwitch alloc] init];
      if ([m.isvalid isEqualToString:@"Y"])
      {
          mySwitch.on = YES;
      } else
      {
          mySwitch.on = NO;
      }
      mySwitch.tag = 3000+indexPath.row;
      [mySwitch addTarget:self  action:@selector(switchDidClick:)
         forControlEvents:UIControlEventValueChanged];
      cell.accessoryView = mySwitch;
      
      return cell;
  }
}



// cell 高度
-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if ([self.key isEqualToString:@"04"] )
    {
        return 100;
    }
    return 70;
}

#pragma mark --- 开关按钮点击方法
- (void)switchDidClick:(UISwitch *)mswitch
{
    BOOL result = mswitch.on;
    KMRemindDetailModel *m = _remindModelArray[mswitch.tag - 3000];
    if (result)
    {
        m.isvalid = @"Y";
    }else
    {
        m.isvalid = @"N";
    }
    // 开始更改操作
    [SVProgressHUD showWithStatus:kLoadStringWithKey(@"Common_network_request_now")];
    
    KMRemindEditModel * editModel = [[KMRemindEditModel alloc] init];
    [editModel setValueWithModel:m];
    
    NSString * body = [editModel mj_JSONString];
    NSString * request = [NSString stringWithFormat:@"updateRemind/%@/%ld/%ld",self.imei,mswitch.tag+1-3000,[m.sType integerValue]];
    
   [[KMNetAPI manager] commonPOSTRequestWithURL:request jsonBody:body Block:^(int code, NSString *res)
    {
        [SVProgressHUD dismiss];
        KMNetworkResModel * resModel = [KMNetworkResModel mj_objectWithKeyValues:res];
        if (code == 0 && resModel.errorCode <= kNetReqSuccess)
        {
            [self requestClinicRemind];
        }else
        {
            [self customAlertViewShowWithMessage:kNetReqFailWithCode(resModel.errorCode)
                                       withImage:@"pop_icon_fail"];
            mswitch.on = !result;
        }
   }];
}

    

#pragma mark --- UITableView delegate
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:NO];
    NSString * title;
    if ([self.key isEqualToString:@"02"]) {
      title = kLoadStringWithKey(@"RemindSettingVC_clinic");
    } else if ([self.key isEqualToString:@"01"]) {
      title = kLoadStringWithKey(@"RemindSettingVC_medical");
    } else if ([self.key isEqualToString:@"04"]) {
       title = kLoadStringWithKey(@"RemindSettingVC_remind");
    }

    
    if ([self.key isEqualToString:@"04"])
    {
        KMCustomRemindEditVC * customVC  = [[KMCustomRemindEditVC alloc] init];
        customVC.model = self.remindModelArray[indexPath.row];
        customVC.team = indexPath.row+1;
        customVC.stauts = remindStatusEdit;
        customVC.title = title;
        [self.navigationController pushViewController:customVC animated:YES];
        
    }else
    {
        KMClinicAndMdicalEditVC * editVC = [[KMClinicAndMdicalEditVC alloc] init];
        editVC.model = self.remindModelArray[indexPath.row];
        editVC.team = indexPath.row+1;
        editVC.type = self.type;
        editVC.key = self.key;
        editVC.title = title;
        [self.navigationController pushViewController:editVC animated:YES];
    }
}

#pragma mark - UITableViewDelegate 方法
// 开启编辑
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
    if ([self.key isEqualToString:@"04"])
    {
        return YES;
    }
    return NO;
}
// 删除操作
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (editingStyle == UITableViewCellEditingStyleDelete)
    {
        
        NSString * request = [NSString stringWithFormat:@"removeRemind/%@/%ld/%ld",self.imei,indexPath.row+1,[self.key integerValue]];
        [self removeRemindMethodWithRequest:request];
    }
}

#pragma mark - 删除方法
-(void)removeRemindMethodWithRequest:(NSString *)request
{
    // 开始更改操作
    [SVProgressHUD showWithStatus:kLoadStringWithKey(@"Common_network_request_now")];
    [[KMNetAPI manager] commonGetRequestWithURL:request Block:^(int code, NSString *res)
    {
        [SVProgressHUD dismiss];
        KMNetworkResModel * resModel = [KMNetworkResModel mj_objectWithKeyValues:res];
        if (code == 0 && resModel.errorCode <= kNetReqSuccess)
        {
            [self requestClinicRemind];
        }else
        {
            [self customAlertViewShowWithMessage:kNetReqFailWithCode(resModel.errorCode)
                                       withImage:@"pop_icon_fail"];
        }
    }];
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
                   });
    
}

// 获取日期字符串
- (NSString *)weekStringWithDetaiModel:(KMRemindDetailModel *)model {
    
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

#pragma mark --- rightBarButton点击方法
-(void)rightBarButtonDidClickedAction:(UIBarButtonItem *)sender
{
    if ([self.key isEqualToString:@"04"]&&[self.type isEqualToString:@"85"]){
        if (self.remindModelArray.count >= 10) {
            [SVProgressHUD showErrorWithStatus:kLoadStringWithKey(@"KMClinicRemind_VC_Custom_number")];
            return;
        }
    }
    KMCustomRemindEditVC * customVC  = [[KMCustomRemindEditVC alloc] init];
    customVC.stauts = remindStatusAdd;
    customVC.imei = self.imei;
    [self.navigationController pushViewController:customVC animated:YES];
    
}




@end









