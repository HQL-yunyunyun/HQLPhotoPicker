//
//  HQLPhotoPickerCell.h
//  HQLPhotoPicker
//
//  Created by weplus on 2017/6/6.
//  Copyright © 2017年 weplus. All rights reserved.
//

#import <UIKit/UIKit.h>

@class HQLPhotoModel, HQLPhotoPickerCell;

@protocol HQLPhotoPickerCellDelegate <NSObject>

@optional
- (void)photoPickerCell:(HQLPhotoPickerCell *)cell didClickCheckButton:(UIButton *)checkButton;

@end

@interface HQLPhotoPickerCell : UICollectionViewCell

@property (strong, nonatomic) HQLPhotoModel *photoModel;
@property (assign, nonatomic) BOOL isShowCheckButton;
@property (assign, nonatomic) id <HQLPhotoPickerCellDelegate>delegate;

@end
