//
//  KM8020RemindSettingVC.m
//  InstantCare
//
//  Created by km on 16/9/9.
//  Copyright © 2016年 omg. All rights reserved.
//

#import "KM8020RemindSettingVC.h"
#import "KMRemindModel.h"
#import "KM8020RemindEditVC.h"
#import "MJRefresh.h"
#import "KMNetAPI.h"
#import "MJExtension.h"
@interface KM8020RemindSettingVC ()<UITableViewDelegate,UITableViewDataSource>

/** 数据数组 */
@property (nonatomic, strong) NSArray *models;


@end

@implementation KM8020RemindSettingVC

-(void)dealloc{
    [[NSNotificationCenter defaultCenter] removeObserver:self name:@"kmRemindSetNotification" object:nil];
}

/** 设置记载完成  */
- (void)viewDidLoad {
    [super viewDidLoad];
    
    WS(ws);
    /** 设置代理  */
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    self.tableView.tableFooterView = [UIView new];
    
    /** 设置导航栏  */
    [self configNavBar];
    
    /** 添加下拉刷新  */
    self.tableView.mj_header = [MJRefreshNormalHeader headerWithRefreshingBlock:^{
        [ws loadData];
    }];
    
    //获取提醒通知刷新界面
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(loadData)
                                                 name:@"kmRemindSetNotification"
                                               object:nil];

}

/**
 *   试图将要显示
 */
- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    /** 加载数据  */
    [self loadData];
}

#pragma mark - 进行网络请求

- (void)loadData
{
    WS(ws);
    // remind/{imei}
    // 创建网址链接
    NSString *request = [NSString stringWithFormat:@"remind/%@", self.imei];
    // 发送网路请求
    [SVProgressHUD show];
    [[KMNetAPI manager] commonGetRequestWithURL:request Block:^(int code, NSString *res)
    {
        
        [ws.tableView.mj_header endRefreshing];
        KMNetworkResModel *resModel = [KMNetworkResModel mj_objectWithKeyValues:res];
        
        if (code == 0 && resModel.errorCode <= kNetReqSuccess) {
            
            [SVProgressHUD dismiss];
            KMRemindModel *remindM = [KMRemindModel mj_objectWithKeyValues:resModel.content];
            ws.models = remindM.list;
            [ws.tableView reloadData];
        } else {
            
            [SVProgressHUD showErrorWithStatus:kNetReqFailWithCode(resModel.errorCode)];
        }
    }];
}

/**
 *   设置导航栏
 */
- (void)configNavBar
{
    UIButton *leftButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [leftButton setBackgroundImage:[UIImage imageNamed:@"return_normal"] forState:UIControlStateNormal];
    [leftButton setBackgroundImage:[UIImage imageNamed:@"return_sel"] forState:UIControlStateSelected];
    leftButton.frame = CGRectMake(0, 0,30, 30);
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:leftButton];
    
    [leftButton addTarget:self action:@selector(leftBarButtonDidClickedAction:) forControlEvents:UIControlEventTouchDown];
    
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAdd target:self action:@selector(rightBarButtonDidClickedAction:)];
}

// leftItem 按钮点击事件
-(void)leftBarButtonDidClickedAction:(UIButton *)sender
{
    [self.navigationController popViewControllerAnimated:YES];
}

// rightItem 按钮点击事件
-(void)rightBarButtonDidClickedAction:(UIButton *)sender
{
    KM8020RemindEditVC * vc = [[KM8020RemindEditVC alloc] init];
    vc.editStatus = KM8020RemindStatusAdd;
    vc.imei = self.imei;
    [self.navigationController pushViewController:vc animated:YES];
}


#pragma mark - TableView data source
/**
 *   分区
 */
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    
    return 1;
}


/**
 *   分组
 */
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {

    return self.models.count;
}


/**
 *   设置显示对象
 */
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    //1.创建cell
    NSString *  identifier = @"default";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:identifier];
    if (cell == nil) {
        
        cell =  [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:identifier];
    }
    
    //2.设置cell
    //数据模型
    KMRemindDetailModel * model = self.models[indexPath.row];
    cell.detailTextLabel.numberOfLines = 0;
    NSString * time;
    if ([model.sType isEqualToString:@"00"]) {
        
         time = [NSString stringWithFormat:@"%@/%@/%@ %@:%@",model.sYear,model.sMon,model.sDay,model.sHour,model.sMin];
    }else{
        
         time = [NSString stringWithFormat:@"%@:%@",model.sHour,model.sMin];
    }
    cell.textLabel.text = time;
    
    NSInteger status = [model.sType integerValue];
    NSString * repeat;
    switch (status)
    {
        case 0:
        {
            repeat =kLoadStringWithKey(@"DeviceManager_HealthSetting_alert_call_onceTime");
        }break;
        case 1:
        {
            repeat =kLoadStringWithKey(@"DeviceManager_HealthSetting_alert_call_onceDay");
        }break;
        case 2:
        {
            repeat = [self weekStringWithDetaiModel:model];
        }break;
    }
    
    repeat = [repeat stringByAppendingFormat:@"\n%@",model.attribute1];
    cell.detailTextLabel.text  = repeat;
    
    
    //3.返回cell
    return cell;
}

/**
 *   返回自定义提醒字符串
 */
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



/**
 *   取消选中
 */
-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    // push出新的界面
    KM8020RemindEditVC * vc = [[KM8020RemindEditVC alloc] init];
    vc.model = self.models[indexPath.row];
    vc.imei = self.imei;
    vc.editStatus =  KM8020RemindStatusEdit;
    [self.navigationController pushViewController:vc animated:YES];
}

/**
 *   返回高度
 */
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 70;
}


#pragma mark - UITableView 编辑
/**
 *   进入编辑状态
 */
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {

    return YES;
}

/**
 *   执行删除操作
 */
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    
    /** 执行删除操作  */
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        
        [self deletateNetwork:indexPath];
    }
}

#pragma mark - 删除的方法
/**
 *   删除数据
 */
- (void)deletateNetwork:(NSIndexPath *)indexPath
{
    WS(ws);
    KMRemindDetailModel * model = self.models[indexPath.row];
    NSInteger team  =  [model.sTeam integerValue];
    NSInteger type  = [model.sType integerValue];
    
    // 创建网址链接
    NSString *request = [NSString stringWithFormat:@"removeRemind/t9/%@/%zd/%zd", self.imei,team,type];
    
    // 发送网路请求
    [SVProgressHUD show];
    [[KMNetAPI manager] commonGetRequestWithURL:request Block:^(int code, NSString *res)
     {
         [SVProgressHUD dismiss];
         KMNetworkResModel *resModel = [KMNetworkResModel mj_objectWithKeyValues:res];
         if (code == 0 && resModel.errorCode <= kNetReqSuccess) {
             
             [ws loadData];
         } else {
             
             [SVProgressHUD showErrorWithStatus:kNetReqFailWithCode(resModel.errorCode)];
         }
     }];
}


@end
