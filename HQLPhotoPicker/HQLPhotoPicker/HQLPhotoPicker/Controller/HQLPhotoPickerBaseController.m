//
//  HQLPhotoPickerBaseController.m
//  HQLPhotoPicker
//
//  Created by 何启亮 on 2017/6/22.
//  Copyright © 2017年 weplus. All rights reserved.
//

#import "HQLPhotoPickerBaseController.h"
#import "UIView+Frame.h"


#define HQLPhotoPickerCellReuseId @"HQLPhotoPickerCellReuseId"
#define HQLTakePhotoCellReuseId @"HQLTakePhotoCellReuseId"
#define kColumnCount 4

@interface HQLPhotoPickerBaseController ()

@end

@implementation HQLPhotoPickerBaseController {
    UICollectionView *_thumbnailCollectionView;
    UICollectionViewFlowLayout *_flowLayout;
    UIButton *_confirmButton;
     NSMutableArray *_selectedCellIndexPathArray;
    HQLPhotoManager *_photoManager;
}

#pragma mark - life cycle

- (void)viewDidLoad {
    [super viewDidLoad];
    [self controllerConfig];
}

- (void)dealloc {
    [self.photoManager unregisterChangeObserver:self];
    NSLog(@"dealloc ---> %@", NSStringFromClass([self class]));
}

#pragma mark - event

- (void)controllerConfig {
    
}

- (void)confirmButtonDidClick:(UIButton *)button {
    if ([self.selectedDelegate respondsToSelector:@selector(photoPickerController:didFinishPickingPhotoWithPhotoAssetArray:)]) {
        [self.selectedDelegate photoPickerController:self didFinishPickingPhotoWithPhotoAssetArray:[self.photoManager getSelectedAsset]];
        [self.photoManager removeAllSelectedAsset];
    }
}

#pragma mark - <UICollectionViewDataSource>

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
    cell.isShowCheckButton = self.collectionViewShowCheckButton;
    cell.isShowSelectedBorder = self.collectionViewShowSelectedBorder;
    return cell;
}

#pragma mark - setter

- (void)setCollectionViewShowCheckButton:(BOOL)collectionViewShowCheckButton {
    _collectionViewShowCheckButton = collectionViewShowCheckButton;
    [self.thumbnailCollectionView reloadData];
}

- (void)setCollectionViewShowSelectedBorder:(BOOL)collectionViewShowSelectedBorder {
    _collectionViewShowSelectedBorder = collectionViewShowSelectedBorder;
    [self.thumbnailCollectionView reloadData];
}

- (void)setIsShowTakePhotoCell:(BOOL)isShowTakePhotoCell {
    _isShowTakePhotoCell = isShowTakePhotoCell;
    [self.thumbnailCollectionView reloadData];
}

- (void)setAlbumModel:(HQLPhotoAlbumModel *)albumModel {
    _albumModel = albumModel;
    
    [self.thumbnailCollectionView reloadData];
}

- (void)setMaxSelectCount:(NSUInteger)maxSelectCount {
    _maxSelectCount = maxSelectCount <= 0 ? 1 : (maxSelectCount >= 9 ? 9 : maxSelectCount);
    
    [self.photoManager removeAllSelectedAsset];
}

#pragma mark - getter

- (NSMutableArray *)selectedCellIndexPathArray {
    if (!_selectedCellIndexPathArray) {
        _selectedCellIndexPathArray = [NSMutableArray array];
    }
    return _selectedCellIndexPathArray;
}

- (UIButton *)confirmButton {
    if (!_confirmButton) {
        _confirmButton = [UIButton buttonWithType:UIButtonTypeCustom];
        
        [_confirmButton addTarget:self action:@selector(confirmButtonDidClick:) forControlEvents:UIControlEventTouchUpInside];
    }
    return _confirmButton;
}

- (UICollectionView *)thumbnailCollectionView {
    if (!_thumbnailCollectionView) {
        _thumbnailCollectionView = [[UICollectionView alloc] initWithFrame:CGRectMake(0, 0, self.view.width, self.view.height) collectionViewLayout:self.flowLayout];
        _thumbnailCollectionView.delegate = self;
        _thumbnailCollectionView.dataSource = self;
        _thumbnailCollectionView.showsVerticalScrollIndicator = NO;
        _thumbnailCollectionView.showsHorizontalScrollIndicator = NO;
        [_thumbnailCollectionView setBackgroundColor:[UIColor whiteColor]];
        
        [_thumbnailCollectionView registerClass:[HQLPhotoPickerCell class] forCellWithReuseIdentifier:HQLPhotoPickerCellReuseId];
        [_thumbnailCollectionView registerClass:[HQLTakePhotoCell class] forCellWithReuseIdentifier:HQLTakePhotoCellReuseId];
        
//        [self.view addSubview:_thumbnailCollectionView];
    }
    return _thumbnailCollectionView;
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

- (HQLPhotoManager *)photoManager {
    if (!_photoManager) {
        _photoManager = [HQLPhotoManager shareManager];
        [_photoManager registerChangeObserver:self];
    }
    return _photoManager;
}

@end
