//
//  KMRemindSettingVC.m
//  InstantCare
//
//  Created by bruce-zhu on 16/2/1.
//  Copyright © 2016年 omg. All rights reserved.
//

#import "KMRemindSettingVC.h"
#import "KMDeviceSettingEditCell.h"
#import "KMClinicRemindVC.h"
#import "KMClinicRemindModel.h"
#import "KMMedicalRemindModel.h"
#import "KMCustomRemindModel.h"
#import "MJExtension.h"
@interface KMRemindSettingVC () <UITableViewDataSource, UITableViewDelegate>

@property (nonatomic, strong) UITableView *tableView;

@property (nonatomic, strong) NSArray *titleArray;
@property (nonatomic, strong) NSArray *detailArray;

@end

@implementation KMRemindSettingVC

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor whiteColor];

    [self initDataArray];
    [self configNavBar];
    [self configView];
}

- (void)initDataArray
{
    self.titleArray = @[kLoadStringWithKey(@"RemindSettingVC_clinic"),
                        kLoadStringWithKey(@"RemindSettingVC_medical"),
                        kLoadStringWithKey(@"RemindSettingVC_remind")];

    self.detailArray = @[kLoadStringWithKey(@"RemindSettingVC_clinic_tip"),
                         kLoadStringWithKey(@"RemindSettingVC_clinic_tip"),
                         kLoadStringWithKey(@"RemindSettingVC_clinic_tip")];

    // 设置数据模型
    [KMClinicRemindModel mj_setupObjectClassInArray:^NSDictionary *{
        return @{
                 @"clinic" : @"KMRemindModel",
                 @"medical" : @"KMRemindModel",
                 @"custom" : @"KMRemindModel"
                 };
    }];

    [KMMedicalRemindModel mj_setupObjectClassInArray:^NSDictionary *{
        return @{
                 @"medical" : @"KMRemindModel"
                 };
    }];

    [KMCustomRemindModel mj_setupObjectClassInArray:^NSDictionary *{
        return @{
                 @"custom" : @"KMRemindModel"
                 };
    }];
}

- (void)configNavBar
{
    self.navigationItem.title = kLoadStringWithKey(@"DeviceEdit_VC_setting_title_device_remind");
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
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if ([self.type isEqualToString:@"1"])
    {
        return 2;
        
    }else
    {
        return 3;
    }
}
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    KMDeviceSettingEditCell *cell = [tableView dequeueReusableCellWithIdentifier:@"cell"];
    if (cell == nil) {
        cell = [[KMDeviceSettingEditCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"cell"];
        cell.titleLabel.font = [UIFont boldSystemFontOfSize:18];
    }
    cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    cell.titleLabel.text = self.titleArray[indexPath.row];
    cell.detailLabel.text = self.detailArray[indexPath.row];

    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:NO];

    switch (indexPath.row) {
        case 0:         // 回诊提醒
        {
            KMClinicRemindVC *vc = [[KMClinicRemindVC alloc] init];
            vc.imei = self.imei;
            vc.key = @"02";
            vc.type = self.type;
            [self.navigationController pushViewController:vc animated:YES];
        } break;
        case 1:         // 吃药提醒
        {
            KMClinicRemindVC *vc = [[KMClinicRemindVC alloc] init];
            vc.imei = self.imei;
            vc.key = @"01";
            vc.type = self.type;
            [self.navigationController pushViewController:vc animated:YES];
        } break;
        case 2:         // 提醒
        {
            KMClinicRemindVC *vc = [[KMClinicRemindVC alloc] init];
            vc.imei = self.imei;
            vc.key = @"04";
            vc.type = self.type;
            [self.navigationController pushViewController:vc animated:YES];
        } break;
        default:
            break;
    }
}

@end
