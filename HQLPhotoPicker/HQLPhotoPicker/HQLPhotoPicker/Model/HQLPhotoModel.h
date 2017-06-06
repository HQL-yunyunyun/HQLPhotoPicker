//
//  HQLPhotoModel.h
//  HQLPhotoPicker
//
//  Created by weplus on 2017/6/3.
//  Copyright © 2017年 weplus. All rights reserved.
//

#import <UIKit/UIKit.h>

@class PHAsset, AVAsset, PHLivePhoto;

typedef enum : NSUInteger {
    HQLPhotoModelMediaTypePhoto = 0, // 照片
    HQLPhotoModelMediaTypeLivePhoto, // LivePhoto
    HQLPhotoModelMediaTypePhotoGif,  // gif图
//    HQLPhotoModelMediaTypePhotoiCloud, // 在iCloud上的照片
    HQLPhotoModelMediaTypeVideo,     // 视频
    HQLPhotoModelMediaTypeAudio,     // 音频
    HQLPhotoModelMediaTypeCameraPhoto,   // 通过相机拍的照片
    HQLPhotoModelMediaTypeCameraVideo,   // 通过相机录制的视频
    HQLPhotoModelMediaTypeUnKnow , // 未知类型
} HQLPhotoModelMediaType;

@interface HQLPhotoModel : NSObject

@property (strong, nonatomic) PHAsset *asset; // 资源
@property (assign, nonatomic) HQLPhotoModelMediaType mediaType; // 类型
@property (copy, nonatomic) NSString *assetLocalizationIdentifer; // 资源的唯一标识

@property (strong, nonatomic) UIImage *thumbnailImage; // 缩略图

/* 这是自己拍时的资源 */
@property (strong, nonatomic) AVAsset *videoAsset; // 拍摄的视频 资源
//@property (strong, nonatomic) AVPlayerItem *playerItem;
@property (assign, nonatomic) NSString *durationTime;
@property (strong, nonatomic) UIImage *cameraPhoto; // 拍照 的照片

@property (assign, nonatomic) BOOL isSelected; // 是否选中

- (void)requestThumbnailImage:(void(^)(UIImage *thumbnail))completeBlock; // 缩略图
- (void)requestHighDefinitionImage:(void(^)(UIImage *highDefinitionImage))completeBlock; // 高清图片
- (void)requestOriginalImage:(void(^)(UIImage *originalImage))completeBlock; // 原图
- (void)requestOriginalImageData:(void(^)(NSData *imageData, NSString *byteString))completeBlock; // 图片的NSData
- (void)requestGifImageData:(void(^)(NSData *gifImageData))completeBlock; // 获取gifData
- (void)requestLivePhoto:(void(^)(PHLivePhoto *livePhoto))completeBlock; // 获取livePhoto

@end
