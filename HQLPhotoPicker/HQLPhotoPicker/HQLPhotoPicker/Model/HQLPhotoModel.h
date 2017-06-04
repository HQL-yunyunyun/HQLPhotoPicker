//
//  HQLPhotoModel.h
//  HQLPhotoPicker
//
//  Created by weplus on 2017/6/3.
//  Copyright © 2017年 weplus. All rights reserved.
//

#import <Foundation/Foundation.h>

@class PHAsset, AVAsset;

typedef enum : NSUInteger {
    HQLPhotoModelMediaTypePhoto = 0, // 照片
    HQLPhotoModelMediaTypeLivePhoto, // LivePhoto
    HQLPhotoModelMediaTypePhotoGif,  // gif图
//    HQLPhotoModelMediaTypePhotoiCloud, // 在iCloud上的照片
    HQLPhotoModelMediaTypeVideo,     // 视频
    HQLPhotoModelMediaTypeAudio,     // 音频
    HQLPhotoModelMediaTypeCameraPhoto,   // 通过相机拍的照片
    HQLPhotoModelMediaTypeCameraVideo,   // 通过相机录制的视频
    HQLPhotoModelMediaTypeUnKnow , // 位置类型
} HQLPhotoModelMediaType;

@interface HQLPhotoModel : NSObject

@property (strong, nonatomic) PHAsset *asset; // 资源
@property (assign, nonatomic) HQLPhotoModelMediaType mediaType; // 类型
@property (copy, nonatomic) NSString *assetLocalizationIdentifer; // 资源的唯一标识

@property (assign, nonatomic) BOOL isSelected; // 是否选中

/* 这是自己拍时的资源 */
@property (strong, nonatomic) AVAsset *videoAsset; // 拍摄的视频 资源
//@property (strong, nonatomic) AVPlayerItem *playerItem;
@property (assign, nonatomic) NSString *videoTime;
@property (strong, nonatomic) NSData *imageData; // 拍照 的照片data

@end
