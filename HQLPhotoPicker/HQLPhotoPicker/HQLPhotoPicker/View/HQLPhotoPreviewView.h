//
//  HQLPhotoPreviewView.h
//  HQLPhotoPicker
//
//  Created by weplus on 2017/6/8.
//  Copyright © 2017年 weplus. All rights reserved.
//

#import <UIKit/UIKit.h>

#import <Photos/Photos.h>

@class HQLPhotoPreviewView;

@protocol HQLPhotoPreviewViewDelegate <NSObject>

@optional
- (void)photoPreviewViewDidClick:(HQLPhotoPreviewView *)previewView;

@end

@interface HQLPhotoPreviewView : UIView

@property (strong, nonatomic) UIImage *photo;
@property (strong, nonatomic) NSData *gifData;
@property (strong, nonatomic) AVPlayerItem *playerItem;
@property (strong, nonatomic) PHLivePhoto *livePhoto;

@property (strong, nonatomic) UIImage *thumbnail;

@property (assign, nonatomic) id <HQLPhotoPreviewViewDelegate>delegate;

- (void)resetViewStatus; // 重置状态
- (void)videoViewShowControlView; // 显示
- (void)videoViewHideControlView; // 隐藏
- (void)activityIndicatorViewAnimate:(BOOL)yesOrNo;

- (void)setVideoViewThumbnail:(UIImage *)thumbnail;

@end
