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
@property (strong, nonatomic) UIActivityIndicatorView *activityIndicatorView; // 显示器

@property (strong, nonatomic) UIImageView *thumbnailView;

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

- (void)layoutSubviews {
    [super layoutSubviews];
    [self updateFrame];
}

- (void)dealloc {
    NSLog(@"dealloc ---> %@", NSStringFromClass([self class]));
}

#pragma mark - event

- (void)viewConfig {
    [self setBackgroundColor:[UIColor blackColor]];
    [self scrollView];
    [self thumbnailView];
    
    [self photoView];
    [self gifView];
    [self videoView];
    [self livePhotoView];
    [self activityIndicatorView];
}

- (void)updateFrame {
    
    // 设置frame
    CGSize contentSize = CGSizeZero;
    CGSize originSize = CGSizeZero;
    if (self.photo) {
        self.photoView.size = [self getRightSizeWithSize:self.photo.size];
        self.photoView.centerX = self.width * 0.5;
        self.photoView.centerY = self.height * 0.5;
        contentSize = self.photoView.size;
        originSize = self.photo.size;
    }
    if (self.gifData) {
        self.gifView.size = [self getRightSizeWithSize:[UIImage animatedGIFWithData:self.gifData].size];
        self.gifView.centerX = self.width * 0.5;
        self.gifView.centerY = self.height * 0.5;
        contentSize = self.gifView.size;
        originSize = self.gifView.image.size;
    }
    if (self.playerItem) {
        self.videoView.frame = self.bounds;
        contentSize = self.videoView.size;
    }
    if (self.livePhoto) {
        self.livePhotoView.size = [self getRightSizeWithSize:self.livePhoto.size];
        self.livePhotoView.centerX = self.width * 0.5;
        self.livePhotoView.centerY = self.height * 0.5;
        contentSize = self.livePhotoView.size;
        originSize = self.livePhoto.size;
    }
    if (self.thumbnail) {
        self.thumbnailView.size = [self getRightSizeWithSize:self.thumbnail.size];
        self.thumbnailView.centerX = self.width * 0.5;
        self.thumbnailView.centerY = self.height * 0.5;
        contentSize = self.thumbnailView.size;
        originSize = self.thumbnail.size;
    }
    
    self.scrollView.maximumZoomScale = [self getRightScaleWithOriginSize:originSize];
    
    self.scrollView.frame = self.bounds;
    self.scrollView.contentSize = contentSize;
    
    self.activityIndicatorView.centerX = self.width * 0.5;
    self.activityIndicatorView.centerY = self.height * 0.5;
}

- (CGFloat)getRightScaleWithOriginSize:(CGSize)originSize {
    
    if (self.playerItem) {
        return 1;
    }
    
    CGSize viewSize = [self getRightSizeWithSize:originSize];
    CGFloat scale = originSize.width / viewSize.width;
    if (viewSize.width > viewSize.height) { // 优先满足小的一方 --- height
        scale = self.photo.size.height / self.photoView.height;
    }
    if (scale > kDefaultZoomScale) {
        NSInteger intScale = scale + 1;
        scale = intScale;
    } else {
        scale = kDefaultZoomScale;
    }
    return scale;
}

- (UIView *)currentContentView {
    if (self.photo) {
        return self.photoView;
    }
    if (self.gifData) {
        return self.gifView;
    }
    if (self.livePhoto) {
        return self.livePhotoView;
    }
    if (self.thumbnail) {
        return self.thumbnailView;
    }
    return nil;
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

// 重置属性
- (void)resetProperty { // 重置所有参数
    [self.scrollView.subviews enumerateObjectsUsingBlock:^(__kindof UIView * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        [obj setHidden:YES];
    }];
    self.photo = nil;
    self.photoView.image = nil;
    
    self.gifData = nil;
    self.gifView.image = nil;

    self.playerItem = nil;
    self.videoView.playerItem = nil;
    
    self.livePhoto = nil;
    self.livePhotoView.livePhoto = nil;
    
//    self.thumbnail = nil;
//    self.thumbnailView.image = nil;
//    
//    [self setVideoViewThumbnail:nil];
    
    [self activityIndicatorViewAnimate:NO];
}

- (void)resetViewStatus { // 重置状态
    // 取消放大缩小状态
    self.scrollView.zoomScale = 1.0;
    
    if (self.playerItem) {
        [self.videoView stopVideo];
    }
    if (self.livePhoto) {
        [self.livePhotoView stopPlayback];
    }
    
    [self updateFrame];
}

- (void)videoViewHideControlView {
    if (self.playerItem) {
        [self.videoView controlViewHideAnimate];
    }
}

- (void)videoViewShowControlView {
    if (self.playerItem) {
        [self.videoView controlViewShowAnimate];
    }
}

- (void)activityIndicatorViewAnimate:(BOOL)yesOrNo {
    if (yesOrNo) {
//        [self resetProperty];
        [self.activityIndicatorView setHidden:NO];
        [self.activityIndicatorView startAnimating];
    } else {
        [self.activityIndicatorView stopAnimating];
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
    
    [tap requireGestureRecognizerToFail:doubleTap]; // 当doubleTap不起效的时候才会调用tap
}

// 单击
- (void)tapGestureMethod:(UITapGestureRecognizer *)gesture {
    if ([self.delegate respondsToSelector:@selector(photoPreviewViewDidClick:)]) {
        [self.delegate photoPreviewViewDidClick:self];
    }
}

// 双击
- (void)doubleTapGestureMethod:(UITapGestureRecognizer *)gesture {
    
    UIView *targetView = [self currentContentView];
    if (targetView) {
        CGFloat scale = self.width / targetView.width;
        if (targetView.height <= targetView.width) {
            scale = self.height / targetView.height;
        }
        
        [self.scrollView setZoomScale:scale animated:YES];
    }
}

#pragma mark - scroll view delegate

- (UIView *)viewForZoomingInScrollView:(UIScrollView *)scrollView {
    return [self currentContentView];
}

- (void)scrollViewDidEndZooming:(UIScrollView *)scrollView withView:(UIView *)view atScale:(CGFloat)scale {
    // 根据scale来确定位置
    [UIView animateWithDuration:0.3f animations:^{
        CGFloat width = scrollView.contentSize.width >= self.width ? scrollView.contentSize.width : self.width;
        CGFloat height = scrollView.contentSize.height >= self.height ? scrollView.contentSize.height : self.height;

        view.centerX = width * 0.5;
        view.centerY = height * 0.5;
        
    } completion:^(BOOL finished) {
        
    }];
}

- (void)scrollViewWillBeginZooming:(UIScrollView *)scrollView withView:(UIView *)view {

}

- (void)scrollViewDidZoom:(UIScrollView *)scrollView {
}

#pragma mark - live photo delegate

- (void)livePhotoView:(PHLivePhotoView *)livePhotoView didEndPlaybackWithStyle:(PHLivePhotoViewPlaybackStyle)playbackStyle {
    
}

#pragma mark - setter

- (void)setPhoto:(UIImage *)photo {
    if (!photo) {
        _photo = nil;
        return;
    }
    [self resetProperty];
    _photo = photo;
    self.photoView.image = photo;
    [self.photoView setHidden:NO];
    
    [self updateFrame];
}

- (void)setGifData:(NSData *)gifData {
    if (!gifData) {
        _gifData = nil;
        return;
    }
    [self resetProperty];
    _gifData = gifData;
    self.gifView.image = [UIImage imageWithData:gifData];
    [self.gifView setHidden:NO];
    
    [self updateFrame];
}

- (void)setPlayerItem:(AVPlayerItem *)playerItem {
    if (!playerItem) {
        _playerItem = nil;
        return;
    }
    [self resetProperty];
    _playerItem = playerItem;
    self.videoView.playerItem = playerItem;
    [self.videoView setHidden:NO];
    
    [self updateFrame];
}

- (void)setLivePhoto:(PHLivePhoto *)livePhoto {
    if (!livePhoto) {
        _livePhoto = nil;
        return;
    }
    [self resetProperty];
    _livePhoto = livePhoto;
    self.livePhotoView.livePhoto = livePhoto;
    [self.livePhotoView setHidden:NO];
    
    [self updateFrame];
}

- (void)setThumbnail:(UIImage *)thumbnail {
    if (!thumbnail) {
        _thumbnail = nil;
        return;
    }
//    [self resetProperty];
    
    [self.scrollView.subviews enumerateObjectsUsingBlock:^(__kindof UIView * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        if (obj != self.activityIndicatorView) {
            [obj setHidden:YES];
        }
    }];
    _thumbnail = thumbnail;
    self.thumbnailView.image = thumbnail;
    [self.thumbnailView setHidden:NO];
    
    [self updateFrame];
}

- (void)setVideoViewThumbnail:(UIImage *)thumbnail {
//    [self resetProperty];
    
    [self.scrollView.subviews enumerateObjectsUsingBlock:^(__kindof UIView * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        if (obj != self.activityIndicatorView) {
            [obj setHidden:YES];
        }
    }];
    self.videoView.frame = self.bounds;
    [self.videoView setHidden:NO];
    [self.videoView setThumbnail:thumbnail];
}

#pragma mark - getter

- (UIImage *)videoViewThumbnail {
    return self.videoView.thumbnail;
}

- (UIImageView *)thumbnailView {
    if (!_thumbnailView) {
        _thumbnailView = [[UIImageView alloc] initWithFrame:self.bounds];
        [_thumbnailView setHidden:YES];
        
        [self.scrollView insertSubview:_thumbnailView atIndex:0];
    }
    return _thumbnailView;
}

- (UIActivityIndicatorView *)activityIndicatorView {
    if (!_activityIndicatorView) {
        _activityIndicatorView = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhiteLarge];
        _activityIndicatorView.hidesWhenStopped = YES;
        
        [self.scrollView addSubview:_activityIndicatorView];
    }
    return _activityIndicatorView;
}

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
        _photoView.userInteractionEnabled = YES;
        
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
        _gifView.userInteractionEnabled = YES;
        
        [self.scrollView addSubview:_gifView];
    }
    return _gifView;
}

@end
