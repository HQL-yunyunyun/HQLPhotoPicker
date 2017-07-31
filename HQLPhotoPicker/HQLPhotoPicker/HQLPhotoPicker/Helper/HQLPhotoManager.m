//
//  HQLPhotoManager.m
//  HQLPhotoPicker
//
//  Created by weplus on 2017/6/2.
//  Copyright © 2017年 weplus. All rights reserved.
//

#import "HQLPhotoManager.h"
#import "HQLPhotoHelper.h"

#import <Photos/Photos.h>

#define HQLScreenScale [UIScreen mainScreen].scale

@interface HQLPhotoManager () <PHPhotoLibraryChangeObserver>

@property (strong, nonatomic) PHPhotoLibrary *photoLibrary;
@property (strong, nonatomic) NSMutableArray <id <HQLPhotoLibraryChangeObserver>>*observerArray;

@end

@implementation HQLPhotoManager

#pragma mark - initialize method 

+ (instancetype)shareManager {
    static HQLPhotoManager *manager;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        manager = [[HQLPhotoManager alloc] init];
        
        [manager imageManager];
        [manager photoLibrary]; // 两个都先初始化
        
        [manager requestPhotoAuthorizationWithCompleteHandler:^(PHAuthorizationStatus status) {
            NSLog(@"%ld", (long)status);
        }];
    });
    return manager;
}

- (void)dealloc {
    [self.photoLibrary unregisterChangeObserver:self];
    [self.observerArray removeAllObjects];
    self.observerArray = nil;
    NSLog(@"dealloc ---> %@", NSStringFromClass([self class]));
}

#pragma mark - observer method

- (void)registerChangeObserver:(id<HQLPhotoLibraryChangeObserver>)observer {
    if (observer) {
        [self.observerArray addObject:observer];
    }
}

- (void)unregisterChangeObserver:(id<HQLPhotoLibraryChangeObserver>)observer {
    if (observer) {
        [self.observerArray removeObject:observer];
    }
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

// 设置 photoModel 的属性
- (void)setupPhotoModelWithPHAsset:(PHAsset *)asset model:(HQLPhotoModel *)model {
    if (!model || !asset) {
        return;
    }
    model.asset = asset;
    model.assetLocalizationIdentifier = asset.localIdentifier;
    model.isSelected = [self getAssetIsSelectedWithIdentifier:model.assetLocalizationIdentifier];
    [model cancelRequest];
    model.requestID = -1;
    model.thumbnailImage = nil;
    
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

#pragma mark - selected method

// 选择 identifier 对应的资源
- (void)addSelectedAssetWithIdentifier:(NSString *)identifier complete:(void(^)(BOOL isSuccess, NSString *message))complete{
    if (![self getAssetIsSelectedWithIdentifier:identifier]) {
        [self.selectedAssetIdentifierArray addObject:identifier];
        
        for (HQLPhotoModel *model in [self getAssetWithIdentifier:identifier]) {
            model.isSelected = YES;
        }
        
        complete ? complete(YES, @"添加成功") : nil;
    } else {
        complete ? complete(NO, @"identifier 所对应的资源已被选中") : nil;
    }
}

// 移除 identifier 对应的资源的选择状态
- (void)removeSelectedAssetWithIdentifier:(NSString *)identifier complete:(void(^)(BOOL isSuccess, NSString *message))complete{
    if ([self getAssetIsSelectedWithIdentifier:identifier]) {
        [self.selectedAssetIdentifierArray removeObject:identifier];
        
        for (HQLPhotoModel *model in [self getAssetWithIdentifier:identifier]) {
            model.isSelected = NO;
        }
        
        complete ? complete(YES, @"删除成功") : nil;
    } else {
        complete ? complete(NO, @"identifier 所对应的资源没有被选中") : nil;
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
        NSArray *objArray = [self getAssetWithIdentifier:identifier];
        if (objArray.count != 0) {
            [array addObject:objArray.firstObject];
        }
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
        
        HQLPhotoAlbumModel *album = [[HQLPhotoAlbumModel alloc] init];
        album.selectedType = self.selectedType;
        album.ascendingByCreationDate = self.ascendingByCreationDate;
        album.albumCollection = collection;
        
        // 将 最近删除 过滤
        if (![album.albumName isEqualToString:@"最近删除"] && album.albumResult.count > 0) {
            [weakSelf.albumArray addObject:album];
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
        [self setupPhotoModelWithPHAsset:asset model:model];
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
        NSLog(@"before current thread %@", [NSThread currentThread]);
        dispatch_async(dispatch_get_main_queue(), ^{
            NSLog(@"after current thread %@", [NSThread currentThread]);
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
    
    HQLWeakSelf;
    for (HQLPhotoAlbumModel *album in self.albumArray) {
        PHFetchResultChangeDetails *fetchResult = [changeInstance changeDetailsForFetchResult:album.albumResult];
        if (fetchResult) {
            NSLog(@"change album name : %@", album.albumName);
            if (fetchResult.hasIncrementalChanges) { // 表明有改变
                [album updateAlbumResult];
                
                NSMutableArray *indexArray = [NSMutableArray array];
                HQLPhotoLibraryDidChangeType type = HQLPhotoLibraryDidNotChange;
                
                if (fetchResult.removedIndexes) { // 表明有移除
                    // 移除只需要将移除的对象移除就好
                    NSMutableArray *deleteArray = [NSMutableArray array];
                    for (PHAsset *asset in fetchResult.removedObjects) {
                        HQLPhotoModel *model = [self getAssetWithIdentifier:asset.localIdentifier inAlbum:album];
                        [deleteArray addObject:model];
                        if ([self getAssetIsSelectedWithIdentifier:asset.localIdentifier]) {
                            [self removeSelectedAssetWithIdentifier:asset.localIdentifier complete:nil];
                        }
                        
                        [indexArray addObject:[NSNumber numberWithUnsignedInteger:[album.photoArray indexOfObject:model]]];
                    }
                    for (HQLPhotoModel *model in deleteArray) {
                        [album.photoArray removeObject:model];
                    }
                    type = HQLPhotoLibraryDidRemove;
                }
                if (fetchResult.insertedIndexes) {
                    NSInteger totalCount = fetchResult.fetchResultAfterChanges.count; // 这是改变后的总数
                    __block NSInteger index = 0;
                    [fetchResult.insertedIndexes enumerateIndexesUsingBlock:^(NSUInteger idx, BOOL * _Nonnull stop) {
                        // 因为在获取照片的时候，排序的方式是最新的照片在前面，而系统排序的方式是最新的在后面，所以导致这里的idx跟现在的情况不一样，需要转换一下index(最新的为0)
                        HQLPhotoModel *model = [[HQLPhotoModel alloc] init];
                        PHAsset *asset = fetchResult.insertedObjects[index];
                        [self setupPhotoModelWithPHAsset:asset model:model];
                        index++;
                        
                        NSUInteger targetIndex = idx;
                        if (weakSelf.ascendingByCreationDate) { // 需要转换index
                            targetIndex = totalCount - 1 - idx;
                        }
                        [album.photoArray insertObject:model atIndex:targetIndex];
                        [indexArray addObject:[NSNumber numberWithUnsignedInteger:targetIndex]];
                    }];
                    
                    type = HQLPhotoLibraryDidInsert;
                }
                if (fetchResult.changedIndexes) {
                    // 根据removeObjects来更新当前model
                    for (PHAsset *asset in fetchResult.changedObjects) {
                        HQLPhotoModel *model = [self getAssetWithIdentifier:asset.localIdentifier inAlbum:album];
                        [self setupPhotoModelWithPHAsset:asset model:model];
                        
                        [indexArray addObject:[NSNumber numberWithUnsignedInteger:[album.photoArray indexOfObject:model]]];
                    }
                    type = HQLPhotoLibraryDidChange;
                }
                
                // 移动了item
                if (fetchResult.hasMoves) {
                    [fetchResult enumerateMovesWithBlock:^(NSUInteger fromIndex, NSUInteger toIndex) {
                        HQLPhotoModel *fromModel = album.photoArray[fromIndex];
                        [album.photoArray removeObject:fromModel];
                        [album.photoArray insertObject:fromModel atIndex:toIndex];
                    }];
                    
                    type = HQLPhotoLibraryDidMove;
                }
                
                // observer method
                dispatch_async(dispatch_get_main_queue(), ^{
                    for (id <HQLPhotoLibraryChangeObserver> observer in weakSelf.observerArray) {
                        if ([observer respondsToSelector:@selector(photoLibraryDidChange:changedAlbum:changeResult:changeIndex:changeType:)]) {
                            [observer photoLibraryDidChange:changeInstance changedAlbum:album changeResult:fetchResult changeIndex:indexArray changeType:type];
                        }
                    }
                });
            }
        }
    }
}

#pragma mark - setter

- (void)setSelectedType:(HQLPhotoSelectedType)selectedType {
    HQLPhotoSelectedType originType = self.selectedType;
    _selectedType = selectedType;
    if (originType != selectedType) {
        [self fetchAllAlbumWithCompleteBlock:nil]; // 重新加载
    }
}

#pragma mark - getter

- (NSMutableArray<id<HQLPhotoLibraryChangeObserver>> *)observerArray {
    if (!_observerArray) {
        _observerArray = [NSMutableArray array];
    }
    return _observerArray;
}

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
