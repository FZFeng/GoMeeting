//
//  vReceRemoteNotificationViewController.h
//  BaseModel
//
//  Created by apple on 15/12/21.
//  Copyright © 2015年 Fabius's Studio. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <WebKit/WebKit.h>

@interface vReceRemoteNotificationViewController : UIViewController<UIWebViewDelegate>{

    UIProgressView *progressView;
    WKWebView *wkWebView;
    UIWebView *webView;

    BOOL bFlag;
    NSTimer *myTimer;
}
@property(nonatomic,strong)NSString *sGetUrl;

@end
