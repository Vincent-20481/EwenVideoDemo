//
//  ClearView.h
//  EwenVideoDemo
//
//  Created by EwenMac on 2017/4/23.
//  Copyright © 2017年 Suomusic. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "masonry.h"
#import "BottomView.h"
typedef void(^LayoutBlock)(MASConstraintMaker * make);
typedef void(^ClearViewBlock)(BOOL playAndPause);
#define kScreenBounds ([[UIScreen mainScreen] bounds])
#define kScreenwidth (kScreenBounds.size.width)
#define kScreenheight (kScreenBounds.size.height)
#define Window [[UIApplication sharedApplication].delegate window]
@interface ClearView : UIView
/**竖屏的限制block*/
@property(nonatomic,copy)LayoutBlock portraitBlock;
/**横屏的限制block*/
@property(nonatomic,copy)LayoutBlock landscapeBlock;
@property(nonatomic,copy)ClearViewBlock clearViewBlock;
@property(nonatomic,strong)BottomView *bottomView;//底部阴影
@property(nonatomic,strong)UIActivityIndicatorView *activityIndicatorView;//等待菊花
@property(nonatomic,strong)UIButton *playOrPause;//播放按钮
@property(nonatomic,strong)UIImageView *backGroundImageView;//未加载视频默认背景
@property(nonatomic,weak)UIView *supView;
@property(nonatomic,weak)UIView *bmView;


/**设置菊花的显示与隐藏*/
- (void)EwenplayerActivity:(BOOL)animated;
/**设置滑动结束*/
- (void)playerDraggedEnd;

@end
