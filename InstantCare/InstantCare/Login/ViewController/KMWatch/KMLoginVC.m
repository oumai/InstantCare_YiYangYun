//
//  ViewController.m
//  InstantCare
//
//  Created by bruce-zhu on 15/11/27.
//  Copyright © 2015年 omg. All rights reserved.
//

#import "KMLoginVC.h"
#import "KMMemberManager.h"
#import "KMNew_MainVC.h"
#import "PNChart.h"
#import "AFNetworking.h"
#import "KMNetAPI.h"
#import "KMUserModel.h"
#import "KMPushMsgModel.h"
#import "JPUSHService.h"
#import "KMShowAlertMsgWindow.h"
#import "KMLocationVC.h"
#import "ECSlidingViewController.h"
#import "KMLeftSlideVC.h"
#import "KMCustomTextField.h"
#import "KMForgetPasswordVC.h"
#import "KMProtocolVC.h"
#import "KMAccountManager.h"
#import "UDNavigationController.h"
#import "CustomIOSAlertView.h"
#import "UIView+Extension.h"
#import "UIImage+Extension.h"
#import "MJExtension.h"
#import "UMMobClick/MobClick.h"
#import "UIImageView+WebCache.h"
// 选择按钮距离屏幕Y坐标距离
#define kCenterOffset       100

static dispatch_source_t _timer;

@interface KMLoginVC ()<UITextFieldDelegate,UITableViewDelegate,UITableViewDataSource>

@property (nonatomic, strong) UIImageView *rememberImageView;
@property (nonatomic, strong) KMCustomTextField *phoneTextField;
@property (nonatomic, strong) KMCustomTextField *pdTextField;
/**
 *  登录
 */
@property (nonatomic, strong) UIButton *loginBtn;
/**
 *  注册
 */
@property (nonatomic, strong) UIButton *registerBtn;
/**
 *  切换按钮时下面的View
 */
@property (nonatomic, strong) UIView *containerView;
/**
 *  橘黄色Line
 */
@property (nonatomic, strong) UIView *orangeLineView;
/**
 *  手机号
 */
@property(nonatomic,strong)KMCustomTextField *phoneNumber;
/**
 *  密码
 */
@property(nonatomic,strong)KMCustomTextField *passWord;
/**
 *  确认密码
 */
@property(nonatomic,strong)KMCustomTextField *confirmPassword;

/**
 *  协议按钮
 */
@property(nonatomic,strong)UIButton *protocolButton;
/**
 *  下一步
 */
@property(nonatomic,strong)UIButton *nextButton;
/**
 *  验证码
 */
@property(nonatomic,strong)KMCustomTextField * VerifTextField;
/**
 *  获取验证码
 */
@property(nonatomic,strong)UIButton * getVerifButton;
/**
 *  完成注册按钮
 */
@property(nonatomic,strong)UIButton * finishButton;
/**
 *  提示框
 */
@property(nonatomic,strong)CustomIOSAlertView * messageView;
/**
 *  最近登录账号列表
 */
@property (nonatomic,weak) UITableView *accountList;
/**
 *  下拉
 */
@property (nonatomic,assign) BOOL isDown;
/**
 *  下拉
 */
@property (nonatomic,weak) UIButton *donwBtn;
/**
 *  最近登录账号
 */
@property (nonatomic,strong) NSArray *accountArray;
/**
 *  记住密码按钮
 */
@property (nonatomic,weak) UIButton *savePwdBtn;



@end

@implementation KMLoginVC

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    [self initLoginView];
    [self autoLogin];
    
    [self configJPush];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    if (self.accountList != nil) {
        [self.accountList reloadData];
    }
    _accountArray = nil;
    [self.accountList reloadData];
    self.phoneTextField.contentTextField.text = member.loginAccount;
    DMLog(@"%@",member.loginPd);
    self.savePwdBtn.selected = member.isSavePwd;
    if (member.isSavePwd) {
        self.pdTextField.contentTextField.text = member.loginPd;
    }else{
        self.pdTextField.contentTextField.text = @"";
    }
}

- (void)initLoginView
{
#pragma mark --- logo 和 功能选择按钮；
    // logo
    UIImageView *logoImageView = [[UIImageView alloc] init];
    logoImageView.image = [UIImage imageNamed:@"login_icon"];
    logoImageView.contentMode = UIViewContentModeScaleAspectFit;
    [self.view addSubview:logoImageView];
    [logoImageView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.view).offset(40);
        make.width.height.equalTo(@80);
        make.centerX.equalTo(self.view);
    }];
    
    // title
    UILabel * title = [[UILabel alloc] init];
    [self.view addSubview:title];
    [title mas_makeConstraints:^(MASConstraintMaker *make)
     {
         make.centerX.equalTo(logoImageView);
         make.top.equalTo(logoImageView.mas_bottom);
         make.height.mas_equalTo(20);
         //        make.width.mas_equalTo(60);
     }];
    title.textAlignment = NSTextAlignmentCenter;
    [title sizeToFit];
    title.text = kLoadStringWithKey(@"CFBundleDisplayName");
    
    // 登录选择按钮
    self.loginBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    self.loginBtn.selected = YES;
    [self.loginBtn setTitle:kLoadStringWithKey(@"VC_login_login") forState:UIControlStateNormal];
    [self.loginBtn setTitle:kLoadStringWithKey(@"VC_login_login") forState:UIControlStateSelected];
    [self.loginBtn setTitleColor:kGrayContextColor forState:UIControlStateNormal];
    [self.loginBtn setTitleColor:kMainColor forState:UIControlStateSelected];
    [self.loginBtn addTarget:self
                      action:@selector(switchLoginAndRegBtn:)
            forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:self.loginBtn];
    [self.loginBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.view);
        make.right.equalTo(self.view.mas_centerX);
        make.bottom.equalTo(self.view.mas_centerY).offset(-kCenterOffset);
        make.height.equalTo(@40);
    }];
    
    // 注册选择按钮
    self.registerBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    [self.registerBtn setTitle:kLoadStringWithKey(@"VC_login_Reg") forState:UIControlStateNormal];
    [self.registerBtn setTitleColor:kGrayContextColor forState:UIControlStateNormal];
    [self.registerBtn setTitleColor:kMainColor forState:UIControlStateSelected];
    [self.registerBtn addTarget:self
                         action:@selector(switchLoginAndRegBtn:)
               forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:self.registerBtn];
    [self.registerBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.bottom.equalTo(self.loginBtn);
        make.left.equalTo(self.loginBtn.mas_right);
        make.right.equalTo(self.view);
    }];
    
    self.orangeLineView = [UIView new];
    self.orangeLineView.backgroundColor = kOrangeColor;
    [self.view addSubview:self.orangeLineView];
    [self.orangeLineView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.equalTo(self.loginBtn);
        make.bottom.equalTo(self.loginBtn);
        make.height.equalTo(@2);
        make.width.equalTo(@(SCREEN_WIDTH*0.3));
    }];
    
    // ==================
    CGFloat startY = SCREEN_HEIGHT/2.0 - kCenterOffset;
    CGFloat height = SCREEN_HEIGHT - startY;
    CGRect frame = CGRectMake(0, startY, SCREEN_WIDTH*3, height);
    self.containerView = [[UIView alloc] initWithFrame:frame];
    [self.view addSubview:self.containerView];
    
    
    
#pragma mark --- 登录内容
    // phone
    self.phoneTextField = [[KMCustomTextField alloc] init];
    
    self.phoneTextField.contentTextField.placeholder = kLoadStringWithKey(@"VC_login_userName");
    //    self.phoneTextField.titleLabel.text = kLoadStringWithKey(@"VC_login_userName");
    self.phoneTextField.contentTextField.text = member.loginAccount;
    self.phoneTextField.contentTextField.textAlignment = NSTextAlignmentCenter;
    self.phoneTextField.contentTextField.font = [UIFont systemFontOfSize:18];
    self.phoneTextField.contentTextField.keyboardType = UIKeyboardTypePhonePad;
    [self.containerView addSubview:self.phoneTextField];
    [self.phoneTextField mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.containerView).offset(20);
        make.width.mas_equalTo(SCREEN_WIDTH-40);
        make.height.equalTo(@50);
        make.top.equalTo(self.containerView).offset(40);
    }];
    self.phoneTextField.contentTextField.delegate = self;
    
    // password
    self.pdTextField = [[KMCustomTextField alloc] init];
    self.pdTextField.contentTextField.placeholder = kLoadStringWithKey(@"VC_login_pd");
    //    self.pdTextField.titleLabel.text = kLoadStringWithKey(@"VC_login_pd");
    self.pdTextField.contentTextField.text = member.loginPd;
    self.pdTextField.contentTextField.textAlignment = NSTextAlignmentCenter;
    self.pdTextField.contentTextField.secureTextEntry = YES;
    self.pdTextField.contentTextField.font = [UIFont systemFontOfSize:18];
    [self.containerView addSubview:self.pdTextField];
    [self.pdTextField mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.right.height.equalTo(self.phoneTextField);
        make.top.equalTo(self.phoneTextField.mas_bottom).offset(25);
    }];
    self.pdTextField.contentTextField.delegate = self;
    
    // forget password
    UIButton *forgetPd = [UIButton buttonWithType:UIButtonTypeCustom];
    [forgetPd setTitle:kLoadStringWithKey(@"VC_login_forgetPd")
              forState:UIControlStateNormal];
    [forgetPd setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    [forgetPd addTarget:self
                 action:@selector(forgetPassWordBtnDidClicked:)
       forControlEvents:UIControlEventTouchUpInside];
    forgetPd.titleLabel.font = [UIFont systemFontOfSize:14];
    [self.containerView addSubview:forgetPd];
    [forgetPd mas_makeConstraints:^(MASConstraintMaker *make) {
        //        make.left.equalTo(self.pdTextField.mas_centerX);
        make.right.equalTo(self.pdTextField);
        make.top.equalTo(self.pdTextField.mas_bottom).offset(20);
        make.height.equalTo(@30);
    }];
    
    //记住密码按钮
    UIButton *savePwdBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    [savePwdBtn setImage:[UIImage imageNamed:@"save_pwd_nor"] forState:UIControlStateNormal];
    self.savePwdBtn = savePwdBtn;
    [savePwdBtn setImage:[UIImage imageNamed:@"save_pwd_sel"] forState:UIControlStateSelected];
    [savePwdBtn setTitle:kLoadStringWithKey(@"VC_login_save_password") forState:UIControlStateNormal];
    savePwdBtn.titleLabel.font = [UIFont systemFontOfSize:14];
    [savePwdBtn setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    savePwdBtn.contentHorizontalAlignment = UIControlContentHorizontalAlignmentLeft;
    savePwdBtn.titleEdgeInsets = UIEdgeInsetsMake(0, 8, 0, 0);
    [savePwdBtn addTarget:self action:@selector(didClickSavePwdBtn:) forControlEvents:UIControlEventTouchUpInside];
    savePwdBtn.selected = member.isSavePwd;
    savePwdBtn.imageView.size = CGSizeMake(50, 50);
    
    [self.containerView addSubview:savePwdBtn];
    [savePwdBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerY.equalTo(forgetPd);
        make.height.equalTo(@(30));
        make.width.equalTo(@(120));
        make.left.equalTo(_pdTextField);
    }];
    
    //    UILabel *savePwdLab = [[UILabel alloc]init];
    //    savePwdLab.text = kLoadStringWithKey(@"VC_login_save_password");
    //    savePwdLab.font = [UIFont systemFontOfSize:14];
    //    [self.containerView addSubview:savePwdLab];
    //    [savePwdLab mas_makeConstraints:^(MASConstraintMaker *make) {
    //        make.height.equalTo(@30);
    //        make.centerY.equalTo(forgetPd);
    //        make.left.equalTo(savePwdBtn.mas_right);
    //    }];
    
    // 真正的登录按钮
    UIButton *realLoginBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    [realLoginBtn setTintColor:[UIColor whiteColor]];
    [realLoginBtn setTitle:kLoadStringWithKey(@"VC_login_login") forState:UIControlStateNormal];
    [realLoginBtn setBackgroundImage:[UIImage imageWithColor:kMainColor] forState:UIControlStateNormal];
    realLoginBtn.layer.cornerRadius = 50/2;
    realLoginBtn.clipsToBounds = YES;
    [realLoginBtn addTarget:self
                     action:@selector(loginBtnDidClicked:)
           forControlEvents:UIControlEventTouchUpInside];
    [self.containerView addSubview:realLoginBtn];
    [realLoginBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.equalTo(self.phoneTextField);
        make.bottom.equalTo(self.containerView).offset(-50);
        make.width.equalTo(@(SCREEN_WIDTH*0.7));
        make.height.equalTo(@50);
    }];
    
    //最近登录账号列表
    UITableView *accountList = [[UITableView alloc]initWithFrame:CGRectMake(20, 90,SCREEN_WIDTH-40, 0)];
    accountList.rowHeight = 50;
    accountList.dataSource = self;
    accountList.delegate = self;
    accountList.showsVerticalScrollIndicator = NO;
    accountList.backgroundColor = [UIColor whiteColor];
    //    accountList.layer.borderWidth = 1;
    //    accountList.layer.borderColor = [UIColor colorWithRed:0.90 green:0.90 blue:0.90 alpha:1.00].CGColor;//设置列表边框
    //    accountList.layer.cornerRadius = 2;
    //    accountList.layer.masksToBounds = YES;
    
    self.accountList = accountList;
    [self.containerView addSubview:accountList];
    
    UIButton *downBtn = [[UIButton alloc]init];
    self.donwBtn = downBtn;
    [downBtn setImage:[UIImage imageNamed:@"ico_more"] forState:UIControlStateNormal];
    //position_button_open_normal
    [downBtn addTarget:self action:@selector(didDownList:) forControlEvents:UIControlEventTouchUpInside];
    [self.containerView addSubview:downBtn];
    [downBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.right.equalTo(self.phoneTextField);
        make.width.height.equalTo(self.phoneTextField.mas_height);
        make.bottom.equalTo(self.phoneTextField).offset(4);
    }];
    
#pragma mark --- 注册内容
    //号码输入框
    self.phoneNumber = [[KMCustomTextField alloc] init];
    self.phoneNumber.contentTextField.keyboardType = UIKeyboardTypePhonePad;
    [self.containerView addSubview:self.phoneNumber];
    [self.phoneNumber mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(SCREEN_WIDTH+25);
        make.width.mas_equalTo(SCREEN_WIDTH-50);
        make.top.equalTo(@20);
        make.height.mas_equalTo(SCREEN_HEIGHT*0.08);
    }];
    self.phoneNumber.titleLabel.text = kLoadStringWithKey(@"VC_login_phone");
    self.phoneNumber.contentTextField.delegate = self;
    //密码输入框
    self.passWord = [[KMCustomTextField alloc] init];
    self.passWord.contentTextField.secureTextEntry = YES;
    [self.containerView addSubview:self.passWord];
    [self.passWord mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.right.height.equalTo(self.phoneNumber);
        make.top.equalTo(self.phoneNumber.mas_bottom).offset(15);
    }];
    self.passWord.titleLabel.text = kLoadStringWithKey(@"VC_login_pd");
    self.passWord.contentTextField.delegate = self;
    
    //确认密码输入框
    self.confirmPassword = [[KMCustomTextField alloc] init];
    self.confirmPassword.contentTextField.secureTextEntry = YES;
    [self.containerView addSubview:self.confirmPassword];
    [self.confirmPassword mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.right.height.equalTo(self.phoneNumber);
        make.top.equalTo(self.passWord.mas_bottom).offset(15);
    }];
    self.confirmPassword.titleLabel.text = kLoadStringWithKey(@"Reg_VC_tip_again_pd");
    self.confirmPassword.contentTextField.delegate = self;
    
    //验证码输入视图；
    self.VerifTextField = [[KMCustomTextField alloc] init];
    self.VerifTextField.contentTextField.keyboardType = UIKeyboardTypePhonePad;
    [self.containerView addSubview:self.VerifTextField];
    [self.VerifTextField mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.right.height.equalTo(self.confirmPassword);
        make.top.equalTo(self.confirmPassword.mas_bottom).offset(10);
    }];
    self.VerifTextField.titleLabel.text = kLoadStringWithKey(@"Reg_VC_register_Verify");
    self.VerifTextField.contentTextField.delegate = self;
    self.VerifTextField.contentTextField.keyboardType = UIKeyboardTypePhonePad;
    
    
    //获取验证码按钮；
    self.getVerifButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [self.containerView addSubview:self.getVerifButton];
    [self.getVerifButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.bottom.equalTo(self.VerifTextField).offset(0);
        make.right.equalTo(self.VerifTextField.mas_right).offset(12.5);
        make.height.mas_equalTo(25);
        make.width.mas_equalTo(80);
    }];
    [self.getVerifButton addTarget:self action:@selector(getVerifButtonDidClicked:) forControlEvents:UIControlEventTouchDown];
    [self.getVerifButton setTitleColor:[UIColor orangeColor] forState:UIControlStateNormal];
    [self.getVerifButton setTitle:kLoadStringWithKey(@"Reg_VC_register_GetVerify") forState:UIControlStateNormal];
    [self.getVerifButton.titleLabel setFont:[UIFont systemFontOfSize:10]];
    self.getVerifButton.layer.borderColor = [UIColor orangeColor].CGColor;
    self.getVerifButton.layer.borderWidth = 1;
    self.getVerifButton.layer.cornerRadius = 12.5;
    
    //协议按钮；
    self.protocolButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [self.containerView addSubview:self.protocolButton];
    [self.protocolButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.height.equalTo(self.phoneNumber);
        make.left.mas_offset(SCREEN_WIDTH+(SCREEN_WIDTH-300)/2);
        make.width.mas_offset(300);
        make.top.equalTo(self.VerifTextField.mas_bottom).offset(10);
    }];
    [self.protocolButton addTarget:self action:@selector(protocolButtonDidClickedAction:) forControlEvents:UIControlEventTouchDown];
    [self.protocolButton setImage:[UIImage imageNamed:@"register_unagree"] forState:UIControlStateNormal];
    [self.protocolButton setImage:[UIImage imageNamed:@"register_agree"] forState:UIControlStateSelected];
    NSString *aString = [NSString stringWithFormat:@"%@%@",
                         kLoadStringWithKey(@"Reg_VC_register_protocol"),
                         kLoadStringWithKey(@"Reg_VC_register_protocol_text")];
    NSMutableAttributedString * aAttributedString = [[NSMutableAttributedString alloc] initWithString:aString];
    [aAttributedString addAttribute:NSForegroundColorAttributeName  //文字颜色
                              value:[UIColor grayColor]
                              range:NSMakeRange(0, kLoadStringWithKey(@"Reg_VC_register_protocol").length)];
    [aAttributedString addAttribute:NSForegroundColorAttributeName  //文字颜色
                              value:kMainColor
                              range:NSMakeRange(kLoadStringWithKey(@"Reg_VC_register_protocol").length, kLoadStringWithKey(@"Reg_VC_register_protocol_text").length)];
    [self.protocolButton setAttributedTitle:aAttributedString forState:UIControlStateNormal];
    self.protocolButton.titleLabel.numberOfLines = 0;
    
    self.protocolButton.titleLabel.font = [UIFont systemFontOfSize:13];
    self.protocolButton.titleEdgeInsets = UIEdgeInsetsMake(0,15,0,0);
    self.protocolButton.selected = YES;
    // 协议视图
    UIView * protocolView = [[UIView alloc] init];
    [self.protocolButton addSubview:protocolView];
    [protocolView mas_makeConstraints:^(MASConstraintMaker *make)
     {
         make.height.equalTo(self.protocolButton);
         make.width.mas_equalTo(130);
         make.top.mas_equalTo(0);
         make.left.equalTo(self.protocolButton.mas_centerX).offset(-5);
     }];
    UITapGestureRecognizer * tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(readProtocolMethod:)];
    [protocolView addGestureRecognizer:tap];
    
    //下一步按钮；
    self.nextButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [self.containerView addSubview:self.nextButton];
    [self.nextButton mas_makeConstraints:^(MASConstraintMaker *make){
        make.top.equalTo(self.protocolButton.mas_bottom).offset(12);
        make.centerX.equalTo(self.phoneNumber.mas_centerX);
        make.width.mas_equalTo(SCREEN_WIDTH*0.7);
        make.height.mas_equalTo(50);
    }];
    [self.nextButton addTarget:self action:@selector(nextButtonDidClicked:) forControlEvents:UIControlEventTouchDown];
    [self.nextButton setBackgroundImage:[UIImage imageWithColor:kMainColor] forState:UIControlStateNormal];
    [self.nextButton setTitle:kLoadStringWithKey(@"Reg_VC_register_finish") forState:UIControlStateNormal];
    self.nextButton.layer.cornerRadius = 50/2;
    self.nextButton.layer.masksToBounds = YES;
}
-(void)viewDidLayoutSubviews {
    
    if ([self.accountList respondsToSelector:@selector(setSeparatorInset:)]) {
        [self.accountList setSeparatorInset:UIEdgeInsetsZero];
        
    }
    if ([self.accountList respondsToSelector:@selector(setLayoutMargins:)])  {
        [self.accountList setLayoutMargins:UIEdgeInsetsZero];
    }
    
}

-(void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPat{
    if ([cell respondsToSelector:@selector(setLayoutMargins:)]) {
        [cell setLayoutMargins:UIEdgeInsetsZero];
    }
    if ([cell respondsToSelector:@selector(setSeparatorInset:)]){
        [cell setSeparatorInset:UIEdgeInsetsZero];
    }
}
#pragma mark - 阅读协议方法
- (void)readProtocolMethod:(UITapGestureRecognizer *)tap
{
    KMProtocolVC * protocol = [[KMProtocolVC alloc] init];
    protocol.htmURL = kLoadStringWithKey(@"HTML_type_protocol");
    UINavigationController * NC = [[UINavigationController alloc] initWithRootViewController:protocol];
    [self presentViewController:NC animated:YES completion:nil];
}

#pragma mark - UITextFieldDelegate
-(BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string
{
    if (textField == self.VerifTextField.contentTextField)
    {
        if (textField.text.length >=10)
        {
            if (string.length == 0)  return YES;
            
            return NO;
        }
    }
    if (textField.text.length >=15)
    {
        if (string.length == 0)  return YES;
        return NO;
    }
    return YES;
}
-(void)textFieldDidBeginEditing:(UITextField *)textField
{
    UIView * view = textField.superview;
    if ([view isKindOfClass:[KMCustomTextField class]])
    {
        KMCustomTextField* newView = (KMCustomTextField *)view;
        newView.grayLine.backgroundColor = [UIColor orangeColor];
    }
    
    //收起下拉菜单
    if (!self.isDown) {
        return;
    }
    [UIView animateWithDuration:0.3 animations:^{
        self.accountList.frame = CGRectMake(self.accountList.frame.origin.x, self.accountList.frame.origin.y, self.accountList.frame.size.width, 0);
        self.donwBtn.transform = CGAffineTransformRotate(self.donwBtn.transform, -M_PI_2);
        self.donwBtn.transform = CGAffineTransformRotate(self.donwBtn.transform, -M_PI_2);
    } completion:^(BOOL finished) {
        
    }];
    self.isDown = NO;
    
}
-(void)textFieldDidEndEditing:(UITextField *)textField
{
    
    UIView * view = textField.superview;
    if ([view isKindOfClass:[KMCustomTextField class]])
    {
        KMCustomTextField* newView = (KMCustomTextField *)view;
        newView.grayLine.backgroundColor = [UIColor colorWithRed:0 green:0 blue:0 alpha:0.05];
    }
    
}


#pragma mark --- 获取验证码按钮
-(void)getVerifButtonDidClicked:(UIButton *)sender
{
    
    BOOL result =  [self registerInfomationDecetionWithIdentiier:1];
    if (result)
    {
        [self startRegisterRequest];
    }
}

#pragma mark --- 下一步按钮点击事件
-(void)nextButtonDidClicked:(UIButton *)sender
{
    //保存数据
    if ([self registerInfomationDecetionWithIdentiier:2])
    {
        [self authWithAccountWithVerifyCode];
    }
}

#pragma mark 忘记密码
- (void)forgetPassWordBtnDidClicked:(UIButton *)sender
{
    KMForgetPasswordVC * forgetVC = [[KMForgetPasswordVC alloc] init];
    UINavigationController * forgetNC = [[UINavigationController alloc] initWithRootViewController:forgetVC];
    [self presentViewController:forgetNC animated:YES completion:nil];
}

#pragma mark --- 通过手机号码和密码，发送验证码；
-(void)startRegisterRequest
{
    WS(ws);
    NSString * request = [NSString stringWithFormat:@"regist_get/%@/86?_type=json",self.phoneNumber.contentTextField.text];
    [[KMNetAPI manager] commonGetRequestWithURL:request Block:^(int code, NSString *res)
     {
         KMNetworkResModel * resModel = [KMNetworkResModel mj_objectWithKeyValues:res];
         if (code == 0 && resModel.errorCode <= kNetReqSuccess)
         {
             [ws theTimer];
             [ws customAlertViewShowWithMessage:kLoadStringWithKey(@"Reg_VC_register_request_success") withStatus:1];
             [ws customAlertViewClose];
         }else
         {
             [ws customAlertViewShowWithMessage:kNetReqFailWithCode(resModel.errorCode) withStatus:0];
         }
     }];
}

// 正则匹配手机号码
-(BOOL)checkTelNumber:(NSString *)telNumber
{
    NSString *pattern = @"^1+[3578]+\\d{9}";
    NSPredicate *pred = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", pattern];
    BOOL isMatch = [pred evaluateWithObject:telNumber];
    return isMatch;
}

// 正则匹配密码
-(BOOL)checkPassword:(NSString *)password
{
    NSString * pattern = @"^.{6,15}$";
    NSPredicate *pred = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", pattern];
    BOOL isMatch = [pred evaluateWithObject:password];
    return isMatch;
}



#pragma mark --- 使用简讯接收认到的证码和相应的账号
-(void)authWithAccountWithVerifyCode
{
    // 开始更改操作
    [SVProgressHUD showWithStatus:kLoadStringWithKey(@"Common_network_request_now")];
    NSString * request = [NSString stringWithFormat:@"auth/%@/%@/%@",self.phoneNumber.contentTextField.text,self.VerifTextField.contentTextField.text,self.passWord.contentTextField.text];
    [[KMNetAPI manager] commonGetRequestWithURL:request Block:^(int code, NSString *res)
     {
         [SVProgressHUD dismiss];
         KMNetworkResModel * resModel = [KMNetworkResModel mj_objectWithKeyValues:res];
         if (code == 0 && resModel.errorCode <= kNetReqSuccess)
         {
             [self cancelVerifyTime];
             [self customAlertViewShowWithMessage:kLoadStringWithKey(@"Reg_VC_register_success") withStatus:1];
             [self customAlertViewClose];
             [self moveView];
             [MobClick event:@"Register_Count"];
             
         }else
         {
             [self customAlertViewShowWithMessage:kNetReqFailWithCode(resModel.errorCode) withStatus:0];
         }
     }];
}
#pragma Mark --- 调整视图
-(void)moveView
{
    self.loginBtn.selected = YES;
    self.registerBtn.selected = NO;
    
    //调整下滑为位置
    [self.orangeLineView mas_remakeConstraints:^(MASConstraintMaker *make)
     {
         make.centerX.equalTo(self.loginBtn);
         make.bottom.equalTo(self.loginBtn);
         make.height.equalTo(@2);
         make.width.equalTo(@70);
     }];
    //调整显示视图位置
    [UIView animateWithDuration:0.5 animations:^
     {
         CGRect frame = self.containerView.frame;
         frame.origin.x = 0;
         self.containerView.frame = frame;
     }];
    
}


#pragma mark --- 取消定时器
-(void)cancelVerifyTime
{
    dispatch_source_cancel(_timer);
    [self.getVerifButton setTitle:kLoadStringWithKey(@"Reg_VC_register_GetVerify") forState:UIControlStateNormal];
    self.getVerifButton.userInteractionEnabled = YES;
}


#pragma mark --- 定时器
-(void)theTimer
{
    __block int  timeout = 59; // 定时时间
    dispatch_queue_t queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
    _timer = dispatch_source_create(DISPATCH_SOURCE_TYPE_TIMER, 0, 0,queue);
    dispatch_source_set_timer(_timer,dispatch_walltime(NULL, 0),1.0*NSEC_PER_SEC, 0); //每秒执行
    dispatch_source_set_event_handler(_timer, ^
                                      {
                                          if(timeout<=0)
                                          { //倒计时结束，关闭
                                              dispatch_source_cancel(_timer);
                                              dispatch_async(dispatch_get_main_queue(), ^
                                                             {
                                                                 //设置界面的按钮显示 根据自己需求设置
                                                                 [_getVerifButton setTitle:kLoadStringWithKey(@"Reg_VC_register_GetVerify") forState:UIControlStateNormal];
                                                                 _getVerifButton.userInteractionEnabled = YES;
                                                             });
                                          }else
                                          {
                                              int seconds = timeout % 60;
                                              NSString *strTime = [NSString stringWithFormat:@"%.2d", seconds];
                                              dispatch_async(dispatch_get_main_queue(), ^
                                                             {
                                                                 //设置界面的按钮显示 根据自己需求设置
                                                                 //NSLog(@"____%@",strTime);
                                                                 [UIView beginAnimations:nil context:nil];
                                                                 [UIView setAnimationDuration:1];
                                                                 [_getVerifButton setTitle:[NSString stringWithFormat:@"%@%@",strTime,kLoadStringWithKey(@"Reg_VC_register_request_wait")] forState:UIControlStateNormal];
                                                                 [UIView commitAnimations];
                                                                 _getVerifButton.userInteractionEnabled = NO;
                                                             });
                                              timeout--;
                                          }
                                      });
    dispatch_resume(_timer);
}

#pragma mark ---  注册信息检测
-(BOOL)registerInfomationDecetionWithIdentiier:(NSInteger)index{
    
    if (index == 1)
    {
        //注册检测信息完整度
        if (![self checkTelNumber:self.phoneNumber.contentTextField.text])
        {
            
            [self customAlertViewShowWithMessage:kLoadStringWithKey(@"CustomAlert_phone_title") withStatus:0];
            return NO;
        }else
        {
            return YES;
        }
    }
    
    // 密码检测；
    if (![self checkPassword:self.passWord.contentTextField.text])
    {
        [self customAlertViewShowWithMessage:kLoadStringWithKey(@"CustomAlert_password_title") withStatus:0];
        [self customAlertViewClose];
        return NO;
    }
    
    //验证码检测
    if (self.VerifTextField.contentTextField.text.length == 0)
    {
        [self customAlertViewShowWithMessage:kLoadStringWithKey(@"CustomAlert_verity_title") withStatus:0];
        [self customAlertViewClose];
        return NO;
    }
    
    // 协议按钮检测；
    if (self.protocolButton.selected != YES)
    {
        [self customAlertViewShowWithMessage:kLoadStringWithKey(@"CustomAlert_protocol_title") withStatus:0];
        [self customAlertViewClose];
        return NO;
    }
    
    // 再次输入密码检测；
    if (![self.passWord.contentTextField.text isEqualToString:self.confirmPassword.contentTextField.text])
    {
        
        [self customAlertViewShowWithMessage:kLoadStringWithKey(@"CustomAlert_againPW_title") withStatus:0];
        [self customAlertViewClose];
        return NO;
    }
    
    return YES;
}


#pragma mark --- 协议按钮点击方法
-(void)protocolButtonDidClickedAction:(UIButton *)sender
{
    sender.selected = !sender.selected;
}


#pragma mark --- 信息提示框显示
//显示信息提示框
-(void)customAlertViewShowWithMessage:(NSString *)message withStatus:(NSInteger)index
{
    // 提示框
    self.messageView = [[CustomIOSAlertView alloc] init];
    self.messageView.buttonTitles = nil;
    [self.messageView setUseMotionEffects:NO];
    
    UIView * alertView = [[UIView alloc] initWithFrame:CGRectMake(0,0,SCREEN_WIDTH*0.9,220)];
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
    if (index == 0)
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
         make.height.mas_equalTo(100);
         make.top.equalTo(alertView.mas_centerY);
     }];
    massageLabel.textAlignment = NSTextAlignmentCenter;
    massageLabel.text = message;
    massageLabel.numberOfLines = 0;
    [self.messageView show];
}

#pragma mark --- 下拉按钮
- (void)didDownList:(UIButton *)sender{
    [self.phoneTextField endEditing:YES];
    if (self.isDown) {
        [UIView animateWithDuration:0.3 animations:^{
            self.accountList.frame = CGRectMake(self.accountList.frame.origin.x, self.accountList.frame.origin.y, self.accountList.frame.size.width, 0);
            self.donwBtn.transform = CGAffineTransformRotate(self.donwBtn.transform, -M_PI_2);
            self.donwBtn.transform = CGAffineTransformRotate(self.donwBtn.transform, -M_PI_2);
        } completion:^(BOOL finished) {
            
        }];
    }else{
        CGFloat height = self.accountArray.count * 50;
        height = (height > 200) ? 200 : height;
        [UIView animateWithDuration:0.3 animations:^{
            self.accountList.frame = CGRectMake(self.accountList.frame.origin.x, self.accountList.frame.origin.y, self.accountList.frame.size.width, height);
            self.donwBtn.transform = CGAffineTransformRotate(self.donwBtn.transform, M_PI);
            
        } completion:^(BOOL finished) {
            
        }];
        
    }
    self.isDown = !self.isDown;
}

- (void)upAccountList{
    if (!self.isDown) {
        return;
    }
    [self.phoneTextField endEditing:YES];
    [UIView animateWithDuration:0.3 animations:^{
        self.accountList.frame = CGRectMake(self.accountList.frame.origin.x, self.accountList.frame.origin.y, self.accountList.frame.size.width, 0);
        self.donwBtn.transform = CGAffineTransformRotate(self.donwBtn.transform, -M_PI_2);
        self.donwBtn.transform = CGAffineTransformRotate(self.donwBtn.transform, -M_PI_2);
    } completion:^(BOOL finished) {
        
    }];
    self.isDown = NO;
}

#pragma mark 记住密码
- (void)didClickSavePwdBtn:(UIButton *)sender{
    sender.selected = !sender.isSelected;
    
    
}

#pragma mark --- TableViewDataSource
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return self.accountArray.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"cell"];
    if (!cell) {
        cell = [[UITableViewCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"cell"];
    }
    
    NSDictionary *dic = self.accountArray[indexPath.row];
    
    cell.textLabel.text = dic[@"account"];
    cell.textLabel.textAlignment = NSTextAlignmentCenter;
    cell.textLabel.font = [UIFont systemFontOfSize:18];
    
    return cell;
}

#pragma mark - TableViewDelegate
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    [tableView deselectRowAtIndexPath:indexPath animated:NO];
    NSDictionary *dic = self.accountArray[indexPath.row];
    self.phoneTextField.contentTextField.text = dic[@"account"];
    NSString *pwd = dic[@"password"];
    if (![pwd isEqualToString:@""] && pwd != nil) {
        
        NSData *nsdataFromBase64String = [[NSData alloc] initWithBase64EncodedString:pwd options:0];
        // Decoded NSString from the NSData
        NSString *base64Decoded = [[NSString alloc] initWithData:nsdataFromBase64String encoding:NSUTF8StringEncoding];
        self.pdTextField.contentTextField.text = base64Decoded;
        self.savePwdBtn.selected = YES;
    }else{
        self.pdTextField.contentTextField.text = @"";
        self.savePwdBtn.selected = NO;
    }
    
    [self upAccountList];
    
}
//侧滑删除
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    return YES;
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        // Delete the row from the data source.
        DMLog(@"delete%zd",indexPath.row);
        [[KMAccountManager sharedInstance]removeAccount:self.accountArray[indexPath.row][@"account"]];
        NSMutableArray *mArr = self.accountArray.mutableCopy;
        [mArr removeObjectAtIndex:indexPath.row];
        self.accountArray = mArr.copy;
        [tableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationFade];
    }
    else if (editingStyle == UITableViewCellEditingStyleInsert) {
        // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view.
    }
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
#pragma mark - 登录、注册按钮切换
- (void)switchLoginAndRegBtn:(UIButton *)sender {
    
    [self.view endEditing:YES];
    self.loginBtn.selected = NO;
    self.registerBtn.selected = NO;
    sender.selected = YES;
    if (sender == self.loginBtn) {
        [self.orangeLineView mas_remakeConstraints:^(MASConstraintMaker *make) {
            make.centerX.equalTo(self.loginBtn);
            make.bottom.equalTo(self.loginBtn);
            make.height.equalTo(@2);
            make.width.equalTo(@70);
        }];
        
        [UIView animateWithDuration:0.5 animations:^{
            CGRect frame = self.containerView.frame;
            frame.origin.x = 0;
            self.containerView.frame = frame;
        }];
    } else {
        [self.orangeLineView mas_remakeConstraints:^(MASConstraintMaker *make) {
            make.centerX.equalTo(self.registerBtn);
            make.bottom.equalTo(self.loginBtn);
            make.height.equalTo(@2);
            make.width.equalTo(@70);
        }];
        
        [UIView animateWithDuration:0.5 animations:^{
            CGRect frame = self.containerView.frame;
            frame.origin.x = -SCREEN_WIDTH;
            self.containerView.frame = frame;
        }];
    }
}

#pragma mark 自动登录

- (void)autoLogin {
    if (member.loginAccount.length != 0 && member.loginPd.length != 0 && member.isSavePwd) {
        
        [SVProgressHUD show];
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            
            [self loginBtnDidClicked:nil];
        });
    }
}

#pragma mark 确认登录
- (void)loginBtnDidClicked:(UIButton *)sender {
    // check
    if (self.phoneTextField.contentTextField.text.length == 0 || self.pdTextField.contentTextField.text.length == 0) {
        
        [self customAlertViewShowWithMessage:kLoadStringWithKey(@"VC_login_error_input")withStatus:0];
        
        return;
    }
    
    // start to login
    [SVProgressHUD show];
    NSString *request = [NSString stringWithFormat:@"loginAuth/%@/%@",
                         self.phoneTextField.contentTextField.text,
                         self.pdTextField.contentTextField.text];
    
    WS(ws);
    
    [[KMNetAPI manager] commonGetRequestWithURL:request Block:^(int code, NSString *res)
     {
         KMNetworkResModel *model = [KMNetworkResModel mj_objectWithKeyValues:res];
         if (code == 0 && model.errorCode <= kNetReqSuccess)
         {
             [SVProgressHUD dismiss];
             [ws loginSuccess];
             
         } else
         {
             [SVProgressHUD dismiss];
             [self customAlertViewShowWithMessage:kNetReqFailWithCode(model.errorCode) withStatus:0];
         }
     }];
}

- (void)loginSuccess {
    // save user login information
    member.loginAccount = self.phoneTextField.contentTextField.text;
    member.loginPd = self.pdTextField.contentTextField.text;
    member.isSavePwd = self.savePwdBtn.isSelected;
    [[KMAccountManager sharedInstance]setAccountListWithSave:self.savePwdBtn.isSelected];
    // 清除图片缓存
    [[SDImageCache sharedImageCache] clearMemory];
    [[SDImageCache sharedImageCache] clearDiskOnCompletion:nil];
    
    // 侧滑
    KMNew_MainVC *mainVC = [[KMNew_MainVC alloc] init];
    UDNavigationController *navVC = [[UDNavigationController alloc] initWithRootViewController:mainVC];
    KMLeftSlideVC *leftVC = [[KMLeftSlideVC alloc] init];
    
    ECSlidingViewController *slideVC = [ECSlidingViewController slidingWithTopViewController:navVC];
    slideVC.underLeftViewController = leftVC;
    [MobClick event:@"Login_Count"];
    [self presentViewController:slideVC animated:YES completion:nil];
}

#pragma mark - 极光推送
- (void)configJPush
{
    NSNotificationCenter *defaultCenter = [NSNotificationCenter defaultCenter];
    [defaultCenter addObserver:self
                      selector:@selector(networkDidSetup:)
                          name:kJPFNetworkDidSetupNotification
                        object:nil];
    [defaultCenter addObserver:self
                      selector:@selector(networkDidClose:)
                          name:kJPFNetworkDidCloseNotification
                        object:nil];
    [defaultCenter addObserver:self
                      selector:@selector(networkDidRegister:)
                          name:kJPFNetworkDidRegisterNotification
                        object:nil];
    [defaultCenter addObserver:self
                      selector:@selector(networkDidLogin:)
                          name:kJPFNetworkDidLoginNotification
                        object:nil];
    [defaultCenter addObserver:self
                      selector:@selector(networkDidReceiveMessage:)
                          name:kJPFNetworkDidReceiveMessageNotification
                        object:nil];
    [defaultCenter addObserver:self
                      selector:@selector(serviceError:)
                          name:kJPFServiceErrorNotification
                        object:nil];
}

- (void)unObserveAllNotifications
{
    NSNotificationCenter *defaultCenter = [NSNotificationCenter defaultCenter];
    [defaultCenter removeObserver:self
                             name:kJPFNetworkDidSetupNotification
                           object:nil];
    [defaultCenter removeObserver:self
                             name:kJPFNetworkDidCloseNotification
                           object:nil];
    [defaultCenter removeObserver:self
                             name:kJPFNetworkDidRegisterNotification
                           object:nil];
    [defaultCenter removeObserver:self
                             name:kJPFNetworkDidLoginNotification
                           object:nil];
    [defaultCenter removeObserver:self
                             name:kJPFNetworkDidReceiveMessageNotification
                           object:nil];
    [defaultCenter removeObserver:self
                             name:kJPFServiceErrorNotification
                           object:nil];
}

- (void)networkDidSetup:(NSNotification *)notification
{
    NSLog(@"已连接");
    
    NSString *jid = [JPUSHService registrationID];
    DMLog(@"JID: %@", jid);
}

- (void)networkDidClose:(NSNotification *)notification
{
    NSLog(@"未连接");
}

- (void)networkDidRegister:(NSNotification *)notification
{
    NSLog(@"已注册");
}

- (void)networkDidLogin:(NSNotification *)notification
{
    NSString *jid = [JPUSHService registrationID];
    DMLog(@"JID: %@", jid);
}

- (void)networkDidReceiveMessage:(NSNotification *)notification
{
    NSDictionary *userInfo = [notification userInfo];
    NSString *title = [userInfo valueForKey:@"title"];
    NSString *content = [userInfo valueForKey:@"content"];
    NSDictionary *extra = [userInfo valueForKey:@"extras"];
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    
    [dateFormatter setDateFormat:@"yyyy-MM-dd hh:mm:ss"];
    
    NSString *currentContent = [NSString
                                stringWithFormat:
                                @"收到自定义消息:%@\ntitle:%@\ncontent:%@\nextra:%@\n",
                                [NSDateFormatter localizedStringFromDate:[NSDate date]
                                                               dateStyle:NSDateFormatterNoStyle
                                                               timeStyle:NSDateFormatterMediumStyle],
                                title, content, [self logDic:extra]];
    DMLog(@"%@", currentContent);
}

- (void)serviceError:(NSNotification *)notification
{
    NSDictionary *userInfo = [notification userInfo];
    NSString *error = [userInfo valueForKey:@"error"];
    NSLog(@"%@", error);
}

// log NSSet with UTF8
// if not ,log will be \Uxxx
- (NSString *)logDic:(NSDictionary *)dic
{
    if (![dic count]) {
        return nil;
    }
    
    NSString *tempStr1 =
    [[dic description] stringByReplacingOccurrencesOfString:@"\\u"
                                                 withString:@"\\U"];
    NSString *tempStr2 =
    [tempStr1 stringByReplacingOccurrencesOfString:@"\"" withString:@"\\\""];
    NSString *tempStr3 =
    [[@"\"" stringByAppendingString:tempStr2] stringByAppendingString:@"\""];
    NSData *tempData = [tempStr3 dataUsingEncoding:NSUTF8StringEncoding];
    NSString *str =
    [NSPropertyListSerialization propertyListFromData:tempData mutabilityOption:NSPropertyListImmutable format:NULL errorDescription:NULL];
    return str;
}

- (NSArray *)accountArray{
    if (_accountArray != nil) {
        return _accountArray;
    }
    _accountArray = [[KMAccountManager sharedInstance]getAccountList];
    
    return _accountArray;
}

- (void)dealloc
{
    [self unObserveAllNotifications];
}

@end
