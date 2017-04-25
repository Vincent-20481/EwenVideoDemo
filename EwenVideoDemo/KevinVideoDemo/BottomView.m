//
//  BottomView.m
//  EwenVideoDemo
//
//  Created by EwenMac on 2017/4/19.
//  Copyright © 2017年 Suomusic. All rights reserved.
//

#import "BottomView.h"
#import <Masonry.h>
@interface BottomView()<UIGestureRecognizerDelegate>



@end


@implementation BottomView

- (instancetype)initWithFrame:(CGRect)frame{
    if (self = [super initWithFrame:frame]) {
        [self createUI];
    }
    return self;
}

- (void)createUI{
    
    self.image = [UIImage imageNamed:@"EwenBottom"];
    self.userInteractionEnabled = YES;
    
    
    [self.leftTime mas_makeConstraints:^(MASConstraintMaker *make) {
        make.bottom.mas_equalTo(-10);
        make.left.mas_equalTo(8);
        make.height.mas_equalTo(12);
    }];
    
    [self.fullScreenButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.bottom.mas_equalTo(-10);
        make.right.mas_equalTo(-8);
        make.height.mas_equalTo(12);
        make.width.mas_equalTo(12);
    }];
    
    [self.rightTime mas_makeConstraints:^(MASConstraintMaker *make) {
        make.bottom.mas_equalTo(-10);
        make.right.equalTo(self.fullScreenButton.left).mas_offset(-8);
        make.height.mas_equalTo(12);
    }];
    
    [self.progressView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.leftTime.right).offset(8);
        make.centerY.equalTo(self.leftTime).offset(1);
        make.right.equalTo(self.rightTime.left).offset(-8);
        make.height.mas_equalTo(1);
    }];
    
    [self.slider mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.leftTime.right).offset(8);
        make.centerY.equalTo(self.leftTime);
        make.right.equalTo(self.rightTime.left).offset(-8);
        make.height.mas_equalTo(30);
    }];
    self.leftTime.text = @"--:--:--";
    self.rightTime.text = @"--:--:--";
}


#pragma mark --- 懒加载

- (UILabel *)leftTime{
    if (!_leftTime) {
        _leftTime = [UILabel new];
        _leftTime.textColor = [UIColor whiteColor];
        _leftTime.font = [UIFont systemFontOfSize:12];
        [self addSubview:_leftTime];
    }
    return _leftTime;
}

- (UILabel *)rightTime{
    if (!_rightTime) {
        _rightTime = [UILabel new];
        _rightTime.textColor = [UIColor whiteColor];
        _rightTime.font = [UIFont systemFontOfSize:12];
        [self addSubview:_rightTime];
    }
    return _rightTime;
}


- (UIProgressView *)progressView{
    if (!_progressView) {
        _progressView = [UIProgressView new];
        _progressView.progressViewStyle = UIProgressViewStyleDefault;
        _progressView.trackTintColor= [UIColor whiteColor];
        _progressView.progressTintColor= [UIColor colorWithRed:180/255.f green:180/255.f blue:180/255.f alpha:1.0f];
        _progressView.progress = 0;
        [self addSubview:_progressView];
    }
    return _progressView;
}

- (UISlider *)slider{
    if (!_slider) {
        _slider = [UISlider new];
        _slider.minimumTrackTintColor = [UIColor whiteColor];
        _slider.maximumTrackTintColor = [UIColor clearColor];
        [_slider setThumbImage:[UIImage imageNamed:@"White_slider"] forState:UIControlStateNormal];
        [_slider setThumbImage:[UIImage imageNamed:@"White_slider"] forState:UIControlStateHighlighted];
        
        // slider开始滑动事件
        [_slider addTarget:self action:@selector(progressSliderTouchBegan:) forControlEvents:UIControlEventTouchDown];
        // slider滑动中事件
        [_slider addTarget:self action:@selector(progressSliderValueChanged:) forControlEvents:UIControlEventValueChanged];
        // slider结束滑动事件
        [_slider addTarget:self action:@selector(progressSliderTouchEnded:) forControlEvents:UIControlEventTouchUpInside | UIControlEventTouchCancel | UIControlEventTouchUpOutside];
        
        UITapGestureRecognizer *sliderTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapSliderAction:)];
        [_slider addGestureRecognizer:sliderTap];
        
        UIPanGestureRecognizer *panRecognizer = [[UIPanGestureRecognizer alloc]initWithTarget:self action:@selector(panRecognizer:)];
        panRecognizer.delegate = self;
        [panRecognizer setMaximumNumberOfTouches:1];
        [panRecognizer setDelaysTouchesBegan:YES];
        [panRecognizer setDelaysTouchesEnded:YES];
        [panRecognizer setCancelsTouchesInView:YES];
        [_slider addGestureRecognizer:panRecognizer];
        
        [self addSubview:_slider];
    }
    return _slider;
}

- (UIButton *)fullScreenButton{
    if (!_fullScreenButton) {
        _fullScreenButton = [UIButton new];
        [_fullScreenButton setBackgroundImage:[UIImage imageNamed:@"full_screen_open"] forState:UIControlStateNormal];
        [_fullScreenButton setBackgroundImage:[UIImage imageNamed:@"full_screen_open"] forState:UIControlStateHighlighted];
        [_fullScreenButton setBackgroundImage:[UIImage imageNamed:@"full_screen_close"] forState:UIControlStateSelected];
        [_fullScreenButton setBackgroundImage:[UIImage imageNamed:@"full_screen_close"] forState:UIControlStateHighlighted | UIControlStateSelected];
        [_fullScreenButton addTarget:self action:@selector(fullScreenClick:) forControlEvents:UIControlEventTouchUpInside];
        [self addSubview:_fullScreenButton];
        
    }
    return _fullScreenButton;
}

- (void)fullScreenClick:(UIButton *)sender{
    sender.selected = !sender.selected;
    if (self.fullScreenBlock) {
        self.fullScreenBlock(sender.selected);
    }
}

/**
 *  UISlider TapAction
 */
- (void)tapSliderAction:(UITapGestureRecognizer *)tap {
    if ([tap.view isKindOfClass:[UISlider class]]) {
        UISlider *slider = (UISlider *)tap.view;
        CGPoint point = [tap locationInView:slider];
        CGFloat length = slider.frame.size.width;
        // 视频跳转的value
        CGFloat tapValue = point.x / length;
        if ([self.delegate respondsToSelector:@selector(bottomView:progressSliderTap:)]) {
            [self.delegate bottomView:self progressSliderTap:tapValue];
        }
    }
}

// 不做处理，只是为了滑动slider其他地方不响应其他手势
- (void)panRecognizer:(UIPanGestureRecognizer *)sender {}

- (void)progressSliderTouchBegan:(UISlider *)sender {
    
    if ([self.delegate respondsToSelector:@selector(bottomView:progressSliderTouchBegan:)]) {
        [self.delegate bottomView:self progressSliderTouchBegan:sender];
    }
}

- (void)progressSliderValueChanged:(UISlider *)sender {
    [self playerCancelAutoFadeOutControlView];
    if ([self.delegate respondsToSelector:@selector(bottomView:progressSliderValueChanged:)]) {
        [self.delegate bottomView:self progressSliderValueChanged:sender];
    }
}

- (void)progressSliderTouchEnded:(UISlider *)sender {
    if ([self.delegate respondsToSelector:@selector(bottomView:progressSliderTouchEnded:)]) {
        [self.delegate bottomView:self progressSliderTouchEnded:sender];
    }
}

#pragma mark - UIGestureRecognizerDelegate

- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldReceiveTouch:(UITouch *)touch {
    CGRect rect = [self thumbRect];
    CGPoint point = [touch locationInView:self.slider];
    if ([touch.view isKindOfClass:[UISlider class]]) { // 如果在滑块上点击就不响应pan手势
        if (point.x <= rect.origin.x + rect.size.width && point.x >= rect.origin.x) { return NO; }
    }
    return YES;
}

/**
 slider滑块的bounds
 */
- (CGRect)thumbRect {
    return [self.slider thumbRectForBounds:self.slider.bounds
                                 trackRect:[self.slider trackRectForBounds:self.slider.bounds]
                                     value:self.slider.value];
}


/**
 *  取消延时隐藏View的方法
 */
- (void)playerCancelAutoFadeOutControlView {
    [NSObject cancelPreviousPerformRequestsWithTarget:self];
}



@end
