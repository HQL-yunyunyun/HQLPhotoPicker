//
//  HQLPhotoAlbumModel.h
//  HQLPhotoPicker
//
//  Created by weplus on 2017/6/3.
//  Copyright © 2017年 weplus. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef enum : NSUInteger {
    HQLPhotoSelectedTypePhoto = 0, // 只选择图片
    HQLPhotoSelectedTypeVideo, // 只选择视频
    HQLPhotoSelectedTypePhotoAndVideo // 图片和视频一起
} HQLPhotoSelectedType;

@class HQLPhotoModel, PHFetchResult, PHAssetCollection;

@interface HQLPhotoAlbumModel : NSObject

@property (strong, nonatomic, readonly) PHFetchResult *albumResult; // 相册
@property (assign, nonatomic, readonly) NSInteger count; // 照片数量
@property (strong, nonatomic, readonly) NSMutableArray <HQLPhotoModel *>*photoArray; // 相册照片
@property (strong, nonatomic, readonly) HQLPhotoModel *albumCover; // 相册封面
@property (copy, nonatomic, readonly) NSString *albumName; // 相册名称
@property (strong, nonatomic) PHAssetCollection *albumCollection; // collection

@property (assign, nonatomic) HQLPhotoSelectedType selectedType; // 根据这个来排序
@property (assign, nonatomic) BOOL ascendingByCreationDate; // 是否按照日期排序，最新的排在前面

- (void)updatePhotoArray; // 更新到最新的photoArray
- (void)updateAlbumResult; // 更新到最新的result

@end
