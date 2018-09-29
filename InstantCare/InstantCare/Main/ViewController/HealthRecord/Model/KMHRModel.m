//
//  KMHRModel.m
//  InstantCare
//
//  Created by 朱正晶 on 16/6/1.
//  Copyright © 2016年 omg. All rights reserved.
//

#import "KMHRModel.h"
#import "MJExtension.h"
@implementation KMHRModel

+ (void)load {
    [KMHRModel mj_setupObjectClassInArray:^NSDictionary *{
        return @{
                 @"list" : @"KMHRDetailModel"
                 };
    }];
}

@end

@implementation KMHRDetailModel

@end
