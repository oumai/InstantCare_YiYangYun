//
//  KMRemindEditModel.m
//  InstantCare
//
//  Created by km on 16/6/16.
//  Copyright © 2016年 omg. All rights reserved.
//

#import "KMRemindEditModel.h"

@implementation KMRemindEditModel


// 遍历构造器
-(void)setValueWithModel:(KMRemindDetailModel *)model
{
    self.isValid = model.isvalid;
    self.attribute1 = model.attribute1;
    
    self.year = model.sYear;
    self.mon  = model.sMon;
    self.day = model.sDay;
    self.hour = model.sHour;
    self.min = model.sMin;
    
    self.t1Hex = model.t1Hex;
    self.t2Hex = model.t2Hex;
    self.t3Hex = model.t3Hex;
    self.t4Hex = model.t4Hex;
    self.t5Hex = model.t5Hex;
    self.t6Hex = model.t6Hex;
    self.t7Hex = model.t7Hex;
    if (self.attribute1.length == 0)
    {
        self.attribute1 = @"";
    }
}

@end
