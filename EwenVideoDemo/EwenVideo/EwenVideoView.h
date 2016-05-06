//
//  EwenVideoView.h
//  EwenVideoDemo
//
//  Created by apple on 16/5/6.
//  Copyright © 2016年 Suomusic. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Masonry.h"
#import <AVFoundation/AVFoundation.h>
#define kScreenBounds ([[UIScreen mainScreen] bounds])
#define kScreenwidth (kScreenBounds.size.width)
#define kScreenheight (kScreenBounds.size.height)
#define KBL kScreenwidth/375

typedef void(^LayoutBlock)(MASConstraintMaker * make);


@interface EwenVideoView : UIView

@property (nonatomic,weak)UIView *supView;


/**
 *  @b 是否在播放
 */
@property (nonatomic, assign, readonly) BOOL isPlaying;

/**
 *  @b 视频的总长度
 */
@property (nonatomic, assign) float totalSeconds;

/**
 * @b 视频源urlStr
 */
@property (nonatomic, copy) NSString * videoUrlStr;


/**
 * @b 唯一的实例方法, 请不要用其他的实例方法
 */
+(EwenVideoView *)avplayerViewWithVideoUrlStr:(NSString *)videoUrl;


/**
 * @b 设置初始位置block和, 全屏的block
 */
-(void)setPositionWithPortraitBlock:(LayoutBlock)porBlock andLandscapeBlock:(LayoutBlock)landscapeBlock;


/**
 *  向外暴露的播放按钮
 */
-(void)playOrPause;

/**
 *  释放播放器
 */
- (void)kzhiqiDealloc;
@end
