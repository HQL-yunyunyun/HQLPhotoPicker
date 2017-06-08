//
//  HQLVideoPreViewView.m
//  HQLPhotoPicker
//
//  Created by weplus on 2017/6/8.
//  Copyright © 2017年 weplus. All rights reserved.
//

#import "HQLVideoPreViewView.h"

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

- (void)dealloc {
    NSLog(@"dealloc ---> %@", NSStringFromClass([self class]));
}

#pragma mark - event

#pragma mark - setter

#pragma mark - getter

@end
