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
// 每当调用 [collectionView: cellForItemAtIndexPath:] 方法时都调用这个代理，如果实现了这个代理可以确定cell.photoPreviewView 的类型，可以节省一点内存的开销
- (HQLPhotoModelMediaType)previewView:(HQLPreviewView *)previewView assetTypeAtIndex:(NSUInteger)index;
// 当cell准备显示的时候会调用这个方法 --- 可以在这个方法设置图片，这样可以 节省一些内存(特别是在iCloud下载图片的时候)
- (void)previewView:(HQLPreviewView *)previewView willDisplayPhotoPreviewView:(HQLPhotoPreviewView *)photoPreviewView atIndex:(NSUInteger)index;
// 当cell移出屏幕时会调用这个方法 --- 可以在这个方法中取消下载图片
- (void)previewView:(HQLPreviewView *)previewView didEndDisplayPhotoPreviewView:(HQLPhotoPreviewView *)photoPreviewView atIndex:(NSUInteger)index;

- (void)previewView:(HQLPreviewView *)previewView didDisplayPhotoPreviewView:(HQLPhotoPreviewView *)photoPreviewView atIndex:(NSUInteger)index;

@end

@interface HQLPreviewView : UIView

@property (assign, nonatomic) id <HQLPreviewViewDelegate>delegate;

@property (assign, nonatomic) NSUInteger currentIndex; // 当前的index
- (void)setCurrentIndex:(NSUInteger)currentIndex animated:(BOOL)animated;
- (void)reloadData;

@end

@interface HQLPreviewViewCell : UICollectionViewCell

@property (strong, nonatomic, readonly) HQLPhotoPreviewView *photoPreviewView;

@end
