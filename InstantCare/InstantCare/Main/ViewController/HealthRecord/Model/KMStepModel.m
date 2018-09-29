//
//  KMStepModel.m
//  InstantCare
//
//  Created by 朱正晶 on 16/6/1.
//  Copyright © 2016年 omg. All rights reserved.
//

#import "KMStepModel.h"
#import "MJExtension.h"
@implementation KMStepModel

+ (void)load {
    [KMStepModel mj_setupObjectClassInArray:^NSDictionary *{
        return @{
                 @"list" : @"KMStepDetailModel"
                 };
    }];
}

@end

@implementation KMStepDetailModel

@end

