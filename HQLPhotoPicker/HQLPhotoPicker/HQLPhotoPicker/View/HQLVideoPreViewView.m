//
//  HQLVideoPreViewView.m
//  HQLPhotoPicker
//
//  Created by weplus on 2017/6/8.
//  Copyright © 2017年 weplus. All rights reserved.
//

#import "HQLVideoPreViewView.h"

#import "HQLPhotoHelper.h"

#import "UIImage+Color.h"
#import "UIView+Frame.h"

#define kControlViewHeight 50
#define kMargin 12

@interface HQLVideoPreViewView ()

@property (strong, nonatomic) AVPlayerLayer *playerLayer; // 播放视频的layer
@property (strong, nonatomic) AVPlayer *player; // 控制器
@property (strong, nonatomic) id timeObserver;

@property (assign, nonatomic) BOOL isSeeking; // 是否在设置视频播放时间
@property (assign, nonatomic) BOOL playerIsPlayBeforeDrag; // 拖拽前的视频状态

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
    [self.player removeTimeObserver:self.timeObserver];
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    NSLog(@"dealloc ---> %@", NSStringFromClass([self class]));
}

#pragma mark - event

- (void)viewConfig {
    [self centerPlayButton];
    [self controlView];
    
    [self setBackgroundColor:[UIColor blackColor]];
}

- (void)playButtonDidClick:(UIButton *)button {
    self.playButton.selected = !button.isSelected;
    self.centerPlayButton.selected = self.playButton.isSelected;
    
    [self.centerPlayButton setHidden:button.isSelected];
    
    if (button.isSelected) {
        [self.player play];
    } else {
        [self.player pause];
    }
}

- (void)sliderWillBeginDraging:(UISlider *)slider {
    self.playerIsPlayBeforeDrag = self.playButton.isSelected; // 选中状态是播放
    
    [self pauseVideo];
}

- (void)sliderDidDraging:(UISlider *)slider {
    if (!self.isSeeking) {
        self.isSeeking = YES;
        [self updateTimeLabelWithIsUpdateSlider:NO];
        
        __weak typeof(self) weakSelf = self;
        [self.player seekToTime:CMTimeMakeWithSeconds(slider.value, NSEC_PER_SEC) toleranceBefore:kCMTimeZero toleranceAfter:kCMTimeZero completionHandler:^(BOOL finished) {
            dispatch_async(dispatch_get_main_queue(), ^{
                weakSelf.isSeeking = NO;
            });
        }];
    }
}

- (void)sliderDidEndDraging:(UISlider *)slider {
    if (self.playerIsPlayBeforeDrag) {
        [self playVideo];
    } else {
        [self pauseVideo];
    }
}

- (void)updateTimeLabelWithIsUpdateSlider:(BOOL)yesOrNo {
    NSInteger totalTime = CMTimeGetSeconds(self.playerItem.asset.duration);
    [self.totalTimeLabel setText:[HQLPhotoHelper getNewTimeFromDurationSecond:totalTime]];
    NSInteger currentTime = CMTimeGetSeconds(self.player.currentTime);
    [self.currentTimeLabel setText:[HQLPhotoHelper getNewTimeFromDurationSecond:currentTime]];
    if (yesOrNo) {
        [self.slider setValue:currentTime animated:YES];
    }
}

- (void)updateFrame {
    self.playerLayer.frame = self.bounds;
    
    self.centerPlayButton.centerX = self.width * 0.5;
    self.centerPlayButton.centerY = self.height * 0.5;
    
    [self.controlView setFrame:CGRectMake(0, self.height - kControlViewHeight, self.width, kControlViewHeight)];
    
    self.totalTimeLabel.x = self.width - self.totalTimeLabel.width - kMargin;
    
    self.currentTimeLabel.x = CGRectGetMaxX(self.playButton.frame) + kMargin;
    
    self.slider.width = self.totalTimeLabel.x - CGRectGetMaxX(self.currentTimeLabel.frame) - 2 * kMargin;
    self.slider.x = CGRectGetMaxX(self.currentTimeLabel.frame) + kMargin;
    
    // 更新时间
    [self updateTimeLabelWithIsUpdateSlider:YES];
}

// 结束放映
- (void)videoDidEndPlay {
    [self stopVideo];
}

// 进入后台 --- 停止播放
- (void)appliactionDidEnterBackground {
    [self pauseVideo];
}

- (void)controlViewShowAnimate {
    [UIView animateWithDuration:0.3f animations:^{
        self.controlView.y = self.height - kControlViewHeight;
    } completion:^(BOOL finished) {
        
    }];
}

- (void)controlViewHideAnimate {
    [UIView animateWithDuration:0.3f animations:^{
        self.controlView.y = self.height;
    } completion:^(BOOL finished) {
        
    }];
}

- (void)playVideo {
    self.playButton.selected = NO;
    [self playButtonDidClick:self.playButton];
}

- (void)pauseVideo {
    self.playButton.selected = YES;
    [self playButtonDidClick:self.playButton];
}

- (void)stopVideo {
    [self.player seekToTime:kCMTimeZero];
    self.playButton.selected = YES;
    [self playButtonDidClick:self.playButton];
}

#pragma mark - setter

- (void)setPlayerItem:(AVPlayerItem *)playerItem {
    _playerItem = playerItem;
    
    if (self.player && self.timeObserver) {
        [self.player removeTimeObserver:self.timeObserver];
        self.player = nil;
        self.timeObserver = nil;
    }
    
    if (playerItem) {
        
        if (!self.playerLayer) {
            self.playerLayer = [[AVPlayerLayer alloc] init];
            self.playerLayer.frame = self.bounds;
            [self.layer insertSublayer:self.playerLayer atIndex:0];
            self.playerLayer.videoGravity = AVLayerVideoGravityResizeAspect;
        }
        
        __weak typeof(self) weakSelf = self;
        self.player = [AVPlayer playerWithPlayerItem:playerItem];
        self.timeObserver = [self.player addPeriodicTimeObserverForInterval:CMTimeMakeWithSeconds(.1f, NSEC_PER_SEC) queue:nil usingBlock:^(CMTime time) {
            [weakSelf updateTimeLabelWithIsUpdateSlider:!weakSelf.isSeeking];
        }];
        
        // 添加通知
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(videoDidEndPlay) name:AVPlayerItemDidPlayToEndTimeNotification object:playerItem];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(applicationDidEnterBackground:) name:UIApplicationDidEnterBackgroundNotification object:nil];
        
        self.playerLayer.player = self.player;
        self.slider.maximumValue = (NSInteger)CMTimeGetSeconds(playerItem.asset.duration);
    } else {
        
        [[NSNotificationCenter defaultCenter] removeObserver:self];
        self.player = nil;
        [self.playerLayer removeFromSuperlayer];
        self.playerLayer = nil;
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
        [_slider setMinimumValue:0];
        
        [_slider setThumbImage:[UIImage drawCircularWithSize:15 insideColor:[UIColor whiteColor] oursideColor:[UIColor whiteColor]] forState:UIControlStateNormal];
        [_slider setMinimumTrackTintColor:[UIColor whiteColor]];
        
        _slider.centerY = kControlViewHeight * 0.5;
        
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
        
        [_totalTimeLabel setText:@"00:00"];
        _totalTimeLabel.width = 1000;
        [_totalTimeLabel sizeToFit];
        _totalTimeLabel.centerY = kControlViewHeight * 0.5;
    }
    return _totalTimeLabel;
}

- (UILabel *)currentTimeLabel {
    if (!_currentTimeLabel) {
        _currentTimeLabel = [[UILabel alloc] init];
        _currentTimeLabel.font = [UIFont systemFontOfSize:12];
        _currentTimeLabel.textColor = [UIColor whiteColor];
        _currentTimeLabel.textAlignment = NSTextAlignmentCenter;
        
        [_currentTimeLabel setText:@"00:00"];
        _currentTimeLabel.width = 1000;
        [_currentTimeLabel sizeToFit];
        _currentTimeLabel.centerY = kControlViewHeight * 0.5;
    }
    return _currentTimeLabel;
}

- (UIButton *)playButton {
    if (!_playButton) {
        _playButton = [UIButton buttonWithType:UIButtonTypeCustom];
        [_playButton setFrame:CGRectMake(kMargin, 0, 30, 30)];
        _playButton.centerY = kControlViewHeight * 0.5;
        
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
        
        [_centerPlayButton setAlpha:0.6];
        
        [_centerPlayButton setImage:[UIImage imageWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"center_playButton" ofType:@"png"]] forState:UIControlStateNormal];
        [_centerPlayButton setImage:[UIImage imageWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"center_pauseButton" ofType:@"png"]] forState:UIControlStateSelected];
        
        [_centerPlayButton addTarget:self action:@selector(playButtonDidClick:) forControlEvents:UIControlEventTouchUpInside];
        
        [self addSubview:_centerPlayButton];
    }
    return _centerPlayButton;
}

@end
