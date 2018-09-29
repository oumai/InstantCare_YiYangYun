//
//  KMEmgRecordsModel.m
//  InstantCare
//
//  Created by 朱正晶 on 16/5/20.
//  Copyright © 2016年 omg. All rights reserved.
//

#import "KMEmgRecordsModel.h"
#import "MJExtension.h"
@implementation KMEmgRecordsModel

+ (void)load {
    [KMEmgRecordsModel mj_setupObjectClassInArray:^NSDictionary *{
        return @{
                 @"list" : @"KMEmgRecordsDetailModel"
                 };
    }];
}

@end

@implementation KMEmgRecordsDetailModel

@end
