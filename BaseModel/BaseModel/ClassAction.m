#import "ClassAction.h"
#define sIssuing               @"正在发布中..."
#define sInitActionData        @"初始化个人信息中..."
#define sIssusSaveLocalDataError            @"保存本地活动数据失败"
#define sIssusSuccess          @"活动发布成功"
#define sCancelActionSuccess   @"取消活动动成功"
#define sActionDisEnable       @"此活动无效,我们已在处理中..."

#define sActionLate            @"你来晚了,此活动已过期了"
#define sActionCancel          @"你来晚了,此活动已被取消了"

#define iRowNums  20 
#define iImageSize 200

#define kSmallImageQuality 0.1


@implementation ClassAction


#pragma mark 建表
-(BOOL)createTable{
    
    BOOL bReturn=YES;
    //表不存在就创建
    if ([SqliteHelper existTb:@"tAction"]==sqliteErrExist) {
        NSString *sSQL=@"CREATE TABLE tAction (";
        sSQL=[sSQL stringByAppendingString:@"iActionID INTEGER,"];
        sSQL=[sSQL stringByAppendingString:@"sActionTitle text collate nocase,"];
        sSQL=[sSQL stringByAppendingString:@"sActionDate  text collate nocase,"];
        sSQL=[sSQL stringByAppendingString:@"sActionPlace text collate nocase,"];
        sSQL=[sSQL stringByAppendingString:@"iActionManNum INTEGER,"];
        sSQL=[sSQL stringByAppendingString:@"fActionCharge real,"];
        sSQL=[sSQL stringByAppendingString:@"sActionContactPhone  text collate nocase,"];
        sSQL=[sSQL stringByAppendingString:@"sActionDescription text collate nocase,"];
        sSQL=[sSQL stringByAppendingString:@"sActionCreater     text collate nocase,"];
        sSQL=[sSQL stringByAppendingString:@"sDate text collate nocase,"];
        sSQL=[sSQL stringByAppendingString:@"iActionJoiner      INTEGER,"];
        sSQL=[sSQL stringByAppendingString:@"bActionFinished    INTEGER,"];
        sSQL=[sSQL stringByAppendingString:@"bActionCanceled    INTEGER )"];
        
        bReturn=[SqliteHelper executeNonQuery:sSQL];
    }
    
    return bReturn;
}

#pragma mark 发布活动
-(void)issueAction:(ClassAction*)cActionObject issueImages:(NSArray*)issueImages fatherObject:(id)pfatherObject returnBlock:(blockFunctionReturn)preturnBlock{

    UIViewController *fatherView=(UIViewController*)pfatherObject;
    
    __block NSString *sErrMsg=@"";
    
    id showHUD=[PublicFunc ShowWaittingHUD:sIssuing view:fatherView.view];
    
    //异步处理数据
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        
        //1--上传数据 图片到服务器
        //最大编号
        int iMaxID;
        //获取当前表最大iID值做为新的iID
        NSArray *arryRows=[SqliteHelper executeQuery:@"select MAX(iActionID) as iActionID from tAction"];
        if (arryRows==nil) {
            iMaxID=1;
        }else{
            iMaxID=[[[arryRows objectAtIndex:0] objectForKey:@"iActionID"] intValue]+1;
        }
        
        //当前日期
        //NSDate格式转换为NSString格式
        NSDateFormatter *sFormatter = [[NSDateFormatter alloc] init];// 创建一个日期格式器
        [sFormatter setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
        NSString *sNowDate = [sFormatter stringFromDate:[NSDate date]];
        
        //活动创建人
        NSString *sCreater=@"";
        sCreater=[SystemPlist GetID];
        
        NSMutableArray *arryIssueAction=[[NSMutableArray alloc] init];
        NSString *sActionID=[NSString stringWithFormat:@"iActionID=%d",iMaxID];
        [arryIssueAction addObject:sActionID];
        
        NSString *sActionTitle=[NSString stringWithFormat:@"sActionTitle=%@",cActionObject.sActionTitle];
        [arryIssueAction addObject:sActionTitle];
        
        NSString *sActionDate=[NSString stringWithFormat:@"sActionDate=%@",cActionObject.sActionDate];
        [arryIssueAction addObject:sActionDate];
        
        NSString *sActionPlace=[NSString stringWithFormat:@"sActionPlace=%@",cActionObject.sActionPlace];
        [arryIssueAction addObject:sActionPlace];
        
        NSString *sActionManNum=[NSString stringWithFormat:@"iActionManNum=%@",cActionObject.sActionManNum];
        [arryIssueAction addObject:sActionManNum];
        
        NSString *sActionCharge=[NSString stringWithFormat:@"fActionCharge=%@",cActionObject.sActionCharge];
        [arryIssueAction addObject:sActionCharge];
        
        NSString *sActionContactPhone=[NSString stringWithFormat:@"sActionContactPhone=%@",cActionObject.sActionContactPhone];
        [arryIssueAction addObject:sActionContactPhone];
        
        NSString *sActionDescription=[NSString stringWithFormat:@"sActionDescription=%@",cActionObject.sActionDescription];
        [arryIssueAction addObject:sActionDescription];
        
        NSString *sActionCreater=[NSString stringWithFormat:@"sActionCreater=%@",sCreater];
        [arryIssueAction addObject:sActionCreater];
        
        NSString *sDate=[NSString stringWithFormat:@"sDate=%@",sNowDate];
        [arryIssueAction addObject:sDate];
        
        //图片内容(这个图片处理有耗时 所以在此用异步处理)
        NSMutableDictionary *dictIssueImages=[[NSMutableDictionary alloc] init];
        NSData *dataImg;
        NSString *sCurImageName;
        for (int i=0; i<=issueImages.count-1; i++) {
            UIImage *image=[issueImages objectAtIndex:i];
            //jpg格式
            dataImg = [PublicFunc resetSizeOfImageData:image maxSize:iImageSize];
            sCurImageName=[NSString stringWithFormat:@"%d_%d.jpg",iMaxID,i+1];
            [dictIssueImages setObject:dataImg forKey:sCurImageName];
        }
        dispatch_async(dispatch_get_main_queue(), ^{
            
            [FZNetworkHelper upLoadTaskWithApiNameNoHUD:@"Api_IssueAction" arryPara:arryIssueAction fromDict:dictIssueImages updateFileType:updateFileTypeImage block:^(NSDictionary *returnData, NSString *sError) {
                if ([sError isEqualToString:@""]) {
                    NSString *sErrorCode=[returnData objectForKey:@"errorcode"];
                    if ([sErrorCode isEqualToString:@"1"]) {
                        sErrMsg=[returnData objectForKey:@"errormsg"];
                    }else{
                        //2---将数据保存到本地(数据,图片)
                        //数据
                        NSString *sSQL=[NSString stringWithFormat:@"INSERT INTO tAction (iActionID,sActionTitle,sActionDate,sActionPlace,iActionManNum,fActionCharge,sActionContactPhone,sActionDescription,sActionCreater,sDate,iActionJoiner,bActionFinished,bActionCanceled) VALUES (%d,'%@','%@','%@',%d,%1.1f,'%@','%@','%@','%@',%d,%d,%d) ",iMaxID,cActionObject.sActionTitle,cActionObject.sActionDate,cActionObject.sActionPlace, [cActionObject.sActionManNum intValue],[cActionObject.sActionCharge floatValue],cActionObject.sActionContactPhone,cActionObject.sActionDescription,sCreater,sNowDate,0,0,0];
                        if (![SqliteHelper executeNonQuery:sSQL]) {
                            sErrMsg=sIssusSaveLocalDataError;
                        }else{
                            //--保存图片到本地
                            //新建sID对应的文件夹
                            NSString *sPath=[[SystemPlist GetActionImagePath] stringByAppendingString:[NSString stringWithFormat:@"%d",iMaxID]];
                            NSFileManager *fileManager=[[NSFileManager alloc] init];
                            [fileManager createDirectoryAtPath:sPath withIntermediateDirectories:YES attributes:nil error:nil];
                            sPath=[sPath stringByAppendingString:@"/"];
                            
                            //保存图片(本地)
                            NSData *dataImg;
                            NSString *sCurImageName;
                            if (issueImages.count>0) {
                                for (int i=0; i<=issueImages.count-1; i++) {
                                    UIImage *image=[issueImages objectAtIndex:i];
                                    if (i==0) {
                                        //生成尺寸,大小 更小的封面
                                        dataImg=UIImageJPEGRepresentation(image, kSmallImageQuality);
                                        sCurImageName=[NSString stringWithFormat:@"%d_%d.jpg",iMaxID,i];
                                        [fileManager createFileAtPath:[NSString stringWithFormat:@"%@%@",sPath,sCurImageName] contents:dataImg attributes:nil];
                                    }
                                    //jpg格式 文件的构成 actionid_imageid 用于图片本地加载
                                    dataImg = [PublicFunc resetSizeOfImageData:image maxSize:iImageSize];
                                    sCurImageName=[NSString stringWithFormat:@"%d_%d.jpg",iMaxID,i+1];
                                    [fileManager createFileAtPath:[NSString stringWithFormat:@"%@%@",sPath,sCurImageName] contents:dataImg attributes:nil];
                                }

                            }
                        }
                    }
                }else{
                    sErrMsg=sError;
                }
                [[NSOperationQueue mainQueue] addOperationWithBlock:^{
                    //关闭等待提示
                    [PublicFunc HideHUD:showHUD];
                    if ([sErrMsg isEqualToString:@""]) {
                        [PublicFunc ShowSuccessHUD:sIssusSuccess view:fatherView.view];
                        preturnBlock(YES);
                    }else{
                        [PublicFunc ShowErrorHUD:sErrMsg view:fatherView.view];
                        preturnBlock(NO);
                    }
                }];
            }];
        });
    });
}

#pragma mark 插入数据
-(BOOL)insertData{
    BOOL bReturn=YES;
    
    if (self==nil) {
        return NO;
    }
    
    //最大编号
    int iMaxID;
    //获取当前表最大iID值做为新的iID
    NSArray *arryRows=[SqliteHelper executeQuery:@"select MAX(iActionID) as iID from tAction"];
    if (arryRows==nil) {
        iMaxID=1;
    }else{
        iMaxID=[[[arryRows objectAtIndex:0] objectForKey:@"iActionID"] intValue]+1;
    }
    
    //当前日期
    //NSDate格式转换为NSString格式
    NSDateFormatter *sFormatter = [[NSDateFormatter alloc] init];// 创建一个日期格式器
    [sFormatter setDateFormat:@"yyyy MM dd HH:mm:ss"];
    NSString *sNowDate = [sFormatter stringFromDate:[NSDate date]];
    
    //活动创建人
    NSString *sCreater=@"";
    if ([SystemPlist GetLoginType]==LoginTypeSdk) {
        sCreater=[SystemPlist GetName];
    }else{
        sCreater=[SystemPlist GetID];
    }
    
    NSString *sSQL=[NSString stringWithFormat:@"INSERT INTO tAction (iActionID,sActionTitle,sActionDate,sActionPlace,iActionManNum,fActionCharge,sActionContactPhone,sActionDescription,sActionCreater,sDate,iActionJoiner,bActionFinished,bActionCanceled) VALUES (%d,'%@','%@','%@',%d,%1.1f,'%@','%@','%@','%@',%d,%d,%d) ",iMaxID,self.sActionTitle,self.sActionDate,self.sActionPlace, [self.sActionManNum intValue],[self.sActionCharge floatValue],self.sActionContactPhone,self.sActionDescription,sCreater,sNowDate,0,self.bActionFinished,self.bActionCanceled];
    
    bReturn=[SqliteHelper executeNonQuery:sSQL];
    
     return bReturn;
}

//删除活动数据和图片图片内容
-(BOOL)deleteActionDataAndImage{
    BOOL bReturn;
    bReturn=[SqliteHelper executeNonQuery:@"delete from tAction "];
    
    if (bReturn) {
        NSArray *arryFiles=[[NSFileManager defaultManager] contentsOfDirectoryAtPath:[SystemPlist GetActionImagePath] error:nil];
        for (NSString *sPath in arryFiles) {
            bReturn=[[NSFileManager defaultManager] removeItemAtPath:[NSString stringWithFormat:@"%@%@",[SystemPlist GetActionImagePath],sPath ] error:nil];
            if (!bReturn) {
                break;
                return bReturn;
            }
        }
        return YES;
        
    }else{
        return bReturn;
    }
}

#pragma mark 保存活动图片致本地
-(BOOL)saveImgToLocal:(NSArray*)arryImgs{

    if (!arryImgs) {
        return NO;
    }
    
    NSString *sMaxID;
    //获取当前表最大iID值做为新的iID
    NSArray *arryRows=[SqliteHelper executeQuery:@"select MAX(iActionID) as iID from tAction"];
    sMaxID=[[arryRows objectAtIndex:0] objectForKey:@"iID"];
    
    //新建sID对应的文件夹
    NSString *sPath=[[PublicFunc GetSandBoxPathWithType:SandBoxPathTypeDocuments] stringByAppendingString:sMaxID];
    NSFileManager *fileManager=[[NSFileManager alloc] init];
    [fileManager createDirectoryAtPath:sPath withIntermediateDirectories:YES attributes:nil error:nil];
    
    sPath=[sPath stringByAppendingString:@"/"];
    
    
    //保存图片
     NSData *dataImg;
    for (int i=0; i<=arryImgs.count-1; i++) {
        UIImage *image=[arryImgs objectAtIndex:i];
        
        if (UIImagePNGRepresentation(image) == nil) {
            dataImg = UIImageJPEGRepresentation(image, 1);
            [fileManager createFileAtPath:[NSString stringWithFormat:@"%@%d.jpg",sPath,i+1] contents:dataImg attributes:nil];
        } else {
            dataImg = UIImagePNGRepresentation(image);
            [fileManager createFileAtPath:[NSString stringWithFormat:@"%@%d.png",sPath,i+1] contents:dataImg attributes:nil];
        }
    }
    
    return YES;
}

#pragma mark 获取本地数据
-(NSArray*)getLocalActionData:(actionDataType)actionDataType{
    //活动到期检查
    [self updateActionDate];
   
    NSMutableArray *arryResult=[[NSMutableArray alloc] init];
    NSString *sSQL=@"select iActionID,sActionTitle,sActionDate,sActionPlace,iActionManNum,fActionCharge,sActionContactPhone,sActionDescription,sActionCreater,iActionJoiner,bActionFinished,bActionCanceled from  tAction ";
    
    switch (actionDataType) {
        case actionDataTypeRunning:{
            sSQL=[sSQL stringByAppendingString:@" where bActionFinished=0 and bActionCanceled=0 "];
            break;
        }case actionDataTypeFinished:{
            sSQL=[sSQL stringByAppendingString:@" where bActionFinished=1 and bActionCanceled=0 "];
            break;
        }case actionDataTypeCanceled:{
            sSQL=[sSQL stringByAppendingString:@" where bActionFinished=0 and bActionCanceled=1 "];
            break;
        }default:
            break;
    }
    sSQL=[sSQL stringByAppendingString:@" ORDER BY iActioniD DESC "];
    NSArray *arryRows=[SqliteHelper executeQuery:sSQL];
    
    if (arryRows==nil || arryRows.count==0) {
        //到服务器读取
        return nil;
    }else{
        for (int i=0; i<=arryRows.count-1; i++) {
            ClassAction *cCurAction=[[ClassAction alloc] init];
            cCurAction.sActionID=[[arryRows objectAtIndex:i] objectForKey:@"iActionID"];
            cCurAction.sActionTitle=[[arryRows objectAtIndex:i] objectForKey:@"sActionTitle"];
            cCurAction.sActionDate=[[arryRows objectAtIndex:i] objectForKey:@"sActionDate"];
            cCurAction.sActionPlace=[[arryRows objectAtIndex:i] objectForKey:@"sActionPlace"];
            
            int iNum=[[[arryRows objectAtIndex:i] objectForKey:@"iActionManNum"] intValue];
            if (iNum==-1) {
                cCurAction.sActionManNum=@"限人数:不限";
            }else{
                cCurAction.sActionManNum=[NSString stringWithFormat:@"限人数:%d",iNum];
            }
            
            float fCharge=[[[arryRows objectAtIndex:i] objectForKey:@"fActionCharge"] floatValue];
            if (fCharge==0.0) {
                cCurAction.sActionCharge=@"费用:免费";
            }else{
                cCurAction.sActionCharge=[NSString stringWithFormat:@"费用:%1.1f",fCharge];
            }
            cCurAction.sActionContactPhone=[[arryRows objectAtIndex:i] objectForKey:@"sActionContactPhone"];
            cCurAction.sActionDescription=[[arryRows objectAtIndex:i] objectForKey:@"sActionDescription"];
            cCurAction.sActionCreater=[[arryRows objectAtIndex:i] objectForKey:@"sActionCreater"];
            cCurAction.sActionJoiner=[NSString stringWithFormat:@"已报名:%@",[[arryRows objectAtIndex:i] objectForKey:@"iActionJoiner"]];
            cCurAction.iActionJoiner=[[[arryRows objectAtIndex:i] objectForKey:@"iActionJoiner"] intValue];
            cCurAction.bActionFinished=[[[arryRows objectAtIndex:i] objectForKey:@"bActionFinished"] intValue];
            cCurAction.bActionCanceled=[[[arryRows objectAtIndex:i] objectForKey:@"bActionCanceled"] intValue];
            [arryResult addObject:cCurAction];
        }
    }
    return [arryResult copy];
}

#pragma mark 获取服务器数据
-(void)getServerActionData:(refreshType)refreshType sLocalUpdateDate:(NSString*)sLocalUpdateDate returnBlock:(blockReServerActionData)returnBlock{
    
    __block BOOL bNeedClearData=NO;
    
    __block NSString *sErrMsg=@"";
    
    __block NSMutableArray *arryResult=[[NSMutableArray alloc] init];//用户发布的活动
    
    __block NSMutableArray *arryAdResult=[[NSMutableArray alloc] init];//系统发布的活动

    //调用参数
    NSMutableArray *arryPara=[[NSMutableArray alloc] init];
    //行数
    NSString *sParaRowNum=[NSString stringWithFormat:@"iRowNum=%d",iRowNums];
    [arryPara addObject:sParaRowNum];
    
    //更新类型
    NSString *sParaRefreshType=[NSString stringWithFormat:@"RefreshType=%d",refreshType];
    [arryPara addObject:sParaRefreshType];
    
    if (refreshType!=refreshTypeInit) {
        //更新对比日期
        NSString *sParaUpdateDate=[NSString stringWithFormat:@"sLocalUpdateDate=%@",sLocalUpdateDate];
        [arryPara addObject:sParaUpdateDate];
    }
    [FZNetworkHelper dataTaskWithApiNameNoHUD:@"Api_GetActionData" arryPara:arryPara requestMethodType:requestMethodGet block:^(NSDictionary *returnData, NSString *sError) {
        
        if ([sError isEqualToString:@""]) {
            NSString *sErrorCode=[returnData objectForKey:@"errorcode"];
            NSString *sNeedClearData=[returnData objectForKey:@"isUp"];
            
            if (![sNeedClearData isEqualToString:@"False"]) {
                bNeedClearData=YES;
            }
            //<1>获取用户发布的活动
            if ([sErrorCode isEqualToString:@"1"]) {
                arryResult=nil;
                sErrMsg=[returnData objectForKey:@"errormsg"];//webserver返回的错误
            }else{
                //获取数据
                arryResult=[[returnData objectForKey:@"data"] mutableCopy];
                if (arryResult.count>0) {
                    [arryResult removeAllObjects];
                    for (NSDictionary *dictData in [returnData objectForKey:@"data"]) {
                        ClassAction *cCurAction=[[ClassAction alloc] init];
                        cCurAction.sActionID=[dictData objectForKey:@"iActionID"];
                        cCurAction.sActionTitle=[dictData objectForKey:@"sActionTitle"];
                        cCurAction.sActionDate=[self converDateString1:[dictData objectForKey:@"sActionDate"]];
                        cCurAction.sDate=[self converDateString2:[dictData objectForKey:@"sDate"]];
                        cCurAction.sActionPlace=[dictData objectForKey:@"sActionPlace"];
                        
                        
                        int iNum=[[dictData objectForKey:@"iActionManNum"] intValue];
                        if (iNum==-1) {
                            cCurAction.sActionManNum=@"限人数:不限";
                        }else{
                            cCurAction.sActionManNum=[NSString stringWithFormat:@"限人数:%d",iNum];
                        }
                        
                        float fCharge=[[dictData objectForKey:@"fActionCharge"] floatValue];
                        if (fCharge==0.0) {
                            cCurAction.sActionCharge=@"费用:免费";
                        }else{
                            cCurAction.sActionCharge=[NSString stringWithFormat:@"费用:%1.1f",fCharge];
                        }
                        cCurAction.sActionContactPhone=[dictData objectForKey:@"sActionContactPhone"];
                        cCurAction.sActionDescription=[dictData objectForKey:@"sActionDescription"];
                        cCurAction.sActionCreater=[dictData objectForKey:@"sActionCreater"];
                        cCurAction.sActionJoiner=[NSString stringWithFormat:@"已报名:%@",[dictData objectForKey:@"iActionJoiner"]];
                        cCurAction.iActionJoiner=[[dictData objectForKey:@"iActionJoiner"] intValue];
                        cCurAction.bActionFinished=[[dictData objectForKey:@"bActionFinished"] intValue];
                        cCurAction.bActionCanceled=[[dictData objectForKey:@"bActionCanceled"] intValue];
                        
                        //判断图片是否已下载到本地
                        NSString *sImgPath=[NSString stringWithFormat:@"%@%@/",[SystemPlist GetActionImagePath],cCurAction.sActionID];
                        NSString *sImgName;
                        NSMutableArray *arryMutabActionImagePath=[[NSMutableArray alloc] init];
                        if ([[NSFileManager defaultManager] fileExistsAtPath:sImgPath]) {
                            //本地路径
                            NSArray *arryFiles=[[NSFileManager defaultManager] contentsOfDirectoryAtPath:sImgPath error:nil];
                            if (arryFiles) {
                                for (int i=0; i<=arryFiles.count-1; i++) {
                                    sImgName=[arryFiles objectAtIndex:i];
                                    [arryMutabActionImagePath addObject:[sImgPath stringByAppendingString:sImgName]];
                                }
                            }
                            cCurAction.bActionImageHasDownload=YES;
                        }else{
                            //图片的url
                            NSArray *arryFiles=[[dictData objectForKey:@"picPath"] componentsSeparatedByString:@";"];
                            if (arryFiles) {
                                for (int i=0; i<=arryFiles.count-1; i++) {
                                    sImgName=[arryFiles objectAtIndex:i];
                                    sImgPath=[NSString stringWithFormat:@"%@%@",[FZNetworkHelper getServerUrl],sImgName];
                                    [arryMutabActionImagePath addObject:sImgPath];
                                }
                            }
                            cCurAction.bActionImageHasDownload=NO;
                        }
                        cCurAction.arryActionImagePath=[arryMutabActionImagePath copy];
                        [arryResult addObject:cCurAction];
                    }
                }
            }
            //<2>获取系统发布的活动
            NSDictionary *dictAdData=[returnData objectForKey:@"sysData"];
            sErrorCode=[dictAdData objectForKey:@"errorcode"];
            
            if ([sErrorCode isEqualToString:@"1"]) {
                arryAdResult=nil;
            }else{
                //获取数据
                arryAdResult=[[dictAdData objectForKey:@"data"] mutableCopy];
                if (arryAdResult.count>0) {
                    [arryAdResult removeAllObjects];
                    for (NSDictionary *dictData in [dictAdData objectForKey:@"data"]) {
                        ClassAction *cCurAction=[[ClassAction alloc] init];
                        cCurAction.sAdActionUrl=[dictData objectForKey:@"appPath"];
                        cCurAction.sAdActionImageUrl=[NSString stringWithFormat:@"%@%@",[FZNetworkHelper getServerUrl],[dictData objectForKey:@"sMainPic"]];
                        cCurAction.sAdActionTitle=[dictData objectForKey:@"sTitle"];
                        [arryAdResult addObject:cCurAction];
                    }
                }
            }
            
        }else{
            arryAdResult=nil;
            sErrMsg=sError;
        }
        returnBlock(arryResult,arryAdResult,bNeedClearData,sErrMsg);
    }];
}

#pragma mark 初始化我的活动数据
-(void)initMyActionData:(id)pfatherObject returnBlock:(blockFunctionReturn)preturnBlock{
    //调用参数
    NSMutableArray *arryPara=[[NSMutableArray alloc] init];
    //行数
    NSString *sParaRowNum=[NSString stringWithFormat:@"iRowNum=%d",iRowNums];
    [arryPara addObject:sParaRowNum];
    
    //用户id
    NSString *sParaUserID=[NSString stringWithFormat:@"sUserID=%@",[SystemPlist GetID]];
    [arryPara addObject:sParaUserID];

    //更新类型
    NSString *sParaRefreshType=@"RefreshType=0";
    [arryPara addObject:sParaRefreshType];
    
    [FZNetworkHelper dataTaskWithApiName:@"Api_GetActionData" arryPara:arryPara requestMethodType:requestMethodGet fatherObject:pfatherObject bShowSuccessMsg:YES sWaitingMsg:sInitActionData block:^(NSDictionary *returnData, BOOL bReturn) {
        if (bReturn) {
            NSString *sErrorCode=[returnData objectForKey:@"errorcode"];
            if ([sErrorCode isEqualToString:@"1"]) {
                NSString *sErrorMsg=[returnData objectForKey:@"errormsg"];
                [PublicFunc ShowErrorHUD:sErrorMsg view:((UIViewController*)pfatherObject).view];
                bReturn=NO;
            }else{
                //获取数据
                NSArray *arryResult=[[returnData objectForKey:@"data"] mutableCopy];
                if (arryResult.count>0) {
                    for (NSDictionary *dictData in [returnData objectForKey:@"data"]) {
                        //保存数据到本地
                        NSString *sNewActionDate=[self converDateString1:[dictData objectForKey:@"sActionDate"]];
                        NSString *sNewDate=[self converDateString1:[dictData objectForKey:@"sDate"]];
                        NSString *sSQL=[NSString stringWithFormat:@"INSERT INTO tAction (iActionID,sActionTitle,sActionDate,sActionPlace,iActionManNum,fActionCharge,sActionContactPhone,sActionDescription,sActionCreater,sDate,iActionJoiner,bActionFinished,bActionCanceled) VALUES (%d,'%@','%@','%@',%d,%1.1f,'%@','%@','%@','%@',%d,%d,%d) ",[[dictData objectForKey:@"iActionID"] intValue],[dictData objectForKey:@"sActionTitle"],sNewActionDate,[dictData objectForKey:@"sActionPlace"], [[dictData objectForKey:@"iActionManNum"] intValue],[[dictData objectForKey:@"fActionCharge"] floatValue],[dictData objectForKey:@"sActionContactPhone"],[dictData objectForKey:@"sActionDescription"],[dictData objectForKey:@"sActionCreater"],sNewDate,[[dictData objectForKey:@"iActionJoiner"] intValue],[[dictData objectForKey:@"bActionFinished"] intValue],[[dictData objectForKey:@"bActionCanceled"] intValue]];
                        [SqliteHelper executeNonQuery:sSQL];
                        
                        //保存图片
                        NSString *sImageUrlList=[dictData objectForKey:@"picPath"];
                        if (sImageUrlList.length>0) {
                            
                            NSArray *arrImageUrl=[sImageUrlList componentsSeparatedByString:@";"];//图片名称集合
                            NSURL *urlImage;
                            NSData *dataImage;
                            
                            //保放图片的本地路径
                            NSString *sSaveImagePath=[[SystemPlist GetActionImagePath] stringByAppendingString:[NSString stringWithFormat:@"%@/",[dictData objectForKey:@"iActionID"]]];
                            //创建文件夹
                            [[NSFileManager defaultManager] createDirectoryAtPath:sSaveImagePath withIntermediateDirectories:NO attributes:nil error:nil];
                            
                            NSInteger iIndex=0;
                            for (NSString *sImageUrl in arrImageUrl) {
                                urlImage=[NSURL URLWithString:[NSString stringWithFormat:@"%@%@",[FZNetworkHelper getServerUrl],sImageUrl]];
                                dataImage=[NSData dataWithContentsOfURL:urlImage];
                                UIImage *image = [UIImage imageWithData:dataImage];
                                //获取图片名称
                                NSString *sImageName=[[sImageUrl componentsSeparatedByString:@"/"] lastObject];
                                
                                //保存图片到本地
                                [UIImageJPEGRepresentation(image, 1) writeToFile:[sSaveImagePath stringByAppendingString:sImageName] options:NSAtomicWrite error:nil];
                                
                                //生成尺寸,大小 更小的封面
                                if (iIndex==0) {
                                    sImageName=[NSString stringWithFormat:@"%@_%ld.jpg",[dictData objectForKey:@"iActionID"],(long)iIndex];
                                    //保存图片到本地
                                    [UIImageJPEGRepresentation(image, kSmallImageQuality) writeToFile:[sSaveImagePath stringByAppendingString:sImageName] options:NSAtomicWrite error:nil];
                                }
                                iIndex++;
                            }
                        }
                    }
                }
            }
        }
         preturnBlock(bReturn);
    }];
}


#pragma mark 取消活动(本地和服务器一起更新)
-(void)cancelMyAction:(int)iActionID  fatherObject:(id)pfatherObject returnBlock:(blockFunctionReturn)preturnBlock{
    
    //错误内容
    __block NSString *sErrMsg=@"";
    
    //调用参数
    NSMutableArray *arryPara=[[NSMutableArray alloc] init];
    //iActioID
    NSString *sParaActionID=[NSString stringWithFormat:@"iActionID=%d",iActionID];
    [arryPara addObject:sParaActionID];
    
    [FZNetworkHelper dataTaskWithApiName:@"Api_CancelAction" arryPara:arryPara requestMethodType:requestMethodGet fatherObject:pfatherObject bShowSuccessMsg:YES sWaitingMsg:nil block:^(NSDictionary *returnData, BOOL bReturn) {
        if (bReturn) {
            NSString *sErrorCode=[returnData objectForKey:@"errorcode"];
            if ([sErrorCode isEqualToString:@"1"]) {
                sErrMsg=[returnData objectForKey:@"errormsg"];
                [PublicFunc ShowErrorHUD:sErrMsg view:((UIViewController*)pfatherObject).view];
                bReturn=NO;
            }else{
                //修改本地内容
                NSString *sSQL=[NSString stringWithFormat:@"update tAction set bActionCanceled=1 where iActionID=%d ",iActionID];
                [SqliteHelper executeNonQuery:sSQL];
            }
        }
        preturnBlock(bReturn);
        //通知所有参加了些活动的人员(推送)
    }];
}

#pragma mark 更新当前活动是否已经到结束日期 精确到小时
-(void)updateActionDate{
    NSString *sSQL=@"SELECT sActionDate FROM tAction WHERE bActionCanceled=0 and  datetime(sActionDate)<strftime('%Y-%m-%d %H:%M:%S','now','localtime') ";
    if ([SqliteHelper executeQuery:sSQL]) {
        //修改本地
        sSQL=@"UPDATE tAction SET bActionFinished=1 WHERE bActionCanceled=0 and   datetime(sActionDate)<strftime('%Y-%m-%d %H:%M:%S','now','localtime')";
        [SqliteHelper executeNonQuery:sSQL];
    }
}

#pragma mark 判断当前活动是否已过期或已被取消
-(void)checkActionEnable:(int)iActionID fatherObject:(id)pfatherObject returnBlock:(blockCheckActionEnable) returnBlock{
    
    UIViewController *fatherView=(UIViewController*)pfatherObject;
    
    //错误内容
    __block NSString *sErrMsg=@"";
    
    //返回结果
    __block BOOL bResult=NO;
    
    __block NSMutableArray *arryResult=[[NSMutableArray alloc] init];
    
    __block int iResultNum=0;
    
    //调用参数
    NSMutableArray *arryPara=[[NSMutableArray alloc] init];
    //iActioID
    NSString *sParaActionID=[NSString stringWithFormat:@"iActionID=%d",iActionID];
    [arryPara addObject:sParaActionID];
    
    [FZNetworkHelper dataTaskWithApiName:@"Api_InspectActionData" arryPara:arryPara requestMethodType:requestMethodGet fatherObject:pfatherObject bShowSuccessMsg:NO sWaitingMsg:nil block:^(NSDictionary *returnData, BOOL bReturn) {
        if (bReturn) {
            NSString *sErrorCode=[returnData objectForKey:@"errorcode"];
            //num 节点 0:活动有效 1:活动已取消 2:活动已过期 3:其它原因不能参加
            int iValueNum=[[returnData objectForKey:@"num"] intValue];
            if ([sErrorCode isEqualToString:@"1"]) {
                sErrMsg=sActionDisEnable;
            }else{
                switch (iValueNum) {
                    case 0:{
                        //获取最新的已参加活动人数
                        arryResult=[[returnData objectForKey:@"data"] mutableCopy];
                        if (arryResult.count>0) {
                            [arryResult removeAllObjects];
                            NSDictionary *dictData=[[returnData objectForKey:@"data"] firstObject];
                            iResultNum=[[dictData objectForKey:@"iActionJoiner"] intValue];
                        }
                        bResult=YES;
                        break;
                    }case 1:{
                        sErrMsg=sActionCancel;
                        break;
                    }case 2:{
                        sErrMsg=sActionLate;
                        break;
                    }case 3:{
                        sErrMsg=sActionDisEnable;
                        break;
                    }
                    default:
                        break;
                }
            }
        }
        //通知所有参加了些活动的人员(推送)
        if (![sErrMsg isEqualToString:@""]) [PublicFunc ShowErrorHUD:sErrMsg view:fatherView.view];
        returnBlock(bResult,iResultNum);
    }];
}

#pragma mark 转换日期格式 精确到分钟且都为00(由于iis的影响 日期格式不太正确 所以把格式为 2015/12/1 11:23:30 转为 2015-12-01 11:00)
-(NSString*)converDateString1:(NSString*)sNeedToConverString{
    NSString *sString=@"";
    NSString *sPart1,*sPart2;
    sPart1=[[sNeedToConverString componentsSeparatedByString:@" "] firstObject];
    sPart2=[[sNeedToConverString componentsSeparatedByString:@" "] lastObject];
    
    
    for (int i=0; i<=[sPart1 componentsSeparatedByString:@"/"].count-1; i++) {
        NSString *sChar=[[sPart1 componentsSeparatedByString:@"/"] objectAtIndex:i];
        if (i==0) {
            sString=[sString stringByAppendingString:sChar];
        }else{
            if (sChar.length==1) {
                sChar=[NSString stringWithFormat:@"0%@",sChar];
            }
            sString=[NSString stringWithFormat:@"%@-%@",sString,sChar];
            
        }
    }
    sPart2=[NSString stringWithFormat:@"%@:%@",[[sPart2 componentsSeparatedByString:@":"] objectAtIndex:0],[[sPart2 componentsSeparatedByString:@":"] objectAtIndex:1]];
    
    sString=[sString stringByAppendingString:[NSString stringWithFormat:@" %@",sPart2]];
    return sString;
}
#pragma mark 转换日期格式 只将/转成-
-(NSString*)converDateString2:(NSString*)sNeedToConverString{
    NSString *sString=@"";
    NSString *sPart1,*sPart2;
    sPart1=[[sNeedToConverString componentsSeparatedByString:@" "] firstObject];
    sPart2=[[sNeedToConverString componentsSeparatedByString:@" "] lastObject];
    
    
    for (int i=0; i<=[sPart1 componentsSeparatedByString:@"/"].count-1; i++) {
        NSString *sChar=[[sPart1 componentsSeparatedByString:@"/"] objectAtIndex:i];
        if (i==0) {
            sString=[sString stringByAppendingString:sChar];
        }else{
            if (sChar.length==1) {
                sChar=[NSString stringWithFormat:@"0%@",sChar];
            }
            sString=[NSString stringWithFormat:@"%@-%@",sString,sChar];
            
        }
    }
    sString=[sString stringByAppendingString:[NSString stringWithFormat:@" %@",sPart2]];
    return sString;
}

@end
