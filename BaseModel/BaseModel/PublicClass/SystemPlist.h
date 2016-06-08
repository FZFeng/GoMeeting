//
//  cSystemPlist.h
//  BaseModel
//
//  Created by apple on 15/9/1.
//  Copyright (c) 2015年 Fabius's Studio. All rights reserved.
//  Info:系统全局信息类 如登录信息

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import "PublicFunc.h"

@interface SystemPlist : NSObject

//创建信息 登录用户信息的plist 和头像logo文件夹HeadLogo
+(void)CreateSystemPlist;

//初始化信息 登录用户信息的plist 清空头像logo文件夹HeadLogo文件
+(void)InitSystemPlist;

//systemPlist文件是否存在
+(BOOL)ExistSystemPlist;

//isLogin
+(void)SetLogin:(BOOL)pbLogin;
+(BOOL)GetLogin;

//登录类型
typedef enum {
    LoginTypeNone=0,//没登录
    LoginTypeSystem,//注册登录
    LoginTypeSdk    //sdk第三方登录
} LoginType;
+(void)SetLoginType:(LoginType)pLoginType;
+(LoginType)GetLoginType;

//sID 注册后记住用户ID 一般为手机号
+(void)SetID:(NSString*)pID;
+(NSString*)GetID;

//sName
+(void)SetName:(NSString*)pName;
+(NSString*)GetName;

//sHeadLogo
//+(void)SetHeadLogo:(NSString*)pHeadLogo;
+(NSString*)GetHeadLogo;
+(NSString*)GetHeadLogoFileName;

//sGender 男:m 女:w
+(void)SetGender:(NSString*)pGendero;
+(NSString*)GetGender;

//sTaken
+(void)SetTaken:(NSString*)pTaken;
+(NSString*)GetTaken;

//保存头像到本地
+(void)SaveHeadLogoToLocalWithUrl:(NSString*)psHeadLogoUrl;
+(void)SaveHeadLogoToLocalWithData:(NSData*)pData;

//获取活动图片的路径
+(NSString*)GetActionImagePath;

@end
