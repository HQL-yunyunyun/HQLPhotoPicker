//
//  HQLTakePhotoCell.m
//  HQLPhotoPicker
//
//  Created by weplus on 2017/6/19.
//  Copyright © 2017年 weplus. All rights reserved.
//

#import "HQLTakePhotoCell.h"
#import "UIView+Frame.h"

@interface HQLTakePhotoCell ()

@property (strong, nonatomic) UIImageView *imageView;

@end

@implementation HQLTakePhotoCell

- (instancetype)init {
    if (self = [super init]) {
        [self viewConfig];
    }
    return self;
}

- (instancetype)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        [self viewConfig];
    }
    return self;
}

- (void)awakeFromNib {
    [super awakeFromNib];
    [self viewConfig];
}

- (void)layoutSubviews {
    [super layoutSubviews];
    
    self.imageView.centerX = self.width * 0.5;
    self.imageView.centerY = self.height * 0.5;
}

- (void)viewConfig {
    [self imageView];
    [self setBackgroundColor:[UIColor colorWithRed:(101 / 255.0) green:(101 / 255.0) blue:(101 / 255.0) alpha:1]];
}

- (UIImageView *)imageView {
    if (!_imageView) {
        _imageView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 24, 24)];
        _imageView.image = [UIImage imageWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"takePhotoButton" ofType:@"png"]];
        
        [self addSubview:_imageView];
    }
    return _imageView;
}

@end
