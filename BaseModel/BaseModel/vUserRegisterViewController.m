//
//  vUserRegisterViewController.m
//  BaseModel
//
//  Created by apple on 15/9/2.
//  Copyright (c) 2015年 Fabius's Studio. All rights reserved.
//

#import "vUserRegisterViewController.h"

@interface vUserRegisterViewController ()

@end

@implementation vUserRegisterViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    fztxtPhoneNum.placeholderText=@"输入手机号";
    fztxtPhoneNum.bNoLeftIcon=YES;
    fztxtPhoneNum.iLblLeftWidth=55;
    fztxtPhoneNum.lblLeftText=@"手机号";
    
    fztxtPhoneVerify.placeholderText=@"输入验证码";
    fztxtPhoneVerify.bNoLeftIcon=YES;
    fztxtPhoneVerify.iLblLeftWidth=55;
    fztxtPhoneVerify.lblLeftText=@"验证码";
    
    fztxtPwd.placeholderText=@"输入用户密码";
    fztxtPwd.bNoLeftIcon=YES;
    fztxtPwd.iLblLeftWidth=55;
    fztxtPwd.lblLeftText=@"密  码";
    
    //圆角
    btnRegister.layer.cornerRadius =5.0;
    btnGetCode.layer.cornerRadius =5.0;
    
    if (_bGetNewPwd) {
        self.navigationItem.title = @"找回用户密码";
    }else{
        self.navigationItem.title = @"新用户注册";
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
#pragma mark 注册
- (IBAction)btnRegisterClick:(id)sender {
    
    
    if (!noticeView) {
        noticeView=[[FZNoticeView alloc] initWithReferView:self.view bHasNavItem:YES];
    }
    
    if (fztxtPhoneNum.text.length!=11) {
        [noticeView showWithNotice:@"请输入11位手机号"];
        [fztxtPhoneNum becomeFirstResponder];
        return;
    }else if (fztxtPhoneVerify.text.length==0){
        [noticeView showWithNotice:@"请输入手机验证码"];
        [fztxtPhoneVerify becomeFirstResponder];
        return;
    }else if (fztxtPwd.text.length==0){
        [noticeView showWithNotice:@"请输注册密码"];
        [fztxtPwd becomeFirstResponder];
        return;
    }
    
    [self disKeyboard];
    
    //验证手机验证码
    [SMS_SDK commitVerifyCode:fztxtPhoneVerify.text result:^(enum SMS_ResponseState state) {
        if (1==state)
        {
            //新注册或重新设置密码
            [ClassUser registerUserWithID:fztxtPhoneNum.text sPwd:fztxtPwd.text bNewUser:!self.bGetNewPwd fatherObject:self returnBlock:^(BOOL bReturnBlock) {
                if (bReturnBlock) {
                    //保存数据到systemplist中
                    //下载头像文件到本地
                    [SystemPlist SetLogin:YES];
                    [SystemPlist SetLoginType:LoginTypeSystem];
                    [SystemPlist SetName:fztxtPhoneNum.text];
                    [SystemPlist SetGender:@"m"];
                    
                    [self performSelector:@selector(dismissView) withObject:nil afterDelay:1.0];
                }
            }];
        }
        else if(0==state)
        {
            [noticeView showWithNotice:@"验证码错误"];
            [fztxtPhoneVerify becomeFirstResponder];
            return;
            
        }
    }];
}

-(void)waitRegistCode{
    if (iTimer<60) {
        iTimer++;
        [btnGetCode setTitle:[NSString stringWithFormat:@"%d秒后重新获取",iTimer] forState:UIControlStateNormal];
        btnGetCode.enabled=NO;
    }else{
        btnGetCode.enabled=YES;
        [btnGetCode setTitle:@"重新获取验证码" forState:UIControlStateNormal];
        [waitTimer invalidate];
    }
}

#pragma mark 获取手机验证码
- (IBAction)btnGetCodeClick:(id)sender {
    NSString *sCountryCode=@"86";
    NSString *sPhone=fztxtPhoneNum.text;
    
    
    if (!noticeView) {
        noticeView=[[FZNoticeView alloc] initWithReferView:self.view bHasNavItem:YES];
    }
    
    if (sPhone.length!=11) {
        [noticeView showWithNotice:@"请输入11位手机号"];
        [fztxtPhoneNum becomeFirstResponder];
        return;
    }
    
    iTimer=0;
    waitTimer=[NSTimer scheduledTimerWithTimeInterval:1.0 target:self selector:@selector(waitRegistCode) userInfo:nil repeats:YES];
    [waitTimer fire];
    
    [self disKeyboard];
    
    //用第三方sdk 获取注册码
    [SMS_SDK getVerificationCodeBySMSWithPhone:sPhone zone:sCountryCode result:^(SMS_SDKError *error) {
        if (error) {
            NSLog(@"%@",error.errorDescription);
            [waitTimer invalidate];
            return;
        }
    }];
}

-(void)dismissView{
    [self dismissViewControllerAnimated:YES completion:nil];
}

#pragma mark 所有txtfield的键盘消失
-(void)disKeyboard{
    [fztxtPhoneNum resignFirstResponder];
    [fztxtPhoneVerify resignFirstResponder];
    [fztxtPwd resignFirstResponder];
}

@end
