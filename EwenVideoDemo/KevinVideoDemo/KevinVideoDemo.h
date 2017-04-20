//
//  KevinVideoDemo.h
//  EwenVideoDemo
//
//  Created by EwenMac on 2017/4/18.
//  Copyright © 2017年 Suomusic. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <Masonry.h>
#import <AVFoundation/AVFoundation.h>

#define kScreenBounds ([[UIScreen mainScreen] bounds])
#define kScreenwidth (kScreenBounds.size.width)
#define kScreenheight (kScreenBounds.size.height)
#define Window [[UIApplication sharedApplication].delegate window]
@interface KevinVideoDemo : UIView

@property(nonatomic,strong)NSString *videoUrlStr;

@end
