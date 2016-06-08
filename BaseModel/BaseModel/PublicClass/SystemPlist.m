//
//  cSystemPlist.m
//  BaseModel
//
//  Created by apple on 15/9/1.
//  Copyright (c) 2015年 Fabius's Studio. All rights reserved.
//



#import "SystemPlist.h"

#define dbLogin            @"bLogin"
#define dsLoginType        @"sLoginType"
#define dsID               @"sID"
#define dsName             @"sName"
#define dsHeadLogo         @"sHeadLogo"
#define dsHeadLogoFileName @"headlogo.png"
#define dsGender           @"sGender"
#define dsTaken            @"sTaken"
#define dsActionImage      @"ActionImage"

#define dsSystemPlistPath [NSString stringWithFormat:@"%@/SystemPlist.plist",NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES).firstObject]

#define dsHeadLogoFolderPath [NSString stringWithFormat:@"%@/HeadLogo",NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES).firstObject]

@implementation SystemPlist

+(SystemPlist*)shared{
    static dispatch_once_t once = 0;
    static SystemPlist *Obj;
    dispatch_once(&once, ^{ Obj = [[SystemPlist alloc] init]; });
    return Obj;
}

#pragma mark 创建信息 登录用户信息的plist 和头像logo文件夹HeadLogo
+(void)CreateSystemPlist{
    if (![[NSFileManager defaultManager] fileExistsAtPath:dsSystemPlistPath]) {
        NSDictionary *dictInfo=@{dbLogin: @"NO",dsLoginType:@"none",dsID:@"",dsName:@"",dsHeadLogo:@"",dsGender:@"",dsTaken:@""};
        [dictInfo writeToFile:dsSystemPlistPath atomically:YES];
    }
    
    //创建头文件夹
    if (![[NSFileManager defaultManager] fileExistsAtPath:dsHeadLogoFolderPath]) {
        [[NSFileManager defaultManager] createDirectoryAtPath:dsHeadLogoFolderPath withIntermediateDirectories:YES attributes:nil error:nil];
    }
    //创建活动图片文件夹
    NSString *sActionImagePath=[NSString stringWithFormat:@"%@%@",[PublicFunc GetSandBoxPathWithType:SandBoxPathTypeDocuments],dsActionImage];
    if (![[NSFileManager defaultManager] fileExistsAtPath:sActionImagePath]) {
        [[NSFileManager defaultManager] createDirectoryAtPath:sActionImagePath withIntermediateDirectories:YES attributes:nil error:nil];
    }

}

#pragma mark 初始化信息 登录用户信息的plist 清空头像logo文件夹HeadLogo文件
+(void)InitSystemPlist{
    //初始化systemplist
    NSDictionary *dictInfo=@{dbLogin: @"NO",dsLoginType:@"none",dsID:@"",dsName:@"",dsHeadLogo:@"",dsGender:@"",dsTaken:@""};
    [dictInfo writeToFile:dsSystemPlistPath atomically:YES];

    //删除头像文件
    [[NSFileManager defaultManager] removeItemAtPath:[NSString stringWithFormat:@"%@/%@",dsHeadLogoFolderPath,dsHeadLogoFileName] error:nil];
}

#pragma mark systemPlist文件是否存在
+(BOOL)ExistSystemPlist{
   return [[NSFileManager defaultManager] fileExistsAtPath:dsSystemPlistPath];
}

#pragma mark 返回systemPlist的NSMutableDictionary
-(NSMutableDictionary*)getSystemPlistDictionary{
    
    NSMutableDictionary *dictPlist;
    dictPlist = [[NSMutableDictionary alloc] initWithContentsOfFile:dsSystemPlistPath];
    
    return dictPlist;
}

#pragma mark 设置值
-(void)setPlistValue:(NSString*)psValue sKey:(NSString*)psKey{
    
    NSMutableDictionary *dictPlist=[[SystemPlist shared] getSystemPlistDictionary];
    
    [dictPlist setObject:psValue forKey:psKey];
    //保存
    [dictPlist writeToFile:dsSystemPlistPath atomically:YES];

}
#pragma mark 获取值
-(NSString*)getPlistValue:(NSString*)psKey{
    NSMutableDictionary *dictPlist=[[SystemPlist shared] getSystemPlistDictionary];
    return  [dictPlist objectForKey:psKey];
}

#pragma mark 设置bLogin的属性
+(void)SetLogin:(BOOL)pbLogin{
    
    NSMutableDictionary *dictPlist=[[SystemPlist shared] getSystemPlistDictionary];
    
    NSString *sFlag=@"";
    if (pbLogin) {
        sFlag=@"YES";
    }else{
        sFlag=@"NO";
    }

    [dictPlist setObject:sFlag forKey:dbLogin];
    //保存
    [dictPlist writeToFile:dsSystemPlistPath atomically:YES];
    
}
+(BOOL)GetLogin{
    NSMutableDictionary *dictPlist=[[SystemPlist shared] getSystemPlistDictionary];
    
    BOOL sFlag;
    
    if ([[dictPlist objectForKey:dbLogin] isEqualToString:@"YES"]) {
        sFlag=YES;
    }else{
        sFlag=NO;
    }
    return sFlag;
}

#pragma mark 登录类型 系统注册:system 第三方:sdk
+(void)SetLoginType:(LoginType)pLoginType{
    NSString *sType=@"";
    switch (pLoginType) {
        case LoginTypeNone:{
            sType=@"none";
            break;
        }case LoginTypeSdk:{
            sType=@"sdk";
            break;
        }case LoginTypeSystem:{
            sType=@"system";
            break;
        }
        default:
            break;
    }
    
    [[SystemPlist shared] setPlistValue:sType sKey:dsLoginType];

}
+(LoginType)GetLoginType{
    
    NSString *sType=[[SystemPlist shared] getPlistValue:dsLoginType];
    
    if ([sType isEqualToString:@"none"]) {
        return LoginTypeNone;
    }else if ([sType isEqualToString:@"sdk"]){
        return LoginTypeSdk;
    }else if ([sType isEqualToString:@"system"]){
        return LoginTypeSystem;
    }else{
        return LoginTypeNone;
    }
}

#pragma mark 设置sID属性
+(void)SetID:(NSString*)pID{
    [[SystemPlist shared] setPlistValue:pID sKey:dsID];
}
+(NSString*)GetID{
    return [[SystemPlist shared] getPlistValue:dsID];
}

#pragma mark 设置sName属性
+(void)SetName:(NSString*)pName{
    [[SystemPlist shared] setPlistValue:pName sKey:dsName];
}
+(NSString*)GetName{
    return [[SystemPlist shared] getPlistValue:dsName];
}

#pragma mark 设置sHeadLogo属性
+(NSString*)GetHeadLogo{
    if (![[[SystemPlist shared] getPlistValue:dsHeadLogo] isEqualToString:@""]) {
        return [NSString stringWithFormat:@"%@/%@",dsHeadLogoFolderPath,[[SystemPlist shared] getPlistValue:dsHeadLogo]];
    }else{
        return @"";
    }
}

+(NSString*)GetHeadLogoFileName{
    return dsHeadLogoFileName;
}

#pragma mark 设置sGender属性
+(void)SetGender:(NSString*)pGendero{
    [[SystemPlist shared] setPlistValue:pGendero sKey:dsGender];
}
+(NSString*)GetGender{
    return [[SystemPlist shared] getPlistValue:dsGender];
}

#pragma mark 设置sTaken属性
+(void)SetTaken:(NSString*)pTaken{
    [[SystemPlist shared] setPlistValue:pTaken sKey:dsTaken];
}
+(NSString*)GetTaken{
    return [[SystemPlist shared] getPlistValue:dsTaken];
}

#pragma mark 保存头像到本地
+(void)SaveHeadLogoToLocalWithUrl:(NSString*)psHeadLogoUrl{
    
    if ([psHeadLogoUrl isEqualToString:@""]) return;
    
    NSData * data = [NSData dataWithContentsOfURL:[NSURL URLWithString:psHeadLogoUrl]];
    UIImage * imageFromURL = [UIImage imageWithData:data];
    
    [UIImageJPEGRepresentation(imageFromURL, 1) writeToFile:[NSString stringWithFormat:@"%@/%@",dsHeadLogoFolderPath,dsHeadLogoFileName] options:NSAtomicWrite error:nil];
    
    //设置HeadLogo到systemplist
    [[SystemPlist shared] setPlistValue:dsHeadLogoFileName sKey:dsHeadLogo];
}

+(void)SaveHeadLogoToLocalWithData:(NSData*)pData{
    if (pData.length==0) return;
    
    //创建文件并重命名
    [[NSFileManager defaultManager] createFileAtPath:[NSString stringWithFormat:@"%@/%@",dsHeadLogoFolderPath,dsHeadLogoFileName] contents:pData attributes:nil];
    
    //设置HeadLogo到systemplist
    [[SystemPlist shared] setPlistValue:dsHeadLogoFileName sKey:dsHeadLogo];
}

#pragma mark 获取活动图片的路径
+(NSString*)GetActionImagePath{
     NSString *sActionImagePath=[NSString stringWithFormat:@"%@%@/",[PublicFunc GetSandBoxPathWithType:SandBoxPathTypeDocuments],dsActionImage];
    return sActionImagePath;
}

@end
