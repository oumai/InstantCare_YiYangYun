//
//  ViewController.m
//  InstantCare
//
//  Created by bruce-zhu on 15/11/27.
//  Copyright © 2015年 omg. All rights reserved.
//

#import "KMMalaysiaLoginVC.h"
#import "KMMemberManager.h"
#import "KMMainVC.h"
#import "PNChart.h"
#import "AFNetworking.h"
#import "KMNetAPI.h"
#import "KMUserModel.h"
#import "KMPushMsgModel.h"
#import "JPUSHService.h"
//#import "KMShowAlertMsgWindow.h"
#import "KMLocationVC.h"
#import "ECSlidingViewController.h"
#import "KMLeftSlideVC.h"
#import "KMCustomTextField.h"
#import "KMForgetPasswordVC.h"
#import "KMProtocolVC.h"
#import "CustomIOSAlertView.h"
#import "UIImage+Extension.h"
#import "UIImageView+WebCache.h"
#import "MJExtension.h"

// 选择按钮距离屏幕Y坐标距离
#define kCenterOffset       100


@interface KMMalaysiaLoginVC ()<UITextFieldDelegate>

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


@end

@implementation KMMalaysiaLoginVC

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    [self initLoginView];
    [self autoLogin];
  
}

- (void)viewDidAppear:(BOOL)animated {
    
    self.phoneTextField.contentTextField.text = member.loginAccount;
    self.pdTextField.contentTextField.text = member.loginPd;
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
    
#pragma mark --- 登录内容
    // phone
    self.phoneTextField = [[KMCustomTextField alloc] init];
    self.phoneTextField.titleLabel.text = kLoadStringWithKey(@"VC_login_userName");
    self.phoneTextField.contentTextField.text = member.loginAccount;
    self.phoneTextField.contentTextField.textAlignment = NSTextAlignmentCenter;
    self.phoneTextField.contentTextField.font = [UIFont systemFontOfSize:18];
    self.phoneTextField.contentTextField.keyboardType = UIKeyboardTypePhonePad;
    [self.view addSubview:self.phoneTextField];
    [self.phoneTextField mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.view).offset(20);
        make.width.mas_equalTo(SCREEN_WIDTH-40);
        make.height.equalTo(@50);
        make.top.equalTo(self.view.mas_centerY).offset(-100);
    }];
    self.phoneTextField.contentTextField.delegate = self;
    
    // password
    self.pdTextField = [[KMCustomTextField alloc] init];
    self.pdTextField.titleLabel.text = kLoadStringWithKey(@"VC_login_pd");
    self.pdTextField.contentTextField.text = member.loginPd;
    self.pdTextField.contentTextField.textAlignment = NSTextAlignmentCenter;
    self.pdTextField.contentTextField.secureTextEntry = YES;
    self.pdTextField.contentTextField.font = [UIFont systemFontOfSize:18];
    [self.view addSubview:self.pdTextField];
    [self.pdTextField mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.right.height.equalTo(self.phoneTextField);
        make.top.equalTo(self.phoneTextField.mas_bottom).offset(25);
    }];
    self.pdTextField.contentTextField.delegate = self;

    // forget password
//    UIButton *forgetPd = [UIButton buttonWithType:UIButtonTypeCustom];
//    [forgetPd setTitle:kLoadStringWithKey(@"VC_login_forgetPd")
//              forState:UIControlStateNormal];
//    [forgetPd setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
//    [forgetPd addTarget:self
//                 action:@selector(forgetPassWordBtnDidClicked:)
//       forControlEvents:UIControlEventTouchUpInside];
//    forgetPd.titleLabel.font = [UIFont systemFontOfSize:14];
//    [self.view addSubview:forgetPd];
//    [forgetPd mas_makeConstraints:^(MASConstraintMaker *make) {
//        make.left.equalTo(self.pdTextField.mas_centerX);
//        make.right.equalTo(self.pdTextField);
//        make.top.equalTo(self.pdTextField.mas_bottom).offset(20);
//        make.height.equalTo(@30);
//    }];

    // 真正的登录按钮
    UIButton *realLoginBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    [realLoginBtn setTintColor:[UIColor whiteColor]];
    [realLoginBtn setTitle:kLoadStringWithKey(@"VC_login_login") forState:UIControlStateNormal];
    [realLoginBtn setBackgroundImage:[UIImage imageWithColor:kMainColor] forState:UIControlStateNormal];
    realLoginBtn.layer.cornerRadius = 50/2;
    realLoginBtn.clipsToBounds = YES;
    
    [realLoginBtn addTarget:self action:@selector(loginBtnDidClicked:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:realLoginBtn];
    [realLoginBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.equalTo(self.phoneTextField);
        make.bottom.equalTo(self.view).offset(-80);
        make.width.equalTo(@(SCREEN_WIDTH*0.7));
        make.height.equalTo(@50);
    }];
    

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

/**
 *   输入框开始编辑
 */
-(void)textFieldDidBeginEditing:(UITextField *)textField
{
    UIView * view = textField.superview;
    if ([view isKindOfClass:[KMCustomTextField class]])
    {
        KMCustomTextField* newView = (KMCustomTextField *)view;
        newView.grayLine.backgroundColor = [UIColor orangeColor];
    }
}

/**
 *   输入框结束编辑
 */
-(void)textFieldDidEndEditing:(UITextField *)textField
{
    
    UIView * view = textField.superview;
    if ([view isKindOfClass:[KMCustomTextField class]])
    {
        KMCustomTextField* newView = (KMCustomTextField *)view;
        newView.grayLine.backgroundColor = [UIColor colorWithRed:0 green:0 blue:0 alpha:0.05];
    }
    
}


#pragma mark 忘记密码
- (void)forgetPassWordBtnDidClicked:(UIButton *)sender
{
    KMForgetPasswordVC * forgetVC = [[KMForgetPasswordVC alloc] init];
    UINavigationController * forgetNC = [[UINavigationController alloc] initWithRootViewController:forgetVC];
    [self presentViewController:forgetNC animated:YES completion:nil];
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
         make.height.mas_equalTo(60);
         make.top.equalTo(alertView.mas_centerY);
     }];
    massageLabel.textAlignment = NSTextAlignmentCenter;
    massageLabel.text = message;
    massageLabel.numberOfLines = 0;
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


#pragma mark 自动登录
- (void)autoLogin {
    if (member.loginAccount.length != 0 && member.loginPd.length != 0 ) {
        
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
    
    // 清除图片缓存
    [[SDImageCache sharedImageCache] clearMemory];
    [[SDImageCache sharedImageCache] clearDiskOnCompletion:nil];
    
    // 侧滑
    KMMainVC *mainVC = [[KMMainVC alloc] init];
    UINavigationController *navVC = [[UINavigationController alloc] initWithRootViewController:mainVC];
    
    KMLeftSlideVC *leftVC = [[KMLeftSlideVC alloc] init];
    
    ECSlidingViewController *slideVC = [ECSlidingViewController slidingWithTopViewController:navVC];
    slideVC.underLeftViewController = leftVC;
    
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
    [NSPropertyListSerialization propertyListFromData:tempData
                                     mutabilityOption:NSPropertyListImmutable
                                               format:NULL
                                     errorDescription:NULL];
    return str;
}


- (void)dealloc
{
    [self unObserveAllNotifications];
}

@end


