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

#import "UIView+Frame.h"

#define kIconSize 30
#define kCheckButtonSize 20

@interface HQLPhotoPickerCell ()

@property (strong, nonatomic) UIImageView *imageView;

@property (strong, nonatomic) UIImageView *typeIcon; // 类型的icon
@property (strong, nonatomic) UILabel *videoDurationLabel; // 视频时长

@property (strong, nonatomic) UIButton *checkButton;

@property (strong, nonatomic) UIView *animateView; // 动画的View

@end

@implementation HQLPhotoPickerCell

#pragma mark - life cycle

- (void)layoutSubviews {
    [super layoutSubviews];
    
    [self updateFrame];
}

#pragma mark - event

- (void)viewConfig {
    [self imageView];
    [self animateView];
}

- (void)updateFrame {
    [self.imageView setFrame:self.bounds];
    
    [self.animateView setFrame:self.bounds];
    
    self.animateView.layer.borderWidth = self.width * 0.05;
    
    self.typeIcon.y = self.height - kIconSize;
    
    self.videoDurationLabel.x = self.width - self.videoDurationLabel.width;
    self.videoDurationLabel.centerY = self.typeIcon.centerY;
    
    self.checkButton.x = self.width - kCheckButtonSize;
    self.checkButton.y = 0;
}

- (void)checkButtonDidClick:(UIButton *)button {
    if ([self.delegate respondsToSelector:@selector(photoPickerCell:didClickCheckButton:)]) {
        [self.delegate photoPickerCell:self didClickCheckButton:button];
    }
}

- (void)setSelectedAnimation:(BOOL)isSelected animated:(BOOL)animated {
    if (!self.isShowSelectedBorder) {
        return;
    }
    NSTimeInterval time = animated ? .3 : 0;
    CGFloat alpha = isSelected ? 1 : 0;
    [UIView animateWithDuration:time animations:^{
        [self.animateView setAlpha:alpha];
    }];
}

#pragma mark - setter

- (void)setIsShowCheckButton:(BOOL)isShowCheckButton {
    _isShowCheckButton = isShowCheckButton;
    [self.checkButton setHidden:!isShowCheckButton];
}

- (void)setPhotoModel:(HQLPhotoModel *)photoModel {
    _photoModel = photoModel;
    HQLWeakSelf; // 都是一样的
    [photoModel requestThumbnailImage:^(UIImage *thumbnail, NSString *errorString) {
        weakSelf.imageView.image = thumbnail;
    }];
    
    [self.checkButton setSelected:photoModel.isSelected];
    [self setSelectedAnimation:photoModel.isSelected animated:NO];
    // 都设置成隐藏
    [self.subviews enumerateObjectsUsingBlock:^(__kindof UIView * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        [obj setHidden:YES];
    }];
    [self.imageView setHidden:NO];
    [self.animateView setHidden:NO];
    [self.checkButton setHidden:!self.isShowCheckButton];
    
    // 根据媒体类型 创建UI
    UIImage *icon = nil;
    switch (photoModel.mediaType) {
        case HQLPhotoModelMediaTypeVideo:
        case HQLPhotoModelMediaTypeCameraVideo: {
            icon = [UIImage imageWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"video_icon" ofType:@"png"]];
            [self.videoDurationLabel setText:photoModel.durationTime];
            [self.videoDurationLabel sizeToFit];
            [self.videoDurationLabel setHidden:NO];
            break;
        }
        case HQLPhotoModelMediaTypePhotoGif: {
            icon = [UIImage imageWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"gif_icon" ofType:@"png"]];
            break;
        }
        case HQLPhotoModelMediaTypeLivePhoto: {
            icon = [UIImage imageWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"livePhoto_icon" ofType:@"png"]];
            break;
        }
        case HQLPhotoModelMediaTypeAudio: { break; }
        case HQLPhotoModelMediaTypeUnKnow: { break; }
        case HQLPhotoModelMediaTypeCameraPhoto: { break; }
        case HQLPhotoModelMediaTypePhoto: { break; }
    }
    if (icon) {
        [self.typeIcon setHidden:NO];
        self.typeIcon.image = icon;
    }
    [self updateFrame];
}

#pragma mark - getter

- (UIView *)animateView {
    if (!_animateView) {
        _animateView = [[UIView alloc] initWithFrame:self.bounds];
        [_animateView setBackgroundColor:[UIColor clearColor]];
        _animateView.layer.borderColor = [UIColor colorWithRed:0 green:(211 / 255.0) blue:(221 / 255.0) alpha:1].CGColor;
        _animateView.alpha = 0;
        
        [self addSubview:_animateView];
    }
    return _animateView;
}

- (UIImageView *)imageView {
    if (!_imageView) {
        _imageView = [[UIImageView alloc] initWithFrame:self.bounds];
        [self insertSubview:_imageView atIndex:0];
    }
    return _imageView;
}

- (UIImageView *)typeIcon {
    if (!_typeIcon) {
        _typeIcon = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, kIconSize, kIconSize)];
        [self addSubview:_typeIcon];
    }
    return _typeIcon;
}

- (UILabel *)videoDurationLabel {
    if (!_videoDurationLabel) {
        _videoDurationLabel = [[UILabel alloc] init];
        [_videoDurationLabel setFont:[UIFont systemFontOfSize:10]];
        [_videoDurationLabel setTextColor:[UIColor whiteColor]];
        
        [self addSubview:_videoDurationLabel];
    }
    return _videoDurationLabel;
}

- (UIButton *)checkButton {
    if (!_checkButton) {
        _checkButton = [UIButton buttonWithType:UIButtonTypeCustom];
        [_checkButton setFrame:CGRectMake(0, 0, kCheckButtonSize, kCheckButtonSize)];
        [_checkButton setImage:[UIImage imageWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"checkButton_normal" ofType:@"png"]] forState:UIControlStateNormal];
        [_checkButton setImage:[UIImage imageWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"checkButton_selected" ofType:@"png"]] forState:UIControlStateSelected];
        
        [_checkButton addTarget:self action:@selector(checkButtonDidClick:) forControlEvents:UIControlEventTouchUpInside];
        [self addSubview:_checkButton];
    }
    return _checkButton;
}

@end
