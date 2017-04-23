//
//  KevinVideoDemo.h
//  EwenVideoDemo
//
//  Created by EwenMac on 2017/4/18.
//  Copyright © 2017年 Suomusic. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <Masonry.h>
#import <AVFoundation/AVFoundation.h>
#import "ClearView.h"
// 播放器的几种状态
typedef NS_ENUM(NSInteger, ZFPlayerState) {
    ZFPlayerStateFailed,     // 播放失败
    ZFPlayerStateBuffering,  // 缓冲中
    ZFPlayerStatePlaying,    // 播放中
    ZFPlayerStateStopped,    // 停止播放
    ZFPlayerStatePause       // 暂停播放
};
typedef void(^LayoutBlock)(MASConstraintMaker * make);
@interface KevinVideoDemo : UIView
@property(nonatomic,strong)ClearView *clearView;//用来存放所有的播放器控件
@property (nonatomic, strong)NSURL *videoURL;
/**设置初始位置block和, 全屏的block*/
-(void)setPositionWithPortraitBlock:(LayoutBlock)porBlock andLandscapeBlock:(LayoutBlock)landscapeBlock;


@end
