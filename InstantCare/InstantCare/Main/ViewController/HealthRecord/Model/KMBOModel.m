//
//  KMBOModel.m
//  InstantCare
//
//  Created by 朱正晶 on 16/6/1.
//  Copyright © 2016年 omg. All rights reserved.
//

#import "KMBOModel.h"
#import "MJExtension.h"
@implementation KMBOModel

+ (void)load {
    [KMBOModel mj_setupObjectClassInArray:^NSDictionary *{
        return @{
                 @"list" : @"KMBODetailModel"
                 };
    }];
}

@end

@implementation KMBODetailModel

@end
