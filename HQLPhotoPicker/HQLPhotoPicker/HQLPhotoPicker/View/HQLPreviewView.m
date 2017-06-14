//
//  HQLPreviewView.m
//  HQLPhotoPicker
//
//  Created by 何启亮 on 2017/6/13.
//  Copyright © 2017年 weplus. All rights reserved.
//

#import "HQLPreviewView.h"
#import "HQLPhotoPreviewView.h"

#define HQLCollectionViewCellPhotoReuseId @"HQLCollectionViewCellPhotoReuseId"
#define HQLCollectionViewCellGifReuseId @"HQLCollectionViewCellGifReuseId"
#define HQLCollectionViewCellVideoReuseld @"HQLCollectionViewCellVideoReuseld"
#define HQLCollectionViewCellLivePhotoReuseld @"HQLCollectionViewCellLivePhotoReuseld"
#define HQLCollectionViewCellUnknownReuseId @"HQLCollectionViewCellUnknownReuseId"

@interface HQLPreviewView () <HQLPhotoPreviewViewDelegate, UICollectionViewDelegate, UICollectionViewDataSource>

@property (strong, nonatomic) UICollectionView *collectionView;
@property (strong, nonatomic) UICollectionViewFlowLayout *flowLayout;

@end

@implementation HQLPreviewView

#pragma mark - initialize method

#pragma mark - event

- (void)setCurrentIndex:(NSUInteger)currentIndex animated:(BOOL)animated {
    if (currentIndex >= [self.collectionView numberOfItemsInSection:0]) {
        return;
    }
    _currentIndex = currentIndex;
    [self.collectionView scrollToItemAtIndexPath:[NSIndexPath indexPathForItem:currentIndex inSection:0] atScrollPosition:UICollectionViewScrollPositionCenteredHorizontally animated:animated];
}

- (void)reloadData {
    [self.collectionView reloadData];
}

#pragma mark - collection view delegate

- (void)collectionView:(UICollectionView *)collectionView didEndDisplayingCell:(UICollectionViewCell *)cell forItemAtIndexPath:(NSIndexPath *)indexPath {
    if (collectionView != self.collectionView) {
        return;
    }
    HQLPreviewViewCell *targetCell = (HQLPreviewViewCell *)cell;
    [targetCell.photoPreviewView resetViewStatus];
    if ([self.delegate respondsToSelector:@selector(previewView:didEndDisplayPhotoPreviewView:atIndex:)]) {
        [self.delegate previewView:self didEndDisplayPhotoPreviewView:targetCell.photoPreviewView atIndex:indexPath.item];
    }
}

- (void)collectionView:(UICollectionView *)collectionView willDisplayCell:(UICollectionViewCell *)cell forItemAtIndexPath:(NSIndexPath *)indexPath {
    if ([self.delegate respondsToSelector:@selector(previewView:willDisplayPhotoPreviewView:atIndex:)]) {
        HQLPreviewViewCell *targetCell = (HQLPreviewViewCell *)cell;
        [self.delegate previewView:self willDisplayPhotoPreviewView:targetCell.photoPreviewView atIndex:indexPath.item];
    }
}

#pragma mark - collection view data source 

- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView {
    return 1;
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    [self checkIfDelegateMissingWithSEL:@selector(numberOfPhotos:)];
    return [self.delegate numberOfPhotos:self];
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    HQLPhotoModelMediaType type = HQLPhotoModelMediaTypeUnKnow;
    NSString *identifier = HQLCollectionViewCellUnknownReuseId;
    if ([self.delegate respondsToSelector:@selector(previewView:assetTypeAtIndex:)]) {
        type = [self.delegate previewView:self assetTypeAtIndex:indexPath.item];
    }
    switch (type) {
        case HQLPhotoModelMediaTypePhoto:
        case HQLPhotoModelMediaTypeCameraPhoto: {
            identifier = HQLCollectionViewCellPhotoReuseId;
            break;
        }
        case HQLPhotoModelMediaTypePhotoGif: {
            identifier = HQLCollectionViewCellGifReuseId;
            break;
        }
        case HQLPhotoModelMediaTypeCameraVideo:
        case HQLPhotoModelMediaTypeVideo: {
            identifier = HQLCollectionViewCellVideoReuseld;
            break;
        }
        case HQLPhotoModelMediaTypeLivePhoto: {
            identifier = HQLCollectionViewCellLivePhotoReuseld;
            break;
        }
        case HQLPhotoModelMediaTypeAudio: { break; }
        case HQLPhotoModelMediaTypeUnKnow: { break; }
    }
    HQLPreviewViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:identifier forIndexPath:indexPath];
    cell.photoPreviewView.photo = nil;
    cell.photoPreviewView.gifData = nil;
    cell.photoPreviewView.playerItem = nil;
    cell.photoPreviewView.livePhoto = nil;
    
    [self checkIfDelegateMissingWithSEL:@selector(previewView:renderPhotoPreviewView:atIndex:)];
    [self.delegate previewView:self renderPhotoPreviewView:cell.photoPreviewView atIndex:indexPath.item];
    
    return cell;
}

- (void)checkIfDelegateMissingWithSEL:(SEL)selector {
    if (![self.delegate respondsToSelector:selector]) {
        NSAssert(NO, @"%@ 需要响应 %@ 的方法 -%@", NSStringFromClass([self class]), NSStringFromProtocol(@protocol(HQLPreviewViewDelegate)), NSStringFromSelector(selector));
    }
}

#pragma mark - scroll view delegate

- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView {
    [self scrollViewDidEndScrollingAnimation:scrollView];
}

- (void)scrollViewDidEndScrollingAnimation:(UIScrollView *)scrollView {
    // 计算当前显示的View
    
    if ([self.delegate respondsToSelector:@selector(previewView:didDisplayPhotoPreviewView:atIndex:)]) {
        NSUInteger index = scrollView.contentOffset.x / self.flowLayout.itemSize.width;
        HQLPreviewViewCell *cell = (HQLPreviewViewCell *)[self.collectionView cellForItemAtIndexPath:[NSIndexPath indexPathForItem:index inSection:0]];
        if (cell) {
            [self.delegate previewView:self didDisplayPhotoPreviewView:cell.photoPreviewView atIndex:index];
        }
    }
}

#pragma mark - setter

- (void)setCurrentIndex:(NSUInteger)currentIndex {
    [self setCurrentIndex:currentIndex animated:NO];
}

#pragma mark - getter

- (UICollectionView *)collectionView {
    if (!_collectionView) {
        _collectionView = [[UICollectionView alloc] initWithFrame:self.bounds collectionViewLayout:self.flowLayout];
        [_collectionView setBackgroundColor:[UIColor blackColor]];
        _collectionView.delegate = self;
        _collectionView.dataSource = self;
        _collectionView.showsVerticalScrollIndicator = NO;
        _collectionView.showsHorizontalScrollIndicator = NO;
        _collectionView.pagingEnabled = YES;
        
        // 注册cell
        [_collectionView registerClass:[HQLPreviewViewCell class] forCellWithReuseIdentifier:HQLCollectionViewCellPhotoReuseId];
        [_collectionView registerClass:[HQLPreviewViewCell class] forCellWithReuseIdentifier:HQLCollectionViewCellGifReuseId];
        [_collectionView registerClass:[HQLPreviewViewCell class] forCellWithReuseIdentifier:HQLCollectionViewCellVideoReuseld];
        [_collectionView registerClass:[HQLPreviewViewCell class] forCellWithReuseIdentifier:HQLCollectionViewCellLivePhotoReuseld];
        [_collectionView registerClass:[HQLPreviewViewCell class] forCellWithReuseIdentifier:HQLCollectionViewCellUnknownReuseId];
        
        [self addSubview:_collectionView];
    }
    return _collectionView;
}

- (UICollectionViewFlowLayout *)flowLayout {
    if (!_flowLayout) {
        _flowLayout = [[UICollectionViewFlowLayout alloc] init];
        _flowLayout.minimumLineSpacing = 0;
        _flowLayout.minimumInteritemSpacing = 0;
        _flowLayout.itemSize = self.bounds.size;
        _flowLayout.scrollDirection = UICollectionViewScrollDirectionHorizontal;
    }
    return _flowLayout;
}

@end

@implementation HQLPreviewViewCell

#pragma mark - initialize method

- (instancetype)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        [self viewConfig];
    }
    return self;
}

- (instancetype)init {
    if (self = [super init]) {
        [self viewConfig];
    }
    return self;
}

- (void)awakeFromNib {
    [super awakeFromNib];
    [self viewConfig];
}

- (void)layoutSubviews {
    [super layoutSubviews];
    
    self.photoPreviewView.frame = self.bounds;
}

#pragma mark - event

- (void)viewConfig {
    _photoPreviewView = [[HQLPhotoPreviewView alloc] init];
    [self.contentView addSubview:_photoPreviewView];
}

@end
