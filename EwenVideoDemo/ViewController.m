//
//  ViewController.m
//  EwenVideoDemo
//
//  Created by apple on 16/5/6.
//  Copyright © 2016年 Suomusic. All rights reserved.
//

#import "ViewController.h"
#import "EwenVideoView.h"
#define kScreenBounds ([[UIScreen mainScreen] bounds])
#define kScreenwidth (kScreenBounds.size.width)
#define kScreenheight (kScreenBounds.size.height)
#define KBL kScreenwidth/375
#define Window [[UIApplication sharedApplication].delegate window]
@interface ViewController ()

@end

@implementation ViewController

- (BOOL)prefersStatusBarHidden
{
    return YES;//隐藏为YES，显示为NO
}

- (void)viewDidLoad {
    [super viewDidLoad];
    EwenVideoView *ewenVideoVideo = [EwenVideoView avplayerViewWithVideoUrlStr:@"http://baobab.wdjcdn.com/1456459181808howtoloseweight_x264.mp4"];
    ewenVideoVideo.supView = self.view;
    [self.view addSubview:ewenVideoVideo];
    [ewenVideoVideo setPositionWithPortraitBlock:^(MASConstraintMaker *make) {
        make.top.equalTo(0);
        make.left.equalTo(0);
        make.right.equalTo(0);
        make.height.mas_equalTo(211*KBL);
    } andLandscapeBlock:^(MASConstraintMaker *make) {
        make.center.equalTo(Window);
        make.width.mas_equalTo(kScreenheight);
        make.height.mas_equalTo(kScreenwidth);
    }];
    
    [self forceOrientation:UIInterfaceOrientationLandscapeLeft];
    
}

- (void)forceOrientation: (UIInterfaceOrientation)orientation {
    if ([[UIDevice currentDevice] respondsToSelector:@selector(setOrientation:)]) {
        SEL selector = NSSelectorFromString(@"setOrientation:");
        NSInvocation *invocation = [NSInvocation invocationWithMethodSignature:[UIDevice instanceMethodSignatureForSelector:selector]];
        [invocation setSelector:selector];
        [invocation setTarget: [UIDevice currentDevice]];
        int val = orientation;
        [invocation setArgument:&val atIndex:2];
        [invocation invoke];
    }
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
