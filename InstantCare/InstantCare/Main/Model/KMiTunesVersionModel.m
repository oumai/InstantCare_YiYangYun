//
//  KMiTunesVersionModel.m
//  InstantCare
//
//  Created by 朱正晶 on 16/6/13.
//  Copyright © 2016年 omg. All rights reserved.
//

#import "KMiTunesVersionModel.h"
#import "MJExtension.h"
@implementation KMiTunesVersionModel

+ (void)load {
    [KMiTunesVersionModel mj_setupObjectClassInArray:^NSDictionary *{
        return @{
                 @"results" : @"KMiTunesVersionDetailModel"
                 };
    }];
}

@end

@implementation KMiTunesVersionDetailModel

@end
