//
//  KevinVideoDemo.m
//  EwenVideoDemo
//
//  Created by EwenMac on 2017/4/18.
//  Copyright © 2017年 Suomusic. All rights reserved.
//

#import "KevinVideoDemo.h"
#import "ClearView.h"
@interface KevinVideoDemo()<BottomViewDelegate>

@property (nonatomic, strong)AVPlayerItem *playerItem;
@property (nonatomic, strong)AVPlayer *player;
@property (nonatomic, strong)AVURLAsset *urlAsset;
@property (nonatomic, strong)AVPlayerLayer *playerLayer;
@property (nonatomic, strong)id timeObserve;
@property (nonatomic, assign)ZFPlayerState  state;
@property (nonatomic, assign)NSInteger  seekTime;
/** 是否再次设置URL播放视频 */
@property (nonatomic, assign) BOOL   repeatToPlay;
/** 播放完了*/
@property (nonatomic, assign) BOOL   playDidEnd;
/** 是否正在拖拽 */
@property (nonatomic, assign)BOOL isDragged;
/** 是否被用户暂停 */
@property (nonatomic, assign)BOOL isPauseByUser;
/** slider上次的值 */
@property (nonatomic, assign)CGFloat   sliderLastValue;


@property(nonatomic,strong)id timerObserver;

@end

@implementation KevinVideoDemo

- (instancetype)initWithFrame:(CGRect)frame{
    if (self = [super initWithFrame:frame]) {
        [self createUI];
    }
    return self;
}

- (void)createUI{
    
    self.backgroundColor = [UIColor blackColor];
    
    [self.clearView mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.edges.mas_equalTo(0);
    }];
}



/**设置初始位置block和, 全屏的block*/
-(void)setPositionWithPortraitBlock:(LayoutBlock)porBlock andLandscapeBlock:(LayoutBlock)landscapeBlock{
    self.clearView.portraitBlock = porBlock;
    self.clearView.landscapeBlock = landscapeBlock;
    [self mas_makeConstraints:porBlock];
    
}



#pragma mark --- 懒加载播放器
- (AVPlayer *)player{
    if (!_player) {
        self.urlAsset = [AVURLAsset assetWithURL:self.videoURL];
        self.playerItem = [AVPlayerItem playerItemWithAsset:self.urlAsset];
        _player = [AVPlayer playerWithPlayerItem:self.playerItem];
        _player.usesExternalPlaybackWhileExternalScreenIsActive = YES;
        [(AVPlayerLayer *)self.layer setPlayer:_player];
    }
    return _player;
}


- (void)createTimer {
    __weak typeof(self) weakSelf = self;
    self.timeObserve = [self.player addPeriodicTimeObserverForInterval:CMTimeMakeWithSeconds(1, 1) queue:nil usingBlock:^(CMTime time){
        AVPlayerItem *currentItem = weakSelf.playerItem;
        NSArray *loadedRanges = currentItem.seekableTimeRanges;
        if (loadedRanges.count > 0 && currentItem.duration.timescale != 0) {
            NSInteger currentTime = (NSInteger)CMTimeGetSeconds([currentItem currentTime]);
            CGFloat totalTime     = (CGFloat)currentItem.duration.value / currentItem.duration.timescale;
            CGFloat value         = CMTimeGetSeconds([currentItem currentTime]) / totalTime;
            [weakSelf zf_playerCurrentTime:currentTime totalTime:totalTime sliderValue:value];
        }
    }];
}

- (void)zf_playerCurrentTime:(NSInteger)currentTime totalTime:(NSInteger)totalTime sliderValue:(CGFloat)value {
    // 当前时长进度progress
    NSInteger proMin = currentTime / 60;//当前秒
    NSInteger proSec = currentTime % 60;//当前分钟
    // duration 总时长
    NSInteger durMin = totalTime / 60;//总秒
    NSInteger durSec = totalTime % 60;//总分钟
    if (!self.isDragged) {
        // 更新slider
        self.clearView.bottomView.slider.value  = value;
        // 更新当前播放时间
        self.clearView.bottomView.leftTime.text       = [NSString stringWithFormat:@"%02zd:%02zd", proMin, proSec];
    }
    // 更新总时间
    self.clearView.bottomView.rightTime.text = [NSString stringWithFormat:@"%02zd:%02zd", durMin, durSec];
}


#pragma mark --- 懒加载

- (ClearView *)clearView{
    if (!_clearView) {
        __weak typeof(self)WeakSelf = self;
        _clearView = [ClearView new];
        _clearView.bmView = self;
        _clearView.bottomView.delegate = self;
        _clearView.clearViewBlock = ^(BOOL playAndPause) {
            if (playAndPause == YES) {
                [WeakSelf play];
            }else{
                [WeakSelf pause];
            }
        };
        [self addSubview:_clearView];
    }
    return _clearView;
}

#pragma mark - Setter

/**
 *  videoURL的setter方法
 *
 *  @param videoURL videoURL
 */
- (void)setVideoURL:(NSURL *)videoURL {
    _videoURL = videoURL;
    // 每次加载视频URL都设置重播为NO
    self.repeatToPlay = NO;
    self.playDidEnd   = NO;
    self.isPauseByUser = YES;
    
}


#pragma mark --- 添加监控
/**
 *  根据playerItem，来添加移除观察者
 *
 *  @param playerItem playerItem
 */
- (void)setPlayerItem:(AVPlayerItem *)playerItem {
    if (_playerItem == playerItem){return;}
    if (_playerItem) {
        [[NSNotificationCenter defaultCenter] removeObserver:self name:AVPlayerItemDidPlayToEndTimeNotification object:_playerItem];
        [_playerItem removeObserver:self forKeyPath:@"status"];
        [_playerItem removeObserver:self forKeyPath:@"loadedTimeRanges"];
        [_playerItem removeObserver:self forKeyPath:@"playbackBufferEmpty"];
        [_playerItem removeObserver:self forKeyPath:@"playbackLikelyToKeepUp"];
    }
    _playerItem = playerItem;
    if (playerItem) {
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(moviePlayDidEnd:) name:AVPlayerItemDidPlayToEndTimeNotification object:playerItem];
        [playerItem addObserver:self forKeyPath:@"status" options:NSKeyValueObservingOptionNew context:nil];
        [playerItem addObserver:self forKeyPath:@"loadedTimeRanges" options:NSKeyValueObservingOptionNew context:nil];
        // 缓冲区空了，需要等待数据
        [playerItem addObserver:self forKeyPath:@"playbackBufferEmpty" options:NSKeyValueObservingOptionNew context:nil];
        // 缓冲区有足够数据可以播放了
        [playerItem addObserver:self forKeyPath:@"playbackLikelyToKeepUp" options:NSKeyValueObservingOptionNew context:nil];
    }
}

-(void)moviePlayDidEnd:(NSNotification *)notification{
    NSLog(@"播放结束");
}





#pragma mark - KVO

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context {
    if (object == self.player.currentItem) {
        if ([keyPath isEqualToString:@"status"]) {
            if (self.player.currentItem.status == AVPlayerItemStatusReadyToPlay) {
                self.state = ZFPlayerStatePlaying;
                [self createTimer];
                // 跳到xx秒播放视频
                if (self.seekTime) {
                    [self seekToTime:self.seekTime completionHandler:nil];
                }
            } else if (self.player.currentItem.status == AVPlayerItemStatusFailed) {
                self.state = ZFPlayerStateFailed;
            }
        } else if ([keyPath isEqualToString:@"loadedTimeRanges"]) {
            // 计算缓冲进度
            NSTimeInterval timeInterval = [self availableDuration];
            CMTime duration             = self.playerItem.duration;
            CGFloat totalDuration       = CMTimeGetSeconds(duration);
            [self.clearView.bottomView.progressView setProgress:timeInterval/totalDuration animated:NO];
            
        } else if ([keyPath isEqualToString:@"playbackBufferEmpty"]) {
            
            // 当缓冲是空的时候
            if (self.playerItem.playbackBufferEmpty) {
                self.state = ZFPlayerStateBuffering;
                [self bufferingSomeSecond];
            }
            
        } else if ([keyPath isEqualToString:@"playbackLikelyToKeepUp"]) {
            // 当缓冲好的时候
            if (self.playerItem.playbackLikelyToKeepUp && self.state == ZFPlayerStateBuffering){
                self.state = ZFPlayerStatePlaying;
            }
        }
    }
}

/**
 *  播放
 */
- (void)play {
    self.clearView.playOrPause.selected = YES;
    if (self.state == ZFPlayerStatePause) { self.state = ZFPlayerStatePlaying; }
    self.isPauseByUser = NO;
    [self.player play];
}

/**
 * 暂停
 */
- (void)pause {
    self.clearView.playOrPause.selected = NO;
    if (self.state == ZFPlayerStatePlaying) { self.state = ZFPlayerStatePause;}
    self.isPauseByUser = YES;
    [self.player pause];
}


/**
 *  设置播放的状态
 *
 *  @param state ZFPlayerState
 */
- (void)setState:(ZFPlayerState)state {
    _state = state;
    // 控制菊花显示、隐藏
    [self.clearView EwenplayerActivity:state == ZFPlayerStateBuffering];
    if (state == ZFPlayerStatePlaying || state == ZFPlayerStateBuffering) {
        // 隐藏占位图
        self.clearView.backGroundImageView.hidden = YES;
    } else if (state == ZFPlayerStateFailed) {
        NSError *error = [self.playerItem error];
        //        [self.controlView zf_playerItemStatusFailed:error];//加载失败点击重试
    }
}

/**
 *  从xx秒开始播放视频跳转
 *
 *  @param dragedSeconds 视频跳转的秒数
 */
- (void)seekToTime:(NSInteger)dragedSeconds completionHandler:(void (^)(BOOL finished))completionHandler {
    if (self.player.currentItem.status == AVPlayerItemStatusReadyToPlay) {
        // seekTime:completionHandler:不能精确定位
        // 如果需要精确定位，可以使用seekToTime:toleranceBefore:toleranceAfter:completionHandler:
        // 转换成CMTime才能给player来控制播放进度
        [self.clearView EwenplayerActivity:YES];
        [self.player pause];
        CMTime dragedCMTime = CMTimeMake(dragedSeconds, 1); //kCMTimeZero
        __weak typeof(self) weakSelf = self;
        [self.player seekToTime:dragedCMTime toleranceBefore:CMTimeMake(1,1) toleranceAfter:CMTimeMake(1,1) completionHandler:^(BOOL finished) {
            [weakSelf.clearView EwenplayerActivity:NO];
            // 视频跳转回调
            if (completionHandler) { completionHandler(finished); }
            [weakSelf.player play];
            weakSelf.seekTime = 0;
            weakSelf.isDragged = NO;
            // 结束滑动
            [weakSelf.clearView playerDraggedEnd];
            if (!weakSelf.playerItem.isPlaybackLikelyToKeepUp){ weakSelf.state = ZFPlayerStateBuffering; }
            
        }];
    }
}

#pragma mark - 计算缓冲进度

/**
 *  计算缓冲进度
 *
 *  @return 缓冲进度
 */
- (NSTimeInterval)availableDuration {
    NSArray *loadedTimeRanges = [[_player currentItem] loadedTimeRanges];
    CMTimeRange timeRange     = [loadedTimeRanges.firstObject CMTimeRangeValue];// 获取缓冲区域
    float startSeconds        = CMTimeGetSeconds(timeRange.start);
    float durationSeconds     = CMTimeGetSeconds(timeRange.duration);
    NSTimeInterval result     = startSeconds + durationSeconds;// 计算缓冲总进度
    return result;
}


#pragma mark - 缓冲较差时候

/**
 *  缓冲较差时候回调这里
 */
- (void)bufferingSomeSecond {
    self.state = ZFPlayerStateBuffering;
    // playbackBufferEmpty会反复进入，因此在bufferingOneSecond延时播放执行完之前再调用bufferingSomeSecond都忽略
    __block BOOL isBuffering = NO;
    if (isBuffering) return;
    isBuffering = YES;
    
    // 需要先暂停一小会之后再播放，否则网络状况不好的时候时间在走，声音播放不出来
    [self.player pause];
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1.0 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        // 如果此时用户已经暂停了，则不再需要开启播放了
        if (self.isPauseByUser) {
            isBuffering = NO;
            return;
        }
        
        [self play];
        // 如果执行了play还是没有播放则说明还没有缓存好，则再次缓存一段时间
        isBuffering = NO;
        if (!self.playerItem.isPlaybackLikelyToKeepUp) { [self bufferingSomeSecond]; }
        
    });
}


/** slider的点击事件（点击slider控制进度） */
- (void)bottomView:(UIView *)controlView progressSliderTap:(CGFloat)value{
    // 视频总时间长度
    CGFloat total = (CGFloat)self.playerItem.duration.value / self.playerItem.duration.timescale;
    //计算出拖动的当前秒数
    NSInteger dragedSeconds = floorf(total * value);
    self.clearView.playOrPause.selected = YES;
    [self seekToTime:dragedSeconds completionHandler:^(BOOL finished) {}];
    
}
/** 开始触摸slider */
- (void)bottomView:(UIView *)controlView progressSliderTouchBegan:(UISlider *)slider{
    
}
/** slider触摸中 */
- (void)bottomView:(UIView *)controlView progressSliderValueChanged:(UISlider *)slider{
    
    
}
/** slider触摸结束 */
- (void)bottomView:(UIView *)controlView progressSliderTouchEnded:(UISlider *)slider{
    if (self.player.currentItem.status == AVPlayerItemStatusReadyToPlay) {
        self.isPauseByUser = NO;
        self.isDragged = NO;
        // 视频总时间长度
        CGFloat total    = (CGFloat)_playerItem.duration.value / _playerItem.duration.timescale;
        //计算出拖动的当前秒数
        NSInteger dragedSeconds = floorf(total * slider.value);
        [self seekToTime:dragedSeconds completionHandler:nil];
    }
}

#pragma mark - 用来将layer转为AVPlayerLayer, 必须实现的方法, 否则会崩
+(Class)layerClass{
    return [AVPlayerLayer class];
}


@end
