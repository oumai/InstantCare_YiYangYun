//
//  KMWebViewVC.m
//  InstantCare
//
//  Created by km on 16/6/20.
//  Copyright © 2016年 omg. All rights reserved.
//

#import "KMWebViewVC.h"
#import "KMRecordsButton.h"

#define kRecordBtnWidth     (SCREEN_WIDTH/3.0)
#define kRecordBtnHeight    40

@interface KMWebViewVC ()

@property(nonatomic,strong)UIWebView *webView;

@property (nonatomic, strong) KMRecordsButton *help8010Btn;

@property (nonatomic, strong) KMRecordsButton *help8000Btn;

@property (nonatomic, strong) KMRecordsButton *helpAppBtn;

@end

@implementation KMWebViewVC

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor whiteColor];
    [self configWebView];
    [self configNavigation];
    
}

#pragma mark - 配置导航栏
-(void)configNavigation
{
    UIButton * leftButton  = [UIButton buttonWithType:UIButtonTypeCustom];
    leftButton.frame = CGRectMake(0, 0,30,30);
    [leftButton setBackgroundImage:[UIImage imageNamed:@"return_normal"] forState:UIControlStateNormal];
    [leftButton setBackgroundImage:[UIImage imageNamed:@"return_sel"] forState:UIControlStateSelected];
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:leftButton];
    [leftButton addTarget:self action:@selector(backToLoginView:) forControlEvents:UIControlEventTouchDown];
    self.title = self.navigationTitle;
}

/**
 *  返回方法
 *
 */
-(void)backToLoginView:(UIButton *)sender
{
    [self.navigationController popViewControllerAnimated:YES];
}

#pragma mark - 配置视图
- (void)configWebView
{
    CGFloat topOffset = 0;
    self.webView = [[UIWebView alloc] init];
    [self.view addSubview:self.webView];

    // 帮助有三个可选项, 默认选择KM8010
    if ([self.htmURL isEqualToString:@"_help"]) {
        [self addThreeHelpBtn];
        self.htmURL = kLoadStringWithKey(@"HTML_type_help_8010");
        topOffset = kRecordBtnHeight;
    }
    topOffset += (IS_IPHONE_X ? 88 : 64);
    [self.webView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.view.mas_top).offset(topOffset);
        make.left.right.bottom.equalTo(self.view);
    }];
    
    NSURL * fileurl = [[NSBundle mainBundle] URLForResource:self.htmURL withExtension:nil];
    NSURLRequest *request = [[NSURLRequest alloc] initWithURL:fileurl];
    [self.webView loadRequest:request];
    
    
}

- (void)addThreeHelpBtn {
    _help8010Btn = [KMRecordsButton buttonWithType:UIButtonTypeCustom];
    _help8010Btn.tag = 0;
    [_help8010Btn setTitle:@"KM - 8010" forState:UIControlStateNormal];
    [_help8010Btn setTitleColor:kGrayColor forState:UIControlStateNormal];
    [_help8010Btn setTitleColor:kMainColor forState:UIControlStateSelected];
    [_help8010Btn addTarget:self action:@selector(helpBtnDidClicked:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:_help8010Btn];
    
    [_help8010Btn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.view);
        make.top.equalTo(self.view).offset(IS_IPHONE_X ? 88 : 64);
        make.width.equalTo(@kRecordBtnWidth);
        make.height.equalTo(@kRecordBtnHeight);
    }];
    _help8010Btn.selected = YES;
    
    _help8000Btn = [KMRecordsButton buttonWithType:UIButtonTypeCustom];
    _help8000Btn.tag = 1;
    [_help8000Btn setTitle:@"KM - 8000" forState:UIControlStateNormal];
    [_help8000Btn setTitleColor:kGrayColor forState:UIControlStateNormal];
    [_help8000Btn setTitleColor:kMainColor forState:UIControlStateSelected];
    [_help8000Btn addTarget:self action:@selector(helpBtnDidClicked:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:_help8000Btn];
    [_help8000Btn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(_help8010Btn.mas_right);
        make.top.width.height.equalTo(_help8010Btn);
    }];
    
    _helpAppBtn = [KMRecordsButton buttonWithType:UIButtonTypeCustom];
    _helpAppBtn.tag = 2;
    [_helpAppBtn setTitle:@"APP" forState:UIControlStateNormal];
    [_helpAppBtn setTitleColor:kGrayColor forState:UIControlStateNormal];
    [_helpAppBtn setTitleColor:kMainColor forState:UIControlStateSelected];
    [_helpAppBtn addTarget:self action:@selector(helpBtnDidClicked:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:_helpAppBtn];
    [_helpAppBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(_help8000Btn.mas_right);
        make.top.width.height.equalTo(_help8010Btn);
    }];
}

- (void)helpBtnDidClicked:(UIButton *)sender {
    [self selectOnlyoneButtonWithIndex:sender.tag];
    switch (sender.tag) {
        case 0:         // KM8010
        {
            self.htmURL = kLoadStringWithKey(@"HTML_type_help_8010");
            NSURL * fileurl = [[NSBundle mainBundle] URLForResource:self.htmURL withExtension:nil];
            NSURLRequest *request = [[NSURLRequest alloc] initWithURL:fileurl];
            [self.webView loadRequest:request];
        } break;
        case 1:         // KM8000
        {
            self.htmURL = kLoadStringWithKey(@"HTML_type_help_8000");
            NSURL * fileurl = [[NSBundle mainBundle] URLForResource:self.htmURL withExtension:nil];
            NSURLRequest *request = [[NSURLRequest alloc] initWithURL:fileurl];
            [self.webView loadRequest:request];
        } break;
        case 2:         // APP
        {
            self.htmURL = kLoadStringWithKey(@"HTML_type_help_app");
            NSURL * fileurl = [[NSBundle mainBundle] URLForResource:self.htmURL withExtension:nil];
            NSURLRequest *request = [[NSURLRequest alloc] initWithURL:fileurl];
            [self.webView loadRequest:request];
        } break;
        default:
            break;
    }
}

- (void)selectOnlyoneButtonWithIndex:(NSInteger)index {
    switch (index) {
        case 0:
            self.help8010Btn.selected = YES;
            self.help8000Btn.selected = NO;
            self.helpAppBtn.selected = NO;
            break;
        case 1:
            self.help8000Btn.selected = YES;
            self.help8010Btn.selected = NO;
            self.helpAppBtn.selected = NO;
            break;
        case 2:
            self.helpAppBtn.selected = YES;
            self.help8010Btn.selected = NO;
            self.help8000Btn.selected = NO;
            break;
        default:
            break;
    }
}


@end
