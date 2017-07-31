//
//  HQLPhotoPickerBaseController.h
//  HQLPhotoPicker
//
//  Created by 何启亮 on 2017/6/22.
//  Copyright © 2017年 weplus. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "HQLPhotoPicker.h"

@class HQLPhotoPickerBaseController;

@protocol HQLPhotoPickerControllerSelectedDelegate <NSObject>

@optional
// 结束选择时的回调
- (void)photoPickerController:(HQLPhotoPickerBaseController *)controller didFinishPickingPhotoWithPhotoAssetArray:(NSMutableArray <HQLPhotoModel *>*)photoAssetArray;

@end

@interface HQLPhotoPickerBaseController : UIViewController <UICollectionViewDelegate, UICollectionViewDataSource, HQLPhotoLibraryChangeObserver, HQLPhotoPickerCellDelegate>

/* public method */
@property (strong, nonatomic) HQLPhotoAlbumModel *albumModel;
@property (assign, nonatomic) NSUInteger maxSelectCount; // 最大选择数  1 到 9
@property (assign, nonatomic) BOOL isShowTakePhotoCell; // 是否显示拍照的选项 defaut : yes
@property (assign, nonatomic) HQLPhotoPickerTakePhotoType takePhotoType;

@property (assign, nonatomic) id <HQLPhotoPickerControllerSelectedDelegate>selectedDelegate; // 选择后的回调

/* private property */
// 只是一些设计
@property (strong, nonatomic, readonly) UICollectionView *thumbnailCollectionView; // 显示缩略图的View
@property (strong, nonatomic, readonly) UICollectionViewFlowLayout *flowLayout; // flowLayout
@property (strong, nonatomic, readonly) UIButton *confirmButton;

@property (strong, nonatomic, readonly) NSMutableArray *selectedCellIndexPathArray; // 已选的index
@property (strong, nonatomic, readonly) HQLPhotoManager *photoManager;
@property (assign, nonatomic) BOOL collectionViewShowCheckButton; // cell是否显示选择的button
@property (assign, nonatomic) BOOL collectionViewShowSelectedBorder; // cell是否显示选择时的border

/* public method */

- (void)controllerConfig;

/* private method */

// 点击确认按钮
- (void)confirmButtonDidClick:(UIButton *)button;

@end
