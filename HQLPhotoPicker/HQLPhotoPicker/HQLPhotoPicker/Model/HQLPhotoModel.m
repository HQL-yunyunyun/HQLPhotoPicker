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

#define kThumbnailImageSize CGSizeMake(100, 100)
#define kOriginalImageSize CGSizeMake(CGFLOAT_MAX, CGFLOAT_MAX)

@implementation HQLPhotoModel

#pragma mark - event

// 获取缩略图
- (void)requestThumbnailImage:(void (^)(UIImage *, NSString *))completeBlock {
    if (self.thumbnailImage) {
        completeBlock ? completeBlock(self.thumbnailImage, @"") : nil;
    } else {
        HQLWeakSelf;
        [self fetchImageWithTragetSize:kThumbnailImageSize photoQuality:HQLPhotoQualityMedium isCaching:NO progressHandler:nil resultHandler:^(UIImage *image, NSString *errorString) {
            weakSelf.thumbnailImage = image;
            completeBlock ? completeBlock(image, errorString) : nil;
        }];
    }
}

// 获取高清图
- (void)requestHighDefinitionImageWithProgressHandler:(PHAssetImageProgressHandler)progressHandler resultHandler:(void (^)(UIImage *, NSString *))resultHandler {
    
    resultHandler ? resultHandler((self.thumbnailImage ? self.thumbnailImage : nil), @"") : nil;
    [self fetchImageWithTragetSize:kOriginalImageSize photoQuality:HQLPhotoQualityMedium isCaching:YES progressHandler:progressHandler resultHandler:resultHandler];
}

// 获取原图
- (void)requestOriginalImageWithProgressHandler:(PHAssetImageProgressHandler)progressHandler resultHandler:(void (^)(UIImage *, NSString *))resultHandler {
    
    resultHandler ? resultHandler((self.thumbnailImage ? self.thumbnailImage : nil), @"") : nil;
    [self fetchImageWithTragetSize:kOriginalImageSize photoQuality:HQLPhotoQualityLarger isCaching:YES progressHandler:progressHandler resultHandler:resultHandler];
}

// 获取 image data
- (void)requestOriginalImageDataWithProgressHandler:(PHAssetImageProgressHandler)progressHandler resultHandler:(void (^)(NSData *, NSString *, NSString *))resultHandler {
    switch (self.mediaType) {
        case HQLPhotoModelMediaTypePhoto:
        case HQLPhotoModelMediaTypeLivePhoto:
        case HQLPhotoModelMediaTypePhotoGif: {
            [[HQLPhotoManager shareManager] fetchimageDataWithPHAsset:self.asset progressHandler:^(double progress, NSError * _Nullable error, BOOL * _Nonnull stop, NSDictionary * _Nullable info) {
                if (error) {
                    NSLog(@"fetch image data error %@", error);
                }
                NSLog(@"fetch image data progress %g", progress);
                progressHandler ? progressHandler(progress, error, stop, info) : nil;
            } resultHandler:^(NSData *imageData, NSString *dataUTI, UIImageOrientation orientation, NSDictionary *info) {
                NSError *error = info[PHImageErrorKey];
                if (error) {
                    
                }
                resultHandler ? resultHandler(imageData, [HQLPhotoHelper fetchPhotosBytes:@[imageData]], [self getErrorStringWithError:error]) : nil;
            }];
            break;
        }
        case HQLPhotoModelMediaTypeCameraPhoto: {
            NSData *imageData = UIImagePNGRepresentation(self.cameraPhoto);
            if (!imageData) {
                imageData = UIImageJPEGRepresentation(self.cameraPhoto, 1.0);
            }
            resultHandler ? resultHandler(imageData, [HQLPhotoHelper fetchPhotosBytes:@[imageData]], @"") : nil;
        }
        default: { break; }
    }
}

// live photo
- (void)requestLivePhotoWithProgressHandler:(PHAssetImageProgressHandler)progressHandler resultHandler:(void (^)(PHLivePhoto *, NSString *))resultHandler {
    if (self.mediaType == HQLPhotoModelMediaTypeLivePhoto) {
        [[HQLPhotoManager shareManager] fetchLivePhotoWithPHAsset:self.asset photoQuality:HQLPhotoQualityLarger photoSize:kOriginalImageSize progressHandler:^(double progress, NSError * _Nullable error, BOOL * _Nonnull stop, NSDictionary * _Nullable info) {
            if (error) {
                NSLog(@"fetch live photo error %@", error);
            }
            NSLog(@"fetch live photo progress %g", progress);
            progressHandler ? progressHandler(progress, error, stop, info) : nil;
        } resultHandler:^(PHLivePhoto *livePhoto, NSDictionary *info) {
            NSError *error = info[PHImageErrorKey];
            if (error) {
                
            }
            resultHandler ? resultHandler(livePhoto, [self getErrorStringWithError:error]) : nil;
        }];
    }
}

- (void)requestPlayerItemWithProgressHandler:(PHAssetVideoProgressHandler)progressHandler resultHandler:(void (^)(AVPlayerItem *, NSString *))resultHandler {
    if (self.mediaType == HQLPhotoModelMediaTypeVideo) {
        [[HQLPhotoManager shareManager] fetchPlayerItemForVideo:self.asset progressHandler:^(double progress, NSError * _Nullable error, BOOL * _Nonnull stop, NSDictionary * _Nullable info) {
            if (error) {
                NSLog(@"fetch video error : %@", error);
            }
            NSLog(@"fetch viedo progress %g", progress);
            progressHandler ? progressHandler(progress, error, stop, info) : nil;
            
        } resultHandler:^(AVPlayerItem *playerItem, NSDictionary *info) {
            NSError *error = info[PHImageErrorKey];
            if (error) {
                
            }
            NSLog(@"info : %@", info);
            resultHandler ? resultHandler(playerItem, [self getErrorStringWithError:error]) : nil;
        }];
    } else if (self.mediaType == HQLPhotoModelMediaTypeCameraVideo) {
        resultHandler ? resultHandler([AVPlayerItem playerItemWithAsset:self.videoAsset], @"") : nil;
    }
}

- (void)cancelRequest {
    [[HQLPhotoManager shareManager].imageManager cancelImageRequest:self.requestID];
}

#pragma mark - tool

- (void)fetchImageWithTragetSize:(CGSize)targetSize
           photoQuality:(HQLPhotoQuality)photoQuality
           isCaching:(BOOL)isCaching
           progressHandler:(PHAssetImageProgressHandler)progressHandler
           resultHandler:(void(^)(UIImage *image, NSString *error))resultHandler
{
    
    HQLWeakSelf;
    
    UIImage *defaultImage = [UIImage imageWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"defaultImage" ofType:@"png"]];
    switch (self.mediaType) {
        case HQLPhotoModelMediaTypePhoto:
        case HQLPhotoModelMediaTypeVideo:
        case HQLPhotoModelMediaTypePhotoGif:
        case HQLPhotoModelMediaTypeLivePhoto: { // 获取原图
            
            // 在获得图片前先显示默认图片
            [[HQLPhotoManager shareManager] fetchImageWithPHAsset:self.asset photoQuality:photoQuality photoSize:targetSize isCaching:isCaching progressHandler:^(double progress, NSError * _Nullable error, BOOL * _Nonnull stop, NSDictionary * _Nullable info) {
                if (error) {
                    NSLog(@"fetch image error %@", error);
                }
                NSLog(@"fetch image progress %g", progress);
                progressHandler ? progressHandler(progress, error, stop, info) : nil;
            } resultHandler:^(UIImage *image, NSDictionary *info) {
                NSError *error = info[PHImageErrorKey];
                if (error) {
                    image = weakSelf.thumbnailImage ? weakSelf.thumbnailImage : defaultImage;
                }
                resultHandler ? resultHandler(image, [self getErrorStringWithError:error]) : nil;
            }];
            break;
        }
        case HQLPhotoModelMediaTypeCameraPhoto: { // 自己拍的照片
            resultHandler ? resultHandler(self.cameraPhoto, @"") : nil;
            break;
        }
        case HQLPhotoModelMediaTypeCameraVideo: { // 自己拍的video
            resultHandler ? resultHandler(defaultImage, @"") : nil;
            break;
        }
        case HQLPhotoModelMediaTypeAudio: {
            resultHandler ? resultHandler(defaultImage, @"") : nil;
            break;
        }
        case HQLPhotoModelMediaTypeUnKnow: {
            resultHandler ? resultHandler(defaultImage, @"") : nil;
            break;
        }
    }
}

// 获取错误信息
- (NSString *)getErrorStringWithError:(NSError *)error {
    
    NSString *errorString = @"";
    
    if (error) {
        errorString = error.domain;
        if ([errorString containsString:@"cloud"]) { // iCloud 的问题
            errorString = @"iCloud 同步出错";
        }
        
        NSError *underLyingError = error.userInfo[NSUnderlyingErrorKey];
        if (underLyingError) {
            errorString = [errorString stringByAppendingString:underLyingError.localizedDescription];
        }
    }
    
    return errorString;
}

@end
