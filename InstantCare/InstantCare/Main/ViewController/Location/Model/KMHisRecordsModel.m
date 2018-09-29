//
//  KMHisRecordsModel.m
//  InstantCare
//
//  Created by 朱正晶 on 16/5/20.
//  Copyright © 2016年 omg. All rights reserved.
//

#import "KMHisRecordsModel.h"
#import "MJExtension.h"
@implementation KMHisRecordsModel

+ (void)load {
    [KMHisRecordsModel mj_setupObjectClassInArray:^NSDictionary *{
        return @{
                 @"list" : @"KMHisRecordsDetailModel"
                 };
    }];
}

@end

@implementation KMHisRecordsDetailModel

@end
