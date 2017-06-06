//
//  HQLPhotoModel.m
//  HQLPhotoPicker
//
//  Created by weplus on 2017/6/3.
//  Copyright © 2017年 weplus. All rights reserved.
//

#import "HQLPhotoModel.h"
#import "HQLPhotoManager.h"

#import "HQLPhotoHelper.h"

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
        [self fetchImageWithTragetSize:kThumbnailImageSize photoQuality:HQLPhotoQualityThumbnails progressHandler:nil resultHandler:^(UIImage *image) {
            weakSelf.thumbnailImage = image;
            completeBlock ? completeBlock(image) : nil;
        }];
    }
}

// 获取高清图
- (void)requestHighDefinitionImageWithProgressHandler:(PHAssetImageProgressHandler)progressHandler resultHandler:(void (^)(UIImage *))resultHandler {
    
    [self fetchImageWithTragetSize:kOriginalImageSize photoQuality:HQLPhotoQualityMedium progressHandler:progressHandler resultHandler:resultHandler];
}

// 获取原图
- (void)requestOriginalImageWithProgressHandler:(PHAssetImageProgressHandler)progressHandler resultHandler:(void (^)(UIImage *))resultHandler {
    
    [self fetchImageWithTragetSize:kOriginalImageSize photoQuality:HQLPhotoQualityLarger progressHandler:progressHandler resultHandler:resultHandler];
}

// 获取 image data
- (void)requestOriginalImageDataWithProgressHandler:(PHAssetImageProgressHandler)progressHandler resultHandler:(void (^)(NSData *, NSString *))resultHandler {
    switch (self.mediaType) {
        case HQLPhotoModelMediaTypePhoto:
        case HQLPhotoModelMediaTypeLivePhoto:
        case HQLPhotoModelMediaTypePhotoGif: {
            [[HQLPhotoManager shareManager] fetchimageDataWithPHAsset:self.asset progressHandler:^(double progress, NSError * _Nullable error, BOOL * _Nonnull stop, NSDictionary * _Nullable info) {
                if (error) {
                    NSLog(@"fetch thumbnail image error %@", error);
                }
                NSLog(@"fetch thumbnail image progress %g", progress);
                progressHandler ? progressHandler(progress, error, stop, info) : nil;
            } resultHandler:^(NSData *imageData, NSString *dataUTI, UIImageOrientation orientation, NSDictionary *info) {
                resultHandler ? resultHandler(imageData, [HQLPhotoHelper fetchPhotosBytes:@[imageData]]) : nil;
            }];
            break;
        }
        case HQLPhotoModelMediaTypeCameraPhoto: {
            NSData *imageData = UIImagePNGRepresentation(self.cameraPhoto);
            if (!imageData) {
                imageData = UIImageJPEGRepresentation(self.cameraPhoto, 1.0);
            }
            resultHandler ? resultHandler(imageData, [HQLPhotoHelper fetchPhotosBytes:@[imageData]]) : nil;
        }
        default: { break; }
    }
}

// live photo
- (void)requestLivePhotoWithProgressHandler:(PHAssetImageProgressHandler)progressHandler resultHandler:(void (^)(PHLivePhoto *))resultHandler {
    if (self.mediaType == HQLPhotoModelMediaTypeLivePhoto) {
        [[HQLPhotoManager shareManager] fetchLivePhotoWithPHAsset:self.asset photoQuality:HQLPhotoQualityLarger photoSize:kOriginalImageSize progressHandler:^(double progress, NSError * _Nullable error, BOOL * _Nonnull stop, NSDictionary * _Nullable info) {
            if (error) {
                NSLog(@"fetch thumbnail image error %@", error);
            }
            NSLog(@"fetch thumbnail image progress %g", progress);
            progressHandler ? progressHandler(progress, error, stop, info) : nil;
        } resultHandler:^(PHLivePhoto *livePhoto, NSDictionary *info) {
            resultHandler ? resultHandler(livePhoto) : nil;
        }];
    }
}

#pragma mark - tool

- (void)fetchImageWithTragetSize:(CGSize)targetSize
           photoQuality:(HQLPhotoQuality)photoQuality
           progressHandler:(PHAssetImageProgressHandler)progressHandler
           resultHandler:(void(^)(UIImage *image))resultHandler
{
    
    UIImage *defaultImage = [UIImage imageWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"defaultImage" ofType:@"png"]];
    switch (self.mediaType) {
        case HQLPhotoModelMediaTypePhoto:
        case HQLPhotoModelMediaTypeVideo:
        case HQLPhotoModelMediaTypePhotoGif:
        case HQLPhotoModelMediaTypeLivePhoto: { // 获取原图
            
            // 在获得图片前先显示默认图片
            [[HQLPhotoManager shareManager] fetchImageWithPHAsset:self.asset photoQuality:photoQuality photoSize:targetSize progressHandler:^(double progress, NSError * _Nullable error, BOOL * _Nonnull stop, NSDictionary * _Nullable info) {
                if (error) {
                    NSLog(@"fetch thumbnail image error %@", error);
                }
                NSLog(@"fetch thumbnail image progress %g", progress);
                progressHandler ? progressHandler(progress, error, stop, info) : nil;
            } resultHandler:^(UIImage *image, NSDictionary *info) {
                    resultHandler ? resultHandler(image) : nil;
            }];
            break;
        }
        case HQLPhotoModelMediaTypeCameraPhoto: { // 自己拍的照片
            resultHandler ? resultHandler(self.cameraPhoto) : nil;
            break;
        }
        case HQLPhotoModelMediaTypeCameraVideo: { // 自己拍的video
            resultHandler ? resultHandler(defaultImage) : nil;
            break;
        }
        case HQLPhotoModelMediaTypeAudio: {
            resultHandler ? resultHandler(defaultImage) : nil;
            break;
        }
        case HQLPhotoModelMediaTypeUnKnow: {
            resultHandler ? resultHandler(defaultImage) : nil;
            break;
        }
    }
}

@end
