//
//  KMRemindModel.m
//  InstantCare
//
//  Created by bruce-zhu on 16/2/22.
//  Copyright © 2016年 omg. All rights reserved.
//

#import "KMRemindModel.h"
#import "MJExtension.h"
@implementation KMRemindModel

+ (void)load {
    [KMRemindModel mj_setupObjectClassInArray:^NSDictionary *{
        return @{
                 @"list" : @"KMRemindDetailModel"
                 };
    }];
}

@end

@implementation KMRemindDetailModel

@end
