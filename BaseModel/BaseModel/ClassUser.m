//
//  cUser.m
//  BaseModel
//
//  Created by apple on 15/9/7.
//  Copyright (c) 2015年 Fabius's Studio. All rights reserved.
//  

#import "ClassUser.h"

@implementation ClassUser

#pragma mark 验证用户并获取用户信息 1.是否存在 2.是否有效用户 3.获取指定用户信息
+(void)checkUserAndGetDataWithID:(NSString*)sID sPwd:(NSString*)sPwd fatherObject:(id)fatherObject returnBlock:(returnUserDataBlock)returnBlock{

    NSMutableArray *arryUserInfo=[[NSMutableArray alloc] init];
    
    //用户名
    NSString *sParaUserID=[NSString stringWithFormat:@"sID=%@",sID];
    [arryUserInfo addObject:sParaUserID];
    //用户密码
    NSString *sParaUserPwd=[NSString stringWithFormat:@"sPwd=%@",sPwd];
    [arryUserInfo addObject:sParaUserPwd];
    
    [FZNetworkHelper dataTaskWithApiName:@"CheckUserAndGetDataWithID" arryPara:[arryUserInfo copy] requestMethodType:requestMethodGet fatherObject:fatherObject bShowSuccessMsg:NO sWaitingMsg:nil block:^(NSDictionary *returnData, BOOL bReturn)
    {
        if (bReturn) {
            NSString *sErrorCode=[returnData objectForKey:@"errorcode"];
            if ([sErrorCode isEqualToString:@"0"]) {
                NSDictionary *dictData=[returnData objectForKey:@"data"];
                ClassUser *cUserObject=[[ClassUser alloc] init];
                cUserObject.sID=[dictData objectForKey:@"sID"];
                cUserObject.sName=[dictData objectForKey:@"sName"];
                cUserObject.sHeadLogo=[dictData objectForKey:@"sHeadLogo"];
                cUserObject.sGender=[dictData objectForKey:@"sGender"];
                cUserObject.sDescription=[dictData objectForKey:@"sDescription"];
                returnBlock(YES,cUserObject);
            }else{
                NSString *sErrorMsg=[returnData objectForKey:@"errormsg"];
                [PublicFunc ShowErrorHUD:sErrorMsg view:((UIViewController*)fatherObject).view];
                returnBlock(NO,nil);
            }
        }else{
            returnBlock(NO,nil);
        }
    }];

}


#pragma mark 新用户注册/重设密码 1.是否存在 2.保存用户信息到服务器
+(void)registerUserWithID:(NSString*)sID sPwd:(NSString*)sPwd bNewUser:(BOOL)bNewUser fatherObject:(id)fatherObject returnBlock:(blockFunctionReturn)returnBlock{

    NSMutableArray *arryUserInfo=[[NSMutableArray alloc] init];
    
    //用户名
    NSString *sParaUserID=[NSString stringWithFormat:@"sID=%@",sID];
    [arryUserInfo addObject:sParaUserID];
    //用户密码
    NSString *sParaUserPwd=[NSString stringWithFormat:@"sPassword=%@",sPwd];
    [arryUserInfo addObject:sParaUserPwd];
    //是否新注册
    NSString *sNewUser=@"";
    if (bNewUser) {
        sNewUser=@"yes";
    }else{
        sNewUser=@"no";
    }
    NSString *sParaNewUser=[NSString stringWithFormat:@"bNewRegister=%@",sNewUser];
    [arryUserInfo addObject:sParaNewUser];
    
    [FZNetworkHelper dataTaskWithApiName:@"RegisterUserWithParams" arryPara:arryUserInfo requestMethodType:requestMethodPost fatherObject:fatherObject bShowSuccessMsg:NO sWaitingMsg:nil block:^(NSDictionary *returnData, BOOL bReturn) {
        if (bReturn) {
            NSString *sErrorCode=[returnData objectForKey:@"errorcode"];
            if ([sErrorCode isEqualToString:@"1"]) {
                NSString *sErrorMsg=[returnData objectForKey:@"errormsg"];
                [PublicFunc ShowErrorHUD:sErrorMsg view:((UIViewController*)fatherObject).view];
                bReturn=NO;
            }
        }
        returnBlock(bReturn);
    }];
}

#pragma mark 获取指定用户信息
+(ClassUser*)getUserDataWithID:(NSString*)sID fatherObject:(id)fatherObject{
    NSMutableArray *arryUserInfo=[[NSMutableArray alloc] init];
    ClassUser *cUserObject=[[ClassUser alloc] init];
    
    //用户名
    NSString *sParaUserID=[NSString stringWithFormat:@"sID=%@",sID];
    [arryUserInfo addObject:sParaUserID];
    
    
    [FZNetworkHelper dataTaskWithApiName:@"GetUserDataWithID" arryPara:[arryUserInfo copy] requestMethodType:requestMethodGet fatherObject:fatherObject bShowSuccessMsg:NO sWaitingMsg:nil block:^(NSDictionary *returnData, BOOL bReturn)
     {
         if (bReturn) {
             cUserObject.sID=[returnData objectForKey:@"sID"];
             cUserObject.sName=[returnData objectForKey:@"sName"];
             cUserObject.sPassword=[returnData objectForKey:@"sPassword"];
             cUserObject.sHeadLogo=[returnData objectForKey:@"sHeadLogo"];
             cUserObject.sGender=[returnData objectForKey:@"sGender"];
             cUserObject.sDescription=[returnData objectForKey:@"sDescription"];
         }
     }];

    return cUserObject;
}
#pragma mark 上传用信息像到服务器(包含头像 当pfromData 不为空时)
+(void)upLoadUserDataWithObject:(ClassUser*)cUserObject fromDict:(NSDictionary*)fromDict fatherObject:(id)fatherObject returnBlock:(blockFunctionReturn)returnBlock{

    //用id
    NSMutableArray *arryUserInfo=[[NSMutableArray alloc] init];
    NSString *sParaUserID=[NSString stringWithFormat:@"sID=%@",cUserObject.sID];
    [arryUserInfo addObject:sParaUserID];
    
    //用户名
    NSString *sParaUserName=[NSString stringWithFormat:@"sName=%@",cUserObject.sName];
    [arryUserInfo addObject:sParaUserName];
    
    //用户性别
    NSString *sParaUserGender=[NSString stringWithFormat:@"sGender=%@",cUserObject.sGender];
    [arryUserInfo addObject:sParaUserGender];
    
    [FZNetworkHelper upLoadTaskWithApiName:@"UpLoadUserDataWithParams" arryPara:arryUserInfo fromDict:fromDict   fatherObject:fatherObject updateFileType:updateFileTypeImage sWaitingMsg:nil block:^(NSDictionary *returnData, BOOL bReturn) {
        if (bReturn) {
            NSString *sErrorCode=[returnData objectForKey:@"errorcode"];
            if ([sErrorCode isEqualToString:@"1"]) {
                NSString *sErrorMsg=[returnData objectForKey:@"errormsg"];
                [PublicFunc ShowErrorHUD:sErrorMsg view:((UIViewController*)fatherObject).view];
                bReturn=NO;
            }
        }
        returnBlock(bReturn);
    }];
}

@end
