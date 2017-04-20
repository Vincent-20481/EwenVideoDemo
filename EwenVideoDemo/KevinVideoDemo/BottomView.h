//
//  BottomView.h
//  EwenVideoDemo
//
//  Created by EwenMac on 2017/4/19.
//  Copyright © 2017年 Suomusic. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface BottomView : UIImageView
@property(nonatomic,strong)UILabel *leftTime;//进度时间
@property(nonatomic,strong)UILabel *rightTime;//视频总时间
@property(nonatomic,strong)UIProgressView *progressView;//缓存进度条
@property(nonatomic,strong)UISlider *slider;//播放进度条
@property(nonatomic,strong)UIButton *fullScreenButton;//全屏
@end
