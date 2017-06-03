//
//  HQLPhotoAlbumModel.h
//  HQLPhotoPicker
//
//  Created by weplus on 2017/6/3.
//  Copyright © 2017年 weplus. All rights reserved.
//

#import <Foundation/Foundation.h>

@class HQLPhotoModel, PHFetchResult;

@interface HQLPhotoAlbumModel : NSObject

@property (strong, nonatomic) PHFetchResult *albumResult; // 相册
@property (copy, nonatomic) NSString *albumName; // 相册名称
@property (assign, nonatomic, readonly) NSInteger count; // 照片数量
@property (strong, nonatomic, readonly) NSMutableArray <HQLPhotoModel *>*photoArray; // 相册照片
@property (strong, nonatomic, readonly) HQLPhotoModel *albumCover; // 相册封面

@end
