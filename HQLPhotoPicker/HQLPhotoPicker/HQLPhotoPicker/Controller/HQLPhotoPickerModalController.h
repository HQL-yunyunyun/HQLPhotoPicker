//
//  HQLPhotoPickerModalController.h
//  HQLPhotoPicker
//
//  Created by weplus on 2017/6/14.
//  Copyright © 2017年 weplus. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "HQLPhotoManager.h"

@class HQLPhotoAlbumModel, HQLPhotoPickerModalController;

@protocol HQLPHotoPickerModalControllerDelegate <NSObject>

@required

// 关闭Controller
- (void)photoPickerModalControllerDidClickCloseButton:(HQLPhotoPickerModalController *)controller;

// 结束选择时的回调
- (void)photoPickerModalController:(HQLPhotoPickerModalController *)controller didFinishPickingPhotoWithPhotoAssetArray:(NSMutableArray <HQLPhotoModel *>*)photoAssetArray;

@end

@interface HQLPhotoPickerModalController : UIViewController

@property (strong, nonatomic) HQLPhotoAlbumModel *albumModel;
@property (assign, nonatomic) NSUInteger maxSelectCount; // 最大选择数，暂时只能单张

@property (assign, nonatomic) id <HQLPHotoPickerModalControllerDelegate>delegate;

@end
