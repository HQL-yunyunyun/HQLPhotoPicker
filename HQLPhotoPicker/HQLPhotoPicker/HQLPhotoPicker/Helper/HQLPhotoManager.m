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
    });
    return manager;
}

- (void)dealloc {
    [self.photoLibrary unregisterChangeObserver:self];
    NSLog(@"dealloc ---> %@", NSStringFromClass([self class]));
}

#pragma mark - event

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
        if (![albumName isEqualToString:@"最近删除"]) {
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
                break;
            }
            case PHAssetMediaTypeAudio: {
                model.mediaType = HQLPhotoModelMediaTypeAudio;
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
