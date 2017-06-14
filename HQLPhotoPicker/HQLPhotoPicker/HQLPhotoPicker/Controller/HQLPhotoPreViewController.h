//
//  HQLPhotoPreViewController.h
//  HQLPhotoPicker
//
//  Created by weplus on 2017/6/7.
//  Copyright © 2017年 weplus. All rights reserved.
//

#import <UIKit/UIKit.h>

@class HQLPhotoAlbumModel;

@interface HQLPhotoPreViewController : UIViewController

@property (strong, nonatomic) HQLPhotoAlbumModel *model;

- (void)setCurrentIndex:(NSUInteger)currentIndex animated:(BOOL)animated;

@end
