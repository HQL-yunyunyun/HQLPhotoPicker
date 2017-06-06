//
//  HQLPhotoModel.m
//  HQLPhotoPicker
//
//  Created by weplus on 2017/6/3.
//  Copyright © 2017年 weplus. All rights reserved.
//

#import "HQLPhotoModel.h"
#import "HQLPhotoManager.h"

#define kThumbnailImageSize CGSizeMake(200, 200)
#define kOriginalImageSize CGSizeMake(1000, 1000)

@implementation HQLPhotoModel

#pragma mark - event

// 获取缩略图
- (void)requestThumbnailImage:(void (^)(UIImage *))completeBlock {
    if (self.thumbnailImage) {
        completeBlock ? completeBlock(self.thumbnailImage) : nil;
    } else {
        HQLWeakSelf;
        UIImage *defaultImage = [UIImage imageWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"defaultImage" ofType:@"png"]];
        switch (self.mediaType) {
            case HQLPhotoModelMediaTypePhoto:
            case HQLPhotoModelMediaTypeVideo:
            case HQLPhotoModelMediaTypePhotoGif:
            case HQLPhotoModelMediaTypeLivePhoto: { // 获取缩略图
                
                // 在获得图片前先显示默认图片
                completeBlock ? completeBlock(defaultImage) : nil;
                
                [[HQLPhotoManager shareManager] fetchImageWithPHAsset:self.asset photoQuality:HQLPhotoQualityThumbnails photoSize:kThumbnailImageSize progressHandler:^(double progress, NSError * _Nullable error, BOOL * _Nonnull stop, NSDictionary * _Nullable info) {
                    if (error) {
                        NSLog(@"fetch thumbnail image error %@", error);
                    }
                    NSLog(@"fetch thumbnail image progress %g", progress);
                } resultHandler:^(UIImage *image, NSDictionary *info) {
                    weakSelf.thumbnailImage = image;
                    completeBlock ? completeBlock(image) : nil;
                }];
                break;
            }
            case HQLPhotoModelMediaTypeCameraPhoto: { // 自己拍的照片
                completeBlock ? completeBlock(self.cameraPhoto) : nil;
                break;
            }
            case HQLPhotoModelMediaTypeCameraVideo: { // 自己拍的video
                completeBlock ? completeBlock(defaultImage) : nil;
                break;
            }
            case HQLPhotoModelMediaTypeAudio: {
                completeBlock ? completeBlock(defaultImage) : nil;
                break;
            }
            case HQLPhotoModelMediaTypeUnKnow: {
                completeBlock ? completeBlock(defaultImage) : nil;
                break;
            }
        }
    }
}

// 获取原图
- (void)requestOriginalImage:(void (^)(UIImage *))completeBlock {
    HQLWeakSelf;
    UIImage *defaultImage = [UIImage imageWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"defaultImage" ofType:@"png"]];
    switch (self.mediaType) {
        case HQLPhotoModelMediaTypePhoto:
        case HQLPhotoModelMediaTypeVideo:
        case HQLPhotoModelMediaTypePhotoGif:
        case HQLPhotoModelMediaTypeLivePhoto: { // 获取缩略图
            
            // 在获得图片前先显示默认图片
            completeBlock ? completeBlock(defaultImage) : nil;
            
            [[HQLPhotoManager shareManager] fetchImageWithPHAsset:self.asset photoQuality:HQLPhotoQualityLarger photoSize:kOriginalImageSize progressHandler:^(double progress, NSError * _Nullable error, BOOL * _Nonnull stop, NSDictionary * _Nullable info) {
                if (error) {
                    NSLog(@"fetch thumbnail image error %@", error);
                }
                NSLog(@"fetch thumbnail image progress %g", progress);
            } resultHandler:^(UIImage *image, NSDictionary *info) {
                completeBlock ? completeBlock(image) : nil;
            }];
            break;
        }
        case HQLPhotoModelMediaTypeCameraPhoto: { // 自己拍的照片
            completeBlock ? completeBlock(self.cameraPhoto) : nil;
            break;
        }
        case HQLPhotoModelMediaTypeCameraVideo: { // 自己拍的video
            completeBlock ? completeBlock(defaultImage) : nil;
            break;
        }
        case HQLPhotoModelMediaTypeAudio: {
            completeBlock ? completeBlock(defaultImage) : nil;
            break;
        }
        case HQLPhotoModelMediaTypeUnKnow: {
            completeBlock ? completeBlock(defaultImage) : nil;
            break;
        }
    }
}

@end
