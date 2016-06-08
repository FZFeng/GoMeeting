//
//  cUser.h
//  BaseModel
//
//  Created by apple on 15/9/7.
//  Copyright (c) 2015年 Fabius's Studio. All rights reserved.
//  Info:用户操作类

#import "BusinessBase.h"

@interface ClassUser : BusinessBase

@property(nonatomic,strong)NSString *sID;        //用户有id 一般为注册的手机号
@property(nonatomic,strong)NSString *sName;      //用户名称
@property(nonatomic,strong)NSString *sPassword;  //用户密码
@property(nonatomic,strong)NSString *sHeadLogo;  //用户头像
@property(nonatomic,strong)NSString *sGender;    //用户性别 男:m 女:w
@property(nonatomic,strong)NSString *sDescription;//用户描述


//返回结果集的block
typedef void (^returnUserDataBlock) (BOOL bReturn,ClassUser *cUserObject);

/**
 *  验证用户并获取用户信息 1.是否存在 2.是否有效用户 3.获取指定用户信息
 *
 *  @param sID          用户表的主键id值 如 手机号等
 *  @param sPwd         用户密码
 *  @param fatherObject 所处的UIViewController
 *  @param returnBlock  返回的结果集
 */
+(void)checkUserAndGetDataWithID:(NSString*)sID sPwd:(NSString*)sPwd fatherObject:(id)fatherObject returnBlock:(returnUserDataBlock)returnBlock;
/**
 *  新用户注册/重设密码 1.是否存在 2.保存用户信息到服务器
 *
 *  @param sID          用户表的主键id值 如 手机号等
 *  @param sPwd         用户密码
 *  @param bNewUser     是否新用户注册 新注册时判断用户不存在才进行保存操作,重设密码的验证用户 判断用户存在时才进行保存操作
 *  @param fatherObject 所处的UIViewController
 *  @param returnBlock  返回的结果集
 */

+(void)registerUserWithID:(NSString*)sID sPwd:(NSString*)sPwd bNewUser:(BOOL)bNewUser fatherObject:(id)fatherObject returnBlock:(blockFunctionReturn)returnBlock;
/**
 *  获取指定用户信息
 *
 *  @param sID          用户表的主键id值 如 手机号等
 *  @param fatherObject 所处的UIViewController
 *
 *  @return cUser数据
 */
+(ClassUser*)getUserDataWithID:(NSString*)sID fatherObject:(id)fatherObject;
/**
 *  上传用信息像到服务器(包含头像 当pfromData 不为空时)
 *
 *  @param cUserObject  cUser对象
 *  @param fromDict     图片data
 *  @param fatherObject 所处的UIViewController
 *  @param returnBlock  返回的结果集
 */
+(void)upLoadUserDataWithObject:(ClassUser*)cUserObject fromDict:(NSDictionary*)fromDict fatherObject:(id)fatherObject returnBlock:(blockFunctionReturn)returnBlock;


@end
