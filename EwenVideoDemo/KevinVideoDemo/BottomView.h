//
//  BottomView.h
//  EwenVideoDemo
//
//  Created by EwenMac on 2017/4/19.
//  Copyright © 2017年 Suomusic. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef void(^FullScreenButtonBlock)(BOOL fullStatus);

@protocol BottomViewDelegate <NSObject>
/** slider的点击事件（点击slider控制进度） */
- (void)bottomView:(UIView *)controlView progressSliderTap:(CGFloat)value;
/** 开始触摸slider */
- (void)bottomView:(UIView *)controlView progressSliderTouchBegan:(UISlider *)slider;
/** slider触摸中 */
- (void)bottomView:(UIView *)controlView progressSliderValueChanged:(UISlider *)slider;
/** slider触摸结束 */
- (void)bottomView:(UIView *)controlView progressSliderTouchEnded:(UISlider *)slider;


@end


@interface BottomView : UIImageView

@property(nonatomic,strong)UILabel *leftTime;//进度时间
@property(nonatomic,strong)UILabel *rightTime;//视频总时间
@property(nonatomic,strong)UIProgressView *progressView;//缓存进度条
@property(nonatomic,strong)UISlider *slider;//播放进度条
@property(nonatomic,strong)UIButton *fullScreenButton;//全屏
@property(nonatomic,strong)FullScreenButtonBlock fullScreenBlock;
@property(nonatomic,weak)id<BottomViewDelegate>   delegate;

@end
