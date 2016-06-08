//
//  FZView.m
//  customClassDemo
//
//  Created by apple on 15/5/30.
//  Copyright (c) 2015年 Fabius's Studio. All rights reserved.
//

#import "FZScrollAdView.h"

@implementation FZScrollAdView


// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    //广告数量
    NSInteger iAdImageNum;
    
    iW=CGRectGetWidth(rect);
    iH=CGRectGetHeight(rect);
    
    //添加scroll
    scrlAd=[[UIScrollView alloc] initWithFrame:rect];
    scrlAd.showsVerticalScrollIndicator=NO;
    scrlAd.showsHorizontalScrollIndicator=NO;
    scrlAd.pagingEnabled=YES;
    scrlAd.delegate=self;
    [self addSubview:scrlAd];
    
    //根据 iAdViewNum 属性 计算scroll ContentSize
    if (_arryAdImage==nil) {
        iAdImageNum=1;
    }else{
        iAdImageNum=_arryAdImage.count;
    }
    scrlAd.contentSize=CGSizeMake(iW*iAdImageNum,iH);
    
    //添加广告内容
    int iCurx=0;//当前image位置
    for (int i=0; i<=_arryAdImage.count-1; i++) {
        iCurx=i*iW;
        UIImageView *adImage=[[UIImageView alloc] initWithFrame:CGRectMake(iCurx, 0, iW, iH)];
        
        if (_bNetworkImage) {
            [adImage sd_setImageWithURL:[NSURL URLWithString:[_arryAdImage objectAtIndex:i]] placeholderImage:[UIImage imageNamed:@"imgActionDefault"]];
        }else{
            adImage.image=[UIImage imageNamed:[_arryAdImage objectAtIndex:i]];
        }
        
        adImage.clipsToBounds=YES;//如果不希望超过frame的区域显示在屏幕上要设置。clipsToBounds属性。
        adImage.contentMode=UIViewContentModeScaleAspectFill;//最好的显示方式
        
        
    
        if (_bEnableClick) {
            UIButton *btnAd=[[UIButton alloc] initWithFrame:adImage.frame];
            btnAd.accessibilityIdentifier=[NSString stringWithFormat:@"%d",i];
            [btnAd addTarget:self action:@selector(btnAdClick:) forControlEvents:UIControlEventTouchUpInside];
            [scrlAd addSubview:btnAd];
        }
        
        [scrlAd addSubview:adImage];
    }
    
    //添加pageControl
    int iPageViewH=10;
    pageView=[[UIPageControl alloc] initWithFrame:CGRectMake(0, iH-iPageViewH, iW, iPageViewH)];
    pageView.numberOfPages=iAdImageNum;
    pageView.currentPage=0;
    pageView.pageIndicatorTintColor=[UIColor lightGrayColor];
    pageView.currentPageIndicatorTintColor=[UIColor orangeColor];
    [self addSubview:pageView];
    
    if (_bTimerOn) {
        iCurTag=-1;
        NSTimeInterval timeInterval =_fTimerFrequency;
        NSTimer *myTimer=[NSTimer scheduledTimerWithTimeInterval:timeInterval target:self selector:@selector(playAdImage) userInfo:nil repeats:YES];
        [myTimer fire];
    }
}

#pragma mark 点击事件
-(void)btnAdClick:(id)sender{
    UIButton *btnObject=sender;
    int iSelectIndex=[btnObject.accessibilityIdentifier  intValue];
    [_delegate delegateClick:iSelectIndex];
}

#pragma-mark Scrol划动事件
- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView
{
    int iTag;
    CGPoint offset = scrollView.contentOffset;
    CGRect bounds = scrollView.frame;
    iTag=offset.x / bounds.size.width;

    pageView.currentPage=iTag;
    iCurTag=iTag;
}

-(void)playAdImage{
    
    if (_arryAdImage==nil || _arryAdImage.count==0) {
        return;
    }
    
    if (iCurTag==_arryAdImage.count-1) {
        iCurTag=0;
    }else{
        iCurTag++;
    }
    scrlAd.contentOffset=CGPointMake(iW*iCurTag, 0);
}

@end
