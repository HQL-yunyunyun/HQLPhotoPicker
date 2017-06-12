//
//  HQLPhotoPreViewController.m
//  HQLPhotoPicker
//
//  Created by weplus on 2017/6/7.
//  Copyright © 2017年 weplus. All rights reserved.
//

#import "HQLPhotoPreViewController.h"

#import "HQLVideoPreViewView.h"

#import "HQLPhotoModel.h"

@interface HQLPhotoPreViewController ()

@property (strong, nonatomic) UIImageView *imageView;

@end

@implementation HQLPhotoPreViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self.view setBackgroundColor:[UIColor whiteColor]];
}

#pragma mark - setter

- (void)setModel:(HQLPhotoModel *)model {
    _model = model;
    
    if (model.mediaType == HQLPhotoModelMediaTypeVideo) {
        
        HQLVideoPreViewView *view = [[HQLVideoPreViewView alloc] initWithFrame:self.view.bounds];
        [self.view addSubview:view];
        [model requestPlayerItemWithProgressHandler:^(double progress, NSError * _Nullable error, BOOL * _Nonnull stop, NSDictionary * _Nullable info) {
            
        } resultHandler:^(AVPlayerItem *playerItem, NSString *error) {
            view.playerItem = playerItem;
        }];
        
    } else {
        [model requestOriginalImageWithProgressHandler:^(double progress, NSError * _Nullable error, BOOL * _Nonnull stop, NSDictionary * _Nullable info) {
            
        } resultHandler:^(UIImage *originalImage, NSString *errorString) {
            self.imageView.image = originalImage;
        }];
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
