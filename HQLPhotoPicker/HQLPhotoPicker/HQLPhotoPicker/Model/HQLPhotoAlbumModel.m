//
//  HQLPhotoAlbumModel.m
//  HQLPhotoPicker
//
//  Created by weplus on 2017/6/3.
//  Copyright © 2017年 weplus. All rights reserved.
//

#import "HQLPhotoAlbumModel.h"
#import <Photos/Photos.h>
#import "HQLPhotoManager.h"
#import "HQLPhotoHelper.h"

@implementation HQLPhotoAlbumModel {
    NSMutableArray<HQLPhotoModel *> *_photoArray;
    PHFetchResult *_albumResult;
}

#pragma mark - event

- (void)updatePhotoArray {
    [_photoArray removeAllObjects];
    _photoArray = nil;
    [self photoArray];
}

- (void)updateAlbumResult {
    _albumResult = nil;
    [self albumResult];
}

#pragma mark - setter

- (void)setAlbumCollection:(PHAssetCollection *)albumCollection {
    if (!albumCollection) {
        return;
    }
    _albumCollection = albumCollection;
    [self updateAlbumResult];
    [self updatePhotoArray];
}

#pragma mark - getter

- (PHFetchResult *)albumResult {
    if (!self.albumCollection) {
        return nil;
    }
    
    if (!_albumResult) {
        PHFetchOptions *option = [[PHFetchOptions alloc] init];
        option.sortDescriptors = @[[NSSortDescriptor sortDescriptorWithKey:@"creationDate" ascending:self.ascendingByCreationDate]];
        if (self.selectedType == HQLPhotoSelectedTypePhoto) { // 只选择图片
            option.predicate = [NSPredicate predicateWithFormat:@"mediaType == %ld", PHAssetMediaTypeImage];
        } else if (self.selectedType == HQLPhotoSelectedTypeVideo) { // 只选择视频
            option.predicate = [NSPredicate predicateWithFormat:@"mediaType == %ld", PHAssetMediaTypeVideo];
        }
        _albumResult = [PHAsset fetchAssetsInAssetCollection:self.albumCollection options:option];
    }
    return _albumResult;
}

- (NSMutableArray<HQLPhotoModel *> *)photoArray {
    if (!_photoArray) {
        _photoArray = [NSMutableArray array];
        [[HQLPhotoManager shareManager] fetchPhotoForAlbumWithResult:self.albumResult completeBlock:^(NSMutableArray<HQLPhotoModel *> *photoArray) {
            [_photoArray addObjectsFromArray:photoArray];
        }];
    }
    return _photoArray;
}

- (void)setSelectedType:(HQLPhotoSelectedType)selectedType {
    HQLPhotoSelectedType originType = self.selectedType;
    _selectedType = selectedType;
    if (originType != selectedType) {
        [_photoArray removeAllObjects];
        _photoArray = nil;
        [self photoArray];
    }
}

- (void)setAscendingByCreationDate:(BOOL)ascendingByCreationDate {
    BOOL origin = self.ascendingByCreationDate;
    _ascendingByCreationDate = ascendingByCreationDate;
    if (origin != ascendingByCreationDate) {
        [_photoArray removeAllObjects];
        _photoArray = nil;
        [self photoArray];
    }
}

- (NSString *)albumName {
    return [HQLPhotoHelper transFormPhotoTitle:self.albumCollection.localizedTitle];
}

- (NSInteger)count {
    return self.photoArray.count;
}

- (HQLPhotoModel *)albumCover {
    return self.photoArray.firstObject;
}

@end
