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
@property(nonatomic,strong)AVPlayerItem *avplayerItem;
@property(nonatomic,strong)AVPlayer *avplayer;
@property(nonatomic,strong)id timerObserver;
@property(nonatomic,assign)float totalSeconds;

/**
 * @b 竖屏的限制block
 */
@property(nonatomic,copy)LayoutBlock portraitBlock;

/**
 * @b 横屏的限制block
 */
@property(nonatomic,copy)LayoutBlock landscapeBlock;
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


- (void)setVideoUrlStr:(NSString *)videoUrlStr{
    _videoUrlStr = videoUrlStr;
}

/**
 * @b 设置初始位置block和, 全屏的block
 */
-(void)setPositionWithPortraitBlock:(LayoutBlock)porBlock andLandscapeBlock:(LayoutBlock)landscapeBlock{
    self.portraitBlock = porBlock;
    self.landscapeBlock = landscapeBlock;
    [self mas_makeConstraints:porBlock];
}






#pragma mark - 用来将layer转为AVPlayerLayer, 必须实现的方法, 否则会崩
+(Class)layerClass{
    return [AVPlayerLayer class];
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
             [WeakSelf removeFromSuperview];
            if (fullStatus == YES) {
                [Window addSubview:WeakSelf];
                [WeakSelf mas_remakeConstraints:WeakSelf.landscapeBlock];
            }else{
                [WeakSelf.supView addSubview:WeakSelf];
                [WeakSelf mas_remakeConstraints:WeakSelf.portraitBlock];
            }
            [UIView beginAnimations:nil context:nil];
            //旋转视频播放的view和显示亮度的view
            WeakSelf.transform = [WeakSelf getOrientation:fullStatus];
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
        return CGAffineTransformMakeRotation(-2*M_PI);
    }else{
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

#pragma mark --- 懒加载播放器
- (AVPlayer *)avplayer{
    if (!_avplayer) {
        AVPlayerItem *playerItem = [self getPlayItem];
        _avplayer = [AVPlayer playerWithPlayerItem:playerItem];
        _avplayer.usesExternalPlaybackWhileExternalScreenIsActive = YES;
        [(AVPlayerLayer *)self.layer setPlayer:_avplayer];
        [self addObserverToPlayerItem:playerItem];
    }
    return _avplayer;
}


#pragma mark --- 创建 playerItem
-(AVPlayerItem *)getPlayItem{
    NSString *urlStr= self.videoUrlStr;
    urlStr =[urlStr stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    NSURL *url=[NSURL URLWithString:urlStr];
    AVPlayerItem *playerItem=[AVPlayerItem playerItemWithURL:url];
    return playerItem;
}

#pragma mark --- 添加监控
-(void)addObserverToPlayerItem:(AVPlayerItem *)playerItem{
    //监控状态属性，注意AVPlayer也有一个status属性，通过监控它的status也可以获得播放状态
    [playerItem addObserver:self forKeyPath:@"status" options:NSKeyValueObservingOptionNew | NSKeyValueObservingOptionOld context:nil];
    [playerItem addObserver:self forKeyPath:@"loadedTimeRanges" options:NSKeyValueObservingOptionNew | NSKeyValueObservingOptionOld context:nil];
    [playerItem addObserver:self forKeyPath:@"playbackLikelyToKeepUp" options:NSKeyValueObservingOptionNew | NSKeyValueObservingOptionOld context:nil];
    [playerItem addObserver:self forKeyPath:@"playbackBufferEmpty" options:NSKeyValueObservingOptionNew | NSKeyValueObservingOptionOld context:nil];
    [playerItem addObserver:self forKeyPath:@"playbackBufferFull" options:NSKeyValueObservingOptionNew | NSKeyValueObservingOptionOld context:nil];
    [playerItem addObserver:self forKeyPath:@"presentationSize" options:NSKeyValueObservingOptionNew | NSKeyValueObservingOptionOld context:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(moviePlayEnd:) name:AVPlayerItemDidPlayToEndTimeNotification object:playerItem];
}

#pragma mark --- 移除监控
-(void)removeObserverFromPlayerItem:(AVPlayerItem *)playerItem{
    [_avplayer removeTimeObserver:self.timerObserver];
    [playerItem removeObserver:self forKeyPath:@"status"];
    [playerItem removeObserver:self forKeyPath:@"loadedTimeRanges"];
    [playerItem removeObserver:self forKeyPath:@"playbackLikelyToKeepUp"];
    [playerItem removeObserver:self forKeyPath:@"playbackBufferEmpty"];
    [playerItem removeObserver:self forKeyPath:@"playbackBufferFull"];
    [playerItem removeObserver:self forKeyPath:@"presentationSize"];
}

-(void)moviePlayEnd:(NSNotification *)notification{
    NSLog(@"播放结束");
}

- (void)playOrPauseClick:(UIButton *)sender{
    sender.selected = !sender.selected;
    if (self.playOrPause.selected == YES) {
         [self.avplayer play];
    }else{
        [self.avplayer pause];
    }
}


#pragma mark - KVO - 监测视频状态, 视频播放的核心部分
-(void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context{
    AVPlayerItem *playerItem=object;
    if ([keyPath isEqualToString:@"status"]) {        //获取到视频信息的状态, 成功就可以进行播放, 失败代表加载失败
        if (playerItem.status == AVPlayerItemStatusReadyToPlay) {   //准备好播放
            //self准备好播放
            [self readyToPlay:playerItem];
            //avplayerView准备好播放
            [self readyToPlayConfigPlayView];
            if (self.playOrPause.selected == YES) {
                [self.avplayer play];
            }else{
                [self.avplayer pause];
            }
        }else if(playerItem.status == AVPlayerItemStatusFailed){    //加载失败
            NSLog(@"AVPlayerItemStatusFailed: 视频播放失败");
        }else if(playerItem.status == AVPlayerItemStatusUnknown){   //未知错误
        }
    }else if([keyPath isEqualToString:@"loadedTimeRanges"]){ //当缓冲进度有变化的时候
        [self updateAvailableDuration:playerItem];
    }else if ([keyPath isEqualToString:@"playbackLikelyToKeepUp"]){ //当视频播放因为各种状态播放停止的时候, 这个属性会发生变化
//        if (self.isPlaying) {
//            [self.viewAVplayer play];
//            [self.actIndicator stopAnimating];
//            self.actIndicator.hidden = YES;
//        }
        NSLog(@"playbackLikelyToKeepUp change : %@", change);
    }else if([keyPath isEqualToString:@"playbackBufferEmpty"]){  //当没有任何缓冲部分可以播放的时候
//        [self.actIndicator startAnimating];
//        self.actIndicator.hidden = NO;
        NSLog(@"playbackBufferEmpty");
    }else if ([keyPath isEqualToString:@"playbackBufferFull"]){
        NSLog(@"playbackBufferFull: change : %@", change);
    }else if([keyPath isEqualToString:@"presentationSize"]){      //获取到视频的大小的时候调用
        NSLog(@"presentationSize");
    }
}

#pragma mark - 缓冲好准备播放所做的操作, 并且添加时间观察, 更新播放时间
- (void)readyToPlay:(AVPlayerItem *)playerItem{
    _totalSeconds = playerItem.duration.value/playerItem.duration.timescale;
    _totalSeconds = (float)self.totalSeconds;
    NSInteger tempLength = self.bottomView.leftTime.text.length;
    if (tempLength > 5) {
        self.bottomView.leftTime.text = @"00:00:00";
    }else{
        self.bottomView.leftTime.text = @"00:00";
    }
    //这个是用来监测视频播放的进度做出相应的操作
    self.timerObserver = [self.avplayer addPeriodicTimeObserverForInterval:CMTimeMake(1, 1) queue:dispatch_get_main_queue() usingBlock:^(CMTime time) {
        long long currentSecond = playerItem.currentTime.value/playerItem.currentTime.timescale;
        [self.bottomView.slider setValue:(float)currentSecond animated:YES];
        NSString * tempTime = [self calculateTimeWithTimeFormatter:currentSecond];
        if (tempTime.length > 5) {
            self.bottomView.leftTime.text = [NSString stringWithFormat:@"00:%@", tempTime];
        }else{
            self.bottomView.leftTime.text = tempTime;
        }
    }];
}

#pragma mark - 更新缓冲时间
-(void)updateAvailableDuration:(AVPlayerItem *)playerItem{
    NSArray * loadedTimeRanges = playerItem.loadedTimeRanges;
    CMTimeRange timeRange = [loadedTimeRanges.firstObject CMTimeRangeValue];
    float startSeconds = CMTimeGetSeconds(timeRange.start);
    float durationSeconds = CMTimeGetSeconds(timeRange.duration);
    NSTimeInterval result = startSeconds + durationSeconds;
    if (self.totalSeconds) {
        self.bottomView.progressView.progress = result/self.totalSeconds ;
    }
}

#pragma mark - 当缓冲好视频调用的方法
-(void)readyToPlayConfigPlayView{
    //将总时间设置slider的最大value, 方便计算
//    self.avplayer.maximumValue = self.totalSeconds;
//    self.actIndicator.hidden = YES;
//    [self.actIndicator stopAnimating];
//    self.totalTimeLabel.text = [self calculateTimeWithTimeFormatter:(self.totalSeconds)];
//    _hiddenTimer = [NSTimer scheduledTimerWithTimeInterval:5.0 target:self selector:@selector(controlViewHidden) userInfo:nil repeats:NO];
}

#pragma mark - 根据秒数计算时间

- (NSString *)calculateTimeWithTimeFormatter:(long long)timeSecond{
    NSString * theLastTime = nil;
    if (timeSecond < 60) {
        theLastTime = [NSString stringWithFormat:@"00:%.2lld", timeSecond];
    }else if(timeSecond >= 60 && timeSecond < 3600){
        theLastTime = [NSString stringWithFormat:@"%.2lld:%.2lld", timeSecond/60, timeSecond%60];
    }else if(timeSecond >= 3600){
        theLastTime = [NSString stringWithFormat:@"%.2lld:%.2lld:%.2lld", timeSecond/3600, timeSecond%3600/60, timeSecond%60];
    }
    return theLastTime;
}



@end
