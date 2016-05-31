//
//  EwenVideoView.m
//  EwenVideoDemo
//
//  Created by apple on 16/5/6.
//  Copyright © 2016年 Suomusic. All rights reserved.
//

#import "EwenVideoView.h"
#define kScreenBounds ([[UIScreen mainScreen] bounds])
#define kScreenwidth (kScreenBounds.size.width)
#define kScreenheight (kScreenBounds.size.height)
#define Window [[UIApplication sharedApplication].delegate window]

@interface EwenVideoView()

{
    //用来控制上下菜单view隐藏的timer
    NSTimer * _hiddenTimer;
    UITapGestureRecognizer * tap;
}

/**
 *  @b 视频的缓冲进度条
 */
@property (weak, nonatomic) IBOutlet UIProgressView *videoProgressView;

/**
 *  @b 视频进度滑块
 */
@property (weak, nonatomic) IBOutlet UISlider *videoSlider;

/**
 *  @b 播放或者暂停按钮
 */
@property (weak, nonatomic) IBOutlet UIButton *playOrPauseBtn;

/**
 *  @b 显示总时间的label
 */
@property (weak, nonatomic) IBOutlet UILabel *totalTimeLabel;

/**
 *  @b 用来显示时间的label
 */
@property (weak, nonatomic) IBOutlet UILabel *timeLabel;

/**
 *  @b 旋转的菊花
 */
@property (weak, nonatomic) IBOutlet UIActivityIndicatorView *actIndicator;

/**
 *  @b 下侧的菜单view, 触屏时做显示隐藏操作
 */
@property (weak, nonatomic) IBOutlet UIView *bottomView;

/**
 *  @b 视图添加了一层透明的涂层, 用来响应手势
 */
@property (weak, nonatomic) IBOutlet UIView *clearView;

/**
 * @b 判断滑块是否在拖动
 */
@property (nonatomic, assign) BOOL sliderValueChanging;

/**
 *  @b avplayerItem主要用来监听播放状态
 */
@property (nonatomic, strong) AVPlayerItem * avplayerItem;

/**
 *  @b avplayer播放器
 */
@property (nonatomic, strong) AVPlayer * viewAVplayer;

/**
 * @b 用来监控播放时间的observer
 */
@property (nonatomic, strong) id timerObserver;

/**
 * @b 竖屏的限制block
 */
@property (nonatomic, copy) LayoutBlock portraitBlock;

/**
 * @b 横屏的限制block
 */
@property (nonatomic, copy) LayoutBlock landscapeBlock;

/**
 *  横竖屏按钮
 */
@property (weak, nonatomic) IBOutlet UIButton *switchingBtn;

@end


@implementation EwenVideoView

#pragma mark - 实例化方法

+(EwenVideoView *)avplayerViewWithVideoUrlStr:(NSString *)videoUrl{
    EwenVideoView * view = [[NSBundle mainBundle] loadNibNamed:@"EwenVideoView" owner:nil options:nil].lastObject;
    view.videoUrlStr = videoUrl;
    return view;
}

/**
 * 设置初始位置block和, 全屏的block
 */
-(void)setPositionWithPortraitBlock:(LayoutBlock)porBlock andLandscapeBlock:(LayoutBlock)landscapeBlock{
    self.portraitBlock = porBlock;
    self.landscapeBlock = landscapeBlock;
    [self mas_makeConstraints:porBlock];
}



#pragma mark - 从xib唤醒视图
-(void)awakeFromNib{
    //从xib唤醒的时候初始化一下值
    [self initialSelfView];
    //对xib拖拽的progressView和Slider重新布局
    [self reConfigSlider];
}

#pragma mark - 初始化播放控制信息
-(void)initialSelfView{
    self.actIndicator.hidden = YES;
    self.userInteractionEnabled = YES;
    self.multipleTouchEnabled = YES;
    _isPlaying = NO;
    [self.playOrPauseBtn setBackgroundImage:[UIImage imageNamed:@"video_play"] forState:UIControlStateNormal];
    [self.playOrPauseBtn setBackgroundImage:[UIImage imageNamed:@"video_play"] forState:UIControlStateHighlighted];
    [self.playOrPauseBtn setBackgroundImage:[UIImage imageNamed:@"video_stop"] forState:UIControlStateSelected];
    [self.playOrPauseBtn setBackgroundImage:[UIImage imageNamed:@"video_stop"] forState:UIControlStateSelected | UIControlStateHighlighted];
    self.bottomView.backgroundColor = [UIColor clearColor];
    /**
     给clearView添加手势
     */
    tap = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(tapGesture:)];
    [self.clearView addGestureRecognizer:tap];
    
}

#pragma mark - 对xib拖拽的progressView和Slider重新布局
-(void)reConfigSlider{
    self.videoSlider.userInteractionEnabled = NO;
    [self.videoSlider setThumbImage:[UIImage imageNamed:@"video_dot"] forState:UIControlStateNormal];
    [self.videoSlider setThumbImage:[UIImage imageNamed:@"video_dot"] forState:UIControlStateHighlighted];
    self.videoSlider.maximumTrackTintColor = [UIColor clearColor];
}

#pragma mark - 当缓冲好视频调用的方法
-(void)readyToPlayConfigPlayView{
    self.userInteractionEnabled = YES;
    //将总时间设置slider的最大value, 方便计算
    self.videoSlider.maximumValue = self.totalSeconds;
    self.actIndicator.hidden = YES;
    [self.actIndicator stopAnimating];
    self.totalTimeLabel.text = [self calculateTimeWithTimeFormatter:(self.totalSeconds)];
    _hiddenTimer = [NSTimer scheduledTimerWithTimeInterval:5.0 target:self selector:@selector(controlViewHidden) userInfo:nil repeats:NO];
}



#pragma mark - 滑动滑块触发的方法, 向controller传入时间值
//拖动滑块时触发的方法
- (IBAction)sliderTouching:(id)sender {
    NSLog(@"11111");
    _sliderValueChanging = YES;
    [self controlViewOutHidden];
}
- (IBAction)sliderValueChanged:(id)sender {
    NSLog(@"22222");
    [self seekToTheTimeValue:self.videoSlider.value];
}


/**
 *  手势事件
 */
- (void)tapGesture:(UITapGestureRecognizer *)sender{
    if (_bottomView.alpha == 0) {
        [self controlViewOutHidden];
    }else{
        [self controlViewHidden];
    }
}

#pragma mark - 控制条隐藏
-(void)controlViewHidden{

    [UIView animateWithDuration:0.25 animations:^{
        _bottomView.alpha = 0;
        _playOrPauseBtn.alpha = 0;

//        self.videoSlider.alpha = 0;
//        self.videoProgressView.alpha = 0;
//        self.playOrPauseBtn.alpha = 0;
//        self.totalTimeLabel.alpha = 0;
//        self.timeLabel.alpha = 0;

    }];
    
    [_hiddenTimer invalidate];
}

#pragma mark - 控制条退出隐藏
-(void)controlViewOutHidden{
    
    [UIView animateWithDuration:0.25 animations:^{
        _bottomView.alpha = 1;
        _playOrPauseBtn.alpha = 1;
        
//        self.videoSlider.alpha = 1;
//        self.videoProgressView.alpha = 1;
//        self.playOrPauseBtn.alpha = 1;
//        self.totalTimeLabel.alpha = 1;
//        self.timeLabel.alpha = 1;
    }];
    
    if (!_hiddenTimer.valid) {
        _hiddenTimer = [NSTimer scheduledTimerWithTimeInterval:5.0 target:self selector:@selector(controlViewHidden) userInfo:nil repeats:NO];
    }else{
        [_hiddenTimer invalidate];
        _hiddenTimer = [NSTimer scheduledTimerWithTimeInterval:5.0 target:self selector:@selector(controlViewHidden) userInfo:nil repeats:NO];
    }
}


#pragma mark - 点击播放或者暂停按钮
- (IBAction)playOrPauseButtonClicked:(id)sender {
    [self playOrPause];
}

-(void)playOrPause{
    if (!self.isPlaying) {
        [self.viewAVplayer play];
        self.playOrPauseBtn.selected = YES;
        _isPlaying = YES;
        self.videoSlider.userInteractionEnabled = YES;
    }else{
        [self.viewAVplayer pause];
        self.playOrPauseBtn.selected = NO;
        _isPlaying = NO;
    }
    //更新一下上下view的隐藏时间
    [self controlViewOutHidden];
}


#pragma mark - 视频播放相关
#pragma mark -----------------------------
#pragma mark - KVO - 监测视频状态, 视频播放的核心部分
-(void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context{
    //    NSLog(@"pip -------- %@", keyPath);
    AVPlayerItem *playerItem=object;
    if ([keyPath isEqualToString:@"status"]) {        //获取到视频信息的状态, 成功就可以进行播放, 失败代表加载失败
        if (playerItem.status == AVPlayerItemStatusReadyToPlay) {   //准备好播放
            
            //self准备好播放
            [self readyToPlay:playerItem];
            //avplayerView准备好播放
            [self readyToPlayConfigPlayView];
            if (self.isPlaying) {
                [self.viewAVplayer play];
            }else{
                [self.viewAVplayer pause];
            }
            
        }else if(playerItem.status == AVPlayerItemStatusFailed){    //加载失败
            NSLog(@"AVPlayerItemStatusFailed: 视频播放失败");
        }else if(playerItem.status == AVPlayerItemStatusUnknown){   //未知错误
        }
    }else if([keyPath isEqualToString:@"loadedTimeRanges"]){ //当缓冲进度有变化的时候
        [self updateAvailableDuration:playerItem];
    }else if ([keyPath isEqualToString:@"playbackLikelyToKeepUp"]){ //当视频播放因为各种状态播放停止的时候, 这个属性会发生变化
        if (self.isPlaying) {
            [self.viewAVplayer play];
            [self.actIndicator stopAnimating];
            self.actIndicator.hidden = YES;
        }
        NSLog(@"playbackLikelyToKeepUp change : %@", change);
    }else if([keyPath isEqualToString:@"playbackBufferEmpty"]){  //当没有任何缓冲部分可以播放的时候
        [self.actIndicator startAnimating];
        self.actIndicator.hidden = NO;
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
    NSInteger tempLength = self.totalTimeLabel.text.length;
    if (tempLength > 5) {
        self.timeLabel.text = @"00:00:00";
    }else{
        self.timeLabel.text = @"00:00";
    }
    //这个是用来监测视频播放的进度做出相应的操作
    __weak EwenVideoView * weakSelf = self;
    self.timerObserver = [self.viewAVplayer addPeriodicTimeObserverForInterval:CMTimeMake(1, 1) queue:dispatch_get_main_queue() usingBlock:^(CMTime time) {
        long long currentSecond = playerItem.currentTime.value/playerItem.currentTime.timescale;
        if (!weakSelf.sliderValueChanging) {
            [weakSelf.videoSlider setValue:(float)currentSecond animated:YES];
        }
        NSString * tempTime = [weakSelf calculateTimeWithTimeFormatter:currentSecond];
        if (tempTime.length > 5) {
            weakSelf.timeLabel.text = [NSString stringWithFormat:@"00:%@", tempTime];
        }else{
            weakSelf.timeLabel.text = tempTime;
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
        self.videoProgressView.progress = result/self.totalSeconds ;
    }
}

//跳转到指定位置
-(void)seekToTheTimeValue:(float)value{
    self.actIndicator.hidden = NO;
    [self.actIndicator startAnimating];
    [self.viewAVplayer pause];
    CMTime changedTime = CMTimeMakeWithSeconds(value, 1);
    NSLog(@"cmtime change time : %lld", changedTime.value);
    __weak EwenVideoView * weakSelf = self;
    [self.viewAVplayer seekToTime:changedTime completionHandler:^(BOOL finished){
        if (weakSelf.isPlaying) {
            [weakSelf.viewAVplayer play];
        }
        //更改avplayerView的播放状态, 并且改变button上的图片
        weakSelf.sliderValueChanging = NO;
        [weakSelf.actIndicator stopAnimating];
        weakSelf.actIndicator.hidden = YES;
    }];
}


#pragma mark --- 播放结束
-(void)moviePlayEnd:(NSNotification *)notification{
    [self kzhiqiDealloc];
}


#pragma mark --- 懒加载播放器
-(AVPlayer *)viewAVplayer{
    if (!_viewAVplayer) {
        AVPlayerItem *playerItem=[self getPlayItem];
        _viewAVplayer = [AVPlayer playerWithPlayerItem:playerItem];
        _viewAVplayer.usesExternalPlaybackWhileExternalScreenIsActive = YES;
        [(AVPlayerLayer *)self.layer setPlayer:_viewAVplayer];
        [self addObserverToPlayerItem:playerItem];
    }
    return _viewAVplayer;
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
    [_viewAVplayer removeTimeObserver:self.timerObserver];
    [playerItem removeObserver:self forKeyPath:@"status"];
    [playerItem removeObserver:self forKeyPath:@"loadedTimeRanges"];
    [playerItem removeObserver:self forKeyPath:@"playbackLikelyToKeepUp"];
    [playerItem removeObserver:self forKeyPath:@"playbackBufferEmpty"];
    [playerItem removeObserver:self forKeyPath:@"playbackBufferFull"];
    [playerItem removeObserver:self forKeyPath:@"presentationSize"];
}


#pragma mark --- 创建 playerItem
-(AVPlayerItem *)getPlayItem{
    NSString *urlStr= self.videoUrlStr;
    urlStr =[urlStr stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    NSURL *url=[NSURL URLWithString:urlStr];
    AVPlayerItem *playerItem=[AVPlayerItem playerItemWithURL:url];
    return playerItem;
}


#pragma mark -- 旋转View
- (IBAction)horizontalScreen:(UIButton *)sender {
    [self toOrientation];
}

#pragma mark - 以下是用来处理全屏旋转
-(void)toOrientation{
    self.switchingBtn.selected = !self.switchingBtn.selected;
    if (self.switchingBtn.selected == YES) {
        [self removeFromSuperview];
        [self.supView addSubview:self];
        [self mas_remakeConstraints:self.portraitBlock];
    }else{
        [self removeFromSuperview];
        [Window addSubview:self];
        [self mas_remakeConstraints:self.landscapeBlock];
    }
    [UIView beginAnimations:nil context:nil];
    //旋转视频播放的view和显示亮度的view
    self.transform = [self getOrientation];
    [UIView setAnimationDuration:0.5];
    [UIView commitAnimations];
    
}

//根据状态条旋转的方向来旋转 avplayerView
-(CGAffineTransform)getOrientation{
    if (self.switchingBtn.selected == YES){
        return CGAffineTransformMakeRotation(-2*M_PI);
    }else{
        return CGAffineTransformMakeRotation(M_PI_2);
    }
}


#pragma mark --- 销毁视频
- (IBAction)destructionVideo:(UIButton *)sender {
    [self kzhiqiDealloc];
}






#pragma mark - 用来将layer转为AVPlayerLayer, 必须实现的方法, 否则会崩
+(Class)layerClass{
    return [AVPlayerLayer class];
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




- (void)kzhiqiDealloc{
    if (self.isPlaying) {
        [self playOrPause];
    }
    if (_hiddenTimer && _hiddenTimer.valid) {
        [_hiddenTimer invalidate];
        _hiddenTimer = nil;
    }
    [self.viewAVplayer.currentItem cancelPendingSeeks];
    [self.viewAVplayer.currentItem.asset cancelLoading];
    [self removeObserverFromPlayerItem:self.viewAVplayer.currentItem];
    [(AVPlayerLayer *)self.layer setPlayer:nil];
    _viewAVplayer = nil;
    [self removeFromSuperview];
}



- (void)dealloc{
    NSLog(@"控制器释放了");
}



@end
