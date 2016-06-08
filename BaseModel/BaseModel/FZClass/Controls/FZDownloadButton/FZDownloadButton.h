//
//  FZDownloadButton.h
//  GoTogether
//
//  Created by apple on 15/7/24.
//  Copyright (c) 2015年 Fabius's Studio. All rights reserved.
//  info:后台下载button 主要功能如下
/*
 1.实例化类后 必须设置sDownTaskIdentify,sDownTaskUrl属性 当两者其中的一个属性为nil时提示 "未初始化" sServerUrl属性为检测网络是否联通的url如果此属性为nil 则被赋值为sDownTaskUrl
 2.在不出退app(即没有kill程序或程序中调用exit) 支持断点,续传;断网后再联网时,续传.当程序被kill时，会调用Delegate 中的 applicationWillTerminate 方法 清除下载任务的临时文件
 3.当下载任务在进行 类对象将要被消毁时 必须调用 doSomethingWhenDisappear 暂停并保存已下载的数据,方便续传(一般可以在调用此类中的viewWillDisappear 过程中调用)
 */

#import <UIKit/UIKit.h>
//#import "cPublicVar.h"

@interface FZDownloadButton : UIButton<NSURLSessionDelegate,NSURLSessionDownloadDelegate>{

    NSURLSessionDataTask *sessionDataTaskCheckNetwork;//测试网络对象
    NSURLSessionDownloadTask *sessionDownLoad;        //下载对象
    NSURLSession *session;
    
    BOOL bTaskRunning;                                //标记下载任务是在运行还是挂起
    BOOL bTaskFinish;                                 //标记下载任务是否已完成
    BOOL bNeedToCheckNetwork;                         //是否需要检查网络
    
    UILabel *lblTitle;
    NSTimer *checkNetworkTimer;
    NSString *sTxtCheckNetwork;
}
@property(nonatomic) int iTimeOutSeconds;             //设置超时时间
@property(nonatomic,strong) NSString *sDownTaskIdentify;//每个下载任务的id 暂停保存的临时文件就是以此id命名.tmp 方便查找
@property(nonatomic,strong) NSString *sDownTaskUrl;     //下载文件的url
@property(nonatomic,strong) NSString *sServerUrl;       //服务器的url(用于检测网络是否可连通)

//当本对象disappear时处理一些事情
-(void)doSomethingWhenDisappear;
//删除下载过程中的临时文件 psDownTaskIdentify为nil时删除全部
-(void)deleteTmpData:(NSString*)psDownTaskIdentify;
@end
