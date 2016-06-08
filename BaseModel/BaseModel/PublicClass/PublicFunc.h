//
//  PublicFunc.h
//  iSaleApp
//
//  Created by DYF on 14-5-14.
//  Copyright (c) 2014年 Fabius-Studio. All rights reserved.
//  Info:公共方法类

#import <Foundation/Foundation.h>
#import "MBProgressHUD.h"
#import "MBSpinningCircle.h"

/***
*  showHUDSuccess 1:成功 
   showHUDError   2:失败 
   showHUDNotice  3:注意
*/
enum showHUDType{
    showHUDSuccess,
    showHUDError,
    showHUDNotice
};

@interface PublicFunc :NSObject

+(PublicFunc*)shared;


#pragma mark HUD
//简单提示框
+(void)ShowSimpleMsg:(NSString *)pMsg;

//清除图片缓存
+(void)ClearImgCache;

//简单MBProgressHUD提示
+(void)ShowSimpleHUD:(NSString*)pMsg view:(UIView*)pView;

//成功MBProgressHUD提示
+(void)ShowSuccessHUD:(NSString*)pMsg view:(UIView*)pView;

//错误MBProgressHUD提示
+(void)ShowErrorHUD:(NSString*)pMsg view:(UIView*)pView;

//注意MBProgressHUD提示
+(void)ShowNoticeHUD:(NSString*)pMsg view:(UIView*)pView;


//等待
+(id)ShowWaittingHUD:(NSString*)pMsg view:(UIView*)pView;

//隐藏指定对象的HUD id指得就是MBProgressHUD对象
+(void)HideHUD:(id)pHUD;

//通过键值获取沙箱plist文件中的值
//pID:键值
+(NSString*)GetPlistValue:(NSString*)pID;

//通过键值设置沙箱plist文件中的值
//pID:键值 pValue 值
+(void)SetPlistValue:(NSString*)pID value:(NSString*)pValue;

//获取沙箱地址类型
typedef enum {
    SandBoxPathTypeDocuments=0,//Documents
    SandBoxPathTypeTemp,       //tmp
    SandBoxPathLibrary          //Library/Caches
} SandBoxPathType;

//获取沙箱地址
+(NSString*)GetSandBoxPathWithType:(SandBoxPathType)SandBoxPathType;

//指定日期与当前日期比较 结果大于0 表示指定日期还在未来时间中
+(float)intervalSinceNow:(NSString *)theDate;

//调整图片的大小(分辨率和大小)
+(NSData *)resetSizeOfImageData:(UIImage *)source_image maxSize:(NSInteger)maxSize;

+(NSData *)resetSizeOfImageData:(UIImage *)source_image newSourceImageSize:(NSInteger)newSourceImageSize maxSize:(NSInteger)maxSize;

//缩成小图片
+(NSData *)resetSmallImageWithImage:(UIImage *)source_image;

@end
