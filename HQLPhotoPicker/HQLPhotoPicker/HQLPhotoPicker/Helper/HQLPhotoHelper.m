//
//  HQLPhotoHelper.m
//  HQLPhotoPicker
//
//  Created by weplus on 2017/6/3.
//  Copyright © 2017年 weplus. All rights reserved.
//

#import "HQLPhotoHelper.h"

@implementation HQLPhotoHelper

/**
 获取视频的时长
 */
+ (NSString *)getNewTimeFromDurationSecond:(NSInteger)duration {
    NSString *newTime;
    if (duration < 10) {
        newTime = [NSString stringWithFormat:@"00:0%zd",duration];
    } else if (duration < 60) {
        newTime = [NSString stringWithFormat:@"00:%zd",duration];
    } else {
        NSInteger min = duration / 60;
        NSInteger sec = duration - (min * 60);
        if (sec < 10) {
            newTime = [NSString stringWithFormat:@"%zd:0%zd",min,sec];
        } else {
            newTime = [NSString stringWithFormat:@"%zd:%zd",min,sec];
        }
    }
    return newTime;
}

/**
 相册名称转换
 */
+ (NSString *)transFormPhotoTitle:(NSString *)englishName {
    NSString *photoName;
    if ([englishName isEqualToString:@"Bursts"]) {
        photoName = @"连拍快照";
    }else if([englishName isEqualToString:@"Recently Added"]){
        photoName = @"最近添加";
    }else if([englishName isEqualToString:@"Screenshots"]){
        photoName = @"屏幕快照";
    }else if([englishName isEqualToString:@"Camera Roll"]){
        photoName = @"相机胶卷";
    }else if([englishName isEqualToString:@"Selfies"]){
        photoName = @"自拍";
    }else if([englishName isEqualToString:@"My Photo Stream"]){
        photoName = @"我的照片流";
    }else if([englishName isEqualToString:@"Videos"]){
        photoName = @"视频";
    }else if([englishName isEqualToString:@"All Photos"]){
        photoName = @"所有照片";
    }else if([englishName isEqualToString:@"Slo-mo"]){
        photoName = @"慢动作";
    }else if([englishName isEqualToString:@"Recently Deleted"]){
        photoName = @"最近删除";
    }else if([englishName isEqualToString:@"Favorites"]){
        photoName = @"个人收藏";
    }else if([englishName isEqualToString:@"Panoramas"]){
        photoName = @"全景照片";
    }else {
        photoName = englishName;
    }
    return photoName;
}

@end
