//
//  HQLPhotoManager.m
//  HQLPhotoPicker
//
//  Created by weplus on 2017/6/2.
//  Copyright © 2017年 weplus. All rights reserved.
//

#import "HQLPhotoManager.h"

@interface HQLPhotoManager () <PHPhotoLibraryChangeObserver>

@end

@implementation HQLPhotoManager

#pragma mark - initialize method 

+ (instancetype)shareManager {
    static HQLPhotoManager *manager;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        manager = [[HQLPhotoManager alloc] init];
        PHPhotoLibrary *library = [PHPhotoLibrary sharedPhotoLibrary];
        [library registerChangeObserver:manager];
    });
    return manager;
}

#pragma mark - event

- (void)photoLibraryDidChange:(PHChange *)changeInstance {

}

@end
