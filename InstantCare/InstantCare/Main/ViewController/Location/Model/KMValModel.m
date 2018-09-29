//
//  KMValModel.m
//  InstantCare
//
//  Created by 朱正晶 on 16/5/20.
//  Copyright © 2016年 omg. All rights reserved.
//

#import "KMValModel.h"
#import "MJExtension.h"
@implementation KMValModel

+ (void)load {
    [KMValModel mj_setupObjectClassInArray:^NSDictionary *{
        return @{
                 @"list" : @"KMValDetailModel"
                 };
    }];
}

@end

@implementation KMValDetailModel

@end

