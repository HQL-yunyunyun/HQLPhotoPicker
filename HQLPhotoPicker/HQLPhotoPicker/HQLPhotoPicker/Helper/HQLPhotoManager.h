//
//  HQLPhotoManager.h
//  HQLPhotoPicker
//
//  Created by weplus on 2017/6/2.
//  Copyright © 2017年 weplus. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <Photos/Photos.h>

#import "HQLPhotoModel.h"
#import "HQLPhotoAlbumModel.h"

#define HQLWeakSelf __weak typeof(self) weakSelf = self
#define iOS9Later ([UIDevice currentDevice].systemVersion.floatValue >= 9.0f)

typedef enum {
    HQLPhotoLibraryDidInsert , // 插入操作
    HQLPhotoLibraryDidRemove , // 移除
    HQLPhotoLibraryDidChange , // 改变
    HQLPhotoLibraryDidMove , // 移动
    HQLPhotoLibraryDidNotChange , // 未知状态
} HQLPhotoLibraryDidChangeType;

@protocol HQLPhotoManagerDelegate <NSObject>

@optional
- (void)photoLibraryDidChange:(PHChange *)changeInstance changedAlbum:(HQLPhotoAlbumModel *)album changeResult:(PHFetchResultChangeDetails *)changeResult changeIndex:(NSArray <NSNumber *>*)changeIndex changeType:(HQLPhotoLibraryDidChangeType)changeType;

@end

@interface HQLPhotoManager : NSObject

@property (strong, nonatomic) NSMutableArray <HQLPhotoAlbumModel *>*albumArray; // 保存相册 --- 第一个相册是所有图片
@property (strong, nonatomic) NSMutableArray <NSString *>*selectedAssetIdentifierArray; // 选中的资源的标识符
@property (assign, nonatomic) HQLPhotoSelectedType selectedType; // 选择的样式
@property (assign, nonatomic) BOOL ascendingByCreationDate; // 是否按照日期排序
@property (assign, nonatomic) BOOL isLivePhotoOpen; // 是否开启livePhoto
@property (assign, nonatomic) BOOL isGifOpen; // 是否开启gif
@property (strong, nonatomic) PHCachingImageManager *imageManager;

@property (assign, nonatomic) id <HQLPhotoManagerDelegate>delegate;

+ (instancetype)shareManager;

// 获取权限
- (void)requestPhotoAuthorizationWithCompleteHandler:(void(^)(PHAuthorizationStatus status))completeHandler;
// 当前权限
- (PHAuthorizationStatus)currentPhotoAuthorizationStatus;

/* selected method */

/* 跟选择图片的一些操作(因为照片会重复(每一个相册都有可能存在一样的照片),所以就需要保存一个全局的已选择照片的数组) */
- (void)addSelectedAssetWithIdentifier:(NSString *)identifier complete:(void(^)(BOOL isSuccess, NSString *message))complete;
// 移除某个identifier对应的资源
- (void)removeSelectedAssetWithIdentifier:(NSString *)identifier complete:(void(^)(BOOL isSuccess, NSString *message))complete;
// identifier 对应的资源是否被选择
- (BOOL)getAssetIsSelectedWithIdentifier:(NSString *)identifier;
// 移除已选择资源
- (void)removeAllSelectedAsset;
// 获取某个相册中已选择的资源index
- (NSMutableArray <NSNumber *>*)getSelectedAssetIndexWithAlbum:(HQLPhotoAlbumModel *)albumModel;
// 获取identifier对应的资源（identifier是唯一但资源不是 --- 不同的相册会identifier相同的资源）
- (NSMutableArray <HQLPhotoModel *>*)getAssetWithIdentifier:(NSString *)identifier;
// 获取某个相册中identifier对应的资源（在相册中 identifier 对应的资源那是唯一的）
- (HQLPhotoModel *)getAssetWithIdentifier:(NSString *)identifier inAlbum:(HQLPhotoAlbumModel *)album;
// 获取被选中的资源
- (NSMutableArray <HQLPhotoModel *>*)getSelectedAsset;

/* save method */

// 保存Image到相册中 --- 只能指定用户的相册 系统生成的相册不能指定
- (void)saveImage:(UIImage *)image toAlbum:(HQLPhotoAlbumModel *)album complete:(void(^)(BOOL isSuccess, NSString *error, NSString *identifier))complete;

- (void)saveImageWithImageUrl:(NSURL *)imageUrl toAlbum:(HQLPhotoAlbumModel *)album complete:(void(^)(BOOL isSuccess, NSString *error, NSString *identifier))complete;

- (void)saveVideoWithVideoUrl:(NSURL *)videoUrl toAlbum:(HQLPhotoAlbumModel *)album complete:(void(^)(BOOL isSuccess, NSString *error, NSString *identifier))complete;

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
