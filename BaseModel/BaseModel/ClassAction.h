//
//  cAction.h
//  BaseModel
//
//  Created by apple on 15/11/4.
//  Copyright (c) 2015年 Fabius's Studio. All rights reserved.
//  Info:活动类

#import "BusinessBase.h"

@interface ClassAction : BusinessBase

//获取本地数据
typedef enum {
    actionDataTypeRunning=0,//进行中
    actionDataTypeFinished, //已完成
    actionDataTypeCanceled  //已取消
}actionDataType;

typedef enum {
    refreshTypeInit=0,//初始化
    refreshTypeDown,  //下拉更新最新数据
    refreshTypeUp     //上拉更新旧数据
}refreshType;


@property(nonatomic,strong)NSString *sActionID;         //主键
@property(nonatomic,strong)NSString *sActionTitle;      //活动主题
@property(nonatomic,strong)NSString *sActionDate;       //活动日期
@property(nonatomic,strong)NSString *sActionPlace;      //活动地点
@property(nonatomic,strong)NSString *sActionManNum;     //活动人数 0为不限人数
@property(nonatomic,strong)NSString *sActionCharge;     //活动费用
@property(nonatomic,strong)NSString *sActionContactPhone; //活动联系人
@property(nonatomic,strong)NSString *sActionDescription;//活动描述
@property(nonatomic,strong)NSString *sActionCreater;    //创建活动者 一般指用app发布活动的user
@property(nonatomic,strong)NSString *sDate;             //录入数据时间
@property(nonatomic,strong)NSString *sActionJoiner;     //参加活动人数(nsstring)
@property(nonatomic)int iActionJoiner;                  //参加活动人数
@property(nonatomic)BOOL bActionFinished;               //活动是否结束
@property(nonatomic)BOOL bActionCanceled;               //活动是否被取消

@property(nonatomic)BOOL bActionImageHasDownload;       //对应的活动图片的第一张图片是否已下载
@property(nonatomic,strong)NSArray *arryActionImagePath;//第一张活动图片的路径 如果 bActionImageHasDownload==yes 就是本地路径 ==no 是 就服务器的url

@property(nonatomic,strong)NSString *sAdActionImageUrl;//系统活动的海报图片地址
@property(nonatomic,strong)NSString *sAdActionUrl;     //系统活动的海报详情地址
@property(nonatomic,strong)NSString *sAdActionTitle;   //系统活动的主题

//保存活动图片致本地
-(BOOL)saveImgToLocal:(NSArray*)arryImgs;

//获取本地活动数据
-(NSArray*)getLocalActionData:(actionDataType)actionDataType;

//获取服务器上的数据
typedef void (^blockReServerActionData)(NSArray *arryServerActionData,NSArray *arryAdActionData,BOOL bNeedClearData,NSString *sErrMsg);
-(void)getServerActionData:(refreshType)refreshType sLocalUpdateDate:(NSString*)sLocalUpdateDate returnBlock:(blockReServerActionData)returnBlock;

//初始化活动数据
-(void)initMyActionData:(id)pfatherObject returnBlock:(blockFunctionReturn)preturnBlock;

//发布活动
-(void)issueAction:(ClassAction*)cActionObject issueImages:(NSArray*)issueImages fatherObject:(id)pfatherObject returnBlock:(blockFunctionReturn)preturnBlock;

//取消活动(本地和服务器一起更新)
-(void)cancelMyAction:(int)iActionID  fatherObject:(id)pfatherObject returnBlock:(blockFunctionReturn)preturnBlock;

//判断当前活动是否已过期和已被取消,成功后并返回最新的已参加活动的人数
typedef void (^blockCheckActionEnable)(BOOL bReturnBlock,int iActionJoiner);
-(void)checkActionEnable:(int)iActionID fatherObject:(id)pfatherObject returnBlock:(blockCheckActionEnable) returnBlock;

//删除活动数据和图片图片内容
-(BOOL)deleteActionDataAndImage;

@end
