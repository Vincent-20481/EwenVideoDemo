//
//  KevinVideoDemo.m
//  EwenVideoDemo
//
//  Created by EwenMac on 2017/4/18.
//  Copyright © 2017年 Suomusic. All rights reserved.
//

#import "KevinVideoDemo.h"
#import "BottomView.h"
@interface KevinVideoDemo()

@property(nonatomic,strong)UIImageView *backGroundImageView;//未加载视频默认背景
@property(nonatomic,strong)UIActivityIndicatorView *activityIndicatorView;//等待菊花
@property(nonatomic,strong)BottomView *bottomView;//底部阴影
@property(nonatomic,strong)UIButton *playOrPause;

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
    
    [self.bottomView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.bottom.mas_equalTo(0);
        make.left.right.mas_equalTo(0);
        make.height.mas_equalTo(55);
    }];
    
    [self.activityIndicatorView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.center.mas_equalTo(0);
        make.width.height.mas_equalTo(50);
    }];
    
    [self.playOrPause mas_makeConstraints:^(MASConstraintMaker *make) {
        make.center.mas_equalTo(0);
        make.width.height.mas_equalTo(50);
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

- (UIActivityIndicatorView *)activityIndicatorView{
    if (!_activityIndicatorView) {
        _activityIndicatorView = [UIActivityIndicatorView new];
        [self addSubview:_activityIndicatorView];
    }
    return _activityIndicatorView;
}

- (BottomView *)bottomView{
    if (!_bottomView) {
        _bottomView = [BottomView new];
        [self addSubview:_bottomView];
    }
    return _bottomView;
}

- (UIButton *)playOrPause{
    if (!_playOrPause) {
        _playOrPause = [UIButton new];
        [_playOrPause setBackgroundImage:[UIImage imageNamed:@"video_play"] forState:UIControlStateNormal];
        [_playOrPause setBackgroundImage:[UIImage imageNamed:@"video_play"] forState:UIControlStateHighlighted];
        [_playOrPause setBackgroundImage:[UIImage imageNamed:@"video_stop"] forState:UIControlStateSelected];
        [_playOrPause setBackgroundImage:[UIImage imageNamed:@"video_stop"] forState:UIControlStateSelected | UIControlStateHighlighted];
        [self addSubview:_playOrPause];
    }
    return _playOrPause;
}





@end
