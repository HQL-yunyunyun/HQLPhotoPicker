//
//  HQLPhotoPickerController.m
//  HQLPhotoPicker
//
//  Created by weplus on 2017/6/6.
//  Copyright © 2017年 weplus. All rights reserved.
//

#import "HQLPhotoPickerController.h"

#import "HQLPhotoPreViewController.h"

#import "HQLPhotoAlbumModel.h"
#import "HQLPhotoModel.h"

#import "UIView+Frame.h"

#import "HQLPhotoPickerCell.h"

#define HQLPhotoPickerCellReuseId @"HQLPhotoPickerCellReuseId"
#define kColumnCount 4

@interface HQLPhotoPickerController () <UICollectionViewDelegate, UICollectionViewDataSource>

@property (strong, nonatomic) UICollectionView *collectionView;
@property (strong, nonatomic) UICollectionViewFlowLayout *flowLayout;

@end

@implementation HQLPhotoPickerController

#pragma mark - life cycle

- (void)viewDidLoad {
    [super viewDidLoad];
    
}

- (void)dealloc {
    NSLog(@"dealloc ---> %@", NSStringFromClass([self class]));
}

#pragma mark - event

- (void)controllerConfig {
    self.automaticallyAdjustsScrollViewInsets = NO;
    [self.view setBackgroundColor:[UIColor whiteColor]];
    
    [self collectionView];
    [self.collectionView reloadData];
}

#pragma mark - collection delegate

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    HQLPhotoPreViewController *controller = [[HQLPhotoPreViewController alloc] init];
    controller.model = self.albumModel.photoArray[indexPath.item];
    [self.navigationController pushViewController:controller animated:YES];
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
    return cell;
}

#pragma mark - setter

- (void)setAlbumModel:(HQLPhotoAlbumModel *)albumModel {
    _albumModel = albumModel;
    
    [self.collectionView reloadData];
}

#pragma mark - getter

- (UICollectionView *)collectionView {
    if (!_collectionView) {
        _collectionView = [[UICollectionView alloc] initWithFrame:self.view.bounds collectionViewLayout:self.flowLayout];
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
