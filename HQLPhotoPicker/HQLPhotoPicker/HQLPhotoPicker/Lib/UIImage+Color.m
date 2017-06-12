//
//  UIImage+Color.m
//  HuanMoney
//
//  Created by Xiang on 16/3/23.
//  Copyright © 2016年 微加科技. All rights reserved.
//

#import "UIImage+Color.h"

@implementation UIImage (Color)

+ (UIImage *)imageWithColor:(UIColor *)color {
    return [self imageWithColor:color size:1.0f];
}

+ (UIImage *)drawCircularWithSize:(CGFloat)diameter insideColor:(UIColor *)insideColor oursideColor:(UIColor *)oursideColor {
    UIGraphicsBeginImageContextWithOptions(CGSizeMake(diameter, diameter), NO, 2.0);
    CGContextRef ctr=UIGraphicsGetCurrentContext();
    double centerx=diameter * 0.5;
    double centery=centerx;
    [oursideColor set];
    CGContextAddArc(ctr, centerx, centery, diameter * 0.5,0, M_PI_2*4,YES);
    CGContextFillPath(ctr);
    [insideColor set];
    CGContextAddArc(ctr, centerx, centery, diameter * 0.3, 0, M_PI_2*4, YES);
    CGContextFillPath(ctr);
    UIImage *newImg=UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return newImg;
}

+ (UIImage *)imageWithColor:(UIColor *)color  size:(CGFloat)diameter{
    // 描述矩形
    CGRect rect = CGRectMake(0.0f, 0.0f, diameter, diameter);
    
    // 开启位图上下文
    UIGraphicsBeginImageContext(rect.size);
    // 获取位图上下文
    CGContextRef context = UIGraphicsGetCurrentContext();
    // 使用color演示填充上下文
    CGContextSetFillColorWithColor(context, [color CGColor]);
    // 渲染上下文
    CGContextFillRect(context, rect);
    // 从上下文中获取图片
    UIImage *theImage = UIGraphicsGetImageFromCurrentImageContext();
    // 结束上下文
    UIGraphicsEndImageContext();
    
    return theImage;
}

- (UIImage*)transformWidth:(CGFloat)width height:(CGFloat)height {
    CGFloat destW = width;
    CGFloat destH = height;
    CGFloat sourceW = width;
    CGFloat sourceH = height;
    CGImageRef imageRef = self.CGImage;
    CGContextRef bitmap = CGBitmapContextCreate(NULL,
                                                           destW,
                                                           destH,
                                                           CGImageGetBitsPerComponent(imageRef),
                                                           4*destW,
                                                           CGImageGetColorSpace(imageRef),
                                                           (kCGBitmapByteOrder32Little | kCGImageAlphaPremultipliedFirst));
    CGContextDrawImage(bitmap, CGRectMake(0, 0, sourceW, sourceH), imageRef);
    CGImageRef ref = CGBitmapContextCreateImage(bitmap);
    UIImage  *result = [UIImage imageWithCGImage:ref];
    CGContextRelease(bitmap);
    CGImageRelease(ref);
    return result;
}

@end
