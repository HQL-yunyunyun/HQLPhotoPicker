//
//  HQLPhotoManager.m
//  HQLPhotoPicker
//
//  Created by weplus on 2017/6/2.
//  Copyright © 2017年 weplus. All rights reserved.
//

#import "HQLPhotoManager.h"
#import "HQLPhotoHelper.h"
#import "HQLPhotoAlbumModel.h"
#import "HQLPhotoModel.h"

#import <Photos/Photos.h>

#define HQLScreenScale [UIScreen mainScreen].scale

@interface HQLPhotoManager () <PHPhotoLibraryChangeObserver>

@property (strong, nonatomic) PHPhotoLibrary *photoLibrary;
//@property (strong, nonatomic) PHImageManager *imageManager;

@end

@implementation HQLPhotoManager

#pragma mark - initialize method 

+ (instancetype)shareManager {
    static HQLPhotoManager *manager;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        manager = [[HQLPhotoManager alloc] init];
        [manager requestPhotoAuthorizationWithCompleteHandler:^(PHAuthorizationStatus status) {
            NSLog(@"%ld", (long)status);
        }];
    });
    return manager;
}

- (void)dealloc {
    [self.photoLibrary unregisterChangeObserver:self];
    NSLog(@"dealloc ---> %@", NSStringFromClass([self class]));
}

#pragma mark - event

- (void)requestPhotoAuthorizationWithCompleteHandler:(void (^)(PHAuthorizationStatus))completeHandler {
    [PHPhotoLibrary requestAuthorization:^(PHAuthorizationStatus status) {
        completeHandler ? completeHandler(status) : nil;
    }];
}

- (PHAuthorizationStatus)currentPhotoAuthorizationStatus {
    return [PHPhotoLibrary authorizationStatus];
}

#pragma mark - fetch method

- (void)fetchAllAlbumWithCompleteBlock:(void(^)(NSMutableArray <HQLPhotoAlbumModel *>*albumArray))completeBlock {
    [self.albumArray removeAllObjects];
    // 获取 系统相册 (包括所有图片) --- 不用按照时间排序
    [self fetchAlbumWithResult:[PHAssetCollection fetchAssetCollectionsWithType:PHAssetCollectionTypeSmartAlbum subtype:PHAssetCollectionSubtypeAlbumRegular options:nil]];
    // 用户相册
    [self fetchAlbumWithResult:[PHAssetCollection fetchAssetCollectionsWithType:PHAssetCollectionTypeAlbum subtype:PHAssetCollectionSubtypeSmartAlbumUserLibrary options:nil]];
    
    completeBlock ? completeBlock(self.albumArray) : nil;
}

#pragma mark - tool method

// 相册
- (void)fetchAlbumWithResult:(PHFetchResult *)albumResult {
    HQLWeakSelf;
    [albumResult enumerateObjectsUsingBlock:^(PHAssetCollection *collection, NSUInteger idx, BOOL * _Nonnull stop) {
        PHFetchOptions *option = [[PHFetchOptions alloc] init];
        option.sortDescriptors = @[[NSSortDescriptor sortDescriptorWithKey:@"creationDate" ascending:YES]];
        if (self.selectedType == HQLPhotoManagerSelectedTypePhoto) { // 只选择图片
            option.predicate = [NSPredicate predicateWithFormat:@"mediaType == %ld", PHAssetMediaTypeImage];
        } else if (self.selectedType == HQLPhotoManagerSelectedTypeVideo) { // 只选择视频
            option.predicate = [NSPredicate predicateWithFormat:@"mediaType == %ld", PHAssetMediaTypeVideo];
        }
        
        // 照片合集
        PHFetchResult *result = [PHAsset fetchAssetsInAssetCollection:collection options:option];
        NSString *albumName = [HQLPhotoHelper transFormPhotoTitle:collection.localizedTitle];
        // 将 最近删除 过滤
        if (![albumName isEqualToString:@"最近删除"] && result.count > 0) {
            HQLPhotoAlbumModel *model = [[HQLPhotoAlbumModel alloc] init];
            model.albumName = albumName;
            model.albumResult = result;
            
            [weakSelf.albumArray addObject:model];
        }
    }];
}

- (void)fetchPhotoForAlbumWithResult:(PHFetchResult *)photoResult completeBlock:(void(^)(NSMutableArray <HQLPhotoModel *>*photoArray))completeBlock {
    NSMutableArray *array = [NSMutableArray array];
    for (NSInteger i = photoResult.count - 1; i >= 0; i--) {
        HQLPhotoModel *model = [[HQLPhotoModel alloc] init];
        [array addObject:model];
        
        PHAsset *asset = photoResult[i];
        model.asset = asset;
        model.assetLocalizationIdentifer = asset.localIdentifier;
        
        switch (asset.mediaType) {
            case PHAssetMediaTypeImage: {
                model.mediaType = HQLPhotoModelMediaTypePhoto;
                if ([[asset valueForKey:@"filename"] hasSuffix:@"GIF"]) {
                    model.mediaType = HQLPhotoModelMediaTypePhotoGif;
                }
                if (iOS9Later) {
                    if (asset.mediaSubtypes == PHAssetMediaSubtypePhotoLive) {
                        model.mediaType = HQLPhotoModelMediaTypeLivePhoto;
                    }
                }
                break;
            }
            case PHAssetMediaTypeVideo: {
                model.mediaType = HQLPhotoModelMediaTypeVideo;
                NSString *timeLength = [NSString stringWithFormat:@"%0.0f",asset.duration];
                model.durationTime = [HQLPhotoHelper getNewTimeFromDurationSecond:timeLength.integerValue];
                break;
            }
            case PHAssetMediaTypeAudio: {
                model.mediaType = HQLPhotoModelMediaTypeAudio;
                NSString *timeLength = [NSString stringWithFormat:@"%0.0f",asset.duration];
                model.durationTime = [HQLPhotoHelper getNewTimeFromDurationSecond:timeLength.integerValue];
                break;
            }
            case PHAssetMediaTypeUnknown: {
                model.mediaType = HQLPhotoModelMediaTypeUnKnow;
                break;
            }
        }
    }
    
    completeBlock ? completeBlock(array) : nil;
}

#pragma mark - fetch photo method

// 获取图片
- (PHImageRequestID)fetchImageWithPHAsset:(PHAsset *)asset photoQuality:(HQLPhotoQuality)photoQuality photoSize:(CGSize)photoSize progressHandler:(PHAssetImageProgressHandler)progressHandler resultHandler:(void (^)(UIImage *, NSDictionary *))resultHandler {
    
    CGSize targetSize = CGSizeMake(photoSize.width * HQLScreenScale, photoSize.height * HQLScreenScale);
    PHImageRequestOptions *option = [[PHImageRequestOptions alloc] init];
    option.networkAccessAllowed = YES;
    switch (photoQuality) {
        case HQLPhotoQualityLarger: {
            option.deliveryMode = PHImageRequestOptionsDeliveryModeHighQualityFormat;
            break;
        }
        case HQLPhotoQualityMedium: {
            option.deliveryMode = PHImageRequestOptionsDeliveryModeOpportunistic;
            break;
        }
        case HQLPhotoQualityThumbnails: {
            option.deliveryMode = PHImageRequestOptionsDeliveryModeFastFormat;
            option.resizeMode = PHImageRequestOptionsResizeModeExact;
            break;
        }
    }
    option.progressHandler = progressHandler;
    
    if (photoQuality == HQLPhotoQualityLarger || photoQuality == HQLPhotoQualityMedium) {
        // 开启缓存
        [self.imageManager startCachingImagesForAssets:@[asset] targetSize:targetSize contentMode:PHImageContentModeAspectFill options:option];
    }
    
    return [self.imageManager requestImageForAsset:asset targetSize:targetSize contentMode:PHImageContentModeAspectFill options:option resultHandler:^(UIImage * _Nullable result, NSDictionary * _Nullable info) {
        dispatch_async(dispatch_get_main_queue(), ^{
            resultHandler ? resultHandler(result, info) : nil;
        });
    }];
}

// 获取imageData
- (PHImageRequestID)fetchimageDataWithPHAsset:(PHAsset *)asset progressHandler:(PHAssetImageProgressHandler)progressHandler resultHandler:(void (^)(NSData *, NSString *, UIImageOrientation, NSDictionary *))resultHandler {
    
    PHImageRequestOptions *option = [[PHImageRequestOptions alloc] init];
    option.networkAccessAllowed = YES;
    option.progressHandler = progressHandler;
    
    return [self.imageManager requestImageDataForAsset:asset options:option resultHandler:^(NSData * _Nullable imageData, NSString * _Nullable dataUTI, UIImageOrientation orientation, NSDictionary * _Nullable info) {
        dispatch_async(dispatch_get_main_queue(), ^{
            resultHandler ? resultHandler(imageData, dataUTI, orientation, info) : nil;
        });
    }];
}

// 获取livePhoto
- (PHImageRequestID)fetchLivePhotoWithPHAsset:(PHAsset *)asset photoQuality:(HQLPhotoQuality)photoQuality photoSize:(CGSize)photoSize progressHandler:(PHAssetImageProgressHandler)progressHandler resultHandler:(void (^)(PHLivePhoto *, NSDictionary *))resultHandler {
    
    CGSize targetSize = CGSizeMake(photoSize.width * HQLScreenScale, photoSize.height * HQLScreenScale);
    PHLivePhotoRequestOptions *option = [[PHLivePhotoRequestOptions alloc] init];
    option.networkAccessAllowed = YES;
    switch (photoQuality) {
        case HQLPhotoQualityLarger: {
            option.deliveryMode = PHImageRequestOptionsDeliveryModeHighQualityFormat;
            break;
        }
        case HQLPhotoQualityMedium: {
            option.deliveryMode = PHImageRequestOptionsDeliveryModeOpportunistic;
            break;
        }
        case HQLPhotoQualityThumbnails: {
            option.deliveryMode = PHImageRequestOptionsDeliveryModeFastFormat;
            break;
        }
    }
    option.progressHandler = progressHandler;
    
    return [self.imageManager requestLivePhotoForAsset:asset targetSize:targetSize contentMode:PHImageContentModeAspectFill options:option resultHandler:^(PHLivePhoto * _Nullable livePhoto, NSDictionary * _Nullable info) {
        dispatch_async(dispatch_get_main_queue(), ^{
            resultHandler ? resultHandler(livePhoto, info) : nil;
        });
    }];
}

// 获取playerItem
- (PHImageRequestID)fetchPlayerItemForVideo:(PHAsset *)asset progressHandler:(PHAssetVideoProgressHandler)progressHandler resultHandler:(void (^)(AVPlayerItem *, NSDictionary *))resultHandler {
    
    PHVideoRequestOptions *option = [[PHVideoRequestOptions alloc] init];
    option.networkAccessAllowed = YES;
    option.progressHandler = progressHandler;
    
    return [self.imageManager requestPlayerItemForVideo:asset options:option resultHandler:^(AVPlayerItem * _Nullable playerItem, NSDictionary * _Nullable info) {
        dispatch_async(dispatch_get_main_queue(), ^{
            resultHandler ? resultHandler(playerItem, info) : nil;
        });
    }];
}

- (PHImageRequestID)fetchExportSessionForVideo:(PHAsset *)asset exportPreset:(NSString *)exportPreset progressHandler:(PHAssetVideoProgressHandler)progressHandler resultHandler:(void (^)(AVAssetExportSession *, NSDictionary *))resultHandler {
    
    PHVideoRequestOptions *option = [[PHVideoRequestOptions alloc] init];
    option.networkAccessAllowed = YES;
    option.progressHandler = progressHandler;
    
    return [self.imageManager requestExportSessionForVideo:asset options:option exportPreset:exportPreset resultHandler:^(AVAssetExportSession * _Nullable exportSession, NSDictionary * _Nullable info) {
        dispatch_async(dispatch_get_main_queue(), ^{
            resultHandler ? resultHandler(exportSession, info) : nil;
        });
    }];
}

- (PHImageRequestID)fetchAVAssetForVideo:(PHAsset *)asset progressHandler:(PHAssetVideoProgressHandler)progressHandler resultHandler:(void (^)(AVAsset *, AVAudioMix *, NSDictionary *))resultHandler {
    
    PHVideoRequestOptions *option = [[PHVideoRequestOptions alloc] init];
    option.networkAccessAllowed = YES;
    option.progressHandler = progressHandler;
    
    return [self.imageManager requestAVAssetForVideo:asset options:option resultHandler:^(AVAsset * _Nullable asset, AVAudioMix * _Nullable audioMix, NSDictionary * _Nullable info) {
        dispatch_async(dispatch_get_main_queue(), ^{
            resultHandler ? resultHandler(asset, audioMix, info) : nil;
        });
    }];
}

#pragma mark - photo library change observer

- (void)photoLibraryDidChange:(PHChange *)changeInstance {
    
}

#pragma mark - setter

- (void)setSelectedType:(HQLPhotoManagerSelectedType)selectedType {
    HQLPhotoManagerSelectedType originType = self.selectedType;
    _selectedType = selectedType;
    if (originType != selectedType) {
        [self fetchAllAlbumWithCompleteBlock:nil]; // 重新加载
    }
}

#pragma mark - getter

- (PHCachingImageManager *)imageManager {
    if (!_imageManager) {
        _imageManager = [[PHCachingImageManager alloc] init];
        
    }
    return _imageManager;
}

- (PHPhotoLibrary *)photoLibrary {
    if (!_photoLibrary) {
        _photoLibrary = [PHPhotoLibrary sharedPhotoLibrary];
        [_photoLibrary registerChangeObserver:self];
    }
    return _photoLibrary;
}

- (NSMutableArray<NSString *> *)selectedAssetIdentifierArray {
    if (!_selectedAssetIdentifierArray) {
        _selectedAssetIdentifierArray = [NSMutableArray array];
    }
    return _selectedAssetIdentifierArray;
}

- (NSMutableArray<HQLPhotoAlbumModel *> *)albumArray {
    if (!_albumArray) {
        _albumArray = [NSMutableArray array];
    }
    return _albumArray;
}

@end
