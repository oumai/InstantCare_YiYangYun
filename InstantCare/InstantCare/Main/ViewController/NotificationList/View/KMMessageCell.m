//
//  KMMessageCell.m
//  InstantCare
//
//  Created by zxy on 2016/11/30.
//  Copyright © 2016年 omg. All rights reserved.
//

#import "KMMessageCell.h"
#import "KMPushContent.h"
#import "KMExtrasModel.h"
#import "KMAlter.h"

@interface KMMessageCell ()
@property (weak, nonatomic) IBOutlet UILabel *argsLabel;
@property (weak, nonatomic) IBOutlet UILabel *alertLable;
@property (weak, nonatomic) IBOutlet UILabel *timeLabel;
@property (weak, nonatomic) IBOutlet UILabel *nameLabel;

@property (strong, nonatomic) NSDateFormatter *formatter;
@property (weak, nonatomic) IBOutlet UIButton *selectBtn;


@end

@implementation KMMessageCell

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
}

+ (instancetype)cellWithTableView:(UITableView *)tableView
{
    static NSString *ID = @"MessageCell";
    KMMessageCell *cell = [tableView dequeueReusableCellWithIdentifier:ID];
    if (cell == nil) {
        cell = [[[NSBundle mainBundle] loadNibNamed:NSStringFromClass([KMMessageCell class]) owner:nil options:nil] lastObject];
        cell.formatter = [[NSDateFormatter alloc]init];
        
        //    [formatter setDateFormat:@"yyyy/MM/dd HH:mm:ss"];
        [cell.formatter setDateFormat:@"yyyy-MM-dd HH:mm"];
    }
    return cell;
}

- (void)setModel:(List *)model{
    _model = model;
    //时间
    self.timeLabel.text = [self getCreateTimeWithInter:model.p_create_time];
    //姓名
    if (model.p_alter.loc_args.count > 0) {
        self.nameLabel.text = model.p_alter.loc_args[0];
    }
    //imei
    self.argsLabel.text = model.p_extras.imei;
    //选中按钮
    self.selectBtn.selected = model.isSelected;
    //消息
    self.alertLable.text = kLoadStringWithKey(model.p_alter.loc_key);
}
//时间格式转换
- (NSString *)getCreateTimeWithInter:(NSUInteger)time{
    
    NSDate *d = [[NSDate alloc]initWithTimeIntervalSince1970:time/1000.0];

    NSString*timeString=[self.formatter stringFromDate:d];
    
    return timeString;
}
//代理
- (IBAction)didClickSelBtn:(UIButton *)sender {
    sender.selected = !sender.isSelected;
    if ([self.delegate respondsToSelector:@selector(selectCellWithIndex:andIs:)]) {
        [self.delegate selectCellWithIndex:self.index andIs:sender.isSelected];
    }
}

@end
