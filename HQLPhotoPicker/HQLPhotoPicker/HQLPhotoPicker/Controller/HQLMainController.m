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
#import "HQLPhotoPickerModalController.h"

#import "HQLPhotoManager.h"
#import "HQLPhotoAlbumModel.h"
#import "HQLPhotoModel.h"

#import "HQLPhotoAlbumCell.h"

#define HQLPhotoAlbumCellReuseId @"HQLPhotoAlbumCellReuseId"
#define kTableViewCellHeight 60

@interface HQLMainController () <UITableViewDelegate, UITableViewDataSource, HQLPHotoPickerModalControllerDelegate>

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

#pragma mark - photo picker modal controller delegate

- (void)photoPickerModalControllerDidClickCloseButton:(HQLPhotoPickerModalController *)controller {
    [self dismissViewControllerAnimated:YES completion:^{
        
    }];
}

#pragma mark - table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
//    HQLPhotoPickerController *controller = [[HQLPhotoPickerController alloc] init];
//    controller.albumModel = self.photoManager.albumArray[indexPath.row];
//    [self.navigationController pushViewController:controller animated:YES];
    HQLPhotoPickerModalController *controller = [[HQLPhotoPickerModalController alloc] init];
    controller.albumModel = self.photoManager.albumArray[indexPath.row];
    controller.delegate = self;
    [self presentViewController:controller animated:YES completion:^{
        
    }];
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
    HQLPhotoAlbumCell *cell = [tableView dequeueReusableCellWithIdentifier:HQLPhotoAlbumCellReuseId];
    cell.albumModel = self.photoManager.albumArray[indexPath.row];
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
        
        _tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
        
        [_tableView registerNib:[UINib nibWithNibName:@"HQLPhotoAlbumCell" bundle:nil] forCellReuseIdentifier:HQLPhotoAlbumCellReuseId];
        
        [self.view addSubview:_tableView];
    }
    return _tableView;
}

- (HQLPhotoManager *)photoManager {
    if (!_photoManager) {
        _photoManager = [HQLPhotoManager shareManager];
        _photoManager.selectedType = HQLPhotoManagerSelectedTypePhotoAndVideo;
        _photoManager.isLivePhotoOpen = YES;
        _photoManager.isGifOpen = YES;
    }
    return _photoManager;
}

@end
