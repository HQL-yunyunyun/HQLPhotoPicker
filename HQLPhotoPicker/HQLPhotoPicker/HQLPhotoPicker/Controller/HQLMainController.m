//
//  HQLMainController.m
//  HQLPhotoPicker
//
//  Created by weplus on 2017/6/5.
//  Copyright © 2017年 weplus. All rights reserved.
//

#import "HQLMainController.h"

#import "HQLPhotoManager.h"
#import "HQLPhotoAlbumModel.h"

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
    
    if (self.photoManager.currentPhotoAuthorizationStatus) {
        
    }
    
    HQLWeakSelf;
    [self.photoManager fetchAllAlbumWithCompleteBlock:^(NSMutableArray<HQLPhotoAlbumModel *> *albumArray) {
        [weakSelf.tableView reloadData];
    }];
}

#pragma mark - table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.photoManager.albumArray.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
//    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"tableViewCellID"];
    UITableViewCell *cell = [[UITableViewCell alloc] init];
    HQLPhotoAlbumModel *model = self.photoManager.albumArray[indexPath.row];
    cell.textLabel.text = [NSString stringWithFormat:@"%@(%ld)", model.albumName, model.count];
    return cell;
}

#pragma mark - getter

- (UITableView *)tableView {
    if (!_tableView) {
        _tableView = [[UITableView alloc] initWithFrame:self.view.bounds style:UITableViewStylePlain];
        _tableView.delegate = self;
        _tableView.dataSource = self;
        
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
