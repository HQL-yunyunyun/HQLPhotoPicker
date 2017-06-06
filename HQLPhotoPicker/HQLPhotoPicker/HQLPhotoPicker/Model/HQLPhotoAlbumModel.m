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
#import "HQLPhotoModel.h"

@implementation HQLPhotoAlbumModel

#pragma mark - setter

- (void)setAlbumResult:(PHFetchResult *)albumResult {
    _albumResult = albumResult;
    // 获取照片
    [_photoArray removeAllObjects];
    
    [[HQLPhotoManager shareManager] fetchPhotoForAlbumWithResult:albumResult completeBlock:^(NSMutableArray<HQLPhotoModel *> *photoArray) {
        _photoArray = [NSMutableArray arrayWithArray:photoArray];
    }];
}

#pragma mark - getter

- (NSInteger)count {
    return self.albumResult.count;
}

-(HQLPhotoModel *)albumCover {
    for (int i = 0; i < self.photoArray.count; i++) {
        HQLPhotoModel *model = self.photoArray[i];
        if (model.mediaType == HQLPhotoModelMediaTypePhoto) {
            return model;
        }
    }
    return nil;
}

@end
