//
//  KMFallModel.m
//  InstantCare
//
//  Created by 朱正晶 on 16/5/21.
//  Copyright © 2016年 omg. All rights reserved.
//

#import "KMFallModel.h"
#import "MJExtension.h"

@implementation KMFallModel

+ (void)load {
    [KMFallModel mj_setupObjectClassInArray:^NSDictionary *{
        return @{
                 @"list" : @"KMFallDetailModel"
                 };
    }];
}

@end

@implementation KMFallDetailModel

@end
