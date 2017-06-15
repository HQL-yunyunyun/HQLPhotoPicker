//
//  HQLPhotoPickerModalController.m
//  HQLPhotoPicker
//
//  Created by weplus on 2017/6/14.
//  Copyright © 2017年 weplus. All rights reserved.
//

#import "HQLPhotoPickerModalController.h"
#import "HQLPhotoPickerCell.h"
#import "HQLPreviewView.h"
#import "HQLPhotoPreviewView.h"
#import "HQLPhotoAlbumModel.h"

#import "UIView+Frame.h"

#define HQLPhotoPickerCellReuseId @"HQLPhotoPickerCellReuseId"
#define kColumnCount 4

@interface HQLPhotoPickerModalController () <UICollectionViewDelegate, UICollectionViewDataSource, HQLPreviewViewDelegate, HQLPhotoPreviewViewDelegate>

@property (strong, nonatomic) HQLPreviewView *previewView;
@property (strong, nonatomic) UICollectionView *collectionView;
@property (strong, nonatomic) UICollectionViewFlowLayout *flowLayout;

@property (strong, nonatomic) UIButton *closeButton;
@property (strong, nonatomic) UIButton *confirmButton;

@property (strong, nonatomic) NSIndexPath *currentSelectedCellIndexPath;

@end

@implementation HQLPhotoPickerModalController

#pragma mark - life cycle

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self.view setBackgroundColor:[UIColor whiteColor]];
    
    [self previewView];
    [self collectionView];
    [self closeButton];
    [self confirmButton];
}

- (void)dealloc {
    NSLog(@"dealloc ---> %@", NSStringFromClass([self class]));
}

#pragma mark - event

- (void)closeButtonDidClick:(UIButton *)button {

}

- (void)confirmButtonDidClick:(UIButton *)button {

}

#pragma mark - collection delegate

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    
    [self.previewView setCurrentIndex:indexPath.item animated:YES];
    
    HQLPhotoModel *model = self.albumModel.photoArray[indexPath.item];
    model.isSelected = YES;
    [[HQLPhotoManager shareManager] addSelectedAssetWithIdentifier:model.assetLocalizationIdentifer];
    
    HQLPhotoPickerCell *cell = (HQLPhotoPickerCell *)[collectionView cellForItemAtIndexPath:indexPath];
    [cell setSelectedAnimation:YES animated:YES];
    
    if ([indexPath compare:self.currentSelectedCellIndexPath] != NSOrderedSame) {
        HQLPhotoModel *currentModel = self.albumModel.photoArray[self.currentSelectedCellIndexPath.item];
        currentModel.isSelected = NO;
        [[HQLPhotoManager shareManager] removeSelectedAssetWithIdentifier:currentModel.assetLocalizationIdentifer];
        
        HQLPhotoPickerCell *currentCell = (HQLPhotoPickerCell *)[collectionView cellForItemAtIndexPath:self.currentSelectedCellIndexPath];
        [currentCell setSelectedAnimation:NO animated:YES];
        self.currentSelectedCellIndexPath = indexPath;
    }
}

#pragma mark - collection data source

- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView {
    return 1;
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return self.albumModel.count;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    HQLPhotoPickerCell *cell = (HQLPhotoPickerCell *)[collectionView dequeueReusableCellWithReuseIdentifier:HQLPhotoPickerCellReuseId forIndexPath:indexPath];
    cell.photoModel = self.albumModel.photoArray[indexPath.item];
    cell.isShowCheckButton = NO;
    cell.isShowSelectedBorder = YES;
    return cell;
}

#pragma mark - preview View delegate

- (NSUInteger)numberOfPhotos:(HQLPreviewView *)previewView {
    return self.albumModel.count;
}

- (void)previewView:(HQLPreviewView *)previewView renderPhotoPreviewView:(HQLPhotoPreviewView *)photoPreviewView atIndex:(NSUInteger)index {
    [photoPreviewView activityIndicatorViewAnimate:YES];
    
//    NSLog(@"create cell : %ld", index);
    
    HQLPhotoModel *model = self.albumModel.photoArray[index];
    photoPreviewView.delegate = self;
    
    switch (model.mediaType) {
        case HQLPhotoModelMediaTypePhoto:
        case HQLPhotoModelMediaTypeCameraPhoto: {
            [model requestHighDefinitionImageWithProgressHandler:^(double progress, NSError * _Nullable error, BOOL * _Nonnull stop, NSDictionary * _Nullable info) {
                
            } resultHandler:^(UIImage *highDefinitionImage, NSString *error) {
                photoPreviewView.photo = highDefinitionImage;
            }];
            break;
        }
        case HQLPhotoModelMediaTypePhotoGif: {
            [model requestOriginalImageDataWithProgressHandler:^(double progress, NSError * _Nullable error, BOOL * _Nonnull stop, NSDictionary * _Nullable info) {
                
            } resultHandler:^(NSData *imageData, NSString *byteString, NSString *error) {
                photoPreviewView.gifData = imageData;
            }];
            break;
        }
        case HQLPhotoModelMediaTypeLivePhoto: {
            [model requestLivePhotoWithProgressHandler:^(double progress, NSError * _Nullable error, BOOL * _Nonnull stop, NSDictionary * _Nullable info) {
                
            } resultHandler:^(PHLivePhoto *livePhoto, NSString *error) {
                photoPreviewView.livePhoto = livePhoto;
            }];
            break;
        }
        case HQLPhotoModelMediaTypeVideo:
        case HQLPhotoModelMediaTypeCameraVideo: {
            [model requestPlayerItemWithProgressHandler:^(double progress, NSError * _Nullable error, BOOL * _Nonnull stop, NSDictionary * _Nullable info) {
                
            } resultHandler:^(AVPlayerItem *playerItem, NSString *error) {
                photoPreviewView.playerItem = playerItem;
            }];
            break;
        }
        case HQLPhotoModelMediaTypeAudio: { break; }
        case HQLPhotoModelMediaTypeUnKnow: { break; }
    }
    
}

- (void)previewView:(HQLPreviewView *)previewView willDisplayPhotoPreviewView:(HQLPhotoPreviewView *)photoPreviewView atIndex:(NSUInteger)index {
    
//    HQLPhotoModel *model = self.albumModel.photoArray[index];
//    if (model.mediaType == HQLPhotoModelMediaTypeVideo || model.mediaType == HQLPhotoModelMediaTypeCameraVideo) {
//        [photoPreviewView setVideoViewThumbnail:model.thumbnailImage];
//    } else {
//        [photoPreviewView setThumbnail:model.thumbnailImage];
//    }
}

- (void)previewView:(HQLPreviewView *)previewView didEndDisplayPhotoPreviewView:(HQLPhotoPreviewView *)photoPreviewView atIndex:(NSUInteger)index {
    HQLPhotoModel *model = self.albumModel.photoArray[index];
    [model cancelRequest];
}

- (void)previewView:(HQLPreviewView *)previewView didDisplayPhotoPreviewView:(HQLPhotoPreviewView *)photoPreviewView atIndex:(NSUInteger)index {
    
}

- (HQLPhotoModelMediaType)previewView:(HQLPreviewView *)previewView assetTypeAtIndex:(NSUInteger)index {
    HQLPhotoModel *photoModel = self.albumModel.photoArray[index];
    return photoModel.mediaType;
}

#pragma mark - setter

- (void)setAlbumModel:(HQLPhotoAlbumModel *)albumModel {
    _albumModel = albumModel;
    
    [self.collectionView reloadData];
    [self.previewView reloadData];
    
    if (![self.collectionView cellForItemAtIndexPath:self.currentSelectedCellIndexPath]) {
        self.currentSelectedCellIndexPath = [NSIndexPath indexPathForItem:0 inSection:0];
    }
    [self collectionView:self.collectionView didSelectItemAtIndexPath:self.currentSelectedCellIndexPath];
}

#pragma mark - getter

- (UIButton *)closeButton {
    if (!_closeButton) {
        _closeButton = [UIButton buttonWithType:UIButtonTypeCustom];
        [_closeButton setImage:[UIImage imageWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"closeButton" ofType:@"png"]] forState:UIControlStateNormal];
        [_closeButton setFrame:CGRectMake(16, 36, 17, 17)];
        
        [_closeButton addTarget:self action:@selector(closeButtonDidClick:) forControlEvents:UIControlEventTouchUpInside];
        
        [self.view addSubview:_closeButton];
    }
    return _closeButton;
}

- (UIButton *)confirmButton {
    if (!_confirmButton) {
        _confirmButton = [UIButton buttonWithType:UIButtonTypeCustom];
        [_confirmButton setImage:[UIImage imageWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"confirmButton" ofType:@"png"]] forState:UIControlStateNormal];
        [_confirmButton setFrame:CGRectMake(self.view.width - 16 - 24, 36, 24, 17)];
        
        [_confirmButton addTarget:self action:@selector(confirmButtonDidClick:) forControlEvents:UIControlEventTouchUpInside];
        
        [self.view addSubview:_confirmButton];
        
    }
    return _confirmButton;
}

- (HQLPreviewView *)previewView {
    if (!_previewView) {
        _previewView = [[HQLPreviewView alloc] initWithFrame:CGRectMake(0, 0, self.view.width, self.view.height * 0.5)];
        _previewView.delegate = self;
        
        // 设置一个阴影
        _previewView.layer.shadowColor = [[UIColor redColor] colorWithAlphaComponent:0.3].CGColor;
        _previewView.layer.shadowOffset = CGSizeMake(1, 2);
        _previewView.layer.shadowOpacity = 1;
        _previewView.layer.shadowRadius = 1.0;
        
        [self.view addSubview:_previewView];
    }
    return _previewView;
}

- (UICollectionView *)collectionView {
    if (!_collectionView) {
        _collectionView = [[UICollectionView alloc] initWithFrame:CGRectMake(0, self.view.height * 0.5, self.view.width, self.view.height * 0.5) collectionViewLayout:self.flowLayout];
        _collectionView.delegate = self;
        _collectionView.dataSource = self;
        _collectionView.showsVerticalScrollIndicator = NO;
        _collectionView.showsHorizontalScrollIndicator = NO;
        [_collectionView setBackgroundColor:[UIColor whiteColor]];
        
        [_collectionView registerClass:[HQLPhotoPickerCell class] forCellWithReuseIdentifier:HQLPhotoPickerCellReuseId];
        
        [self.view addSubview:_collectionView];
    }
    return _collectionView;
}

- (UICollectionViewFlowLayout *)flowLayout {
    if (!_flowLayout) {
        _flowLayout = [[UICollectionViewFlowLayout alloc] init];
        
        CGFloat itemWidth = (self.view.width - (kColumnCount - 1)) / kColumnCount;
        NSInteger width = (NSInteger)itemWidth;
        CGFloat temp = itemWidth - width;
        CGFloat spacing = 1 + (temp * kColumnCount) / (kColumnCount - 1);
        
        _flowLayout.minimumLineSpacing = spacing;
        _flowLayout.minimumInteritemSpacing = spacing;
        
        _flowLayout.itemSize = CGSizeMake(width, width);
        
    }
    return _flowLayout;
}

@end
