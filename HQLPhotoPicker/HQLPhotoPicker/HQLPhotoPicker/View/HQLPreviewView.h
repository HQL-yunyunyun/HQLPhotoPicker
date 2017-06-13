//
//  HQLPreviewView.h
//  HQLPhotoPicker
//
//  Created by 何启亮 on 2017/6/13.
//  Copyright © 2017年 weplus. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "HQLPhotoModel.h"

@class HQLPhotoPreviewView, HQLPreviewView;

@protocol HQLPreviewViewDelegate <NSObject>

@required
- (NSUInteger)numberOfPhotos:(HQLPreviewView *)previewView;
- (void)previewView:(HQLPreviewView *)previewView renderPhotoPreviewView:(HQLPhotoPreviewView *)photoPreviewView atIndex:(NSUInteger)index;

@optional
- (HQLPhotoModelMediaType)previewView:(HQLPhotoPreviewView *)previewView assetTypeAtIndex:(NSUInteger)index;

@end

@interface HQLPreviewView : UIView

@property (assign, nonatomic) id <HQLPreviewViewDelegate>delegate;

@property (assign, nonatomic) NSUInteger currentIndex; // 当前的index
- (void)setCurrentIndex:(NSUInteger)currentIndex animated:(BOOL)animated;

@end

@interface HQLPreviewViewCell : UICollectionViewCell

@end
