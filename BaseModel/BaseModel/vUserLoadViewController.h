//
//  vUserLoad.h
//  BaseModel
//
//  Created by apple on 15/9/2.
//  Copyright (c) 2015年 Fabius's Studio. All rights reserved.
//  Info:用户登录view

#import <UIKit/UIKit.h>
#import "FZTextField.h"
#import "FZNoticeView.h"
#import "OuterSDKManager.h"
#import "vUserRegisterViewController.h"
#import "ClassUser.h"
#import "ClassAction.h"

@interface vUserLoadViewController : UIViewController<UITextFieldDelegate>{
    IBOutlet FZTextField *fztxtUserName;     //用户名
    IBOutlet FZTextField *fztxtUserPwd;      //用户密码
    IBOutlet UIButton *btnLoad;              //登录
    FZNoticeView *noticeView;
}

#pragma mark 事件
- (IBAction)btnLoadClick:(id)sender;         //登录
- (IBAction)btnGetPwdClick:(id)sender;       //找回密码
- (IBAction)btnSinawbLoadClick:(id)sender;   //微博登录
- (IBAction)btnWeixinLoadClick:(id)sender;   //微信登录
- (IBAction)btnQqLoadClick:(id)sender;

- (IBAction)barBtnItemCloseClick:(id)sender; //关闭

@end
