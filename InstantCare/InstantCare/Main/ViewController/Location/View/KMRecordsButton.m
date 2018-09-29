//
//  KMRecordsButton.m
//  InstantCare
//
//  Created by 朱正晶 on 16/5/19.
//  Copyright © 2016年 omg. All rights reserved.
//

#import "KMRecordsButton.h"

@interface KMRecordsButton()

@property (nonatomic, strong) UIView *bottomLine;

@end

@implementation KMRecordsButton

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        _bottomLine = [UIView new];
        _bottomLine.hidden = YES;
        _bottomLine.backgroundColor = kMainColor;
        [self addSubview:_bottomLine];
        [_bottomLine mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.right.bottom.equalTo(self);
            make.height.equalTo(@2);
        }];
        self.backgroundColor = [UIColor whiteColor];
    }
    
    return self;
}

- (void)setSelected:(BOOL)selected {
    [super setSelected:selected];
    
    _bottomLine.hidden = !selected;
}

@end
