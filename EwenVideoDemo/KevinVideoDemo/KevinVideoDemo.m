//
//  KevinVideoDemo.m
//  EwenVideoDemo
//
//  Created by EwenMac on 2017/4/18.
//  Copyright © 2017年 Suomusic. All rights reserved.
//

#import "KevinVideoDemo.h"

@interface KevinVideoDemo()

@property(nonatomic,strong)UIImageView *backGroundImageView;//未加载视频默认背景
@property(nonatomic,strong)UIImageView *bottomShabow;//下方阴影
@property(nonatomic,strong)UILabel *leftTime;//进度时间
@property(nonatomic,strong)UILabel *rightTime;//视频总时间
@property(nonatomic,strong)UIActivityIndicatorView *activityIndicatorView;//等待菊花
@property(nonatomic,strong)UIProgressView *progressView;//缓存进度条
@property(nonatomic,strong)UISlider *slider;//播放进度条
@property(nonatomic,strong)UIButton *fullScreenButton;//全屏


@end


@implementation KevinVideoDemo

- (instancetype)initWithFrame:(CGRect)frame{
    if (self = [super initWithFrame:frame]) {
        [self createUI];
    }
    return self;
}

- (void)createUI{
    self.backgroundColor = [UIColor grayColor];
    [self.backGroundImageView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.mas_equalTo(0);
    }];
    
    [self.bottomShabow mas_makeConstraints:^(MASConstraintMaker *make) {
        make.bottom.mas_equalTo(0);
        make.left.right.mas_equalTo(0);
        make.height.mas_equalTo(55);
    }];
    
    
}














#pragma mark --- 懒加载控件
- (UIImageView *)backGroundImageView{
    if (_backGroundImageView) {
        _backGroundImageView = [UIImageView new];
        _backGroundImageView.userInteractionEnabled = YES;
        [self addSubview:_backGroundImageView];
    }
    return _backGroundImageView;
}

- (UIImageView *)bottomShabow{
    if (!_bottomShabow) {
        _bottomShabow = [UIImageView new];
        _bottomShabow.userInteractionEnabled = YES;
        [self addSubview:_bottomShabow];
    }
    return _bottomShabow;
}

- (UILabel *)leftTime{
    if (!_leftTime) {
        _leftTime = [UILabel new];
        [self.bottomShabow addSubview:_leftTime];
    }
    return _leftTime;
}

- (UILabel *)rightTime{
    if (!_rightTime) {
        _rightTime = [UILabel new];
        [self.bottomShabow addSubview:_rightTime];
    }
    return _rightTime;
}

- (UIActivityIndicatorView *)activityIndicatorView{
    if (!_activityIndicatorView) {
        _activityIndicatorView = [UIActivityIndicatorView new];
        [self addSubview:_activityIndicatorView];
    }
    return _activityIndicatorView;
}

- (UIProgressView *)progressView{
    if (!_progressView) {
        _progressView = [UIProgressView new];
        [self.bottomShabow addSubview:_progressView];
    }
    return _progressView;
}

- (UISlider *)slider{
    if (!_slider) {
        _slider = [UISlider new];
        [self.bottomShabow addSubview:_slider];
    }
    return _slider;
}









@end
