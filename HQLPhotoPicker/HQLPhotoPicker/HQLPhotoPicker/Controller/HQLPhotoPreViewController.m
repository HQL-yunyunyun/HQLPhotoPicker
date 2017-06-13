//
//  HQLPhotoPreViewController.m
//  HQLPhotoPicker
//
//  Created by weplus on 2017/6/7.
//  Copyright © 2017年 weplus. All rights reserved.
//

#import "HQLPhotoPreViewController.h"

#import "HQLPhotoPreviewView.h"

#import "HQLPhotoModel.h"

@interface HQLPhotoPreViewController ()

@property (strong, nonatomic) UIImageView *imageView;

@end

@implementation HQLPhotoPreViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self.view setBackgroundColor:[UIColor whiteColor]];
    self.automaticallyAdjustsScrollViewInsets = NO;
}

#pragma mark - setter

- (void)setModel:(HQLPhotoModel *)model {
    _model = model;
    
    HQLPhotoPreviewView *previewView = [[HQLPhotoPreviewView alloc] initWithFrame:self.view.bounds];
    [self.view addSubview:previewView];
    
    switch (model.mediaType) {
        case HQLPhotoModelMediaTypePhoto:
        case HQLPhotoModelMediaTypeCameraPhoto: {
//            [model requestHighDefinitionImageWithProgressHandler:^(double progress, NSError * _Nullable error, BOOL * _Nonnull stop, NSDictionary * _Nullable info) {
//                
//            } resultHandler:^(UIImage *highDefinitionImage, NSString *error) {
//                previewView.photo = highDefinitionImage;
//            }];
            [model requestOriginalImageWithProgressHandler:^(double progress, NSError * _Nullable error, BOOL * _Nonnull stop, NSDictionary * _Nullable info) {
                
            } resultHandler:^(UIImage *originalImage, NSString *error) {
                previewView.photo = originalImage;
            }];
            break;
        }
        case HQLPhotoModelMediaTypePhotoGif: {
            [model requestOriginalImageDataWithProgressHandler:^(double progress, NSError * _Nullable error, BOOL * _Nonnull stop, NSDictionary * _Nullable info) {
                
            } resultHandler:^(NSData *imageData, NSString *byteString, NSString *error) {
                previewView.gifData = imageData;
            }];
            break;
        }
        case HQLPhotoModelMediaTypeLivePhoto: {
            [model requestLivePhotoWithProgressHandler:^(double progress, NSError * _Nullable error, BOOL * _Nonnull stop, NSDictionary * _Nullable info) {
                
            } resultHandler:^(PHLivePhoto *livePhoto, NSString *error) {
                previewView.livePhoto = livePhoto;
            }];
            break;
        }
        case HQLPhotoModelMediaTypeVideo:
        case HQLPhotoModelMediaTypeCameraVideo: {
            [model requestPlayerItemWithProgressHandler:^(double progress, NSError * _Nullable error, BOOL * _Nonnull stop, NSDictionary * _Nullable info) {
                
            } resultHandler:^(AVPlayerItem *playerItem, NSString *error) {
                previewView.playItem = playerItem;
            }];
            break;
        }
        case HQLPhotoModelMediaTypeAudio: { break; }
        case HQLPhotoModelMediaTypeUnKnow: { break; }
    }
}

#pragma mark - getter

- (UIImageView *)imageView {
    if (!_imageView) {
        _imageView = [[UIImageView alloc] initWithFrame:self.view.bounds];
        
        [self.view addSubview:_imageView];
    }
    return _imageView;
}

@end
