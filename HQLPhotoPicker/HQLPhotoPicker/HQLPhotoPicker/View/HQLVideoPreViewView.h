//
//  HQLVideoPreViewView.h
//  HQLPhotoPicker
//
//  Created by weplus on 2017/6/8.
//  Copyright © 2017年 weplus. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <AVFoundation/AVFoundation.h>

@interface HQLVideoPreViewView : UIView

@property (strong, nonatomic) AVPlayerItem *playerItem;

@property (strong, nonatomic) UIImage *thumbnail; // 显示缩略图

- (void)controlViewShowAnimate;
- (void)controlViewHideAnimate;

- (void)playVideo; // 播放
- (void)pauseVideo; // 暂停播放
- (void)stopVideo; // 停止播放

@end
