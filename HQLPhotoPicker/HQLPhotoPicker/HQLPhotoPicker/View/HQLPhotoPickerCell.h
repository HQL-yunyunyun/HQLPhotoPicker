//
//  HQLPhotoPickerCell.h
//  HQLPhotoPicker
//
//  Created by weplus on 2017/6/6.
//  Copyright © 2017年 weplus. All rights reserved.
//

#import <UIKit/UIKit.h>

@class HQLPhotoModel;

@interface HQLPhotoPickerCell : UICollectionViewCell

@property (strong, nonatomic) HQLPhotoModel *photoModel;
@property (assign, nonatomic) BOOL isShowCheckButton;

@end
