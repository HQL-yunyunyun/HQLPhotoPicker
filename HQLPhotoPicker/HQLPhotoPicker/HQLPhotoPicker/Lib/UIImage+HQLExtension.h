//
//  UIImage+HQLExtension.h
//  HQLPhotoPicker
//
//  Created by weplus on 2017/6/13.
//  Copyright © 2017年 weplus. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIImage (HQLExtension)
+ (UIImage *)animatedGIFWithData:(NSData *)data;
- (UIImage *)animatedImageByScalingAndCroppingToSize:(CGSize)size;
- (UIImage *)normalizedImage;
- (UIImage *)clipImage:(CGFloat)scale;
- (UIImage *)scaleImagetoScale:(float)scaleSize;
- (UIImage *)clipNormalizedImage:(CGFloat)scale;
- (UIImage *)fullNormalizedImage;
- (UIImage *)clipLeftOrRightImage:(CGFloat)scale;
@end
