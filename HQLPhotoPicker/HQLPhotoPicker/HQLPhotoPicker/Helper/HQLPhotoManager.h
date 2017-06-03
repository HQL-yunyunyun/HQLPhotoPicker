//
//  HQLPhotoManager.h
//  HQLPhotoPicker
//
//  Created by weplus on 2017/6/2.
//  Copyright © 2017年 weplus. All rights reserved.
//

#import <Foundation/Foundation.h>

@class HQLPhotoModel, HQLPhotoAlbumModel, PHFetchResult;

#define HQLWeakSelf __weak typeof(self) weakSelf = self
#define iOS9Later ([UIDevice currentDevice].systemVersion.floatValue >= 9.0f)

typedef enum : NSUInteger {
    HQLPhotoManagerSelectedTypePhoto = 0, // 只选择图片
    HQLPhotoManagerSelectedTypeVideo, // 只选择视频
    HQLPhotoManagerSelectedTypePhotoAndVideo // 图片和视频一起
} HQLPhotoManagerSelectedType;

@interface HQLPhotoManager : NSObject

@property (strong, nonatomic) NSMutableArray <HQLPhotoAlbumModel *>*albumArray; // 保存相册 --- 第一个相册是所有图片
@property (strong, nonatomic) NSMutableArray <NSString *>*selectedAssetIdentifierArray; // 选中的资源的标识符
@property (assign, nonatomic) HQLPhotoManagerSelectedType selectedType; // 选择的样式

+ (instancetype)shareManager;

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

@end
