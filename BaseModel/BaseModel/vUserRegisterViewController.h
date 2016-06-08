//
//  vUserRegisterViewController.h
//  BaseModel
//
//  Created by apple on 15/9/2.
//  Copyright (c) 2015年 Fabius's Studio. All rights reserved.
//  Info:用户手机注册

#import <UIKit/UIKit.h>
#import "FZTextField.h"
#import "FZNoticeView.h"
#import "ClassUser.h"
#import <SMS_SDK/SMS_SDK.h>

@interface vUserRegisterViewController : UIViewController{
    
    NSString *sDefaultCode;        //当前国家地区编号
    NSTimer *waitTimer;
    int iTimer;

    IBOutlet FZTextField *fztxtPhoneNum;
    IBOutlet FZTextField *fztxtPhoneVerify;
    IBOutlet FZTextField *fztxtPwd;
    
    IBOutlet UIButton *btnRegister;
    IBOutlet UIButton *btnGetCode;
    
    FZNoticeView *noticeView;
}
@property(nonatomic) BOOL bGetNewPwd;//标记是否忘记密码重新获取验证码(默认为NO)
- (IBAction)btnRegisterClick:(id)sender;
- (IBAction)btnGetCodeClick:(id)sender;

@end
