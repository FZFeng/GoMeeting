//
//  OuterSDKClass.h
//  BaseModel
//
//  Created by apple on 15/8/27.
//  Copyright (c) 2015年 Fabius's Studio. All rights reserved.
//  Info:第三方 sso登录,分享
//  支持 新浪微博,微信,QQ
//  由于微信只支持企业所以，还没申请下来 2015-09-11

#import <Foundation/Foundation.h>
#import "FZNetworkHelper.h"
#import "WeiboSDK.h"

#import <SMS_SDK/SMS_SDK.h>

#import <TencentOpenAPI/TencentOAuth.h>
#import <TencentOpenAPI/TencentOAuthObject.h>
#import <TencentOpenAPI/TencentApiInterface.h>
#import "TencentOpenAPI/QQApiInterface.h"

#import "SystemPlist.h"

/**
 请求方法类型 get,post
 */
typedef enum {
    sdkTypeSinaweibo=0,
    sdkTypeTencentweixin,
    sdkTypeTencentqq
} sdkType;

@interface OuterSDKManager : NSObject<WeiboSDKDelegate,TencentSessionDelegate>
 
@property(nonatomic) BOOL bWaitting;
@property(nonatomic) BOOL bReturnResult;
@property(nonatomic,strong) NSString *sSdkTaken;
@property(nonatomic,strong) UIViewController *fatherView;
@property(nonatomic,strong) TencentOAuth *tencentOAuth;

#pragma mark share SMS短信发送注册
+(void)RegisterSMSWithKey;


#pragma mark 新浪微博
//注册
//@param pbMode 是否开启调试模式
+(void)RegisterSinaWbWithEnableDebugMode:(BOOL)pbMode;

//分享到新浪微博
//psText      要文享的文字内容
//psUrl       指定要跑到的链接 如:http://www.baidu.com 必须有效地址
//psImageName 图片名(必须包含扩展名)
+(void)ShareToSinaWbWithText:(NSString*)psText sUrl:(NSString *)psUrl sImageName:(NSString*)psImageName;

#pragma mark 用户取消对应⽤用的授权
//psToken 获取的taken
//dkType sdktype
+(void)LoginOutWithToken:(sdkType)psdkType;

#pragma mark 根据sdktype来获取用户信息
//pSdkType           sdktype
//pFatherObject      调用此接口的对象 使用 HUD 时需要
//presultBlock       结果block
+(BOOL)GetUserInfoWithSdkType:(sdkType)psdkType FatherObject:(id)pFatherObject;

#pragma mark 第三方回调
//url 返回的rul
//return Yes/No
+(BOOL)handleOpenURL:(NSURL *)url;

//分享文本给QQ好友
+(void)ShareToQQWithText:(NSString *)psText;
//分享文本到QQ空间
+(void)ShareToQQZoneWithText:(NSString *)psText;

@end



