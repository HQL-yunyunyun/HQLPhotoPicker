//
//  HQLPhotoPickerController.m
//  HQLPhotoPicker
//
//  Created by weplus on 2017/6/6.
//  Copyright © 2017年 weplus. All rights reserved.
//

#import "HQLPhotoPickerController.h"

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
        _flowLayout.minimumLineSpacing = 0;
        _flowLayout.minimumInteritemSpacing = 0;
        CGFloat itemWidth = self.view.width / kColumnCount;
        _flowLayout.itemSize = CGSizeMake(itemWidth, itemWidth);
        
    }
    return _flowLayout;
}

@end
