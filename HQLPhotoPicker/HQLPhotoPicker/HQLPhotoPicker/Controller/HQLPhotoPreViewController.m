//
//  HQLPhotoPreViewController.m
//  HQLPhotoPicker
//
//  Created by weplus on 2017/6/7.
//  Copyright © 2017年 weplus. All rights reserved.
//

#import "HQLPhotoPreViewController.h"

#import "HQLPhotoPreviewView.h"
#import "HQLPreviewView.h"
#import "HQLPhotoModel.h"
#import "HQLPhotoAlbumModel.h"

@interface HQLPhotoPreViewController () <HQLPreviewViewDelegate, HQLPhotoPreviewViewDelegate>

@property (strong, nonatomic) HQLPreviewView *previewView;

//@property (assign, nonatomic) BOOL 

@end

@implementation HQLPhotoPreViewController

#pragma mark - life cycle

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self.view setBackgroundColor:[UIColor whiteColor]];
    self.automaticallyAdjustsScrollViewInsets = NO;
}

- (void)dealloc {
    NSLog(@"dealloc ---> %@", NSStringFromClass([self class]));
}

#pragma mark - event

- (void)setCurrentIndex:(NSUInteger)currentIndex animated:(BOOL)animated {
    [self.previewView setCurrentIndex:currentIndex animated:animated];
}

#pragma mark - photo preview view delegate

- (void)photoPreviewViewDidClick:(HQLPhotoPreviewView *)previewView {
    [self.navigationController.navigationBar setHidden:!self.navigationController.navigationBar.isHidden];
    if (self.navigationController.navigationBar.isHidden) {
        [previewView videoViewHideControlView];
    } else {
        [previewView videoViewShowControlView];
    }
}

#pragma mark - preview View delegate

- (NSUInteger)numberOfPhotos:(HQLPreviewView *)previewView {
    return self.model.count;
}

- (void)previewView:(HQLPreviewView *)previewView renderPhotoPreviewView:(HQLPhotoPreviewView *)photoPreviewView atIndex:(NSUInteger)index {
    HQLPhotoModel *model = self.model.photoArray[index];
    [photoPreviewView activityIndicatorViewAnimate:YES];
    photoPreviewView.delegate = self;
    
    switch (model.mediaType) {
        case HQLPhotoModelMediaTypePhoto:
        case HQLPhotoModelMediaTypeCameraPhoto: {
            [model requestHighDefinitionImageWithProgressHandler:^(double progress, NSError * _Nullable error, BOOL * _Nonnull stop, NSDictionary * _Nullable info) {
                
            } resultHandler:^(UIImage *highDefinitionImage, NSString *error) {
                photoPreviewView.photo = highDefinitionImage;
            }];
            break;
        }
        case HQLPhotoModelMediaTypePhotoGif: {
            [model requestOriginalImageDataWithProgressHandler:^(double progress, NSError * _Nullable error, BOOL * _Nonnull stop, NSDictionary * _Nullable info) {
                
            } resultHandler:^(NSData *imageData, NSString *byteString, NSString *error) {
                photoPreviewView.gifData = imageData;
            }];
            break;
        }
        case HQLPhotoModelMediaTypeLivePhoto: {
            [model requestLivePhotoWithProgressHandler:^(double progress, NSError * _Nullable error, BOOL * _Nonnull stop, NSDictionary * _Nullable info) {
                
            } resultHandler:^(PHLivePhoto *livePhoto, NSString *error) {
                photoPreviewView.livePhoto = livePhoto;
            }];
            break;
        }
        case HQLPhotoModelMediaTypeVideo:
        case HQLPhotoModelMediaTypeCameraVideo: {
            [model requestPlayerItemWithProgressHandler:^(double progress, NSError * _Nullable error, BOOL * _Nonnull stop, NSDictionary * _Nullable info) {
                
            } resultHandler:^(AVPlayerItem *playerItem, NSString *error) {
                photoPreviewView.playerItem = playerItem;
                NSLog(@"playerItem %@", playerItem);
            }];
            break;
        }
        case HQLPhotoModelMediaTypeAudio: { break; }
        case HQLPhotoModelMediaTypeUnKnow: { break; }
    }
}

- (HQLPhotoModelMediaType)previewView:(HQLPreviewView *)previewView assetTypeAtIndex:(NSUInteger)index {
    HQLPhotoModel *photoModel = self.model.photoArray[index];
    return photoModel.mediaType;
}

#pragma mark - setter

- (void)setModel:(HQLPhotoAlbumModel *)model {
    _model = model;
    [self.previewView reloadData];
}

#pragma mark - getter

- (HQLPreviewView *)previewView {
    if (!_previewView) {
        _previewView = [[HQLPreviewView alloc] initWithFrame:self.view.bounds];
        _previewView.delegate = self;
        
        [self.view addSubview:_previewView];
    }
    return _previewView;
}

@end
