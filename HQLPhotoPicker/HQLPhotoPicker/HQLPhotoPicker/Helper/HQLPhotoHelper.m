//
//  HQLPhotoHelper.m
//  HQLPhotoPicker
//
//  Created by weplus on 2017/6/3.
//  Copyright © 2017年 weplus. All rights reserved.
//

#import "HQLPhotoHelper.h"
#import <MobileCoreServices/MobileCoreServices.h>

#define kVideoMaxDuration 9.0f

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

// 获取图片大小
+ (NSString *)fetchPhotosBytes:(NSArray<NSData *> *)photos {
    NSInteger length = 0;
    for (NSData *data in photos) {
        length += data.length;
    }
    return [self getBytesFromDataLength:length];
}

// 获取图片大小
+ (void)fetchPhotosBytes:(NSArray<UIImage *> *)photos resultHandler:(void (^)(NSString *))resultHandler {
    __block NSInteger dataLength = 0;
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        for (UIImage *image in photos) {
            NSData *imageData = UIImagePNGRepresentation(image); // png
            if (!imageData) {
                //返回为JPEG图像。
                imageData = UIImageJPEGRepresentation(image, 1.0);
            }
            dataLength += imageData.length;
        }
        dispatch_async(dispatch_get_main_queue(), ^{
            resultHandler ? resultHandler([self getBytesFromDataLength:dataLength]) : nil;
        });
    });
}

// 获取NSData大小
+ (NSString *)getBytesFromDataLength:(NSInteger)dataLength {
    NSString *bytes;
    if (dataLength >= 0.1 * (1024 * 1024)) {
        bytes = [NSString stringWithFormat:@"%0.1fM",dataLength/1024/1024.0];
    } else if (dataLength >= 1024) {
        bytes = [NSString stringWithFormat:@"%0.0fK",dataLength/1024.0];
    } else {
        bytes = [NSString stringWithFormat:@"%zdB",dataLength];
    }
    return bytes;
}

// 照相
+ (void)takePhotoWithController:(UIViewController *)controller delegate:(id<UIImagePickerControllerDelegate, UINavigationControllerDelegate>)delegate type:(HQLPhotoPickerTakePhotoType)type {
    if (![UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera]) {
        [self showAlertViewWithTitle:@"温馨提示" message:@"当前设备不支持拍照" controller:controller];
        return;
    }
    
    UIImagePickerController *pickerController = [[UIImagePickerController alloc] init];
    pickerController.allowsEditing = NO;
    pickerController.sourceType = UIImagePickerControllerSourceTypeCamera;
    pickerController.delegate = delegate;
    
    switch (type) {
        case HQlPhotoPickerTakePhotoTypeOnlyVideo: {
            pickerController.mediaTypes = @[(NSString *)kUTTypeMovie];
            pickerController.cameraCaptureMode = UIImagePickerControllerCameraCaptureModeVideo;
            pickerController.videoMaximumDuration = kVideoMaxDuration;
            [controller presentViewController:pickerController animated:YES completion:nil];
            break;
        }
        case HQLPhotoPickerTakePhotoTypeOnlyPicture: {
            pickerController.cameraCaptureMode = UIImagePickerControllerCameraCaptureModePhoto;
            pickerController.mediaTypes = @[(NSString *)kUTTypeImage];
            [controller presentViewController:pickerController animated:YES completion:nil];
            break;
        }
        case HQLPhotoPickerTakePhotoTypeVideoAndPicture: {
            UIAlertController *alertController = [UIAlertController alertControllerWithTitle:@"拍照" message:@"选择拍照方式" preferredStyle:UIAlertControllerStyleActionSheet];
            UIAlertAction *picture = [UIAlertAction actionWithTitle:@"拍照" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
                pickerController.cameraCaptureMode = UIImagePickerControllerCameraCaptureModePhoto;
                pickerController.mediaTypes = @[(NSString *)kUTTypeImage];
                [controller presentViewController:pickerController animated:YES completion:nil];
            }];
            UIAlertAction *video = [UIAlertAction actionWithTitle:@"拍摄" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
                pickerController.mediaTypes = @[(NSString *)kUTTypeMovie];
                pickerController.cameraCaptureMode = UIImagePickerControllerCameraCaptureModeVideo;
                pickerController.videoMaximumDuration = kVideoMaxDuration;
                
                [controller presentViewController:pickerController animated:YES completion:nil];
            }];
            UIAlertAction *cancel = [UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {
                
            }];
            
            [alertController addAction:picture];
            [alertController addAction:video];
            [alertController addAction:cancel];
            [controller presentViewController:alertController animated:YES completion:nil];
            break;
        }
    }
}

// 显示alert
+ (void)showAlertViewWithTitle:(NSString *)title message:(NSString *)message controller:(UIViewController *)controller {
    static BOOL isShowAlertView = NO;
    
    if (isShowAlertView) {
        return;
    }
    isShowAlertView = YES;
    UIAlertAction *cancel = [UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {
        isShowAlertView = NO;
    }];
    UIAlertAction *confirm = [UIAlertAction actionWithTitle:@"确定" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        isShowAlertView = NO;
    }];
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:title message:message preferredStyle:UIAlertControllerStyleAlert];
    [alert addAction:cancel];
    [alert addAction:confirm];
    
    [controller presentViewController:alert animated:YES completion:nil];
}

// 获取错误信息
+ (NSString *)getErrorStringWithError:(NSError *)error {
    
    NSString *errorString = @"";
    
    if (error) {
        errorString = error.domain;
        if ([errorString containsString:@"cloud"]) { // iCloud 的问题
            errorString = @"iCloud 同步出错";
        }
        
        NSError *underLyingError = error.userInfo[NSUnderlyingErrorKey];
        if (underLyingError) {
            errorString = [errorString stringByAppendingString:underLyingError.localizedDescription];
        }
    }
    
    return errorString;
}

@end
