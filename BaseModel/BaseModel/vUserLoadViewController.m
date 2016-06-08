//
//  vUserLoad.m
//  BaseModel
//
//  Created by apple on 15/9/2.
//  Copyright (c) 2015年 Fabius's Studio. All rights reserved.
//

#import "vUserLoadViewController.h"

@implementation vUserLoadViewController

-(void)viewDidLoad{
    
    [super viewDidLoad];
   
    fztxtUserName.placeholderText=@"请输入注册手机号";
    fztxtUserName.leftIcon=LeftIconTypeUser;
    fztxtUserName.delegate=self;
    
    fztxtUserPwd.placeholderText=@"请输注册密码";
    fztxtUserPwd.leftIcon=LeftIconTypePwd;
    fztxtUserPwd.secureTextEntry=YES;
    fztxtUserPwd.delegate=self;
    
    //圆角
    btnLoad.layer.cornerRadius =5.0;
    
    //点击空白处键盘消失
    self.view.userInteractionEnabled = YES;
    UITapGestureRecognizer *singleTouch = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(disKeyboard)];
    [self.view addGestureRecognizer:singleTouch];
}


#pragma mark 登陆
- (IBAction)btnLoadClick:(id)sender {
    
    //验证信息输入的有效性
    if (!noticeView) {
        noticeView=[[FZNoticeView alloc] initWithReferView:self.view bHasNavItem:YES];
    }
    
    if (fztxtUserName.text.length==0){
        [noticeView showWithNotice:@"请输入注册手机号"];
        [fztxtUserName becomeFirstResponder];
        return;
    }else if (fztxtUserName.text.length!=11){
        [noticeView showWithNotice:@"请输入11位手机号"];
        [fztxtUserName becomeFirstResponder];
        return;
    }else if (fztxtUserPwd.text.length==0){
        [noticeView showWithNotice:@"请输注册密码"];
        [fztxtUserPwd becomeFirstResponder];
        return;
    }
    //关闭键盘
    [self disKeyboard];
    
    //去服务器验证用户的有效性
    [ClassUser checkUserAndGetDataWithID:fztxtUserName.text sPwd:fztxtUserPwd.text fatherObject:self returnBlock:^(BOOL bReturn, ClassUser *cUserObject) {
        if (bReturn) {
            //保存数据到systemplist中
            //下载头像文件到本地
            [SystemPlist SaveHeadLogoToLocalWithUrl:cUserObject.sHeadLogo];
            [SystemPlist SetLogin:YES];
            [SystemPlist SetLoginType:LoginTypeSystem];
            [SystemPlist SetID:cUserObject.sID];
            [SystemPlist SetName:cUserObject.sName];
            [SystemPlist SetGender:cUserObject.sGender];
            [SystemPlist SetTaken:@""];
            
            //初始化个人活动数据
            [self performSelector:@selector(initMyActionData) withObject:nil afterDelay:0.5];
        }
    }];
}

-(void)initMyActionData{
    //下载活动数据
    ClassAction *cActionObject=[[ClassAction alloc] init];
   [cActionObject initMyActionData:self returnBlock:^(BOOL bReturnBlock) {
       if (bReturnBlock) [self dismissViewControllerAnimated:YES completion:nil];
   }];
    
}

#pragma mark 微博登陆
- (IBAction)btnSinawbLoadClick:(id)sender {
    if ([OuterSDKManager GetUserInfoWithSdkType:sdkTypeSinaweibo FatherObject:self]) [self dismissViewControllerAnimated:YES completion:nil];
}

#pragma mark 微信登陆
- (IBAction)btnWeixinLoadClick:(id)sender {
    if ([OuterSDKManager GetUserInfoWithSdkType:sdkTypeTencentweixin FatherObject:self]) [self dismissViewControllerAnimated:YES completion:nil];
}
#pragma mark qq登陆
- (IBAction)btnQqLoadClick:(id)sender {
        if ([OuterSDKManager GetUserInfoWithSdkType:sdkTypeTencentqq FatherObject:self]) [self dismissViewControllerAnimated:YES completion:nil];
}

#pragma mark 关闭
- (IBAction)barBtnItemCloseClick:(id)sender {
    [self disKeyboard];
    [self dismissViewControllerAnimated:YES completion:nil];
}

#pragma mark 忘记密码
- (IBAction)btnGetPwdClick:(id)sender {
    vUserRegisterViewController *vUserRegister=[self.storyboard instantiateViewControllerWithIdentifier:@"UIViewRegister"];
    ;
    vUserRegister.bGetNewPwd=YES;
    UIBarButtonItem *backItem=[[UIBarButtonItem alloc] initWithTitle:@"" style:UIBarButtonItemStyleDone target:nil action:nil];
    [self.navigationItem setBackBarButtonItem:backItem];
    [self.navigationController pushViewController:vUserRegister animated:YES];
}

#pragma mark 所有txtfield的键盘消失
-(void)disKeyboard{
    [fztxtUserName resignFirstResponder];
    [fztxtUserPwd resignFirstResponder];
}

#pragma mark prepareForSegue 跳转事件
-(void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender{
    if ([segue.identifier isEqualToString:@"segueUserRegister"]) {
        UIBarButtonItem *backItem=[[UIBarButtonItem alloc] initWithTitle:@"" style:UIBarButtonItemStyleDone target:nil action:nil];
        [self.navigationItem setBackBarButtonItem:backItem];
    }
}


@end
