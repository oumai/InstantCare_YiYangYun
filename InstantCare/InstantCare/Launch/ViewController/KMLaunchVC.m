//
//  KMLaunchVC.m
//  InstantCare
//
//  Created by km on 16/6/17.
//  Copyright © 2016年 omg. All rights reserved.
//

#import "KMLaunchVC.h"
#import "KMLoginVC.h"
#import "KMProtocolVC.h"
#import "KMMalaysiaLoginVC.h"


@interface KMLaunchVC ()

/** 滑动背景  */
@property(nonatomic,strong)UIScrollView * backGoundView;

/** 选择按钮  */
@property(nonatomic,strong)UIButton * cheakButton;

/** 协议按钮 */
@property (nonatomic, strong) UIButton *protocolBtn;



@end

@implementation KMLaunchVC


- (void)viewDidLoad
{
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor whiteColor];
    
    [self configView];
}


#pragma mark - 配置子视图
-(void)configView
{
    self.backGoundView = [[UIScrollView alloc] init];
    self.backGoundView.pagingEnabled = YES;
    self.backGoundView.bounces = NO;
    [self.view addSubview:self.backGoundView ];
    [self.backGoundView mas_makeConstraints:^(MASConstraintMaker *make)
    {
        make.edges.equalTo(self.view);
    }];
    self.backGoundView.contentSize = CGSizeMake(SCREEN_WIDTH*3,0);
    NSString * languageStatus = kLoadStringWithKey(@"Common_language_status");
    NSArray * imageName;
    if ([languageStatus isEqualToString:@"en"]){
        
        // 设置马来差异
        NSString * name;
        #ifdef kApplicationMLVersion
                name = @"引导页_en";
        #else
                name = @"引导页1_en";
        #endif
         imageName = @[name,@"引导页2_en",@"引导页3_en"];
    }else{
        // 设置马来差异
        NSString * name;
        #ifdef kApplicationMLVersion
                name = @"引导页";
        #else
                name = @"引导页1";
        #endif
        imageName = @[name,@"引导页2",@"引导页3"];
    }
    
    // 添加引导视图
    for (int i = 0; i < imageName.count; i++)
    {
        UIImageView *newImageView = [[UIImageView alloc] init];
        newImageView.image = [UIImage imageNamed:imageName[i]];
        newImageView.contentMode = UIViewContentModeScaleToFill;
        [self.backGoundView addSubview:newImageView];
        newImageView.frame = CGRectMake(SCREEN_WIDTH*i,0, SCREEN_WIDTH, SCREEN_HEIGHT);
        
        // 设置进入引导页
        if (i == 2)
        {
            newImageView.userInteractionEnabled = YES;
            self.cheakButton = [UIButton buttonWithType:UIButtonTypeCustom];
            self.cheakButton.layer.cornerRadius = 20;
            self.cheakButton.layer.masksToBounds = YES;
            [newImageView addSubview:self.cheakButton];
            self.cheakButton.backgroundColor = kMainColor;
            [self.cheakButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
            [self.cheakButton setTitle:kLoadStringWithKey(@"LaunchVC_button_title") forState:UIControlStateNormal];
            [self.cheakButton mas_makeConstraints:^(MASConstraintMaker *make) {
                make.width.equalTo(@220);
                make.height.equalTo(@40);
                make.centerX.equalTo(newImageView);
                make.bottom.equalTo(newImageView).offset(-50);
            }];
            [self.cheakButton addTarget:self action:@selector(checkButtonDidClickedAction:) forControlEvents:UIControlEventTouchDown];
            // 设置马来差异
            #ifdef kApplicationMLVersion
                        [self configProtocolViewWithSuperView:newImageView];
//                        self.cheakButton.backgroundColor = [UIColor grayColor];
            #else
                   [self configProtocolViewWithSuperView:newImageView];
            #endif
        }
    }
}

/**
 *   创建协议视图
 */
- (void)configProtocolViewWithSuperView:(UIImageView *)imageView
{
    WS(ws);
    //协议按钮；
    self.protocolBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    [imageView addSubview:self.protocolBtn];
    [self.protocolBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.width.equalTo(@300);
        make.height.equalTo(@40);
        make.centerX.equalTo(imageView);
        make.bottom.equalTo(imageView).offset(-100);
    }];
    self.protocolBtn.selected = YES;
    //设置背景图片
    [self.protocolBtn setImage:[UIImage imageNamed:@"register_unagree"] forState:UIControlStateNormal];
    [self.protocolBtn setImage:[UIImage imageNamed:@"register_agree"] forState:UIControlStateSelected];
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
    [self.protocolBtn setAttributedTitle:aAttributedString forState:UIControlStateNormal];
    self.protocolBtn.titleLabel.numberOfLines = 0;
    self.protocolBtn.titleLabel.font = [UIFont systemFontOfSize:15];
    
    // 添加点击事件
    [self.protocolBtn addTarget:self action:@selector(protocolButtonDidClickedAction:) forControlEvents:UIControlEventTouchDown];
    self.protocolBtn.titleLabel.font = [UIFont systemFontOfSize:13];
    self.protocolBtn.titleEdgeInsets = UIEdgeInsetsMake(0,15,0,0);
    // 协议视图
    UIView * protocolView = [[UIView alloc] init];
    [self.protocolBtn addSubview:protocolView];
    [protocolView mas_makeConstraints:^(MASConstraintMaker *make)
     {
         make.height.equalTo(ws.protocolBtn);
         make.width.mas_equalTo(130);
         make.top.mas_equalTo(0);
         make.left.equalTo(ws.protocolBtn.mas_centerX).offset(-5);
     }];
    protocolView.backgroundColor = [UIColor clearColor];
    UITapGestureRecognizer * tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(readProtocolMethod:)];
    [protocolView addGestureRecognizer:tap];
    self.cheakButton.enabled = self.protocolBtn.isSelected;
    self.cheakButton.backgroundColor = self.protocolBtn.isSelected ? kMainColor:[UIColor grayColor];
}

#pragma mark --- 协议按钮点击方法
-(void)protocolButtonDidClickedAction:(UIButton *)sender
{
    sender.selected = !sender.selected;
    self.cheakButton.enabled = sender.isSelected;
    self.cheakButton.backgroundColor = self.cheakButton.isEnabled ? kMainColor:[UIColor grayColor];
}

#pragma mark - 阅读协议方法
- (void)readProtocolMethod:(UITapGestureRecognizer *)tap
{
    KMProtocolVC * protocol = [[KMProtocolVC alloc] init];
    
    #ifdef kApplicationMLVersion
        protocol.htmURL = @"Malaysia.html";
    #else
        protocol.htmURL = kLoadStringWithKey(@"LaunchVC_policy");
    #endif
    
    UINavigationController * NC = [[UINavigationController alloc] initWithRootViewController:protocol];
    [self presentViewController:NC animated:YES completion:nil];
}

/**
 *   切换根视图
 */
- (void)checkButtonDidClickedAction:(UIButton *)sender
{
    
#ifdef kApplicationMLVersion
    
    KMMalaysiaLoginVC * mainVC = [[KMMalaysiaLoginVC alloc] init];
#else
    
    KMLoginVC *mainVC = [[KMLoginVC alloc] init];
#endif
    float currentVersion = [[NSBundle mainBundle].infoDictionary[@"CFBundleShortVersionString"] floatValue];
    [[NSUserDefaults standardUserDefaults] setFloat:currentVersion forKey:@"CFBundleShortVersionString"];
    [UIApplication sharedApplication].keyWindow.rootViewController = mainVC;
}

@end
