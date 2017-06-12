//
//  UIImage+Color.h
//  HuanMoney
//
//  Created by Xiang on 16/3/23.
//  Copyright © 2016年 微加科技. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIImage (Color)

+ (UIImage *)imageWithColor:(UIColor *)color;

+ (UIImage *)drawCircularWithSize:(CGFloat)radius insideColor:(UIColor *)insideColor oursideColor:(UIColor *)oursideColor;

+ (UIImage *)imageWithColor:(UIColor *)color  size:(CGFloat)diameter;

- (UIImage*)transformWidth:(CGFloat)width height:(CGFloat)height;

@end
