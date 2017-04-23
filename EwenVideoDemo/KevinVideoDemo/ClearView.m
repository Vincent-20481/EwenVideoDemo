//
//  ClearView.m
//  EwenVideoDemo
//
//  Created by EwenMac on 2017/4/23.
//  Copyright © 2017年 Suomusic. All rights reserved.
//

#import "ClearView.h"


@interface ClearView(){
    //用来控制上下菜单view隐藏的timer
    NSTimer * _hiddenTimer;
}
@property(nonatomic,strong)UIButton *backButton;//返回按钮
/** 是否拖拽slider控制播放进度 */
@property (nonatomic, assign, getter=isDragged) BOOL  dragged;
@end

@implementation ClearView

- (instancetype)initWithFrame:(CGRect)frame{
    if (self = [super initWithFrame:frame]) {
        [self createUI];
    }
    return self;
}

- (void)createUI{
    [self.backGroundImageView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.mas_equalTo(0);
    }];
    
    [self.backButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(20);
        make.left.mas_equalTo(15);
        make.width.height.mas_equalTo(30);
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
    
    UITapGestureRecognizer * tap = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(tapGesture:)];
    [self addGestureRecognizer:tap];
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
        __weak typeof(self)WeakSelf = self;
        _bottomView = [BottomView new];
        _bottomView.fullScreenBlock = ^(BOOL fullStatus) {
            WeakSelf.backButton.selected = fullStatus;
            if (fullStatus == YES) {
                [Window addSubview:WeakSelf.bmView];
                [WeakSelf.bmView mas_remakeConstraints:WeakSelf.landscapeBlock];
            }else{
                [WeakSelf.supView addSubview:WeakSelf.bmView];
                [WeakSelf.bmView mas_remakeConstraints:WeakSelf.portraitBlock];
            }
            [UIView beginAnimations:nil context:nil];
            //旋转视频播放的view和显示亮度的view
            WeakSelf.bmView.transform = [WeakSelf getOrientation:fullStatus];
            [UIView setAnimationDuration:0.5];
            [UIView commitAnimations];
        };
        [self addSubview:_bottomView];
    }
    return _bottomView;
}

//根据状态条旋转的方向来旋转 avplayerView
-(CGAffineTransform)getOrientation:(BOOL)fullStatusStatus{
    if (fullStatusStatus == NO){
        self.backButton.hidden = YES;
        return CGAffineTransformMakeRotation(-2*M_PI);
    }else{
        self.backButton.hidden = NO;
        return CGAffineTransformMakeRotation(M_PI_2);
    }
}

- (UIButton *)playOrPause{
    if (!_playOrPause) {
        _playOrPause = [UIButton new];
        [_playOrPause setBackgroundImage:[UIImage imageNamed:@"video_play-1"] forState:UIControlStateNormal];
        [_playOrPause setBackgroundImage:[UIImage imageNamed:@"video_play-1"] forState:UIControlStateHighlighted];
        [_playOrPause setBackgroundImage:[UIImage imageNamed:@"player_video_pause"] forState:UIControlStateSelected];
        [_playOrPause setBackgroundImage:[UIImage imageNamed:@"player_video_pause"] forState:UIControlStateSelected | UIControlStateHighlighted];
        [_playOrPause addTarget:self action:@selector(playOrPauseClick:) forControlEvents:UIControlEventTouchUpInside];
        [self addSubview:_playOrPause];
    }
    return _playOrPause;
}

- (UIButton *)backButton{
    if (!_backButton) {
        _backButton = [UIButton new];
        _backButton.hidden = YES;
        [_backButton setBackgroundImage:[UIImage imageNamed:@"full_screen_back"] forState:UIControlStateNormal];
        [_backButton setBackgroundImage:[UIImage imageNamed:@"full_screen_back"] forState:UIControlStateHighlighted];
        [_backButton addTarget:self action:@selector(backClick:) forControlEvents:UIControlEventTouchUpInside];
        [self addSubview:_backButton];
    }
    return _backButton;
}

- (void)backClick:(UIButton *)sender{
    sender.selected = !sender.selected;
    if (sender.selected == YES) {
        [Window addSubview:self.bmView];
        [self.bmView mas_remakeConstraints:self.landscapeBlock];
    }else{
        [self.supView addSubview:self.bmView];
        [self.bmView mas_remakeConstraints:self.portraitBlock];
    }
    self.bottomView.fullScreenButton.selected = sender.selected;
    [UIView beginAnimations:nil context:nil];
    //旋转视频播放的view和显示亮度的view
    self.bmView.transform = [self getOrientation:sender.selected];
    [UIView setAnimationDuration:0.5];
    [UIView commitAnimations];
}

- (void)playOrPauseClick:(UIButton *)sender{
    sender.selected = !sender.selected;
    if (self.clearViewBlock) {
        self.clearViewBlock(self.playOrPause.selected);
    }
}


#pragma mark --- 点击隐藏动画
/**手势事件*/
- (void)tapGesture:(UITapGestureRecognizer *)sender{
    if (self.bottomView.alpha == 0) {
        [self controlViewOutHidden];
    }else{
        [self controlViewHidden];
    }
}

#pragma mark - 控制条隐藏
-(void)controlViewHidden{
    [UIView animateWithDuration:0.25 animations:^{
        self.bottomView.alpha = 0;
        self.backButton.alpha = 0;
        self.playOrPause.alpha = 0;
    }];
    [_hiddenTimer invalidate];
}

#pragma mark - 控制条退出隐藏
-(void)controlViewOutHidden{
    
    [UIView animateWithDuration:0.25 animations:^{
        self.bottomView.alpha = 1;
        self.backButton.alpha = 1;
        self.playOrPause.alpha = 1;
    }];
    
    if (!_hiddenTimer.valid) {
        _hiddenTimer = [NSTimer scheduledTimerWithTimeInterval:5.0 target:self selector:@selector(controlViewHidden) userInfo:nil repeats:NO];
    }else{
        [_hiddenTimer invalidate];
        _hiddenTimer = [NSTimer scheduledTimerWithTimeInterval:5.0 target:self selector:@selector(controlViewHidden) userInfo:nil repeats:NO];
    }
}

- (void)EwenplayerActivity:(BOOL)animated{
    if (animated) {
        [self.activityIndicatorView startAnimating];
    } else {
        [self.activityIndicatorView stopAnimating];
    }
}

- (void)playerDraggedEnd{
    self.dragged = NO;
    // 结束滑动时候把开始播放按钮改为播放状态
    self.playOrPause.selected = YES;
    // 滑动结束延时隐藏controlView
    [self controlViewHidden];
}


@end
