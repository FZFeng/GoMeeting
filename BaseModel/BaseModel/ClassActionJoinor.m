
#import "ClassActionJoinor.h"

#define sActionDisEnable       @"此活动无效,我们已在处理中..."
#define sActionLate            @"你来晚了,此活动已过期了"
#define sActionCancel          @"你来晚了,此活动已被取消了"
#define sHasJoinAction         @"你已参加了此活动"
#define sActionNumMax          @"你来晚了,此活动人数已满"
#define sSuccessJoinAction     @"已成功参加此活动"

@implementation ClassActionJoinor

-(BOOL)createTable{
    
    BOOL bReturn=YES;
    //表不存在就创建
    if ([SqliteHelper existTb:@"tActionJoinor"]==sqliteErrExist) {
        NSString *sSQL=@"CREATE TABLE tActionJoinor (";
        sSQL=[sSQL stringByAppendingString:@"iID INTEGER,"];
        sSQL=[sSQL stringByAppendingString:@"sJoinorID text collate nocase,"];
        sSQL=[sSQL stringByAppendingString:@"sJoinorName  text collate nocase,"];
        sSQL=[sSQL stringByAppendingString:@"sContactPhone text collate nocase,"];
        sSQL=[sSQL stringByAppendingString:@"sActionID text collate nocase,"];
        sSQL=[sSQL stringByAppendingString:@"sRemark  text collate nocase)"];

        bReturn=[SqliteHelper executeNonQuery:sSQL];
    }
    
    return bReturn;
}

-(BOOL)insertData{
    BOOL bReturn=YES;
    
    if (self==nil) {
        return NO;
    }
    
    NSString *sSQL=[NSString stringWithFormat:@"INSERT INTO tActionJoinor (iID,sJoinorID,sActionID,sJoinorName,sContactPhone,sActionID,sRemark) VALUES ('%@','%@','%@','%@','%@') ",self.sJoinorID,self.sActionID,self.sJoinorName,self.sContactPhone,self.sRemark];
    
    bReturn=[SqliteHelper executeNonQuery:sSQL];
    
    return bReturn;
}

#pragma mark 参于某一活动
-(void)joinAction:(int)iActionID sContactPhone:(NSString*)sContactPhone sRemark:(NSString*)sRemark fatherObject:(id)pfatherObject returnBlock:(blockFunctionReturn)preturnBlock{
    //判断活动是否已过期
    //判断活动是否已取消
    //判断是否已参加过活动
    //判断活动是否已满人
    //保存内容
    //1.tAction修改参加人数 2.在tActionJoinor 添加参加活动的信息 3.信息保存本地后同步到服务器
    
    UIViewController *fatherView=(UIViewController*)pfatherObject;
    
    //错误内容
    __block NSString *sResultMsg=@"";
    
    //返回结果
    __block BOOL bResult=NO;
    
    //修改服务器上内容
    //调用参数
    NSMutableArray *arryPara=[[NSMutableArray alloc] init];
    
    //sJoinorID
    NSString *sParaJoinorID=[NSString stringWithFormat:@"sJoinorID=%@",[SystemPlist GetID]];
    [arryPara addObject:sParaJoinorID];
    
    //sJoinorName
    NSString *sParaJoinorName=[NSString stringWithFormat:@"sJoinorName=%@",[SystemPlist GetName]];
    [arryPara addObject:sParaJoinorName];

    //sContactPhone
    NSString *sParaContactPhone=[NSString stringWithFormat:@"sContactPhone=%@",sContactPhone];
    [arryPara addObject:sParaContactPhone];
    
    //iActioID
    NSString *sParaActionID=[NSString stringWithFormat:@"iActionID=%d",iActionID];
    [arryPara addObject:sParaActionID];
    
    //sRemark
    NSString *sParaRemark=[NSString stringWithFormat:@"sRemark=%@",sRemark];
    [arryPara addObject:sParaRemark];
    
    [FZNetworkHelper dataTaskWithApiName:@"api_JoinAction" arryPara:arryPara requestMethodType:requestMethodGet fatherObject:fatherView bShowSuccessMsg:NO sWaitingMsg:nil block:^(NSDictionary *returnData, BOOL bReturn) {
        if (bReturn) {
            NSString *sErrorCode=[returnData objectForKey:@"errorcode"];
            //num 节点 正常：0,已取消：1，已过期：2，已参与：3，已满：4，其它：5
            int iValueNum=[[returnData objectForKey:@"num"] intValue];
            if ([sErrorCode isEqualToString:@"1"]) {
                sResultMsg=sActionDisEnable;
            }else{
                switch (iValueNum) {
                    case 0:{
                        sResultMsg=sSuccessJoinAction;
                        bResult=YES;
                        break;
                    }case 1:{
                        sResultMsg=sActionCancel;
                        break;
                    }case 2:{
                        sResultMsg=sActionLate;
                        break;
                    }case 3:{
                        sResultMsg=sHasJoinAction;
                        break;
                    }case 4:{
                        sResultMsg=sActionNumMax;
                        break;
                    }
                    default:
                        sResultMsg=sActionDisEnable;
                        break;
                }
            }
        }
        if (![sResultMsg isEqualToString:@""]) {
            if ([sResultMsg isEqualToString:sHasJoinAction] || [sResultMsg isEqualToString:sActionNumMax]) {
                [PublicFunc ShowNoticeHUD:sResultMsg view:fatherView.view];
            }else if([sResultMsg isEqualToString:sSuccessJoinAction]){
                [PublicFunc ShowSuccessHUD:sResultMsg view:fatherView.view];
            }else{
                [PublicFunc ShowErrorHUD:sResultMsg view:fatherView.view];
            }
        }
        //通知所有参加了些活动的人员(推送)
        
        preturnBlock(bResult);
    }];
    
    }

#pragma mark 获取参于过活动的数据
-(void)getJoinActionData:(NSString*)sUserID joinActionDataType:(joinActionDataType)joinActionDataType fatherObject:(id)pfatherObject returnBlock:(returnJoinActionDataBlock)preturnBlock{
    
    NSMutableArray *arryResult=[[NSMutableArray alloc] init];
    //用id
    NSMutableArray *arryPara=[[NSMutableArray alloc] init];
    NSString *sParaUserID=[NSString stringWithFormat:@"sUserID=%@",sUserID];
    [arryPara addObject:sParaUserID];
    
    //数据类型
    NSString *sParaDataType=[NSString stringWithFormat:@"joinActionDataType=%d",joinActionDataType];
    [arryPara addObject:sParaDataType];
    
    
    [FZNetworkHelper dataTaskWithApiName:@"api_GetJoinActionData" arryPara:arryPara requestMethodType:requestMethodGet fatherObject:pfatherObject bShowSuccessMsg:NO sWaitingMsg:nil block:^(NSDictionary *returnData, BOOL bReturn)
     {
         if (bReturn) {
             NSString *sErrorCode=[returnData objectForKey:@"errorcode"];
             if ([sErrorCode isEqualToString:@"0"]) {
                 for (NSDictionary *dictData in [returnData objectForKey:@"data"]) {
                     ClassActionJoinor *cActionJoinorObject=[[ClassActionJoinor alloc] init];
                     cActionJoinorObject.sActionID=[dictData objectForKey:@"iActionID"];
                     cActionJoinorObject.sActionTitle=[dictData objectForKey:@"sActionTitle"];
                     cActionJoinorObject.sActionJoiner=[NSString stringWithFormat:@"已参加人数:%@",[dictData objectForKey:@"iActionJoiner"]];
                     float fCharge=[[dictData objectForKey:@"fActionCharge"] floatValue];
                     if (fCharge==0.0) {
                         cActionJoinorObject.sActionCharge=@"费用:免费";
                     }else{
                         cActionJoinorObject.sActionCharge=[NSString stringWithFormat:@"费用:%1.1f",fCharge];
                     }
                     cActionJoinorObject.sActionContactPhone=[NSString stringWithFormat:@"联系人:%@",[dictData objectForKey:@"sActionContactPhone"]];
                     //图片的url
                     NSArray *arryFiles=[[dictData objectForKey:@"picPath"] componentsSeparatedByString:@";"];
                     cActionJoinorObject.sActionImagePath=[NSString stringWithFormat:@"%@%@",[FZNetworkHelper getServerUrl],[arryFiles firstObject]];;
                     
                     [arryResult addObject:cActionJoinorObject];
                 }
             }else{
                 NSString *sErrorMsg=[returnData objectForKey:@"errormsg"];
                 [PublicFunc ShowErrorHUD:sErrorMsg view:((UIViewController*)pfatherObject).view];
             }
         }
         if (!arryResult || arryResult.count==0) {
             preturnBlock(nil);
         }else{
             preturnBlock(arryResult);
         }
     }];
}
#pragma mark 取消参于的某一活动
-(void)cancelJoinAction:(int)iActionID sUserID:(NSString *)sUserID fatherObject:(id)pfatherObject returnBlock:(blockFunctionReturn)preturnBlock{
    
    NSMutableArray *arryPara=[[NSMutableArray alloc] init];
    
    //actionID
    NSString *sParaActionID=[NSString stringWithFormat:@"iActionID=%d",iActionID];
    [arryPara addObject:sParaActionID];
    //userID
    NSString *sParaUserId=[NSString stringWithFormat:@"sUserID=%@",sUserID];
    [arryPara addObject:sParaUserId];
    
    [FZNetworkHelper dataTaskWithApiName:@"api_JoinorCancelAction" arryPara:arryPara requestMethodType:requestMethodGet fatherObject:pfatherObject bShowSuccessMsg:NO sWaitingMsg:nil block:^(NSDictionary *returnData, BOOL bReturn) {
        if (bReturn) {
            NSString *sErrorCode=[returnData objectForKey:@"errorcode"];
            if ([sErrorCode isEqualToString:@"1"]) {
                NSString *sErrorMsg=[returnData objectForKey:@"errormsg"];
                [PublicFunc ShowErrorHUD:sErrorMsg view:((UIViewController*)pfatherObject).view];
                bReturn=NO;
            }
        }
        preturnBlock(bReturn);
    }];
}

@end
