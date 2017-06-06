//
//  HQLPhotoPickerCell.m
//  HQLPhotoPicker
//
//  Created by weplus on 2017/6/6.
//  Copyright © 2017年 weplus. All rights reserved.
//

#import "HQLPhotoPickerCell.h"
#import "HQLPhotoModel.h"
#import "HQLPhotoManager.h"

@interface HQLPhotoPickerCell ()

@property (strong, nonatomic) UIImageView *imageView;

@end

@implementation HQLPhotoPickerCell

#pragma mark - life cycle

- (void)layoutSubviews {
    [super layoutSubviews];
    [self.imageView setFrame:self.bounds];
}

#pragma mark - event

#pragma mark - setter

- (void)setPhotoModel:(HQLPhotoModel *)photoModel {
    _photoModel = photoModel;
    HQLWeakSelf;
    
    if (photoModel.thumbnailImage) {
        self.imageView.image = photoModel.thumbnailImage;
    } else {
        self.imageView.image = [UIImage imageWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"defaultImage" ofType:@"png"]];
        [[HQLPhotoManager shareManager] fetchImageWithPHAsset:photoModel.asset photoQuality:HQLPhotoQualityThumbnails photoSize:self.frame.size progressHandler:^(double progress, NSError * _Nullable error, BOOL * _Nonnull stop, NSDictionary * _Nullable info) {
            NSLog(@"progress : %g", progress);
            if (error) {
                NSLog(@"progress error : %@", error);
            }
        } resultHandler:^(UIImage *image, NSDictionary *info) {
            weakSelf.imageView.image = image;
            photoModel.thumbnailImage = image; // 记录缩略图
        }];
    }
}

#pragma mark - getter

- (UIImageView *)imageView {
    if (!_imageView) {
        _imageView = [[UIImageView alloc] initWithFrame:self.bounds];
        [self addSubview:_imageView];
    }
    return _imageView;
}

@end
