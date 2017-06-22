//
//  HQLPhotoPickerBaseController.h
//  HQLPhotoPicker
//
//  Created by 何启亮 on 2017/6/22.
//  Copyright © 2017年 weplus. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "HQLPhotoPicker.h"

@interface HQLPhotoPickerBaseController : UIViewController

@property (strong, nonatomic) HQLPhotoAlbumModel *albumModel;
@property (assign, nonatomic) NSUInteger maxSelectCount; // 最大选择数  1 到 9
@property (assign, nonatomic) BOOL isShowTakePhotoCell; // 是否显示拍照的选项 defaut : yes
@property (assign, nonatomic) HQLPhotoPickerTakePhotoType takePhotoType;

@end
