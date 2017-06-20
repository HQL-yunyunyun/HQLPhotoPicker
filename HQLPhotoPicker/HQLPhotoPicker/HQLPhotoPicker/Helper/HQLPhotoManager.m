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

// 获取权限
- (void)requestPhotoAuthorizationWithCompleteHandler:(void (^)(PHAuthorizationStatus))completeHandler {
    [PHPhotoLibrary requestAuthorization:^(PHAuthorizationStatus status) {
        dispatch_async(dispatch_get_main_queue(), ^{
            completeHandler ? completeHandler(status) : nil;
        });
    }];
}

// 返回当前权限状态
- (PHAuthorizationStatus)currentPhotoAuthorizationStatus {
    return [PHPhotoLibrary authorizationStatus];
}

#pragma mark - selected method

// 选择 identifier 对应的资源
- (void)addSelectedAssetWithIdentifier:(NSString *)identifier complete:(void(^)(BOOL isSuccess, NSString *message))complete{
    if (!complete) {
        return;
    }
    if (![self getAssetIsSelectedWithIdentifier:identifier]) {
        [self.selectedAssetIdentifierArray addObject:identifier];
        
        for (HQLPhotoModel *model in [self getAssetWithIdentifier:identifier]) {
            model.isSelected = YES;
        }
        
        complete(YES, @"添加成功");
    } else {
        complete(NO, @"identifier 所对应的资源已被选中");
    }
}

// 移除 identifier 对应的资源的选择状态
- (void)removeSelectedAssetWithIdentifier:(NSString *)identifier complete:(void(^)(BOOL isSuccess, NSString *message))complete{
    if (!complete) {
        return;
    }
    if ([self getAssetIsSelectedWithIdentifier:identifier]) {
        [self.selectedAssetIdentifierArray removeObject:identifier];
        
        for (HQLPhotoModel *model in [self getAssetWithIdentifier:identifier]) {
            model.isSelected = NO;
        }
        
        complete(YES, @"删除成功");
    } else {
        complete(NO, @"identifier 所对应的资源没有被选中");
    }
}

// 资源是否已被选择
- (BOOL)getAssetIsSelectedWithIdentifier:(NSString *)identifier {
    for (NSString *ID in self.selectedAssetIdentifierArray) {
        if ([identifier isEqualToString:ID]) {
            return YES;
        }
    }
    return NO;
}

// 移除所有已选择的资源
- (void)removeAllSelectedAsset {
    for (NSString *identifier in self.selectedAssetIdentifierArray) {
        for (HQLPhotoModel *model in [self getAssetWithIdentifier:identifier]) {
            model.isSelected = NO;
        }
    }
    [self.selectedAssetIdentifierArray removeAllObjects];
}

// 获取 identifier 所对应的所有资源
- (NSMutableArray<HQLPhotoModel *> *)getAssetWithIdentifier:(NSString *)identifier {
    NSMutableArray *array = [NSMutableArray array];
    for (HQLPhotoAlbumModel *album in self.albumArray) {
        HQLPhotoModel *model = [self getAssetWithIdentifier:identifier inAlbum:album];
        if (model) {
            [array addObject:model];
        }
    }
    return array;
}

// 获取某个相册中 identifier 对应的资源
- (HQLPhotoModel *)getAssetWithIdentifier:(NSString *)identifier inAlbum:(HQLPhotoAlbumModel *)album {
    for (HQLPhotoModel *model in album.photoArray) {
        if ([model.assetLocalizationIdentifier isEqualToString:identifier]) {
            return model;
        }
    }
    return nil;
}

// 获取所有已选择的 资源 对应的相册中的 index
- (NSMutableArray<NSNumber *> *)getSelectedAssetIndexWithAlbum:(HQLPhotoAlbumModel *)albumModel {
    NSMutableArray *array = [NSMutableArray array];
    for (HQLPhotoModel *model in albumModel.photoArray) {
        if ([self getAssetIsSelectedWithIdentifier:model.assetLocalizationIdentifier]) {
            [array addObject:[NSNumber numberWithUnsignedInteger:[albumModel.photoArray indexOfObject:model]]];
        }
    }
    return array;
}

// 获取已选择的资源
- (NSMutableArray<HQLPhotoModel *> *)getSelectedAsset {
    NSMutableArray *array = [NSMutableArray array];
    for (NSString *identifier in self.selectedAssetIdentifierArray) {
        [array addObject:[self getAssetWithIdentifier:identifier].firstObject];
    }
    return array;
}

#pragma mark - save method

// 保存图片到指定相册
- (void)saveImage:(UIImage *)image toAlbum:(HQLPhotoAlbumModel *)album complete:(void (^)(BOOL, NSString *, NSString *))complete {
    __block NSString *targetIdentifier = @"";
    [self.photoLibrary performChanges:^{
        
        PHAssetChangeRequest *assetChangeRequest = [PHAssetChangeRequest creationRequestForAssetFromImage:image];
        targetIdentifier = assetChangeRequest.placeholderForCreatedAsset.localIdentifier;
        
        // 只有用户相册才能指定
        if (album.albumCollection.assetCollectionType == PHAssetCollectionTypeAlbum && album.albumCollection.assetCollectionSubtype == PHAssetCollectionSubtypeSmartAlbumUserLibrary && album.albumCollection) {
            PHAssetCollectionChangeRequest *collectionChangeRequest = [PHAssetCollectionChangeRequest changeRequestForAssetCollection:album.albumCollection];
            [collectionChangeRequest addAssets:@[assetChangeRequest.placeholderForCreatedAsset]];
        }
        
    } completionHandler:^(BOOL success, NSError * _Nullable error) {
        complete ? complete(success, [HQLPhotoHelper getErrorStringWithError:error], targetIdentifier) : nil;
    }];
}

// 保存 Image --- 用imageUrl
- (void)saveImageWithImageUrl:(NSURL *)imageUrl toAlbum:(HQLPhotoAlbumModel *)album complete:(void (^)(BOOL, NSString *, NSString *))complete {
    __block NSString *targetIdentifier = @"";
    
    [self.photoLibrary performChanges:^{
        PHAssetChangeRequest *assetChangeRequest = [PHAssetChangeRequest creationRequestForAssetFromImageAtFileURL:imageUrl];
        targetIdentifier = assetChangeRequest.placeholderForCreatedAsset.localIdentifier;
        if (album.albumCollection.assetCollectionType == PHAssetCollectionTypeAlbum && album.albumCollection.assetCollectionSubtype == PHAssetCollectionSubtypeSmartAlbumUserLibrary && album.albumCollection) {
            PHAssetCollectionChangeRequest *collectionChangeRequest = [PHAssetCollectionChangeRequest changeRequestForAssetCollection:album.albumCollection];
            [collectionChangeRequest addAssets:@[assetChangeRequest.placeholderForCreatedAsset]];
        }
    } completionHandler:^(BOOL success, NSError * _Nullable error) {
        complete ? complete(success, [HQLPhotoHelper getErrorStringWithError:error], targetIdentifier) : nil;
    }];
}

// 保存视频
- (void)saveVideoWithVideoUrl:(NSURL *)videoUrl toAlbum:(HQLPhotoAlbumModel *)album complete:(void (^)(BOOL, NSString *, NSString *))complete {
    __block NSString *targetIdentifier = @"";
    [self.photoLibrary performChanges:^{
        PHAssetChangeRequest *assetChangeRequest = [PHAssetChangeRequest creationRequestForAssetFromVideoAtFileURL:videoUrl];
        targetIdentifier = assetChangeRequest.placeholderForCreatedAsset.localIdentifier;
        if (album.albumCollection.assetCollectionType == PHAssetCollectionTypeAlbum && album.albumCollection.assetCollectionSubtype == PHAssetCollectionSubtypeSmartAlbumUserLibrary && album.albumCollection) {
            PHAssetCollectionChangeRequest *collectionChangeRequest = [PHAssetCollectionChangeRequest changeRequestForAssetCollection:album.albumCollection];
            [collectionChangeRequest addAssets:@[assetChangeRequest.placeholderForCreatedAsset]];
        }
    } completionHandler:^(BOOL success, NSError * _Nullable error) {
       complete ? complete(success, [HQLPhotoHelper getErrorStringWithError:error], targetIdentifier) : nil;
    }];
}

#pragma mark - fetch method

// 获取所有相册
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
            model.albumCollection = collection;
            
            [weakSelf.albumArray addObject:model];
        }
    }];
}

// 获取相册的照片
- (void)fetchPhotoForAlbumWithResult:(PHFetchResult *)photoResult completeBlock:(void(^)(NSMutableArray <HQLPhotoModel *>*photoArray))completeBlock {
    NSMutableArray *array = [NSMutableArray array];
    for (NSInteger i = photoResult.count - 1; i >= 0; i--) {
        HQLPhotoModel *model = [[HQLPhotoModel alloc] init];
        [array addObject:model];
        
        PHAsset *asset = photoResult[i];
        model.asset = asset;
        model.assetLocalizationIdentifier = asset.localIdentifier;
        model.isSelected = [self getAssetIsSelectedWithIdentifier:model.assetLocalizationIdentifier];
        
        switch (asset.mediaType) {
            case PHAssetMediaTypeImage: {
                model.mediaType = HQLPhotoModelMediaTypePhoto;
                if (self.isGifOpen) {
                    if ([[asset valueForKey:@"filename"] hasSuffix:@"GIF"]) {
                        model.mediaType = HQLPhotoModelMediaTypePhotoGif;
                    }
                }
                
                if (iOS9Later && self.isLivePhotoOpen) {
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
- (PHImageRequestID)fetchImageWithPHAsset:(PHAsset *)asset photoQuality:(HQLPhotoQuality)photoQuality photoSize:(CGSize)photoSize isCaching:(BOOL)isCaching progressHandler:(PHAssetImageProgressHandler)progressHandler resultHandler:(void (^)(UIImage *, NSDictionary *))resultHandler {
    
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
            break;
        }
    }
    option.resizeMode = PHImageRequestOptionsResizeModeExact;
    option.progressHandler = progressHandler;
    
    if (isCaching) {
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

// 获取 视频资源
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
    
    NSLog(@"library did change : %@", changeInstance);
    
    for (HQLPhotoAlbumModel *album in self.albumArray) {
        
        PHFetchResultChangeDetails *fetchResult = [changeInstance changeDetailsForFetchResult:album.albumResult];
        if (fetchResult) {
            NSLog(@"change album name : %@", album.albumName);
            
            if (fetchResult.hasIncrementalChanges) { // 表明有改变
                if (fetchResult.removedIndexes) { // 表明有移除
                    NSLog(@"remove indexes : %@", fetchResult.removedIndexes);
                    NSLog(@"remove objects : %@", fetchResult.removedObjects);
                }
                if (fetchResult.insertedIndexes) {
                    NSLog(@"insert indexes : %@", fetchResult.insertedIndexes);
                    NSLog(@"insert objects : %@", fetchResult.insertedObjects);
                }
                if (fetchResult.changedIndexes) {
                    NSLog(@"change indexes : %@", fetchResult.changedIndexes);
                    NSLog(@"change objects : %@", fetchResult.changedObjects);
                }
                
                
                // 移动了item
                if (fetchResult.hasMoves) {
                    [fetchResult enumerateMovesWithBlock:^(NSUInteger fromIndex, NSUInteger toIndex) {
                        NSLog(@"move item , from index : %ld  ---  to index : %ld", fromIndex, toIndex);
                    }];
                }
            }
        }
    }
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
