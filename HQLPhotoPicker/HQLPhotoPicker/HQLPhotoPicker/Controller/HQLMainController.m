//
//  HQLMainController.m
//  HQLPhotoPicker
//
//  Created by weplus on 2017/6/5.
//  Copyright © 2017年 weplus. All rights reserved.
//

#import "HQLMainController.h"
#import "UIView+Frame.h"

#import "HQLPhotoPickerController.h"

#import "HQLPhotoManager.h"
#import "HQLPhotoAlbumModel.h"
#import "HQLPhotoModel.h"

#define HQLPhotoAlbumCellReuseId @"HQLPhotoAlbumCellReuseId"
#define kTableViewCellHeight 60

@interface HQLMainController () <UITableViewDelegate, UITableViewDataSource>

@property (strong, nonatomic) UITableView *tableView;
@property (strong, nonatomic) HQLPhotoManager *photoManager;

@end

@implementation HQLMainController

#pragma mark - life cycle

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self controllerConfig];
}

#pragma mark - event

- (void)controllerConfig {
    [self.view setBackgroundColor:[UIColor whiteColor]];
    self.automaticallyAdjustsScrollViewInsets = NO;
    
    HQLWeakSelf;
    
    switch (self.photoManager.currentPhotoAuthorizationStatus) {
        case PHAuthorizationStatusNotDetermined: { // 还没确定
            [self.photoManager requestPhotoAuthorizationWithCompleteHandler:^(PHAuthorizationStatus status) {
                if (status == PHAuthorizationStatusAuthorized) {
                    [self.photoManager fetchAllAlbumWithCompleteBlock:^(NSMutableArray<HQLPhotoAlbumModel *> *albumArray) {
                        [weakSelf.tableView reloadData];
                    }];
                } else {
                    NSLog(@"不允许使用相册");
                }
            }];
            break;
        }
        case PHAuthorizationStatusAuthorized: {
            NSLog(@"允许使用");
            [self.photoManager fetchAllAlbumWithCompleteBlock:^(NSMutableArray<HQLPhotoAlbumModel *> *albumArray) {
                [weakSelf.tableView reloadData];
            }];
            break;
        }
        case PHAuthorizationStatusDenied:
        case PHAuthorizationStatusRestricted: {
            NSLog(@"不允许使用");
            break;
        }
    }
}

#pragma mark - table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    HQLPhotoPickerController *controller = [[HQLPhotoPickerController alloc] init];
    controller.albumModel = self.photoManager.albumArray[indexPath.row];
    [self.navigationController pushViewController:controller animated:YES];
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return kTableViewCellHeight;
}

#pragma mark - table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.photoManager.albumArray.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:HQLPhotoAlbumCellReuseId];
    if (!cell) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:HQLPhotoAlbumCellReuseId];
    }
    HQLPhotoAlbumModel *album = self.photoManager.albumArray[indexPath.row];
    HQLPhotoModel *photo = album.albumCover;
    // 设置封面
    if (photo.thumbnailImage) {
        cell.imageView.image = photo.thumbnailImage;
    } else {
        cell.imageView.image = [UIImage imageWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"defaultImage" ofType:@"png"]];
        [self.photoManager fetchImageWithPHAsset:photo.asset photoQuality:HQLPhotoQualityThumbnails photoSize:CGSizeMake(kTableViewCellHeight, kTableViewCellHeight) progressHandler:^(double progress, NSError * _Nullable error, BOOL * _Nonnull stop, NSDictionary * _Nullable info) {
            NSLog(@"progress : %g", progress);
            if (error) {
                NSLog(@"progress error : %@", error);
            }
        } resultHandler:^(UIImage *image, NSDictionary *info) {
            cell.imageView.image = image;
            photo.thumbnailImage = image; // 记录缩略图
        }];
    }
    
    cell.textLabel.text = [NSString stringWithFormat:@"%@(%ld)", album.albumName, album.count];
    cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    
    return cell;
}

#pragma mark - getter

- (UITableView *)tableView {
    if (!_tableView) {
        _tableView = [[UITableView alloc] initWithFrame:self.view.bounds style:UITableViewStylePlain];
        _tableView.y = 64;
        _tableView.height -= 64;
        _tableView.delegate = self;
        _tableView.dataSource = self;
        [_tableView setShowsVerticalScrollIndicator:NO];
        [_tableView setShowsHorizontalScrollIndicator:NO];
        
        [self.view addSubview:_tableView];
    }
    return _tableView;
}

- (HQLPhotoManager *)photoManager {
    if (!_photoManager) {
        _photoManager = [HQLPhotoManager shareManager];
    }
    return _photoManager;
}

@end
