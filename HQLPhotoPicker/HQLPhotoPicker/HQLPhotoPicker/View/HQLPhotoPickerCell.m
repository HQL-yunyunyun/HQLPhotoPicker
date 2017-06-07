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
    [photoModel requestThumbnailImage:^(UIImage *thumbnail, NSString *errorString) {
        weakSelf.imageView.image = thumbnail;
    }];
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
