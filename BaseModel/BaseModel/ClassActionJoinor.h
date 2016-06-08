//
//  cActionJoinor.h
//  BaseModel
//
//  Created by apple on 15/11/9.
//  Copyright (c) 2015年 Fabius's Studio. All rights reserved.
//  Info:参加活动人员

#import "BusinessBase.h"

@interface ClassActionJoinor : BusinessBase

@property(nonatomic,strong)NSString *sJoinorID;         //参于活动者的id 手机号/第三方登录id
@property(nonatomic,strong)NSString *sActionID;         //参加的活动编号
@property(nonatomic,strong)NSString *sJoinorName;       //参于水禾土
@property(nonatomic,strong)NSString *sContactPhone;     //联系人
@property(nonatomic,strong)NSString *sRemark;           //备注

@property(nonatomic,strong)NSString *sActionTitle;      //活动主题
@property(nonatomic,strong)NSString *sActionJoiner;     //参加活动人数(nsstring)
@property(nonatomic,strong)NSString *sActionCharge;     //活动费用
@property(nonatomic,strong)NSString *sActionContactPhone; //活动联系人
@property(nonatomic,strong)NSString *sActionImagePath;//第一张活动图片的路径

//获取本地数据
typedef enum {
    joinActionDataTypeRunning=0,  //进行中
    joinActionDataTypeFinished,   //已完成
    joinActionDataTypeBeCanceled, //被取消
    joinActionDataTypeMyCanceled //我取消
}joinActionDataType;
//获取参于过活动的数据

//返回结果集的block
typedef void (^returnJoinActionDataBlock) (NSArray *arryActionJoinorData);
-(void)getJoinActionData:(NSString*)sUserID joinActionDataType:(joinActionDataType)joinActionDataType fatherObject:(id)pfatherObject returnBlock:(returnJoinActionDataBlock)preturnBlock;

//参于某一活动
-(void)joinAction:(int)iActionID sContactPhone:(NSString*)sContactPhone sRemark:(NSString*)sRemark fatherObject:(id)pfatherObject returnBlock:(blockFunctionReturn)preturnBlock;

//取消参于的某一活动
-(void)cancelJoinAction:(int)iActionID sUserID:(NSString *)sUserID fatherObject:(id)pfatherObject returnBlock:(blockFunctionReturn)preturnBlock;

@end
