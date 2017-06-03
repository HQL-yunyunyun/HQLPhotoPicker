//
//  HQLPhotoHelper.h
//  HQLPhotoPicker
//
//  Created by weplus on 2017/6/3.
//  Copyright © 2017年 weplus. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <Photos/Photos.h>

@interface HQLPhotoHelper : NSObject

/**
 获取视频的时长
 */
+ (NSString *)getNewTimeFromDurationSecond:(NSInteger)duration;

/**
 相册名称转换
 */
+ (NSString *)transFormPhotoTitle:(NSString *)englishName;

@end
