//
//  HQLPhotoHelper.h
//  HQLPhotoPicker
//
//  Created by weplus on 2017/6/3.
//  Copyright © 2017年 weplus. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <Photos/Photos.h>

typedef enum {
    HQLPhotoPickerTakePhotoTypeVideoAndPicture, // videoAndPicture
    HQlPhotoPickerTakePhotoTypeOnlyVideo, // video
    HQLPhotoPickerTakePhotoTypeOnlyPicture, // picture
} HQLPhotoPickerTakePhotoType;

@interface HQLPhotoHelper : NSObject

/**
 获取视频的时长
 */
+ (NSString *)getNewTimeFromDurationSecond:(NSInteger)duration;

/**
 相册名称转换
 */
+ (NSString *)transFormPhotoTitle:(NSString *)englishName;

/**
 获取数组里面图片的大小
 */
+ (NSString *)fetchPhotosBytes:(NSArray <NSData *>*)photos;

/**
 获取数组里面图片的大小
 */
+ (void)fetchPhotosBytes:(NSArray <UIImage *>*)photos resultHandler:(void(^)(NSString *bytes))resultHandler;

/**
 照相

 @param controller Controller
 @param delegate delegate
 @param type 模式
 */
+ (void)takePhotoWithController:(UIViewController *)controller delegate:(id <UIImagePickerControllerDelegate, UINavigationControllerDelegate>)delegate type:(HQLPhotoPickerTakePhotoType)type;

// 显示alert
+ (void)showAlertViewWithTitle:(NSString *)title message:(NSString *)message controller:(UIViewController *)controller;

// 获取错误信息
+ (NSString *)getErrorStringWithError:(NSError *)error;

@end
