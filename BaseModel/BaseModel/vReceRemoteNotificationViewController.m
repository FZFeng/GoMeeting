//
//  vReceRemoteNotificationViewController.m
//  BaseModel
//
//  Created by apple on 15/12/21.
//  Copyright © 2015年 Fabius's Studio. All rights reserved.
//

#import "vReceRemoteNotificationViewController.h"

#define iTopH 64

@interface vReceRemoteNotificationViewController ()

@end

@implementation vReceRemoteNotificationViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    // 进度条
    progressView = [[UIProgressView alloc] initWithFrame:CGRectMake(0,iTopH, self.view.frame.size.width, 0)];
    progressView.tintColor = [UIColor orangeColor];
    [self.view addSubview:progressView];

    if ([[UIDevice currentDevice].systemVersion floatValue]>=8.0) {
        wkWebView = [[WKWebView alloc] initWithFrame:self.view.bounds];
        wkWebView.autoresizingMask = UIViewAutoresizingFlexibleWidth|UIViewAutoresizingFlexibleHeight;
        wkWebView.backgroundColor = [UIColor whiteColor];
        wkWebView.scrollView.bounces=NO;
        [self.view insertSubview:wkWebView belowSubview:progressView];
        //增加监听 通过属性 estimatedProgress 计算加载进度
        [wkWebView addObserver:self forKeyPath:@"estimatedProgress" options:NSKeyValueObservingOptionNew context:nil];
        //加载网页
        NSURLRequest *request=[[NSURLRequest alloc] initWithURL:[NSURL URLWithString:_sGetUrl]];
        [wkWebView loadRequest:request];
    }else{
        webView = [[UIWebView alloc] initWithFrame:self.view.bounds];
        webView.autoresizingMask = UIViewAutoresizingFlexibleWidth|UIViewAutoresizingFlexibleHeight;
        webView.scalesPageToFit = YES;
        webView.backgroundColor = [UIColor whiteColor];
        webView.delegate = self;
        [self.view insertSubview:webView belowSubview:progressView];
        NSURLRequest *request=[[NSURLRequest alloc] initWithURL:[NSURL URLWithString:_sGetUrl]];
        [webView loadRequest:request];
    }
}
#pragma mark UIWebView Delegate
- (void)webViewDidStartLoad:(UIWebView *)webView{
    progressView.progress = 0;
    bFlag=NO;
    
    //0.01667 is roughly 1/60, so it will update at 60 FPS
    myTimer = [NSTimer scheduledTimerWithTimeInterval:0.01667 target:self selector:@selector(timerCallback) userInfo:nil repeats:YES];
}
- (void)webViewDidFinishLoad:(UIWebView *)webView{
    bFlag = YES;
}
-(void)timerCallback {
    if (bFlag) {
        if (progressView.progress >= 1) {
            progressView.hidden = YES;
            [myTimer invalidate];
        }
        else {
            progressView.progress += 0.1;
        }
    }
    else {
        progressView.progress += 0.05;
        if (progressView.progress >= 0.95) {
            progressView.progress = 0.95;
        }
    }
}

#pragma mark 计算wkWebView进度条
- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context {
    if (object ==wkWebView && [keyPath isEqualToString:@"estimatedProgress"]) {
        CGFloat newprogress = [[change objectForKey:NSKeyValueChangeNewKey] doubleValue];
        if (newprogress == 1) {
            progressView.hidden = YES;
            [progressView setProgress:0 animated:NO];
            //完成后取消监听
            [wkWebView removeObserver:self forKeyPath:@"estimatedProgress"];
        }else {
            progressView.hidden = NO;
            [progressView setProgress:newprogress animated:YES];
        }
    }
}

-(void)viewWillDisappear:(BOOL)animated{
    if (wkWebView.loading) {
        //取消监听
        [wkWebView removeObserver:self forKeyPath:@"estimatedProgress"];
    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
