//
//  HQLPhotoPickerModalController.h
//  HQLPhotoPicker
//
//  Created by weplus on 2017/6/14.
//  Copyright © 2017年 weplus. All rights reserved.
//

#import "HQLPhotoPickerBaseController.h"

@class HQLPhotoPickerModalController;

@protocol HQLPhotoPickerModalControllerDelegate <NSObject>

@required

// 关闭Controller
- (void)photoPickerModalControllerDidClickCloseButton:(HQLPhotoPickerModalController *)controller;

@end

@interface HQLPhotoPickerModalController : HQLPhotoPickerBaseController

@property (assign, nonatomic) id <HQLPhotoPickerModalControllerDelegate>delegate;

@end
