//
//  HQLVideoPreViewView.h
//  HQLPhotoPicker
//
//  Created by weplus on 2017/6/8.
//  Copyright © 2017年 weplus. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <AVFoundation/AVFoundation.h>

@interface HQLVideoPreViewView : UIView

@property (strong, nonatomic) AVPlayerItem *playerItem;

- (void)controlViewShowAnimate;
- (void)controlViewHideAnimate;

@end
