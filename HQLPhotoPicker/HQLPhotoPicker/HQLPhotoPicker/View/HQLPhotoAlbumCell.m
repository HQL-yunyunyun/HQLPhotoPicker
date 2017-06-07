//
//  HQLPhotoAlbumCell.m
//  HQLPhotoPicker
//
//  Created by weplus on 2017/6/7.
//  Copyright © 2017年 weplus. All rights reserved.
//

#import "HQLPhotoAlbumCell.h"
#import "HQLPhotoAlbumModel.h"
#import "HQLPhotoModel.h"

@interface HQLPhotoAlbumCell ()

@property (weak, nonatomic) IBOutlet UIImageView *coverImageView;
@property (weak, nonatomic) IBOutlet UILabel *nameLabel;

@end

@implementation HQLPhotoAlbumCell

#pragma mark - setter

- (void)setAlbumModel:(HQLPhotoAlbumModel *)albumModel {
    _albumModel = albumModel;
    
    // 设置封面
    [albumModel.albumCover requestThumbnailImage:^(UIImage *thumbnail, NSString *errorString) {
        self.coverImageView.image = thumbnail;
    }];
    
    self.nameLabel.text = [NSString stringWithFormat:@"%@(%ld)", albumModel.albumName, albumModel.count];
}

@end
