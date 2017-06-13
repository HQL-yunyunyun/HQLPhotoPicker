//
//  HQLPhotoPreviewView.m
//  HQLPhotoPicker
//
//  Created by weplus on 2017/6/8.
//  Copyright © 2017年 weplus. All rights reserved.
//

#import "HQLPhotoPreviewView.h"
#import "HQLVideoPreViewView.h"
#import "UIImage+HQLExtension.h"
#import "UIView+Frame.h"

#define kDefaultZoomScale 3.0

#import <PhotosUI/PhotosUI.h>

@interface HQLPhotoPreviewView () <UIScrollViewDelegate, PHLivePhotoViewDelegate>

@property (strong, nonatomic) UIScrollView *scrollView;
@property (strong, nonatomic) UIImageView *photoView; // 显示图片
@property (strong, nonatomic) PHLivePhotoView *livePhotoView; // 显示livePhoto
@property (strong, nonatomic) HQLVideoPreViewView *videoView; // 显示video
@property (strong, nonatomic) UIImageView *gifView; // 显示GIFView

@property (assign, nonatomic) BOOL livePhotoViewIsAnimating;

@end

@implementation HQLPhotoPreviewView

#pragma mark - initialize method

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

- (void)dealloc {
    NSLog(@"dealloc ---> %@", NSStringFromClass([self class]));
}

#pragma mark - event

- (void)viewConfig {
    [self setBackgroundColor:[UIColor blackColor]];
    [self scrollView];
}

- (void)updateFrame {
    self.scrollView.maximumZoomScale = 0.0;
    // 设置frame
    CGSize contentSize = CGSizeZero;
    if (self.photo) {
        self.photoView.size = [self getRightSizeWithSize:self.photo.size];
        self.photoView.centerX = self.width * 0.5;
        self.photoView.centerY = self.height * 0.5;
        contentSize = self.photoView.size;
        
        self.scrollView.maximumZoomScale = kDefaultZoomScale;
        CGFloat scale = self.photo.size.width / self.photoView.width;
        if (self.photoView.width > self.photoView.height) { // 优先满足小的一方 --- height
            scale = self.photo.size.height / self.photoView.height;
        }
        if (scale > kDefaultZoomScale) {
            NSInteger intScale = scale + 1;
            self.scrollView.maximumZoomScale = intScale;
        }
    }
    if (self.gifData) {
        self.gifView.size = [self getRightSizeWithSize:[UIImage animatedGIFWithData:self.gifData].size];
        self.gifView.centerX = self.width * 0.5;
        self.gifView.centerY = self.height * 0.5;
        contentSize = self.gifView.size;
    }
    if (self.playItem) {
        self.videoView.frame = self.bounds;
        contentSize = self.videoView.size;
    }
    if (self.livePhoto) {
        self.livePhotoView.size = [self getRightSizeWithSize:self.livePhoto.size];
        self.livePhotoView.centerX = self.width * 0.5;
        self.livePhotoView.centerY = self.height * 0.5;
        contentSize = self.livePhotoView.size;
    }
    
    self.scrollView.contentSize = contentSize;
}

// 根据目标size来获取相应的size
- (CGSize)getRightSizeWithSize:(CGSize)targetSize {
    // 先以self.height为标准 --- 计算出相同比例的宽度，若宽度超出self.width, 就以self.width 为标准
    CGFloat height = self.height;
    CGFloat width = (height * targetSize.width) / targetSize.height;
    if (width > self.width) {
        width = self.width;
        height = (width * targetSize.height) / targetSize.width;
    }
    return CGSizeMake(width, height);
}

// 重置属性 --- index : 0 - 全部重置 / 1 - 不重置photo / 2 - 不重置GIF / 3 - 不重置playItem / 4 - 不重置livePhoto
- (void)resetPropertyWithOut:(NSInteger)index { // 重置所有参数
    [self.scrollView.subviews makeObjectsPerformSelector:@selector(setHidden:) withObject:[NSNumber numberWithBool:YES]];
    if (index != 1) {
        self.photo = nil;
        self.photoView.image = nil;
    }
    if (index != 2) {
        self.gifData = nil;
        self.gifView.image = nil;
    }
    if (index != 3) {
        self.playItem = nil;
        self.videoView.playerItem = nil;
    }
    if (index != 4) {
        self.livePhoto = nil;
        self.livePhotoView.livePhoto = nil;
    }
}

#pragma mark - gesture method

// 创建手势
- (void)createGesture {
    // 双击
    UITapGestureRecognizer *doubleTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(doubleTapGestureMethod:)];
    doubleTap.numberOfTapsRequired = 2;
    [self.scrollView addGestureRecognizer:doubleTap];
    // 单击
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapGestureMethod:)];
    tap.numberOfTapsRequired = 1;
    [self.scrollView addGestureRecognizer:tap];
    // 长按
    UILongPressGestureRecognizer *longPress = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(longPressGestureMethod:)];
    longPress.minimumPressDuration = 3.0;
    [self.scrollView addGestureRecognizer:longPress];
}

// 单击
- (void)tapGestureMethod:(UITapGestureRecognizer *)gesture {
    if ([self.delegate respondsToSelector:@selector(photoPreviewViewDidClick:)]) {
        [self.delegate photoPreviewViewDidClick:self];
    }
}

// 双击
- (void)doubleTapGestureMethod:(UITapGestureRecognizer *)gesture {
    if (self.photo) { // 只适用于photo中
        CGFloat scale = self.photo.size.width / self.photoView.width;
        if (self.photoView.width > self.photoView.height) { // 优先满足小的一方 --- height
            scale = self.photo.size.height / self.photoView.height;
        }
        [self.scrollView setZoomScale:scale animated:YES];
    }
}

// 长按
- (void)longPressGestureMethod:(UILongPressGestureRecognizer *)gesture {
    if (self.livePhoto) { // 播放
        if (!self.livePhotoViewIsAnimating) {
            self.livePhotoViewIsAnimating = YES;
            [self.livePhotoView startPlaybackWithStyle:PHLivePhotoViewPlaybackStyleFull];
        }
    }
}

#pragma mark - live photo delegate

- (void)livePhotoView:(PHLivePhotoView *)livePhotoView didEndPlaybackWithStyle:(PHLivePhotoViewPlaybackStyle)playbackStyle {
    self.livePhotoViewIsAnimating = NO;
}

#pragma mark - setter

- (void)setPhoto:(UIImage *)photo {
    [self resetPropertyWithOut:1];
    _photo = photo;
    self.photoView.image = photo;
    
    [self updateFrame];
}

- (void)setGifData:(NSData *)gifData {
    [self resetPropertyWithOut:2];
    _gifData = gifData;
    self.gifView.image = [UIImage imageWithData:gifData];
    
    [self updateFrame];
}

- (void)setPlayItem:(AVPlayerItem *)playItem {
    [self resetPropertyWithOut:3];
    _playItem = playItem;
    self.videoView.playerItem = playItem;
    
    [self updateFrame];
}

- (void)setLivePhoto:(PHLivePhoto *)livePhoto {
    [self resetPropertyWithOut:4];
    _livePhoto = livePhoto;
    self.livePhotoView.livePhoto = livePhoto;
    
    [self updateFrame];
}

#pragma mark - getter

- (UIScrollView *)scrollView {
    if (!_scrollView) {
        _scrollView = [[UIScrollView alloc] initWithFrame:self.bounds];
        _scrollView.delegate = self;
        _scrollView.minimumZoomScale = 1.0;
        _scrollView.backgroundColor = [UIColor blackColor];
        
        [self createGesture];
        [self addSubview:_scrollView];
    }
    return _scrollView;
}

- (UIImageView *)photoView {
    if (!_photoView) {
        _photoView = [[UIImageView alloc] initWithFrame:self.bounds];
        [_photoView setHidden:YES];
        
        [self.scrollView addSubview:_photoView];
    }
    return _photoView;
}

- (PHLivePhotoView *)livePhotoView {
    if (!_livePhotoView) {
        _livePhotoView = [[PHLivePhotoView alloc] initWithFrame:self.bounds];
        [_livePhotoView  setHidden:YES];
        _livePhotoView.delegate = self;
        
        [self.scrollView addSubview:_livePhotoView];
    }
    return _livePhotoView;
}

- (HQLVideoPreViewView *)videoView {
    if (!_videoView) {
        _videoView = [[HQLVideoPreViewView alloc] initWithFrame:self.bounds];
        [_videoView setHidden:YES];
        
        [self.scrollView addSubview:_videoView];
    }
    return _videoView;
}

- (UIImageView *)gifView {
    if (!_gifView) {
        _gifView = [[UIImageView alloc] initWithFrame:self.bounds];
        [_gifView setHidden:YES];
        
        [self.scrollView addSubview:_gifView];
    }
    return _gifView;
}

@end
