//
//  ViewController.m
//  EwenVideoDemo
//
//  Created by apple on 16/5/6.
//  Copyright © 2016年 Suomusic. All rights reserved.
//

#import "ViewController.h"
#define kScreenBounds ([[UIScreen mainScreen] bounds])
#define kScreenwidth (kScreenBounds.size.width)
#define kScreenheight (kScreenBounds.size.height)
#define KBL kScreenwidth/375
#define Window [[UIApplication sharedApplication].delegate window]

#import "KevinVideoDemo.h"
@interface ViewController ()
@property(nonatomic,strong)KevinVideoDemo *kevinVideo;
@property(nonatomic,strong)UIImageView *imageView;
@property(nonatomic,strong)UIButton *playOrPause;
@end

@implementation ViewController

- (BOOL)prefersStatusBarHidden
{
    return YES;//隐藏为YES，显示为NO
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    
    
    self.imageView = [UIImageView new];
    self.imageView .image = [UIImage imageNamed:@"112233344"];
    self.imageView.userInteractionEnabled = YES;
    [self.view addSubview:self.imageView ];
    [self.imageView  mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(10);
        make.right.mas_equalTo(-10);
        make.top.mas_equalTo(50);
        make.height.mas_equalTo(self.imageView.mas_width).multipliedBy(9.0f/16.0f);
    }];
    
    [self.imageView addSubview:self.playOrPause];
    [self.playOrPause mas_makeConstraints:^(MASConstraintMaker *make) {
        make.width.height.mas_equalTo(50);
        make.center.mas_equalTo(0);
    }];
    
    
    
    
}

- (KevinVideoDemo *)kevinVideo{
    if (!_kevinVideo) {
        _kevinVideo = [KevinVideoDemo new];
        _kevinVideo.videoURL = [NSURL URLWithString:@"http://baobab.wdjcdn.com/1456231710844S(24).mp4"];
    }
    return _kevinVideo;
}

- (UIButton *)playOrPause{
    if (!_playOrPause) {
        _playOrPause = [UIButton new];
        [_playOrPause setBackgroundImage:[UIImage imageNamed:@"video_play-1"] forState:UIControlStateNormal];
        [_playOrPause setBackgroundImage:[UIImage imageNamed:@"video_play-1"] forState:UIControlStateHighlighted];
        [_playOrPause setBackgroundImage:[UIImage imageNamed:@"player_video_pause"] forState:UIControlStateSelected];
        [_playOrPause setBackgroundImage:[UIImage imageNamed:@"player_video_pause"] forState:UIControlStateSelected | UIControlStateHighlighted];
        [_playOrPause addTarget:self action:@selector(playOrPauseClick:) forControlEvents:UIControlEventTouchUpInside];
    }
    return _playOrPause;
}

- (void)playOrPauseClick:(UIButton *)sender{
    
    
    [self.imageView addSubview:self.kevinVideo];
    self.kevinVideo.clearView.supView = self.imageView;
    self.kevinVideo.clearView.backGroundImageView.image = [UIImage imageNamed:@"112233344"];
    [self.kevinVideo setPositionWithPortraitBlock:^(MASConstraintMaker *make) {
        make.edges.mas_equalTo(0);
    } andLandscapeBlock:^(MASConstraintMaker *make) {
        make.center.equalTo(Window);
        make.width.mas_equalTo(kScreenheight);
        make.height.mas_equalTo(kScreenwidth);
    }];
    [self.kevinVideo play];
}



- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
