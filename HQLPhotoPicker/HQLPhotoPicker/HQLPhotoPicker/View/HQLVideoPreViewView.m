//
//  HQLVideoPreViewView.m
//  HQLPhotoPicker
//
//  Created by weplus on 2017/6/8.
//  Copyright © 2017年 weplus. All rights reserved.
//

#import "HQLVideoPreViewView.h"

#import "HQLPhotoHelper.h"

#import "UIView+Frame.h"

#define kControlViewHeight 50
#define kMargin 12

@interface HQLVideoPreViewView ()

@property (strong, nonatomic) AVPlayerLayer *playerLayer; // 播放视频的layer
@property (strong, nonatomic) AVPlayer *player; // 控制器

/* UI */

@property (strong, nonatomic) UIButton *centerPlayButton; // 中间的播放button

@property (strong, nonatomic) UIView *controlView; // 下面的控件的View
@property (strong, nonatomic) UISlider *slider; // 时间线
@property (strong, nonatomic) UIButton *playButton; // 在控制View的button
@property (strong, nonatomic) UILabel *currentTimeLabel; // 当前时间
@property (strong, nonatomic) UILabel *totalTimeLabel; // 总时长

@property (strong, nonatomic) UIActivityIndicatorView *activityIndicatorView; // loading指示器

@end

@implementation HQLVideoPreViewView

#pragma mark - initialize method 

- (void)layoutSubviews {
    [super layoutSubviews];
    [self updateFrame];
}

- (void)dealloc {
    NSLog(@"dealloc ---> %@", NSStringFromClass([self class]));
}

#pragma mark - event

- (void)viewConfig {
    [self centerPlayButton];
    [self controlView];
}

- (void)playButtonDidClick:(UIButton *)button {

}

- (void)sliderWillBeginDraging:(UISlider *)slider {

}

- (void)sliderDidDraging:(UISlider *)slider {

}

- (void)sliderDidEndDraging:(UISlider *)slider {

}

- (void)updateFrame {
    self.centerPlayButton.centerX = self.width * 0.5;
    self.centerPlayButton.centerY = self.height * 0.5;
    
    self.controlView.y = self.height - kControlViewHeight;
    self.controlView.width = self.width;
    
    self.playButton.x = kMargin;
    self.playButton.centerY = kControlViewHeight * 0.5;
    
    NSInteger totlaTime = CMTimeGetSeconds(self.playerItem.duration);
    NSInteger currentTime = CMTimeGetSeconds(self.player.currentTime);
    
    [self.totalTimeLabel setWidth:1000];
    self.totalTimeLabel.text = [HQLPhotoHelper getNewTimeFromDurationSecond:totlaTime];
    [self.totalTimeLabel sizeToFit];
    self.totalTimeLabel.centerY = kControlViewHeight * 0.5;
    self.totalTimeLabel.x = self.width - self.totalTimeLabel.width - kMargin;
    
    self.currentTimeLabel.width = self.totalTimeLabel.width;
    self.currentTimeLabel.height = self.totalTimeLabel.height;
    self.currentTimeLabel.x = CGRectGetMaxX(self.playButton.frame) + kMargin;
    self.currentTimeLabel.centerY = kControlViewHeight * 0.5;
    self.currentTimeLabel.text = [HQLPhotoHelper getNewTimeFromDurationSecond:currentTime];
    
    self.slider.width = CGRectGetMaxX(self.currentTimeLabel.frame) - self.totalTimeLabel.x - 2 * kMargin;
    self.slider.centerY = kControlViewHeight * 0.5;
    self.slider.x = CGRectGetMaxX(self.currentTimeLabel.frame) + kMargin;
    [self.slider setValue:((CGFloat)currentTime / (CGFloat)totlaTime) animated:NO];
}

#pragma mark - setter

- (void)setPlayerItem:(AVPlayerItem *)playerItem {
    _playerItem = playerItem;
    
    if (!self.playerLayer) {
        self.playerLayer = [[AVPlayerLayer alloc] init];
        self.playerLayer.frame = self.bounds;
        [self.layer addSublayer:self.playerLayer];
        self.playerLayer.videoGravity = AVLayerVideoGravityResizeAspect;
    }
    
    if (playerItem) {
        self.player = [AVPlayer playerWithPlayerItem:playerItem];
        self.playerLayer.player = self.player;
        
        self.slider.maximumValue = CMTimeGetSeconds(playerItem.duration);
        self.slider.minimumValue = 0;
    }
}

#pragma mark - getter

- (UIActivityIndicatorView *)activityIndicatorView {
    if (!_activityIndicatorView) {
        _activityIndicatorView = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhite];
        
        [self addSubview:_activityIndicatorView];
    }
    return _activityIndicatorView;
}

- (UISlider *)slider {
    if (!_slider) {
        _slider = [[UISlider alloc] init];
        
        [_slider addTarget:self action:@selector(sliderWillBeginDraging:) forControlEvents:UIControlEventTouchDown];
        [_slider addTarget:self action:@selector(sliderDidDraging:) forControlEvents:UIControlEventValueChanged];
        [_slider addTarget:self action:@selector(sliderDidEndDraging:) forControlEvents:UIControlEventTouchUpInside];
        
    }
    return _slider;
}

- (UILabel *)totalTimeLabel {
    if (!_totalTimeLabel) {
        _totalTimeLabel = [[UILabel alloc] init];
        _totalTimeLabel.font = [UIFont systemFontOfSize:12];
        _totalTimeLabel.textColor = [UIColor whiteColor];
        _totalTimeLabel.textAlignment = NSTextAlignmentCenter;
    }
    return _totalTimeLabel;
}

- (UILabel *)currentTimeLabel {
    if (!_currentTimeLabel) {
        _currentTimeLabel = [[UILabel alloc] init];
        _currentTimeLabel.font = [UIFont systemFontOfSize:12];
        _currentTimeLabel.textColor = [UIColor whiteColor];
        _currentTimeLabel.textAlignment = NSTextAlignmentCenter;
    }
    return _currentTimeLabel;
}

- (UIButton *)playButton {
    if (!_playButton) {
        _playButton = [UIButton buttonWithType:UIButtonTypeCustom];
        [_playButton setFrame:CGRectMake(0, 0, 30, 30)];
        
        [_playButton setImage:[UIImage imageWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"playButton" ofType:@"png"]] forState:UIControlStateNormal];
        [_playButton setImage:[UIImage imageWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"pauseButton" ofType:@"png"]] forState:UIControlStateSelected];
        
        [_playButton addTarget:self action:@selector(playButtonDidClick:) forControlEvents:UIControlEventTouchUpInside];
    }
    return _playButton;
}

-(UIView *)controlView {
    if (!_controlView) {
        _controlView = [[UIView alloc] init];
        [_controlView setBackgroundColor:[UIColor clearColor]];
        
        [_controlView addSubview:self.playButton];
        [_controlView addSubview:self.currentTimeLabel];
        [_controlView addSubview:self.slider];
        [_controlView addSubview:self.totalTimeLabel];
        
        [self addSubview:_controlView];
    }
    return _controlView;
}

- (UIButton *)centerPlayButton {
    if (!_centerPlayButton) {
        _centerPlayButton = [UIButton buttonWithType:UIButtonTypeCustom];
        [_centerPlayButton setFrame:CGRectMake(0, 0, 50, 50)];
        
        [_centerPlayButton setAlpha:0];
        
        [_centerPlayButton setImage:[UIImage imageWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"center_playButton" ofType:@"png"]] forState:UIControlStateNormal];
        [_centerPlayButton setImage:[UIImage imageWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"center_pauseButton" ofType:@"png"]] forState:UIControlStateSelected];
        
        [_centerPlayButton addTarget:self action:@selector(playButtonDidClick:) forControlEvents:UIControlEventTouchUpInside];
        
        [self addSubview:_centerPlayButton];
    }
    return _centerPlayButton;
}

/*
- (AVPlayer *)player {
    if (!_player) {
        _player = [[AVPlayer alloc] init];
    }
    return _player;
}

- (AVPlayerLayer *)playerLayer {
    if (!_playerLayer) {
        _playerLayer = [AVPlayerLayer playerLayerWithPlayer:self.player];
//        AVLayerVideoGravityResize
//        AVLayerVideoGravityResizeAspect
//        AVLayerVideoGravityResizeAspectFill
        _playerLayer.frame = self.bounds;
        [self.layer addSublayer:_playerLayer];
    }
    return _playerLayer;
}*/

@end
