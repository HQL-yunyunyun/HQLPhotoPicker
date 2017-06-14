//
//  HQLPhotoModel.h
//  HQLPhotoPicker
//
//  Created by weplus on 2017/6/3.
//  Copyright © 2017年 weplus. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <Photos/Photos.h>

typedef enum : NSUInteger {
    HQLPhotoModelMediaTypePhoto = 0, // 照片
    HQLPhotoModelMediaTypeLivePhoto, // LivePhoto
    HQLPhotoModelMediaTypePhotoGif,  // gif图
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
@property (assign, nonatomic) NSString *durationTime;
@property (strong, nonatomic) UIImage *cameraPhoto; // 拍照 的照片

@property (assign, nonatomic) BOOL isSelected; // 是否选中
@property (assign, nonatomic) PHImageRequestID requestID; //选择图片时的requestID

/* fetch method  */
- (void)requestThumbnailImage:(void(^)(UIImage *thumbnail, NSString *error))resultHandler; // 缩略图
- (void)requestHighDefinitionImageWithProgressHandler:(PHAssetImageProgressHandler)progressHandler resultHandler:(void(^)(UIImage *highDefinitionImage, NSString *error))resultHandler; // 高清图片
- (void)requestOriginalImageWithProgressHandler:(PHAssetImageProgressHandler)progressHandler resultHandler:(void(^)(UIImage *originalImage, NSString *error))resultHandler; // 原图
- (void)requestOriginalImageDataWithProgressHandler:(PHAssetImageProgressHandler)progressHandler resultHandler:(void(^)(NSData *imageData, NSString *byteString, NSString *error))resultHandler; // 图片的NSData
//- (void)requestGifImageDataWithProgressHandler:(PHAssetImageProgressHandler)progressHandler resultHandler:(void(^)(NSData *gifImageData, NSString *byteString))resultHandler; // 获取gifData
- (void)requestLivePhotoWithProgressHandler:(PHAssetImageProgressHandler)progressHandler resultHandler:(void(^)(PHLivePhoto *livePhoto, NSString *error))resultHandler; // 获取livePhoto
- (void)requestPlayerItemWithProgressHandler:(PHAssetVideoProgressHandler)progressHandler resultHandler:(void(^)(AVPlayerItem *playerItem, NSString *error))resultHandler;

- (void)cancelRequest; // 取消选择

@end
