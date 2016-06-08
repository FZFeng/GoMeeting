//
//  OuterSDKClass.m
//  BaseModel
//
//  Created by apple on 15/8/27.
//  Copyright (c) 2015年 Fabius's Studio. All rights reserved.
//

#import "OuterSDKManager.h"

#define sWaitting            @"正在处理中..."
#define sSSOLoadError        @"授权登录失败"
#define sSSOLoadCancel       @"用户取消授权登录"
#define sSSOLoadErrConnection @"网络连接错误"

#define kSinaSSOAppKey       @"3087389294"
#define sSinaSSODefaultRedirectUri  @"https://api.weibo.com/oauth2/default.html"

#define kShareSMSKey         @"a24c007a7003"
#define kShareSMSSecret      @"d66a534fdba26ddc166105ebe9e65aee"

#define KTencentqqAppKey     @"1104648123"


@implementation OuterSDKManager

+(OuterSDKManager*)shared{
    static dispatch_once_t once = 0;
    static OuterSDKManager *Obj;
    dispatch_once(&once, ^{ Obj = [[OuterSDKManager alloc] init]; });
    return Obj;
}

#pragma mark 新浪微博

//注册
+(void)RegisterSinaWbWithEnableDebugMode:(BOOL)pbMode{
    [WeiboSDK enableDebugMode:pbMode];
    [WeiboSDK registerApp:kSinaSSOAppKey];
}

//分享内容
+(void)ShareToSinaWbWithText:(NSString*)psText sUrl:(NSString *)psUrl sImageName:(NSString*)psImageName{
    
    WBAuthorizeRequest *authRequest = [WBAuthorizeRequest request];
    authRequest.redirectURI = sSinaSSODefaultRedirectUri;
    authRequest.scope = @"all";
    
    //文件扩展名
    NSString *sFileExtent=[psImageName pathExtension];
    //没有扩展名的文件名
    NSString *ImageNameWithoutExtension=[psImageName substringWithRange:NSMakeRange(0,psImageName.length-sFileExtent.length-1)];
    
    //分享信息
    //文字+链接地址
    WBMessageObject *message = [WBMessageObject message];
    message.text=[NSString stringWithFormat:@"%@ %@",psText,psUrl];
    //图片
    WBImageObject *image = [WBImageObject object];
    image.imageData =  image.imageData = [NSData dataWithContentsOfFile:[[NSBundle mainBundle] pathForResource:ImageNameWithoutExtension ofType:sFileExtent]];
    
    message.imageObject = image;
    
    WBSendMessageToWeiboRequest *request = [WBSendMessageToWeiboRequest requestWithMessage:message authInfo:authRequest access_token:[OuterSDKManager shared].sSdkTaken];
    request.userInfo = @{@"SSO": @"weibo_share"};
    [WeiboSDK sendRequest:request];

}

//回调
//请求
- (void)didReceiveWeiboRequest:(WBBaseRequest *)request
{
    
}

//接收
- (void)didReceiveWeiboResponse:(WBBaseResponse *)response
{
    if ([response isKindOfClass:WBAuthorizeResponse.class])
    {
        NSString *sUid=[(WBAuthorizeResponse *)response userID];
        NSString *sTaken=[(WBAuthorizeResponse *)response accessToken];
        
        //sso授权成功
        if (response.statusCode==0) {
            NSString *urlStr=[NSString stringWithFormat:@"https://api.weibo.com/2/users/show.json?uid=%@&access_token=%@",sUid,sTaken];
            
            [FZNetworkHelper dataTaskWithUrl:urlStr arryPara:nil requestMethodType:requestMethodGet fatherObject:[OuterSDKManager shared].fatherView bShowSuccessMsg:NO block:^(NSDictionary *returnData, BOOL bReturn) {
                if (bReturn) {
                    NSString *sErrorCode=[returnData objectForKey:@"error_code"];
                    if (sErrorCode==nil) {
                        //下载头像文件到本地
                        NSString *sHeadLogoUrl=[returnData objectForKey:@"avatar_large"];
                        [SystemPlist SaveHeadLogoToLocalWithUrl:sHeadLogoUrl];
                        [SystemPlist SetLogin:YES];
                        [SystemPlist SetLoginType:LoginTypeSdk];
                        [SystemPlist SetName:[returnData objectForKey:@"screen_name"]];
                        [SystemPlist SetGender:[returnData objectForKey:@"gender"]];
                        [SystemPlist SetID:[returnData objectForKey:@"idstr"]];
                        [SystemPlist SetTaken:sTaken];
                        [OuterSDKManager shared].sSdkTaken=sTaken;
                        [OuterSDKManager shared].bReturnResult=YES;
                        
                    }else{
                        [[NSOperationQueue mainQueue] addOperationWithBlock:^{
                            //错误提示
                            [PublicFunc ShowErrorHUD:sSSOLoadError view:[OuterSDKManager shared].fatherView.view];
                        }];
                        [OuterSDKManager shared].bReturnResult=NO;
                    }
                }else{
                    [OuterSDKManager shared].bReturnResult=NO;
                }
                [OuterSDKManager shared].bWaitting=NO;
            }];
        }else{
            [OuterSDKManager shared].bWaitting=NO;
        }
    }
}


#pragma mark 腾讯qq

//回调 TencentSessionDelegate

- (void)tencentDidLogin
{
    NSString *sToken=[OuterSDKManager shared].tencentOAuth.accessToken;
    [OuterSDKManager shared].sSdkTaken=sToken;
    
    if (sToken && sToken.length>0)
    {
        //记录登录用户的信息
        if (![[OuterSDKManager shared].tencentOAuth getUserInfo]) {
            [OuterSDKManager shared].bWaitting=NO;
            [OuterSDKManager shared].bReturnResult=NO;
            //错误提示
            [PublicFunc ShowErrorHUD:sSSOLoadError view:[OuterSDKManager shared].fatherView.view];
        }
    }
    else
    {
        [OuterSDKManager shared].bWaitting=NO;
        [OuterSDKManager shared].bReturnResult=NO;
        //错误提示
        [PublicFunc ShowErrorHUD:sSSOLoadError view:[OuterSDKManager shared].fatherView.view];
    }
}

//非网络错误导致登录失败：
-(void)tencentDidNotLogin:(BOOL)cancelled
{
    [OuterSDKManager shared].bWaitting=NO;
    [OuterSDKManager shared].bReturnResult=NO;
    /*
    if (cancelled)
    {
        [PublicFunc ShowErrorHUD:sSSOLoadCancel view:[OuterSDKLoadClass shared].fatherView.view];
    }else{
        [PublicFunc ShowErrorHUD:sSSOLoadError view:[OuterSDKLoadClass shared].fatherView.view];
    }*/
}
// 网络错误导致登录失败：
-(void)tencentDidNotNetWork
{
    [OuterSDKManager shared].bWaitting=NO;
    [OuterSDKManager shared].bReturnResult=NO;
    [PublicFunc ShowErrorHUD:sSSOLoadErrConnection view:[OuterSDKManager shared].fatherView.view];
}

//获取用户详细信息
-(void)getUserInfoResponse:(APIResponse *)response
{
    [OuterSDKManager shared].bWaitting=NO;
    NSDictionary *returnData=response.jsonResponse;
    
    //下载头像文件到本地
    NSString *sHeadLogoUrl=[returnData objectForKey:@"figureurl_qq_2"];
    [SystemPlist SaveHeadLogoToLocalWithUrl:sHeadLogoUrl];
    [SystemPlist SetLogin:YES];
    [SystemPlist SetLoginType:LoginTypeSdk];
    [SystemPlist SetName:[returnData objectForKey:@"nickname"]];
    [SystemPlist SetID:[NSString stringWithFormat:@"%@_sdkload",[returnData objectForKey:@"nickname"]]];
    [SystemPlist SetGender:[returnData objectForKey:@"gender"]];
    [SystemPlist SetTaken:[OuterSDKManager shared].sSdkTaken];
    [OuterSDKManager shared].bReturnResult=YES;
}

//分享内容
+(void)ShareToQQWithText:(NSString *)psText{
    QQApiTextObject *txtObj=[QQApiTextObject objectWithText:psText];
    SendMessageToQQReq *req=[SendMessageToQQReq reqWithContent:txtObj];
    QQApiSendResultCode sent=[QQApiInterface sendReq:req];
    [[OuterSDKManager shared] handleSendResult:sent];
}

+(void)ShareToQQZoneWithText:(NSString *)psText{
    QQApiTextObject *txtObj=[QQApiTextObject objectWithText:psText];
    
    
    SendMessageToQQReq *req=[SendMessageToQQReq reqWithContent:txtObj];
    QQApiSendResultCode sent=[QQApiInterface SendReqToQZone:req];
    
    
    [[OuterSDKManager shared] handleSendResult:sent];
}

- (void)handleSendResult:(QQApiSendResultCode)sendResult
{
    switch (sendResult)
    {
        case EQQAPIAPPNOTREGISTED:
        {
            UIAlertView *msgbox = [[UIAlertView alloc] initWithTitle:@"Error" message:@"App未注册" delegate:nil cancelButtonTitle:@"取消" otherButtonTitles:nil];
            [msgbox show];
            
            
            break;
        }
        case EQQAPIMESSAGECONTENTINVALID:
        case EQQAPIMESSAGECONTENTNULL:
        case EQQAPIMESSAGETYPEINVALID:
        {
            UIAlertView *msgbox = [[UIAlertView alloc] initWithTitle:@"Error" message:@"发送参数错误" delegate:nil cancelButtonTitle:@"取消" otherButtonTitles:nil];
            [msgbox show];
            break;
        }
        case EQQAPIQQNOTINSTALLED:
        {
            UIAlertView *msgbox = [[UIAlertView alloc] initWithTitle:@"Error" message:@"未安装手Q" delegate:nil cancelButtonTitle:@"取消" otherButtonTitles:nil];
            [msgbox show];
            
            
            break;
        }
        case EQQAPIQQNOTSUPPORTAPI:
        {
            UIAlertView *msgbox = [[UIAlertView alloc] initWithTitle:@"Error" message:@"API接口不支持" delegate:nil cancelButtonTitle:@"取消" otherButtonTitles:nil];
            [msgbox show];
            
            
            break;
        }
        case EQQAPISENDFAILD:
        {
            UIAlertView *msgbox = [[UIAlertView alloc] initWithTitle:@"Error" message:@"发送失败" delegate:nil cancelButtonTitle:@"取消" otherButtonTitles:nil];
            [msgbox show];
            
            break;
        }
        default:
        {
            break;
        }
    }
}


#pragma mark 腾讯微信


#pragma mark share SMS短信发送注册
+(void)RegisterSMSWithKey{
    //注册sharesdk 短信发送平台
    [SMS_SDK registerApp:kShareSMSKey withSecret:kShareSMSSecret];
}

#pragma mark 公共方法
//获取用户信息(微博,qq,微信)
+(BOOL)GetUserInfoWithSdkType:(sdkType)psdkType FatherObject:(id)pFatherObject{
    
    [OuterSDKManager shared].fatherView=(UIViewController*)pFatherObject;
    
    [OuterSDKManager shared].bWaitting=YES;
    
    switch (psdkType) {
        case sdkTypeSinaweibo:{
            //新浪微博
            WBAuthorizeRequest *request = [WBAuthorizeRequest request];
            request.redirectURI = sSinaSSODefaultRedirectUri;
            request.scope = @"all";
            request.userInfo = @{@"SSO": @"weibo_load"};
            [WeiboSDK sendRequest:request];
            
            break;
        }case sdkTypeTencentqq:{
            //腾讯qq 2015-09-01 前后sdk版本 如果手机中没有安装qq的app 提示要求安装 没有新浪微浪人性化
            //这里要注意 一定要在腾讯开放平台中输入测试的QQ号，不然会出现 qq登录授权失败110406
            [OuterSDKManager shared].tencentOAuth=[[TencentOAuth alloc] initWithAppId:KTencentqqAppKey andDelegate:[OuterSDKManager shared]];
            
            NSArray *permissions= [NSArray arrayWithObjects:@"get_user_info",@"get_simple_userinfo",@"add_t",nil];
            [[OuterSDKManager shared].tencentOAuth authorize:permissions inSafari:NO];
            break;
        }
        default:
            break;
    }
    
    //等待回调结果
    while ([OuterSDKManager shared].bWaitting) {
        [[NSRunLoop currentRunLoop] runMode:NSDefaultRunLoopMode beforeDate:[NSDate distantFuture]];
    }
    
    return  [OuterSDKManager shared].bReturnResult;
    
}


//退出注册(微博,qq,微信)
+(void)LoginOutWithToken:(sdkType)psdkType{
    switch (psdkType) {
        case sdkTypeSinaweibo:{
            //新浪微博
            [WeiboSDK logOutWithToken:[SystemPlist GetTaken] delegate:nil withTag:nil];
            break;
        }
        default:
            break;
    }
}

//第三方回调
+(BOOL)handleOpenURL:(NSURL *)url{
    return  [WeiboSDK handleOpenURL:url delegate:[OuterSDKManager shared]] || [TencentOAuth HandleOpenURL:url];;
}



@end
