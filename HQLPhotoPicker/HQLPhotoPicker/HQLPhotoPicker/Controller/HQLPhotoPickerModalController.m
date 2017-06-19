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
#import "HQLTakePhotoCell.h"

#import <MobileCoreServices/MobileCoreServices.h>

#import "UIView+Frame.h"

#define HQLPhotoPickerCellReuseId @"HQLPhotoPickerCellReuseId"
#define HQLTakePhotoCellReuseId @"HQLTakePhotoCellReuseId"
#define kColumnCount 4
#define kVideoMaxDuration 9.0f

#define HQLShowAlertView(Title, Message) [[[UIAlertView alloc] initWithTitle:Title message:Message delegate:nil cancelButtonTitle:@"取消" otherButtonTitles:@"确定", nil] show]

@interface HQLPhotoPickerModalController () <UINavigationControllerDelegate, UIImagePickerControllerDelegate, UICollectionViewDelegate, UICollectionViewDataSource, HQLPreviewViewDelegate, HQLPhotoPreviewViewDelegate>

@property (strong, nonatomic) HQLPreviewView *previewView;
@property (strong, nonatomic) UICollectionView *collectionView;
@property (strong, nonatomic) UICollectionViewFlowLayout *flowLayout;

@property (strong, nonatomic) UIButton *closeButton;
@property (strong, nonatomic) UIButton *confirmButton;

//@property (strong, nonatomic) NSIndexPath *currentSelectedCellIndexPath;

@property (strong, nonatomic) NSMutableArray <NSIndexPath *>*selectedCellIndexPathArray;

@property (assign, nonatomic) BOOL isShowAlertView;

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
    
    self.maxSelectCount = 1;
    self.isShowTakePhotoCell = YES;
}

- (void)dealloc {
    NSLog(@"dealloc ---> %@", NSStringFromClass([self class]));
}

#pragma mark - event

- (void)closeButtonDidClick:(UIButton *)button {
    [[HQLPhotoManager shareManager] removeAllSelectedAsset];
    if ([self.delegate respondsToSelector:@selector(photoPickerModalControllerDidClickCloseButton:)]) {
        [self.delegate photoPickerModalControllerDidClickCloseButton:self];
    }
}

- (void)confirmButtonDidClick:(UIButton *)button {
    
    if ([self.delegate respondsToSelector:@selector(photoPickerModalController:didFinishPickingPhotoWithPhotoAssetArray:)]) {
        [self.delegate photoPickerModalController:self didFinishPickingPhotoWithPhotoAssetArray:[[HQLPhotoManager shareManager] getSelectedAsset]];
        [[HQLPhotoManager shareManager] removeAllSelectedAsset];
    }
}

- (void)showAlertViewWithTitle:(NSString *)title message:(NSString *)message { // 一次只能有一个View
    if (self.isShowAlertView) {
        return;
    }
    HQLWeakSelf;
    self.isShowAlertView = YES;
    UIAlertAction *cancel = [UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {
        weakSelf.isShowAlertView = NO;
    }];
    UIAlertAction *confirm = [UIAlertAction actionWithTitle:@"确定" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        weakSelf.isShowAlertView = NO;
    }];
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:title message:message preferredStyle:UIAlertControllerStyleAlert];
    [alert addAction:cancel];
    [alert addAction:confirm];
    
    [self presentViewController:alert animated:YES completion:nil];
}

- (void)takePhoto {
    
    if (![UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera]) {
        [self showAlertViewWithTitle:@"温馨提示" message:@"当前设备不支持拍照"];
        return;
    }
    
    UIImagePickerController *pickerController = [[UIImagePickerController alloc] init];
    pickerController.allowsEditing = NO;
    pickerController.sourceType = UIImagePickerControllerSourceTypeCamera;
    pickerController.delegate = self;
    
    switch (self.takePhotoType) {
        case HQlPhotoPickerTakePhotoTypeOnlyVideo: {
            pickerController.mediaTypes = @[(NSString *)kUTTypeMovie];
            pickerController.cameraCaptureMode = UIImagePickerControllerCameraCaptureModeVideo;
            pickerController.videoMaximumDuration = kVideoMaxDuration;
            [self presentViewController:pickerController animated:YES completion:nil];
            break;
        }
        case HQLPhotoPickerTakePhotoTypeOnlyPicture: {
            pickerController.cameraCaptureMode = UIImagePickerControllerCameraCaptureModePhoto;
            pickerController.mediaTypes = @[(NSString *)kUTTypeImage];
            [self presentViewController:pickerController animated:YES completion:nil];
            break;
        }
        case HQLPhotoPickerTakePhotoTypeVideoAndPicture: {
            HQLWeakSelf;
            UIAlertController *alertController = [UIAlertController alertControllerWithTitle:@"拍照" message:@"选择拍照方式" preferredStyle:UIAlertControllerStyleActionSheet];
            UIAlertAction *picture = [UIAlertAction actionWithTitle:@"拍照" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
                pickerController.cameraCaptureMode = UIImagePickerControllerCameraCaptureModePhoto;
                pickerController.mediaTypes = @[(NSString *)kUTTypeImage];
                [weakSelf presentViewController:pickerController animated:YES completion:nil];
            }];
            UIAlertAction *video = [UIAlertAction actionWithTitle:@"拍摄" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
                pickerController.mediaTypes = @[(NSString *)kUTTypeMovie];
                pickerController.cameraCaptureMode = UIImagePickerControllerCameraCaptureModeVideo;
                pickerController.videoMaximumDuration = kVideoMaxDuration;
                
                [weakSelf presentViewController:pickerController animated:YES completion:nil];
            }];
            UIAlertAction *cancel = [UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {
                
            }];
            
            [alertController addAction:picture];
            [alertController addAction:video];
            [alertController addAction:cancel];
            [self presentViewController:alertController animated:YES completion:nil];
            break;
        }
    }
}

#pragma mark - image picker controller delegate

- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker {
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary<NSString *,id> *)info {
    NSLog(@"info : %@", info);
    [self dismissViewControllerAnimated:YES completion:nil];
}

#pragma mark - collection delegate

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    
    if (self.isShowTakePhotoCell && indexPath.item == 0) {
        [self takePhoto];
        return;
    }
    
    NSInteger targetIndex = indexPath.item - (self.isShowTakePhotoCell ? 1 : 0);
    
    HQLWeakSelf;
    HQLPhotoManager *manager = [HQLPhotoManager shareManager];
    HQLPhotoModel *currentModel = self.albumModel.photoArray[targetIndex];
    
    if (self.maxSelectCount == 1) {
        
        if ([self.selectedCellIndexPathArray.lastObject compare:indexPath] == NSOrderedSame && self.selectedCellIndexPathArray.count != 0) {
            return;
        }
        
        [self.previewView setCurrentIndex:targetIndex animated:YES];
        // 取消前一个
        [manager removeAllSelectedAsset];
        if (self.selectedCellIndexPathArray.count == 1) {
            HQLPhotoPickerCell *cell = (HQLPhotoPickerCell *)[collectionView cellForItemAtIndexPath:self.selectedCellIndexPathArray.lastObject];
            [cell setSelectedAnimation:NO animated:YES];
        }
        
        [self.selectedCellIndexPathArray removeAllObjects];
        
        [manager addSelectedAssetWithIdentifier:currentModel.assetLocalizationIdentifier complete:^(BOOL isSuccess, NSString *message) {
            if (isSuccess) {
                HQLPhotoPickerCell *cell = (HQLPhotoPickerCell *)[collectionView cellForItemAtIndexPath:indexPath];
                [cell setSelectedAnimation:YES animated:YES];
                [weakSelf.selectedCellIndexPathArray addObject:indexPath];
            } else {
                NSLog(@"%@", message);
            }
        }];
        
    } else {
        if (self.selectedCellIndexPathArray.count >= self.maxSelectCount && ![manager getAssetIsSelectedWithIdentifier:currentModel.assetLocalizationIdentifier]) {
            return;
        }
        
        [self.previewView setCurrentIndex:targetIndex animated:YES];
        
        __weak typeof(manager) weakManager = manager;
        
        [manager addSelectedAssetWithIdentifier:currentModel.assetLocalizationIdentifier complete:^(BOOL isSuccess, NSString *message) {
            if (isSuccess) { // 添加成功表明添加前这个资源没有被选中
                [weakSelf.selectedCellIndexPathArray addObject:indexPath];
                HQLPhotoPickerCell *cell = (HQLPhotoPickerCell *)[collectionView cellForItemAtIndexPath:indexPath];
                [cell setSelectedAnimation:YES animated:YES];
            } else { // 表明之前已有这个资源
                [weakManager removeSelectedAssetWithIdentifier:currentModel.assetLocalizationIdentifier complete:^(BOOL isSuccess, NSString *message) {
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

#pragma mark - collection data source

- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView {
    return 1;
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return self.albumModel.count + (self.isShowTakePhotoCell ? 1 : 0);
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    
    if (self.isShowTakePhotoCell && indexPath.item == 0) { // 显示拍照的cell
        return [collectionView dequeueReusableCellWithReuseIdentifier:HQLTakePhotoCellReuseId forIndexPath:indexPath];
    }
    
    NSInteger sign = self.isShowTakePhotoCell ? 1 : 0;
    HQLPhotoPickerCell *cell = (HQLPhotoPickerCell *)[collectionView dequeueReusableCellWithReuseIdentifier:HQLPhotoPickerCellReuseId forIndexPath:indexPath];
    cell.photoModel = self.albumModel.photoArray[indexPath.item - sign];
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
    
    HQLWeakSelf;
    
    HQLPhotoModel *model = self.albumModel.photoArray[index];
    photoPreviewView.delegate = self;
    
    switch (model.mediaType) {
        case HQLPhotoModelMediaTypePhoto:
        case HQLPhotoModelMediaTypeCameraPhoto: {
            [model requestHighDefinitionImageWithProgressHandler:^(double progress, NSError * _Nullable error, BOOL * _Nonnull stop, NSDictionary * _Nullable info) {
                
            } resultHandler:^(UIImage *highDefinitionImage, NSString *error) {
                if (![error isEqualToString:@""]) {
                    // 发生错误
                    [weakSelf showAlertViewWithTitle:@"错误" message:error];
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
                
            } resultHandler:^(NSData *imageData, NSString *byteString, NSString *error) {
                if (![error isEqualToString:@""]) {
                    // 发生错误
                    [weakSelf showAlertViewWithTitle:@"错误" message:error];
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
                
            } resultHandler:^(PHLivePhoto *livePhoto, NSString *error) {
                if (![error isEqualToString:@""]) {
                    [weakSelf showAlertViewWithTitle:@"错误" message:error];
                    photoPreviewView.thumbnail = model.thumbnailImage;
                } else {
                    if (livePhoto) {
                        photoPreviewView.livePhoto = livePhoto;
                    }
                }
            }];
            break;
        }
        case HQLPhotoModelMediaTypeVideo:
        case HQLPhotoModelMediaTypeCameraVideo: {
            [model requestPlayerItemWithProgressHandler:^(double progress, NSError * _Nullable error, BOOL * _Nonnull stop, NSDictionary * _Nullable info) {
                
            } resultHandler:^(AVPlayerItem *playerItem, NSString *error) {
                if (![error isEqualToString:@""]) {
                    [weakSelf showAlertViewWithTitle:@"错误" message:error];
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

#pragma mark - setter

- (void)setIsShowTakePhotoCell:(BOOL)isShowTakePhotoCell {
    _isShowTakePhotoCell = isShowTakePhotoCell;
    [self.collectionView reloadData];
    [self.previewView reloadData];
}

- (void)setAlbumModel:(HQLPhotoAlbumModel *)albumModel {
    _albumModel = albumModel;
    
    [self.collectionView reloadData];
    [self.previewView reloadData];
    [self.collectionView layoutIfNeeded]; // 强制刷新
    
    // 将selectedCellIndexPath 清空
    [self.selectedCellIndexPathArray removeAllObjects];
    for (NSNumber *index in [[HQLPhotoManager shareManager] getSelectedAssetIndexWithAlbum:albumModel]) {
        [self.selectedCellIndexPathArray addObject:[NSIndexPath indexPathForItem:[index integerValue] inSection:0]];
    }
    
    /*
    if (![self.collectionView cellForItemAtIndexPath:self.currentSelectedCellIndexPath]) {
        self.currentSelectedCellIndexPath = [NSIndexPath indexPathForItem:0 inSection:0];
    }
    [self.collectionView layoutIfNeeded]; // 强制刷新
    [self collectionView:self.collectionView didSelectItemAtIndexPath:self.currentSelectedCellIndexPath];
     */
}

- (void)setMaxSelectCount:(NSUInteger)maxSelectCount {
    _maxSelectCount = maxSelectCount <= 0 ? 1 : (maxSelectCount >= 9 ? 9 : maxSelectCount);
    
    [[HQLPhotoManager shareManager] removeAllSelectedAsset];
}

#pragma mark - getter

- (NSMutableArray<NSIndexPath *> *)selectedCellIndexPathArray {
    if (!_selectedCellIndexPathArray) {
        _selectedCellIndexPathArray = [NSMutableArray array];
    }
    return _selectedCellIndexPathArray;
}

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
        [_collectionView registerClass:[HQLTakePhotoCell class] forCellWithReuseIdentifier:HQLTakePhotoCellReuseId];
        
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
