//
//  HQLPhotoManager.h
//  HQLPhotoPicker
//
//  Created by weplus on 2017/6/2.
//  Copyright © 2017年 weplus. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <Photos/Photos.h>

@class HQLPhotoModel, HQLPhotoAlbumModel;

#define HQLWeakSelf __weak typeof(self) weakSelf = self
#define iOS9Later ([UIDevice currentDevice].systemVersion.floatValue >= 9.0f)

typedef enum : NSUInteger {
    HQLPhotoManagerSelectedTypePhoto = 0, // 只选择图片
    HQLPhotoManagerSelectedTypeVideo, // 只选择视频
    HQLPhotoManagerSelectedTypePhotoAndVideo // 图片和视频一起
} HQLPhotoManagerSelectedType;

typedef enum {
    HQLPhotoQualityLarger , // 原图
    HQLPhotoQualityMedium , // 中等
    HQLPhotoQualityThumbnails , // 缩略图
} HQLPhotoQuality;

@interface HQLPhotoManager : NSObject

@property (strong, nonatomic) NSMutableArray <HQLPhotoAlbumModel *>*albumArray; // 保存相册 --- 第一个相册是所有图片
@property (strong, nonatomic) NSMutableArray <NSString *>*selectedAssetIdentifierArray; // 选中的资源的标识符
@property (assign, nonatomic) HQLPhotoManagerSelectedType selectedType; // 选择的样式
@property (strong, nonatomic) PHCachingImageManager *imageManager;

+ (instancetype)shareManager;

- (void)requestPhotoAuthorizationWithCompleteHandler:(void(^)(PHAuthorizationStatus status))completeHandler;
- (PHAuthorizationStatus)currentPhotoAuthorizationStatus;

/* fetch method */

/**
 获取所有相册

 @param completeBlock 获取完毕时的回调，参数与photoManager.albumArray 是一样的
 */
- (void)fetchAllAlbumWithCompleteBlock:(void(^)(NSMutableArray <HQLPhotoAlbumModel *>*albumArray))completeBlock;

/**
 获取相册里的资源(照片 - 视频 - livePhoto 等)

 @param photoResult 相册资源
 @param completeBlock 获取完毕时的回调
 */
- (void)fetchPhotoForAlbumWithResult:(PHFetchResult *)photoResult completeBlock:(void(^)(NSMutableArray <HQLPhotoModel *>*photoArray))completeBlock;

/**
 获取图片

 @param asset 资源
 @param photoQuality 图片质量
 @param photoSize 图片大小
 @param isCaching 是否缓存
 @param progressHandler 过程的回调
 @param resultHandler 完成的回调
 @return 对应的id
 */
- (PHImageRequestID)fetchImageWithPHAsset:(PHAsset *)asset photoQuality:(HQLPhotoQuality)photoQuality photoSize:(CGSize)photoSize isCaching:(BOOL)isCaching progressHandler:(PHAssetImageProgressHandler)progressHandler resultHandler:(void(^)(UIImage *image, NSDictionary *info))resultHandler;

/**
 获取图片的NSData

 @param asset 资源
 @param progressHandler 过程的回调
 @param resultHandler 完成的回调
 @return 对应的id
 */
- (PHImageRequestID)fetchimageDataWithPHAsset:(PHAsset *)asset progressHandler:(PHAssetImageProgressHandler)progressHandler resultHandler:(void(^)(NSData *imageData, NSString *dataUTI, UIImageOrientation orientation, NSDictionary *info))resultHandler;


/**
 获取livePhoto

 @param asset 资源
 @param photoQuality 图片质量
 @param photoSize 图片大小
 @param progressHandler 过程的回调
 @param resultHandler 完成的回调
 @return 对应的id
 */
- (PHImageRequestID)fetchLivePhotoWithPHAsset:(PHAsset *)asset photoQuality:(HQLPhotoQuality)photoQuality photoSize:(CGSize)photoSize progressHandler:(PHAssetImageProgressHandler)progressHandler resultHandler:(void(^)(PHLivePhoto *livePhoto, NSDictionary *info))resultHandler;

/**
 获取playeritem

 @param asset 资源
 @param progressHandler 过程的回调
 @param resultHandler 完成的回到
 @return 对应的id
 */
- (PHImageRequestID)fetchPlayerItemForVideo:(PHAsset *)asset progressHandler:(PHAssetVideoProgressHandler)progressHandler resultHandler:(void (^)(AVPlayerItem *playerItem, NSDictionary *info))resultHandler;

/**
 获取exportSession

 @param asset 资源
 @param exportPreset preset
 @param progressHandler 过程的回调
 @param resultHandler 完成的回调
 @return 对应的id
 */
- (PHImageRequestID)fetchExportSessionForVideo:(PHAsset *)asset exportPreset:(NSString *)exportPreset progressHandler:(PHAssetVideoProgressHandler)progressHandler resultHandler:(void (^)(AVAssetExportSession *exportSession, NSDictionary *info))resultHandler;

/**
 获取AVAsset

 @param asset 资源
 @param progressHandler 过程的回调
 @param resultHandler 完成的回调
 @return 对应的id
 */
- (PHImageRequestID)fetchAVAssetForVideo:(PHAsset *)asset progressHandler:(PHAssetVideoProgressHandler)progressHandler resultHandler:(void (^)(AVAsset *asset, AVAudioMix *audioMix, NSDictionary *info))resultHandler;

@end
