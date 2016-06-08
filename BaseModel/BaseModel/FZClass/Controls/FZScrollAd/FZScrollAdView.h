 //
//  FZView.h
//  customClassDemo
//
//  Created by apple on 15/5/30.
//  Copyright (c) 2015年 Fabius's Studio. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "UIImageView+WebCache.h"

@protocol FZScrollAdViewDelegate

@optional
-(void)delegateClick:(int)iSelectIndex;

@end

@interface FZScrollAdView : UIView<UIScrollViewDelegate>{

    UIPageControl *pageView;
    UIScrollView *scrlAd;
    int iW,iH,iCurTag;

}
//是否开启自动播放动画功能
@property(nonatomic)BOOL bTimerOn;
//开启自动播放的频率
@property(nonatomic)float fTimerFrequency;
//广告图片集(内容为图片文件名称 或images.xcassets 中的文件名称)
@property(nonatomic,strong)NSMutableArray *arryAdImage;
//是否启用点击事件
@property(nonatomic)BOOL bEnableClick;
//返回点击哪个ad回调
@property(nonatomic,strong) id<FZScrollAdViewDelegate>delegate;
//是否显示网络图片
@property(nonatomic)BOOL bNetworkImage;


@end
