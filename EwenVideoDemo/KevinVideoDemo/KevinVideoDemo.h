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
typedef void(^LayoutBlock)(MASConstraintMaker * make);
#define kScreenBounds ([[UIScreen mainScreen] bounds])
#define kScreenwidth (kScreenBounds.size.width)
#define kScreenheight (kScreenBounds.size.height)
#define Window [[UIApplication sharedApplication].delegate window]
@interface KevinVideoDemo : UIView

@property(nonatomic,weak)UIView *supView;
@property(nonatomic,strong)NSString *videoUrlStr;
/**
 * @b 设置初始位置block和, 全屏的block
 */
-(void)setPositionWithPortraitBlock:(LayoutBlock)porBlock andLandscapeBlock:(LayoutBlock)landscapeBlock;


@end
