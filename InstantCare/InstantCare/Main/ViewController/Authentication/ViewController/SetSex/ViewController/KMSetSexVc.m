//
//  KMSetSexVc.m
//  InstantCare
//
//  Created by KM on 2016/12/1.
//  Copyright © 2016年 omg. All rights reserved.
//

#import "KMSetSexVc.h"
#import "UIBarButtonItem+Extension.h"
@interface KMSetSexVc ()<UITableViewDelegate,UITableViewDataSource>
@property (weak, nonatomic) IBOutlet UITableView *tableView;

@end

@implementation KMSetSexVc

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self setupUI];
}

- (void)setupUI
{
    self.view.backgroundColor = RGB(247, 247, 246);
    self.navigationItem.title = kLoadStringWithKey(@"KMVIPServer_Sex");
    //左边导航栏按钮
//    self.navigationItem.leftBarButtonItem = [UIBarButtonItem itemWithImage:@"return_normal" hightImage:@"return_sel" target:self action:@selector(leftBarButtonDidClickedAction:)];
    
#warning leftBarButtonItem 修改左边返回键
    UIBarButtonItem *leftNegativeSpacer = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFixedSpace target:nil action:nil];
    [leftNegativeSpacer setWidth:-10];
    
    UIBarButtonItem *leftBarButtonItem = [UIBarButtonItem itemWithImage:@"return_normal" hightImage:@"return_sel" target:self action:@selector(leftBarButtonDidClickedAction:)];
    
    self.navigationItem.leftBarButtonItems = @[leftNegativeSpacer,leftBarButtonItem];
    
    
    
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
}


#pragma mark - <UITableViewDataSource>

-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return 2;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    
    UITableViewCell *cell = [[UITableViewCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:nil];
    if (indexPath.row == 0) {
        if ([self.sex isEqualToString:kLoadStringWithKey(@"DeviceManager_HealthSetting_sex_man")]) {
            [cell setAccessoryType:UITableViewCellAccessoryCheckmark];
        }
        cell.textLabel.text = kLoadStringWithKey(@"DeviceManager_HealthSetting_sex_man");
    }else{
        if ([self.sex isEqualToString:kLoadStringWithKey(@"DeviceManager_HealthSetting_sex_woman")]) {
            [cell setAccessoryType:UITableViewCellAccessoryCheckmark];
        }
        cell.textLabel.text = kLoadStringWithKey(@"DeviceManager_HealthSetting_sex_woman");
    }
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:NO];
    if (indexPath.section == 0) {
    
        NSArray *array = [tableView visibleCells];
        for (UITableViewCell *cell in array) {
            // 不打对勾
            [cell setAccessoryType:UITableViewCellAccessoryNone];
        }
        
        UITableViewCell *cell = [tableView cellForRowAtIndexPath:indexPath];
        [cell setAccessoryType:UITableViewCellAccessoryCheckmark];
        
        NSString *sexStr = nil;
        if (indexPath.row == 0) {
            sexStr = kLoadStringWithKey(@"DeviceManager_HealthSetting_sex_man");
        }else{
            sexStr = kLoadStringWithKey(@"DeviceManager_HealthSetting_sex_woman");
        }
        
        [[NSUserDefaults standardUserDefaults]setObject:sexStr forKey:@"Sex"];
        [self.navigationController popViewControllerAnimated:YES];
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    return 20;
}

/**
 *   返回上一级界面
 */
-(void)leftBarButtonDidClickedAction:(UIButton *)sender
{
    [self.navigationController popViewControllerAnimated:YES];
}

@end
