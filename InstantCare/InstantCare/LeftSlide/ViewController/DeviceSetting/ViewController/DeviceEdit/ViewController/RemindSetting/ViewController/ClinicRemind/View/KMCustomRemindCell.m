
//
//  KMCustomRemindCell.m
//  InstantCare
//
//  Created by km on 16/6/22.
//  Copyright © 2016年 omg. All rights reserved.
//

#import "KMCustomRemindCell.h"

@implementation KMCustomRemindCell

-(instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self)
    {
        self.affir = [[UILabel alloc] init];
        [self.contentView addSubview:self.affir];
        self.affir.textAlignment = NSTextAlignmentLeft;
        self.affir.font = [UIFont systemFontOfSize:12];
        self.affir.textColor = kGrayContextColor;
    }
    return self;
}

-(void)layoutSubviews
{
    [super layoutSubviews];
    
   
    [self.affir mas_makeConstraints:^(MASConstraintMaker *make)
     {
         make.left.mas_equalTo(18);
         make.right.mas_equalTo(0);
         make.height.mas_equalTo(30);
         make.bottom.mas_equalTo(0);
    }];
    
}


@end
