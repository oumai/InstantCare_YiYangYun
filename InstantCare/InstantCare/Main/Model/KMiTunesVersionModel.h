//
//  KMiTunesVersionModel.h
//  InstantCare
//
//  Created by 朱正晶 on 16/6/13.
//  Copyright © 2016年 omg. All rights reserved.
//

#import <Foundation/Foundation.h>

/**
 *  iTunes上面最新的版本模型
 */
@interface KMiTunesVersionModel : NSObject

@property (nonatomic, assign) int resultCount;

@property (nonatomic, strong) NSArray *results;

@end


@interface KMiTunesVersionDetailModel : NSObject

@property (nonatomic, copy) NSString *screenshotUrls;

@property (nonatomic, copy) NSString *fileSizeBytes;
// 版本号
@property (nonatomic, copy) NSString *version;
/**
 *  升级地址，直接跳转过去
 */
@property (nonatomic, copy) NSString *trackViewUrl;

@property (nonatomic, copy) NSString *bundleId;

@property (nonatomic, copy) NSString *releaseDate;

@property (nonatomic, copy) NSString *minimumOsVersion;

@end


