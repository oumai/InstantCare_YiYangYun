//
//  KMHeaderView.m
//  InstantCare
//
//  Created by mac on 2016/11/26.
//  Copyright © 2016年 omg. All rights reserved.
//

#import "KMHeaderView.h"
@interface KMHeaderView()
- (IBAction)btnColick:(UIButton *)sender;
@property (weak, nonatomic) IBOutlet UILabel *promptLabel;
@property (weak, nonatomic) IBOutlet UIButton *Open;

@end

@implementation KMHeaderView

- (void)awakeFromNib
{
    [super awakeFromNib];
    self.backgroundColor = RGB(240, 240, 229);
    self.autoresizingMask = UIViewAutoresizingNone;
    self.userInteractionEnabled = YES;
    self.promptLabel.textColor = RGB(208, 165, 117);
    [self.Open setTitle:kLoadStringWithKey(@"message_notification_open") forState:UIControlStateNormal];
}

+ (instancetype)viewFromXib{

    return [[[NSBundle mainBundle] loadNibNamed:NSStringFromClass([KMHeaderView class]) owner:nil options:nil] lastObject];
}

- (IBAction)btnColick:(UIButton *)sender {
    
    if ([self.delegate respondsToSelector:@selector(headerViewButtonClick)]) {
        [self.delegate headerViewButtonClick];
    }
}
@end
