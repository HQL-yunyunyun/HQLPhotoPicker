//
//  HQLPhotoPickerModalController.h
//  HQLPhotoPicker
//
//  Created by weplus on 2017/6/14.
//  Copyright © 2017年 weplus. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "HQLPhotoManager.h"

@class HQLPhotoAlbumModel;

@interface HQLPhotoPickerModalController : UIViewController

@property (strong, nonatomic) HQLPhotoAlbumModel *albumModel;
@property (assign, nonatomic) NSUInteger maxSelectCount; // 最大选择数，暂时只能单张

@end
