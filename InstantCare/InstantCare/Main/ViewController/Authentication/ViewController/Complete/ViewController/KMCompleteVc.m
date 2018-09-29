//
//  KMCompleteVc.m
//  InstantCare
//
//  Created by KM on 2016/12/1.
//  Copyright © 2016年 omg. All rights reserved.
//

#import "KMCompleteVc.h"
#import "KMMainVC.h"
#import "UIBarButtonItem+Extension.h"

@interface KMCompleteVc ()
@property (weak, nonatomic) IBOutlet UIButton *completeBtn;
@property (weak, nonatomic) IBOutlet UIButton *btnLabel;
@property (weak, nonatomic) IBOutlet UILabel *msgLabel;

@end

@implementation KMCompleteVc

- (void)viewDidLoad {
    [super viewDidLoad];
    [self setupUI];
}

- (void)setupUI
{
    self.navigationItem.title = kLoadStringWithKey(@"real_name_authentication");
    //左边导航栏按钮 pop_icon_success
//    self.navigationItem.leftBarButtonItem = [UIBarButtonItem itemWithImage:@"return_normal" hightImage:@"return_sel" target:self action:@selector(leftBarButtonDidClickedAction:)];
    
    UIBarButtonItem *leftNegativeSpacer = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFixedSpace target:nil action:nil];
    [leftNegativeSpacer setWidth:-10];
    
    UIBarButtonItem *leftBarButtonItem = [UIBarButtonItem itemWithImage:@"return_normal" hightImage:@"return_sel" target:self action:@selector(leftBarButtonDidClickedAction:)];
    
    self.navigationItem.leftBarButtonItems = @[leftNegativeSpacer,leftBarButtonItem];
    
    self.completeBtn.layer.cornerRadius = 20;
    self.completeBtn.backgroundColor = RGB(81, 202, 108);
    [self.completeBtn setTitle:kLoadStringWithKey(@"Reg_VC_register_finish") forState:UIControlStateNormal];
    self.completeBtn.layer.masksToBounds = YES;
    
    [self.btnLabel setTitle:kLoadStringWithKey(@"SubmittedSuccessfully") forState:UIControlStateNormal];
    self.msgLabel.text = kLoadStringWithKey(@"msgLabel");
    
}

/**
 *   返回上一级界面
 */
-(void)leftBarButtonDidClickedAction:(UIButton *)sender
{
    [self.navigationController popViewControllerAnimated:YES];
}
- (IBAction)completeClick:(UIButton *)sender {
    
    for (UIViewController *vc in self.navigationController.viewControllers) {
        
        if ([vc isKindOfClass:[KMMainVC class]]) {
            
            [self.navigationController popToViewController:vc animated:YES];
            
        }
        
    }
}

@end
