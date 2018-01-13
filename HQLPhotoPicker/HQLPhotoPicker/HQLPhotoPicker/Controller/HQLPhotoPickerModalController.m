
//  HQLPhotoPickerModalController.m
//  HQLPhotoPicker
//
//  Created by weplus on 2017/6/14.
//  Copyright © 2017年 weplus. All rights reserved.
//

#import "HQLPhotoPickerModalController.h"

#import "HQLPreviewView.h"
#import "HQLPhotoPreviewView.h"

#import "UIView+Frame.h"

@interface HQLPhotoPickerModalController () <UINavigationControllerDelegate, UIImagePickerControllerDelegate, HQLPreviewViewDelegate, HQLPhotoPreviewViewDelegate>

@property (strong, nonatomic) HQLPreviewView *previewView;

@property (strong, nonatomic) UIButton *closeButton;

@end

@implementation HQLPhotoPickerModalController

#pragma mark - life cycle

- (void)viewDidLoad {
    [super viewDidLoad];
}

#pragma mark - event

- (void)controllerConfig {
    [super controllerConfig];
    
    [self.view setBackgroundColor:[UIColor whiteColor]];
    
    [self previewView];
    
    [self.view addSubview:self.thumbnailCollectionView];
    self.thumbnailCollectionView.y = self.view.height * 0.5;
    self.thumbnailCollectionView.height = self.view.height * 0.5;
    
    [self closeButton];
    
    [self.view addSubview:self.confirmButton];
    [self.confirmButton setImage:[UIImage imageWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"confirmButton" ofType:@"png"]] forState:UIControlStateNormal];
    [self.confirmButton setFrame:CGRectMake(self.view.width - 16 - 24, 36, 24, 17)];
    
    self.maxSelectCount = 1;
    self.isShowTakePhotoCell = YES;
    
    self.collectionViewShowSelectedBorder = YES;
}

- (void)closeButtonDidClick:(UIButton *)button {
    [self.photoManager removeAllSelectedAsset];
    if ([self.delegate respondsToSelector:@selector(photoPickerModalControllerDidClickCloseButton:)]) {
        [self.delegate photoPickerModalControllerDidClickCloseButton:self];
    }
}

- (void)updateSelectedCellIndexPath {
    [self.selectedCellIndexPathArray removeAllObjects];
    for (NSNumber *index in [self.photoManager getSelectedAssetIndexWithAlbum:self.albumModel]) {
        [self.selectedCellIndexPathArray addObject:[NSIndexPath indexPathForItem:[index integerValue] inSection:0]];
    }
}

#pragma mark - image picker controller delegate

- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker {
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary<NSString *,id> *)info {
    
    NSString *mediaType = info[UIImagePickerControllerMediaType];
    if ([mediaType isEqualToString:@"public.image"]) { // 图片
        // 保存图片
        [self.photoManager saveImage:info[UIImagePickerControllerOriginalImage] toAlbum:self.albumModel complete:^(BOOL isSuccess, NSString *error, NSString *identifier) {
            NSLog(@"succes : %d , error : %@, identifier : %@", isSuccess, error, identifier);
        }];
    } else if ([mediaType isEqualToString:@"public.movie"]) { // 视频
        [self.photoManager saveVideoWithVideoUrl:info[UIImagePickerControllerMediaURL] toAlbum:self.albumModel complete:^(BOOL isSuccess, NSString *error, NSString *identifier) {
            NSLog(@"succes : %d , error : %@, identifier : %@", isSuccess, error, identifier);
        }];
    } else {
    
    }
    [self dismissViewControllerAnimated:YES completion:nil];
}

#pragma mark - collection delegate

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    
    if (self.isShowTakePhotoCell && indexPath.item == 0) {
        [HQLPhotoHelper takePhotoWithController:self delegate:self type:self.takePhotoType];
        return;
    }
    
    NSInteger targetIndex = indexPath.item - (self.isShowTakePhotoCell ? 1 : 0);
    
    HQLWeakSelf;
    HQLPhotoModel *currentModel = self.albumModel.photoArray[targetIndex];
    
    if (self.maxSelectCount == 1) {
        
        if ([self.selectedCellIndexPathArray.lastObject compare:indexPath] == NSOrderedSame && self.selectedCellIndexPathArray.count != 0) {
            return;
        }
        
        [self.previewView setCurrentIndex:targetIndex animated:YES];
        // 取消前一个
        [self.photoManager removeAllSelectedAsset];
        if (self.selectedCellIndexPathArray.count == 1) {
            HQLPhotoPickerCell *cell = (HQLPhotoPickerCell *)[collectionView cellForItemAtIndexPath:self.selectedCellIndexPathArray.lastObject];
            [cell setSelectedAnimation:NO animated:YES];
        }
        
        [self.selectedCellIndexPathArray removeAllObjects];
        
        [self.photoManager addSelectedAssetWithIdentifier:currentModel.assetLocalizationIdentifier complete:^(BOOL isSuccess, NSString *message) {
            if (isSuccess) {
                HQLPhotoPickerCell *cell = (HQLPhotoPickerCell *)[collectionView cellForItemAtIndexPath:indexPath];
                [cell setSelectedAnimation:YES animated:YES];
                [weakSelf.selectedCellIndexPathArray addObject:indexPath];
            } else {
                NSLog(@"%@", message);
            }
        }];
        
    } else {
        if (self.selectedCellIndexPathArray.count >= self.maxSelectCount && ![self.photoManager getAssetIsSelectedWithIdentifier:currentModel.assetLocalizationIdentifier]) {
            return;
        }
        
        [self.previewView setCurrentIndex:targetIndex animated:YES];
        [self.photoManager addSelectedAssetWithIdentifier:currentModel.assetLocalizationIdentifier complete:^(BOOL isSuccess, NSString *message) {
            if (isSuccess) { // 添加成功表明添加前这个资源没有被选中
                [weakSelf.selectedCellIndexPathArray addObject:indexPath];
                HQLPhotoPickerCell *cell = (HQLPhotoPickerCell *)[collectionView cellForItemAtIndexPath:indexPath];
                [cell setSelectedAnimation:YES animated:YES];
            } else { // 表明之前已有这个资源
                [weakSelf.photoManager removeSelectedAssetWithIdentifier:currentModel.assetLocalizationIdentifier complete:^(BOOL isSuccess, NSString *message) {
                    if (isSuccess) { // 表明删除成功
                        NSIndexPath *dele;
                        for (NSIndexPath *path in weakSelf.selectedCellIndexPathArray) {
                            if ([path compare:indexPath] == NSOrderedSame) {
                                dele = path;
                            }
                        }
                        if (dele) {
                            [weakSelf.selectedCellIndexPathArray removeObject:dele];
                            HQLPhotoPickerCell *cell = (HQLPhotoPickerCell *)[collectionView cellForItemAtIndexPath:indexPath];
                            [cell setSelectedAnimation:NO animated:YES];
                        }
                    } else { // 删除失败
                        NSLog(@"%@", message);
                    }
                }];
            }
        }];
    }
}

#pragma mark - preview View delegate

- (NSUInteger)numberOfPhotos:(HQLPreviewView *)previewView {
    return self.albumModel.count;
}

- (void)previewView:(HQLPreviewView *)previewView renderPhotoPreviewView:(HQLPhotoPreviewView *)photoPreviewView atIndex:(NSUInteger)index {
    [photoPreviewView activityIndicatorViewAnimate:YES];
    
    HQLWeakSelf;
    
    HQLPhotoModel *model = self.albumModel.photoArray[index];
    photoPreviewView.delegate = self;
    
    switch (model.mediaType) {
        case HQLPhotoModelMediaTypePhoto: {
            [model requestHighDefinitionImageWithProgressHandler:^(double progress, NSError * _Nullable error, BOOL * _Nonnull stop, NSDictionary * _Nullable info) {
                
                if (!photoPreviewView.thumbnail) {
                    dispatch_async(dispatch_get_main_queue(), ^{
                        photoPreviewView.thumbnail = model.thumbnailImage;
                    });
                }
                
            } resultHandler:^(UIImage *highDefinitionImage, NSString *error) {
                if (![error isEqualToString:@""]) {
                    // 发生错误
                    [HQLPhotoHelper showAlertViewWithTitle:@"错误" message:error controller:weakSelf];
                } else {
                    if (highDefinitionImage) {
                        photoPreviewView.photo = highDefinitionImage;
                    }
                }
            }];
            break;
        }
        case HQLPhotoModelMediaTypePhotoGif: {
            [model requestOriginalImageDataWithProgressHandler:^(double progress, NSError * _Nullable error, BOOL * _Nonnull stop, NSDictionary * _Nullable info) {
                
                if (!photoPreviewView.thumbnail) {
                    dispatch_async(dispatch_get_main_queue(), ^{
                        photoPreviewView.thumbnail = model.thumbnailImage;
                    });
                }
                
            } resultHandler:^(NSData *imageData, NSString *byteString, NSString *error) {
                if (![error isEqualToString:@""]) {
                    // 发生错误
                    [HQLPhotoHelper showAlertViewWithTitle:@"错误" message:error controller:weakSelf];
                    photoPreviewView.thumbnail = model.thumbnailImage;
                } else {
                    if (imageData) {
                        photoPreviewView.gifData = imageData;
                    }
                }
            }];
            break;
        }
        case HQLPhotoModelMediaTypeLivePhoto: {
            [model requestLivePhotoWithProgressHandler:^(double progress, NSError * _Nullable error, BOOL * _Nonnull stop, NSDictionary * _Nullable info) {
                
                if (!photoPreviewView.thumbnail) {
                    dispatch_async(dispatch_get_main_queue(), ^{
                        photoPreviewView.thumbnail = model.thumbnailImage;
                    });
                }
                
            } resultHandler:^(PHLivePhoto *livePhoto, NSString *error) {
                if (![error isEqualToString:@""]) {
                    [HQLPhotoHelper showAlertViewWithTitle:@"错误" message:error controller:weakSelf];
                    photoPreviewView.thumbnail = model.thumbnailImage;
                } else {
                    if (livePhoto) {
                        photoPreviewView.livePhoto = livePhoto;
                    }
                }
            }];
            break;
        }
        case HQLPhotoModelMediaTypeVideo: {
            [model requestPlayerItemWithProgressHandler:^(double progress, NSError * _Nullable error, BOOL * _Nonnull stop, NSDictionary * _Nullable info) {

                
                if (!photoPreviewView.videoViewThumbnail) {
                    dispatch_async(dispatch_get_main_queue(), ^{
                        [photoPreviewView setVideoViewThumbnail:model.thumbnailImage];
                    });
                }
                
            } resultHandler:^(AVPlayerItem *playerItem, NSString *error) {
                if (![error isEqualToString:@""]) {
                    [HQLPhotoHelper showAlertViewWithTitle:@"错误" message:error controller:weakSelf];
                    [photoPreviewView setVideoViewThumbnail:model.thumbnailImage];
                } else {
                    if (playerItem) {
                        photoPreviewView.playerItem = playerItem;
                    }
                }
            }];
            break;
        }
        case HQLPhotoModelMediaTypeAudio: { break; }
        case HQLPhotoModelMediaTypeUnKnow: { break; }
    }
    
}

- (void)previewView:(HQLPreviewView *)previewView willDisplayPhotoPreviewView:(HQLPhotoPreviewView *)photoPreviewView atIndex:(NSUInteger)index {
    
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

#pragma mark - photo manager delegate

- (void)photoLibraryDidChange:(PHChange *)changeInstance
           changedAlbum:(HQLPhotoAlbumModel *)album
           changeResult:(PHFetchResultChangeDetails *)changeResult
           changeIndex:(NSArray<NSNumber *> *)changeIndex
           changeType:(HQLPhotoLibraryDidChangeType)changeType
{
    [self.previewView reloadData];
    if ([album.albumName isEqualToString:self.albumModel.albumName]) {
        // 更新 selectedIndexPath
        [self updateSelectedCellIndexPath];
        // 因为如果这个代理调用了，表明就有变化
        NSMutableArray *indexPathArray = [NSMutableArray array];
        for (NSNumber *index in changeIndex) {
            [indexPathArray addObject:[NSIndexPath indexPathForItem:([index integerValue] + (self.isShowTakePhotoCell ? 1 : 0)) inSection:0]];
        }
        switch (changeType) {
            case HQLPhotoLibraryDidRemove: { // 删除
                [self.thumbnailCollectionView deleteItemsAtIndexPaths:indexPathArray];
                break;
            }
            case HQLPhotoLibraryDidChange: { // 改变
                [self.thumbnailCollectionView reloadItemsAtIndexPaths:indexPathArray];
                break;
            }
            case HQLPhotoLibraryDidInsert: { // 插入
                [self.thumbnailCollectionView insertItemsAtIndexPaths:indexPathArray];
                break;
            }
            case HQLPhotoLibraryDidMove: { // 移动和其他都不一样
                if (changeResult.hasIncrementalChanges && changeResult.hasMoves) {
                    [changeResult enumerateMovesWithBlock:^(NSUInteger fromIndex, NSUInteger toIndex) {
                        NSIndexPath *fromPath = [NSIndexPath indexPathForItem:fromIndex inSection:0];
                        NSIndexPath *toPath = [NSIndexPath indexPathForItem:toIndex inSection:0];
                        [self.thumbnailCollectionView moveItemAtIndexPath:fromPath toIndexPath:toPath];
                    }];
                }
                break;
            }
            case HQLPhotoLibraryDidNotChange: { break; }
        }
    }
}

#pragma mark - setter

- (void)setIsShowTakePhotoCell:(BOOL)isShowTakePhotoCell {
    [super setIsShowTakePhotoCell:isShowTakePhotoCell];
    [self.previewView reloadData];
}

- (void)setAlbumModel:(HQLPhotoAlbumModel *)albumModel {
    [super setAlbumModel:albumModel];
    
    [self.previewView reloadData];
    
    // 更新selectedCellIndexPath
    [self updateSelectedCellIndexPath];
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

@end
