
//
//  KMProtocolVC.m
//  InstantCare
//
//  Created by km on 16/6/20.
//  Copyright © 2016年 omg. All rights reserved.
//

#import "KMProtocolVC.h"

@interface KMProtocolVC ()

@property(nonatomic,strong)UIWebView * webView;

@end

@implementation KMProtocolVC

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor greenColor];
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
    [leftButton addTarget:self action:@selector(backToLoginView) forControlEvents:UIControlEventTouchDown];
    self.title = kLoadStringWithKey(@"Reg_VC_register_protocol_title");
}

/**
 *  返回方法
 *
 */
-(void)backToLoginView
{
    [self dismissViewControllerAnimated:YES completion:nil];
}


#pragma mark - 配置视图
-(void)configWebView
{
    self.webView = [[UIWebView alloc] init];
    [self.view addSubview:self.webView];
    [self.webView mas_makeConstraints:^(MASConstraintMaker *make)
    {
        make.edges.equalTo(self.view).insets(UIEdgeInsetsMake(0, 0, 0, 0));
    }];
    
    NSURL * fileurl = [[NSBundle mainBundle] URLForResource:self.htmURL withExtension:nil];
    NSURLRequest * request = [[NSURLRequest alloc] initWithURL:fileurl];
    [self.webView loadRequest:request];
}



@end
