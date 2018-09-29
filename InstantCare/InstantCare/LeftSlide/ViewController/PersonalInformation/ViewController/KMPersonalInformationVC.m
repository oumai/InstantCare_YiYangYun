//
//  KMPersonalInformationVC.m
//  InstantCare
//
//  Created by 朱正晶 on 16/5/24.
//  Copyright © 2016年 omg. All rights reserved.
//

#import "KMPersonalInformationVC.h"
#import "KMBindDeviceListVC.h"
#import "KMCommonInputCell.h"
#import "KMPersonModel.h"
#import "KMChangePasswordVC.h"
#import "KMCommonAlertView.h"
#import "KMLongTextTableViewCell.h"
#import "MJRefresh.h"
#import "KMNetAPI.h"
#import "MJExtension.h"
#import "NSString+Extension.h"

@interface KMPersonalInformationVC () <KMBindDeviceListVCDelegate, UITableViewDelegate, UITableViewDataSource, UITextFieldDelegate,UITextViewDelegate>

@property (nonatomic, strong) UITableView *tableView;

@property (nonatomic, strong) KMPersonDetailModel *detaiModel;

@property(nonatomic,strong)CustomIOSAlertView * alertView;
@property(nonatomic,strong)KMCommonInputCell * birthdadyCell;
@property(nonatomic,strong)UIDatePicker * datePicker;
@property(nonatomic,copy)NSString * address;

@end

@implementation KMPersonalInformationVC 

- (void)viewDidLoad {
    [super viewDidLoad];
    
    
    [self configNavBar];
    [self configView];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    [self requestAccountInfo];
}

- (void)configNavBar
{
    // leftBarButtonItem
    UIButton *leftNavButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [leftNavButton setBackgroundImage:[UIImage imageNamed:@"return_normal"]
                             forState:UIControlStateNormal];
    [leftNavButton addTarget:self
                      action:@selector(backBarButtonDidClicked:)
            forControlEvents:UIControlEventTouchUpInside];
    leftNavButton.frame = CGRectMake(0, 0, 30, 30);
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:leftNavButton];
    
    // rightBarButtonItem;
    UIButton *rightNarBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    [rightNarBtn setTitle:kLoadStringWithKey(@"Personal_info_save") forState:UIControlStateNormal];
    [rightNarBtn addTarget:self
                    action:@selector(rightBarButtonDidClicked:)
          forControlEvents:UIControlEventTouchUpInside];
    rightNarBtn.frame = CGRectMake(0, 0, 60, 30);
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:rightNarBtn];
    
    // title
    self.title = kLoadStringWithKey(@"Personal_info_Account");
}

- (void)configView {
    self.view.backgroundColor = kGrayBackColor;
    
    WS(ws);
    self.tableView = [[UITableView alloc] init];
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    self.tableView.sectionHeaderHeight = 20;
    self.tableView.rowHeight = 54;
    self.tableView.tableFooterView = [UIView new];
    self.tableView.backgroundColor = [UIColor clearColor];
    self.tableView.backgroundView = [UIView new];
    self.tableView.mj_header = [MJRefreshNormalHeader headerWithRefreshingBlock:^{
        [ws requestAccountInfo];
    }];
    [self.tableView registerClass:[KMCommonInputCell class] forCellReuseIdentifier:@"cell"];
    [self.view addSubview:self.tableView];
    [self.tableView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.equalTo(self.view);
    }];
    
    [self.tableView registerNib:[UINib nibWithNibName:cKMLongTextTableViewCell bundle:nil] forCellReuseIdentifier:cKMLongTextTableViewCell];
}

#pragma mark - 保存用户信息
- (void)rightBarButtonDidClicked:(UIBarButtonItem *)sender
{
    [self.view endEditing:YES];
    
    if (self.detaiModel.memberIdNumber.length != 0) {
    
        if (![self checkIDCardWithString:self.detaiModel.memberIdNumber]) {
            
            [SVProgressHUD showErrorWithStatus:kLoadStringWithKey(@"Personal_IDCard_alert")];
            return;
        }
    }
    WS(ws);
    [SVProgressHUD showWithStatus:kLoadStringWithKey(@"Common_network_request_now")];
    [[KMNetAPI manager] updateAccountInfoWith:_detaiModel account:member.loginAccount block:^(int code, NSString *res) {
        KMNetworkResModel *resModel = [KMNetworkResModel mj_objectWithKeyValues:res];
        if (code == 0 && resModel.errorCode <= kNetReqSuccess) {
            [SVProgressHUD showSuccessWithStatus:kLoadStringWithKey(@"Common_save_success")];
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.6 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                [ws.navigationController popViewControllerAnimated:YES];
            });
        } else {
            [SVProgressHUD showErrorWithStatus:kNetReqFailWithCode(resModel.errorCode)];
        }
    }];
}

#pragma mark - 返回
- (void)backBarButtonDidClicked:(UIButton *)sender {
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)requestAccountInfo
{
    [SVProgressHUD show];
    [[KMNetAPI manager] getAccountInfoWithAccount:member.loginAccount Block:^(int code, NSString *res)
    {
       
        [_tableView.mj_header endRefreshing];
        KMNetworkResModel *resModel = [KMNetworkResModel mj_objectWithKeyValues:res];
        if (code == 0 && resModel.errorCode <= kNetReqSuccess)
        {
             [SVProgressHUD dismiss];
            KMPersonModel *m = [KMPersonModel mj_objectWithKeyValues:resModel.content];
            _detaiModel = [m.list objectAtIndex:0];
            [_tableView reloadData];
            if (_detaiModel.memberIdNumber.length == 0)
            {
                [self customAlertViewShowWithMessage:kLoadStringWithKey(@"Person_alert") withStatus:NO];
            }
        } else
        {
            DMLog(@"*** Person: %@", resModel.msg);
            
            [SVProgressHUD showErrorWithStatus:resModel.msg.length == 0 ? kNetReqFailStr : resModel.msg];
            
        }
    }];
}

#pragma mark - UITableView

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    UIView *view = [UIView new];
    view.backgroundColor = kGrayBackColor;
    return view;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    if (_detaiModel)
    {
        return 2;
    }
    return 0;
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    if(indexPath.section == 1 && indexPath.row == 0){
        
       CGFloat height =  [KMLongTextTableViewCell cellHeightForText:_detaiModel.address inTableView:tableView];
        return height;
    }
    return 70;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if (_detaiModel)
    {
        if (section == 0)
        {
            return 3;
        }
        return 3;
    }
    return 0;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    KMCommonInputCell *cell = [tableView dequeueReusableCellWithIdentifier:@"cell"];
    if (indexPath.section == 0) {
        switch (indexPath.row) {
            case 0:         // 姓名
                cell.imageView.image = [UIImage imageNamed:@"edit_name"];
                cell.textField.text = _detaiModel.realName;
                cell.textField.placeholder = kLoadStringWithKey(@"Reg_VC_tip_name");
                cell.textField.tag = 2000;
                cell.textField.delegate = self;
                 [cell.textField addTarget:self action:@selector(textfieldDidChanged:) forControlEvents:UIControlEventEditingChanged];
                break;
            case 2:         // 生日
                cell.imageView.image = [UIImage imageNamed:@"edit_birthday"];
                cell.textField.text = [NSString stringYearWithDate:_detaiModel.birthday];
                cell.textField.enabled = NO;
//                cell.textField.tag = 2;
                break;
            case 1:         // 身份证
                cell.imageView.image = [UIImage imageNamed:@"edit_ID"];
                cell.textField.text =  _detaiModel.memberIdNumber;
                cell.textField.placeholder = kLoadStringWithKey(@"Person_idCard");
                cell.textField.tag = 2002;
                break;

            default:
                break;
        }
    } else if (indexPath.section == 1)
    {
        switch (indexPath.row) {
            case 0:         // 地址
                return [self tableView:tableView cellForAddress:_detaiModel.address];
            case 1:         // 账号-注册电话号码
                cell.imageView.image = [UIImage imageNamed:@"edit_imei"];
                cell.textField.text = member.loginAccount;
                cell.textField.enabled = NO;
                cell.textField.tag = 4;
                break;
            case 2:         // 修改密码
                cell.imageView.image = [UIImage imageNamed:@"edit_password"];
                cell.textField.enabled = NO;
                cell.textField.text = kLoadStringWithKey(@"Personal_info_change_password");
                cell.textField.tag = 5;
                cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
                break;
            default:
                break;
        }
    }
    cell.textField.delegate = self;
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    cell.backgroundColor = [UIColor whiteColor];
    
    return cell;  
}

-(UITableViewCell*)tableView:(UITableView*)tableView cellForAddress:(NSString*)address{
    KMLongTextTableViewCell* cell = [tableView dequeueReusableCellWithIdentifier:cKMLongTextTableViewCell];
    cell.imageView.image = [UIImage imageNamed:@"edit_address"];
    cell.longTextView.text = address;
    cell.longTextView.delegate = self;
    return cell;
}
#pragma mark - TextView 代理方法
/**
 *   编辑方法
 */
- (BOOL)textView:(UITextView *)textView shouldChangeTextInRange:(NSRange)range replacementText:(NSString *)text
{
    if (text.length == 0)  return YES;

    if (textView.text.length >=255)
    {
        return NO;
    }
    
    NSInteger existedLength = textView.text.length;
    NSInteger selectedLength = range.length;
    NSInteger replaceLength = text.length;
    if (existedLength - selectedLength + replaceLength >255)
    {
        return NO;
    }
    return YES;
}
/**
 *   结束编辑方法
 */
- (void)textViewDidEndEditing:(UITextView *)textView
{
    _detaiModel.address = textView.text;
}

/**
 *  正则匹配身份证号码
 *
 *  param idCard 传入的参数
 *
 *  return 匹配结果
 */
- (BOOL)checkIDCardWithString: (NSString *)identityCard
{
    BOOL flag;
    if (identityCard.length <= 0) {
        flag = NO;
        return flag;
    }
    NSString *regex2 = @"^(\\d{14}|\\d{17})(\\d|[xX])$";
    NSPredicate *identityCardPredicate = [NSPredicate predicateWithFormat:@"SELF MATCHES %@",regex2];
    return [identityCardPredicate evaluateWithObject:identityCard];
    
}

/**
 *  限制输入长度
 *
 *  @param textField 输入内容的对象
 */
-(void)textfieldDidChanged:(UITextField *)textField
{
    if (textField.tag == 3000)
    {
        if (textField.text.length > 255)
        {
            textField.text = [textField.text substringToIndex:35];
        }
        
    }else if (textField.tag == 2002)
    {
        if (textField.text.length >18)
        {
            textField.text = [textField.text substringToIndex:18];
        }
    }else
    {
        if (textField.text.length >18)
        {
            textField.text = [textField.text substringToIndex:15];
        }

    }
}

/**
 *  tableView 选中的方法
 *
 *  @param tableView 表对象
 *  @param indexPath 选中的下标
 */
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    
    if (indexPath.section == 1 && indexPath.row == 2) {
        KMChangePasswordVC *vc = [KMChangePasswordVC new];
        [self.navigationController pushViewController:vc animated:YES];
    }
    if (indexPath.section == 0 && indexPath.row == 2) {
        self.alertView = [[CustomIOSAlertView alloc] init];
        self.birthdadyCell = [tableView cellForRowAtIndexPath:indexPath];
        KMCommonAlertView * contentView = [[KMCommonAlertView alloc] initWithFrame:CGRectMake(0, 0,SCREEN_WIDTH*0.8,SCREEN_HEIGHT*0.4)];
        contentView.titleLabel.text = kLoadStringWithKey(@"Personal_info_birthday_selectedTime");
        contentView.buttonsArray = @[kLoadStringWithKey(@"Reg_VC_birthday_OK")];
        UIButton * okButton = contentView.realButtons[0];
        [okButton addTarget:self action:@selector(alertButtonDidClickedAction:) forControlEvents:UIControlEventTouchDown];
        
        //datepicker
        UIDatePicker * datePicker = [[UIDatePicker alloc] init];
        [contentView.customerView  addSubview:datePicker];
        [datePicker mas_makeConstraints:^(MASConstraintMaker *make) {
            make.center.equalTo(contentView);
            make.left.right.mas_equalTo(0);
            make.height.mas_equalTo(100);
        }];
        //设置地区时间；
//        datePicker.locale = [NSLocale currentLocale];
        datePicker.datePickerMode = UIDatePickerModeDate;
        self.datePicker = datePicker;
        
        //设置可选时间范围；
        datePicker.maximumDate = [NSDate date];
        
        NSDateFormatter * dateFormatter = [[NSDateFormatter alloc] init];
        dateFormatter.dateFormat = @"yyyy-MM-dd";
        NSString * dateString = @"1900-01-01";
        NSDate * minDate = [dateFormatter dateFromString:dateString];
        datePicker.minimumDate = minDate;
        
        NSDate * date = [NSDate dateWithTimeIntervalSince1970:self.detaiModel.birthday/1000];
        [self.datePicker setDate:date animated:YES];
        
        self.alertView.containerView = contentView;
        [self.alertView setButtonTitles:nil];
        [self.alertView setUseMotionEffects:NO];
        [self.alertView show];
    }
}

#pragma mark --- 信息提示框显示
//显示信息提示框
-(void)customAlertViewShowWithMessage:(NSString *)message withStatus:(BOOL)index
{
    // 提示框
    self.alertView = [[CustomIOSAlertView alloc] init];
    self.alertView.buttonTitles = nil;
    [self.alertView setUseMotionEffects:NO];
    
    UIView * alertView = [[UIView alloc] initWithFrame:CGRectMake(0,0,SCREEN_WIDTH*0.9,220)];
    alertView.backgroundColor = [UIColor whiteColor];
    self.alertView.containerView = alertView;
    
    // 图标
    UIImageView * fail = [[UIImageView alloc] init];
    [alertView addSubview:fail];
    [fail mas_makeConstraints:^(MASConstraintMaker *make)
     {
         make.centerX.equalTo(alertView);
         make.width.height.mas_equalTo(70);
         make.bottom.equalTo(alertView.mas_centerY);
     }];
    if (!index)
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
    [self.alertView show];
}

#pragma mark - UITextFieldDelegate
-(BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string
{
    if (string.length == 0)  return YES;
    if (textField.tag == 3000)
    {
        if (textField.text.length >=255)
        {
            return NO;
        }
        
        NSInteger existedLength = textField.text.length;
        NSInteger selectedLength = range.length;
        NSInteger replaceLength = string.length;
        if (existedLength - selectedLength + replaceLength >255)
        {
            return NO;
        }
        return YES;
    }else if (textField.tag == 2002)
    {
        
        if (textField.text.length >=19)
        {
            return NO;
        }
        
        NSInteger existedLength = textField.text.length;
        NSInteger selectedLength = range.length;
        NSInteger replaceLength = string.length;
        if (existedLength - selectedLength + replaceLength >18)
        {
            return NO;
        }
        
        return  [self checkIDCardNumberWithString:string];
        return YES;

    }else
    {
        if (textField.text.length >=15)
        {
            return NO;
        }
        
        NSInteger existedLength = textField.text.length;
        NSInteger selectedLength = range.length;
        NSInteger replaceLength = string.length;
        if (existedLength - selectedLength + replaceLength >15)
        {
            return NO;
        }
        
        return YES;
    }
}

- (BOOL)checkIDCardNumberWithString: (NSString *)identityCard
{
    BOOL flag;
    if (identityCard.length <= 0) {
        flag = NO;
        return flag;
    }
    NSString *regex2 = @"^[0123456789x]+$";
    NSPredicate *identityCardPredicate = [NSPredicate predicateWithFormat:@"SELF MATCHES %@",regex2];
    return [identityCardPredicate evaluateWithObject:identityCard];
    
}

#pragma mark --- 出生日期点击事件
-(void)alertButtonDidClickedAction:(UIButton *)sender
{
    [self.alertView close];
    NSDateFormatter * dateFormatter  = [[NSDateFormatter alloc] init];
    dateFormatter.dateFormat = @"yyyy-MM-dd";
    NSString * dateString = [dateFormatter stringFromDate:self.datePicker.date];
    self.birthdadyCell.textField.text = dateString;
    self.detaiModel.birthday = [self.datePicker.date timeIntervalSince1970]*1000;
}

- (void)textFieldDidEndEditing:(UITextField *)textField
{
    NSInteger index = textField.tag - 2000;
    switch (index)
    {
        case 0:         // 姓名
        {
            _detaiModel.realName = textField.text;
        }break;
        case 1000:         // 地址
        {
            _detaiModel.address = textField.text;
        }break;
        case 2:
        {
            _detaiModel.memberIdNumber = textField.text;
        }break;
        default:
            break;
    }
}


@end
