//
//  FZDownloadButton.m
//  GoTogether
//
//  Created by apple on 15/7/24.
//  Copyright (c) 2015年 Fabius's Studio. All rights reserved.
//

#import "FZDownloadButton.h"

#define txtWaitting          @"等待..."
#define txtDown              @"下载"
#define txtGoon              @"继续"
#define txtFinish            @"完成"
#define txtError             @"下载出错"
#define txtError_Network     @"网络出错" // url格式错误,手机无网络
#define txtError_Init        @"未初始化" // 没有设置 sDownTaskUrl 或 sDownTaskIdentify属性
#define txtError_Timeout     @"连接超时"
#define iNetworkTimeout      8
#define sSaveDataPathDirectory @"DownData"
#define sTmpDataPathDirectory @"tmpData"


#define fontNormal    [UIFont systemFontOfSize:15]
#define sSaveDataPath [NSString stringWithFormat:@"%@/Documents/%@/%@.data",NSHomeDirectory(),sSaveDataPathDirectory,self.sDownTaskIdentify]
#define sTmpDataPath  [NSString stringWithFormat:@"%@/Documents/%@/%@.data",NSHomeDirectory(),sTmpDataPathDirectory,self.sDownTaskIdentify]

@implementation FZDownloadButton
@synthesize sDownTaskIdentify;
@synthesize sDownTaskUrl;


// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    //Drawing code
    [self addTarget:self action:@selector(btnClick) forControlEvents:UIControlEventTouchUpInside];
    
    if (!self.sDownTaskUrl || !self.sDownTaskIdentify) {
        lblTitle.text=txtError_Init;
        bTaskFinish=YES;
        return;
    }
    
    if (!self.sServerUrl) {
        self.sServerUrl=self.sDownTaskUrl;
    }
    
    if (!self.iTimeOutSeconds) {
        self.iTimeOutSeconds=iNetworkTimeout;
    }
    
    
    bTaskRunning=NO;
    bNeedToCheckNetwork=YES;
    sTxtCheckNetwork=txtError_Network;
    
    self.titleLabel.font=fontNormal;
    self.layer.masksToBounds=YES;
    self.layer.cornerRadius =5.0;//圆角
    [self setTitle:txtDown forState:UIControlStateNormal];
   
    lblTitle=[[UILabel alloc] initWithFrame:rect];
    lblTitle.backgroundColor=[UIColor orangeColor];
    lblTitle.textColor=[UIColor whiteColor];
    lblTitle.font=fontNormal;
    lblTitle.text=txtDown;
    lblTitle.textAlignment=NSTextAlignmentCenter;
    lblTitle.hidden=YES;
    [self addSubview:lblTitle];
    
    //button长按事件 取消下载
    UILongPressGestureRecognizer *longPress = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(btnLongClick:)];
    longPress.minimumPressDuration = 0.8; //定义按的时间
    [self addGestureRecognizer:longPress];
    
    
    //检测文件是否已下载
    if ([[NSFileManager defaultManager] fileExistsAtPath:sSaveDataPath]){
        bTaskFinish=YES;
        
        lblTitle.hidden=YES;
        [self setTitle:txtFinish forState:UIControlStateNormal];
    }else{
        bTaskFinish=NO;
    }

}

//长按取消下载(暂时不用)
-(void)btnLongClick:(UILongPressGestureRecognizer *)gestureRecognizer{
    if ([gestureRecognizer state] == UIGestureRecognizerStateBegan) {
        
        //在等待网络的时候 关闭下载
        if (sessionDataTaskCheckNetwork) {
            sTxtCheckNetwork=txtDown;
            [sessionDataTaskCheckNetwork cancel];
            sessionDataTaskCheckNetwork=nil;
            return;
        }
        
        if (sessionDownLoad) {
            [sessionDownLoad cancel];
            sessionDownLoad=nil;
            
            lblTitle.hidden=YES;
            [self setTitle:txtDown forState:UIControlStateNormal];
    
            bTaskRunning=NO;
            bNeedToCheckNetwork=YES;
            
            //删除暂停时保存的续传文件
            [[NSFileManager defaultManager] removeItemAtPath:sTmpDataPath error:nil];
        }
    }
}

//检测网络超时后断开下载
-(void)BreakCheckNetworkTimeout{
    sTxtCheckNetwork=txtError_Timeout;
    [sessionDataTaskCheckNetwork cancel];
    sessionDataTaskCheckNetwork=nil;
}

//当本对象disappear时处理一些事情
-(void)doSomethingWhenDisappear{

    //在等待网络的时候 关闭下载
    if (sessionDataTaskCheckNetwork) {
        [sessionDataTaskCheckNetwork cancel];
        sessionDataTaskCheckNetwork=nil;
        return;
    }

    //下载正在进行时强制cancel且保存数据
    [self DownLoadCancelAndSave];
}

//删除下载过程中的临时文件 psDownTaskIdentify为nil时删除全部
-(void)deleteTmpData:(NSString *)psDownTaskIdentify{
    
    NSFileManager* fileManager = [NSFileManager defaultManager];
    
    if (psDownTaskIdentify) {
        //删除暂停时保存的续传文件
        [fileManager removeItemAtPath:sTmpDataPath error:nil];
    }else{
        //1删除tmp中的文件
        NSArray* arryTmpFile = [fileManager contentsOfDirectoryAtPath:NSTemporaryDirectory() error:nil ];
        
        for (NSString *curFile in arryTmpFile) {
            //删除以.tmp结尾且有CFNetworkDownload的文件
            NSString *sExtension=[curFile pathExtension];
            NSRange range=[curFile rangeOfString:@"CFNetworkDownload"];
            
            if (range.length>0 && [sExtension isEqualToString:@"tmp"]) {
                [fileManager removeItemAtPath:[NSString stringWithFormat:@"%@%@",NSTemporaryDirectory(),curFile] error:nil];
            }
        }
        arryTmpFile=nil;
        
        //2删除tmpdata文件夹中的文件
        NSString *sDirectory=[NSString stringWithFormat:@"%@/Documents/%@/",NSHomeDirectory(),sTmpDataPathDirectory];
        arryTmpFile = [fileManager contentsOfDirectoryAtPath:sDirectory error:nil ];
        
        for (NSString *curFile in arryTmpFile) {
            [fileManager removeItemAtPath:[NSString stringWithFormat:@"%@%@",sDirectory,curFile] error:nil];
        }
    }
}

-(void)btnClick{
    
    if (bTaskFinish) return;
    
    //等待网络时 不再执行操作,防止多次点击btnClick
    if ([lblTitle.text isEqualToString:txtWaitting] && lblTitle.hidden==NO) return;
    
    //测试网络是否能连通
    if (bNeedToCheckNetwork) {
        
        [self setTitle:@"" forState:UIControlStateNormal];
        lblTitle.hidden=NO;
        lblTitle.text=txtWaitting;
        
        __block BOOL bWaitting=YES;//等待sessiondatatask测试网络的处理结果
        __block BOOL bNetwork=YES; //测试网络是否边通结果
        

        NSURLSession *sessionCheckNetwork=[NSURLSession sharedSession];
        
        //1.创建url
        NSString *urlStr=[self.sServerUrl stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
        NSURL *url=[NSURL URLWithString:urlStr];
        //2.创建请求
        NSURLRequest *request=[NSURLRequest requestWithURL:url];
        //3.请求
        sessionDataTaskCheckNetwork=[sessionCheckNetwork dataTaskWithRequest:request completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
            if (error) {
                bNetwork=NO;
            }else{
                bNeedToCheckNetwork=NO;
            }
            bWaitting=NO;
        }];
        //4.开始任务
        [sessionDataTaskCheckNetwork resume];
        
        //开始计时,超过指定时间就强制断开任务
        checkNetworkTimer=[NSTimer scheduledTimerWithTimeInterval:self.iTimeOutSeconds target:self selector:@selector(BreakCheckNetworkTimeout) userInfo:nil repeats:NO];
        
        //等待网络的block处理完后在返回结果
        while (bWaitting) {
            [[NSRunLoop currentRunLoop] runMode:NSDefaultRunLoopMode beforeDate:[NSDate distantFuture]];
        }
        
        //四种情况会到这边 1.正常超过self.iTimeOutSeconds时间 2.长按取消下载时 3.此类将要消失时 4.网络出错时
        if (bNetwork==NO) {
            //停止超时计时
            [checkNetworkTimer invalidate];
            bNeedToCheckNetwork=YES;
            
            if ([sTxtCheckNetwork isEqualToString:txtDown]) {
                lblTitle.text=sTxtCheckNetwork;
                lblTitle.hidden=YES;
                
                [self setTitle:txtDown forState:UIControlStateNormal];
            }else{
                lblTitle.text=sTxtCheckNetwork;
                lblTitle.hidden=NO;
                
                [self setTitle:@"" forState:UIControlStateNormal];
            }
            sTxtCheckNetwork=txtError_Network;
            return;
        }
        
        //停止超时计时
        [checkNetworkTimer invalidate];
        sessionDataTaskCheckNetwork=nil;
    }
    
    //根据sDownTaskIdentif判断有断传的文件
    if ([[NSFileManager defaultManager] fileExistsAtPath:sTmpDataPath]) {
        
        //续传
        if (bTaskRunning==NO) {
            bTaskRunning=YES;
            
            lblTitle.hidden=NO;
            [self setTitle:@"" forState:UIControlStateNormal];
            
            [self DownloadContinue:sTmpDataPath];
            
        }else{
            
            bTaskRunning=NO;
            
            lblTitle.hidden=YES;
            [self setTitle:txtGoon forState:UIControlStateNormal];
            
            [self DownLoadCancelAndSave];
            sessionDownLoad=nil;
        }
        
    }else{
        //新下载
        if (bTaskRunning==NO) {
            bTaskRunning=YES;
            
            lblTitle.hidden=NO;
            [self setTitle:@"" forState:UIControlStateNormal];
            
            [self NewDownloadTaskWithUrl:self.sDownTaskUrl];

        }else{
            bTaskRunning=NO;
            
            lblTitle.hidden=YES;
            [self setTitle:txtGoon forState:UIControlStateNormal];
            
            [self DownLoadCancelAndSave];
            sessionDownLoad=nil;
        }
    }

   
}

//新下载的初始化
-(void)NewDownloadTaskWithUrl:(NSString *)pUrl{
    
    //1.创建url
    NSString *urlStr=[pUrl stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    NSURL *url=[NSURL URLWithString:urlStr];
    
    NSMutableURLRequest *request=[NSMutableURLRequest requestWithURL:url];
    
    //2.创建后台会话
    NSURLSessionConfiguration *sessionConfig=[NSURLSessionConfiguration defaultSessionConfiguration];
    sessionConfig.timeoutIntervalForRequest=10;             //请求超时时间
    sessionConfig.allowsCellularAccess=NO;                  //是否允许蜂窝网络下载（2G/3G/4G）
    sessionConfig.discretionary=YES;
    if (session==nil) {
        session=[NSURLSession sessionWithConfiguration:sessionConfig delegate:self delegateQueue:nil];
    }
    sessionDownLoad=[session downloadTaskWithRequest:request];
    [sessionDownLoad resume];
}

//保存续传数据
-(void)DownLoadCancelAndSave{
    
    if (sessionDownLoad) {
        [sessionDownLoad cancelByProducingResumeData:^(NSData *resumeData) {
            if (resumeData.length>0) {
                [self SaveResumeData:resumeData];
            }
        }];
    }
}

//保存续传数据方法
-(void)SaveResumeData:(NSData*)presumeData{
    NSString *sDirectory=[NSString stringWithFormat:@"%@/Documents/%@",NSHomeDirectory(),sTmpDataPathDirectory];
    BOOL bDirectoryExist=[[NSFileManager defaultManager] fileExistsAtPath:sDirectory];
    
    //创建文件夹
    if (!bDirectoryExist) {
        [[NSFileManager defaultManager] createDirectoryAtPath:sDirectory withIntermediateDirectories:YES attributes:nil error:nil
         ];
    }
    
    //保存已经下载的数据
    [[NSFileManager defaultManager] createFileAtPath:sTmpDataPath contents:presumeData attributes:nil];
}

//续传
-(void)DownloadContinue:(NSString*)psTmpDataPath{
    
    //创建后台会话
    NSURLSessionConfiguration *sessionConfig=[NSURLSessionConfiguration defaultSessionConfiguration];
    sessionConfig.timeoutIntervalForRequest=10;             //请求超时时间
    sessionConfig.allowsCellularAccess=NO;                  //是否允许蜂窝网络下载（2G/3G/4G）
    sessionConfig.discretionary=YES;
    
    if (session==nil) {
        session=[NSURLSession sessionWithConfiguration:sessionConfig delegate:self delegateQueue:nil];
    }
    
    NSData *data = [NSData dataWithContentsOfFile:psTmpDataPath];
    sessionDownLoad = [session downloadTaskWithResumeData:data];
    [sessionDownLoad resume];
}


#pragma-mark NSURLSession delegate
/* 从fileOffset位移处恢复下载任务 */
- (void)URLSession:(NSURLSession *)session
      downloadTask:(NSURLSessionDownloadTask *)downloadTask didResumeAtOffset:(int64_t)fileOffset expectedTotalBytes:(int64_t)expectedTotalBytes {
    //NSLog(@"NSURLSessionDownloadDelegate: Resume download at %lld", fileOffset);
}

//下载完成(不管正确错误)
-(void)URLSession:(NSURLSession *)session task:(NSURLSessionTask *)task didCompleteWithError:(NSError *)error{
    
    //处理下载过程中网络中断后保存数据
    if ([error.domain isEqualToString:NSURLErrorDomain] && error.code!=NSURLErrorCancelled) {
        
        //NSURLErrorNetworkConnectionLost 断线处理
        //NSURLErrorCannotConnectToHost   连不上服务器
        NSLog(@"error.code : %ld",(long)error.code);
        
        // !!Note:-cancel获取不到resumeData
        NSData *dataNetworkBreak=[error.userInfo objectForKey:NSURLSessionDownloadTaskResumeData];
        if (dataNetworkBreak.length>0) {
            [self SaveResumeData:dataNetworkBreak];
        }
        
        [[NSOperationQueue mainQueue] addOperationWithBlock:^{
            bNeedToCheckNetwork=YES;
            bTaskRunning=NO;
            
            lblTitle.text=txtError_Network;
            lblTitle.hidden=NO;
            
            [self setTitle:@"" forState:UIControlStateNormal];
        }];
    }
    
}


//下载中(会多次调用，可以记录下载进度)
-(void)URLSession:(NSURLSession *)session downloadTask:(NSURLSessionDownloadTask *)downloadTask didWriteData:(int64_t)bytesWritten totalBytesWritten:(int64_t)totalBytesWritten totalBytesExpectedToWrite:(int64_t)totalBytesExpectedToWrite{
    
    NSString  *sPercentMsg=[NSNumberFormatter localizedStringFromNumber:[NSNumber numberWithFloat:(float)totalBytesWritten/totalBytesExpectedToWrite] numberStyle:NSNumberFormatterPercentStyle];
    NSLog(@"%@",sPercentMsg);
   
    [[NSOperationQueue mainQueue] addOperationWithBlock:^{
        lblTitle.text=sPercentMsg;
    }];
    
}

//下载完成
-(void)URLSession:(NSURLSession *)session downloadTask:(NSURLSessionDownloadTask *)downloadTask didFinishDownloadingToURL:(NSURL *)location{
    
    NSString *sDirectory=[NSString stringWithFormat:@"%@/Documents/%@",NSHomeDirectory(),sSaveDataPathDirectory];
    BOOL bDirectoryExist=[[NSFileManager defaultManager] fileExistsAtPath:sDirectory];
    
    //创建文件夹
    if (!bDirectoryExist) {
        [[NSFileManager defaultManager] createDirectoryAtPath:sDirectory withIntermediateDirectories:YES attributes:nil error:nil
         ];
    }
    
    //如果有相同的文件，先删除
    if ([[NSFileManager defaultManager] fileExistsAtPath:sSaveDataPath]) {
        [[NSFileManager defaultManager] removeItemAtPath:sSaveDataPath error:nil];
    }
    
    //保存下载文件
    NSError *error;
    NSURL *sSaveUrl=[NSURL fileURLWithPath:sSaveDataPath];
    [[NSFileManager defaultManager] copyItemAtURL:location toURL:sSaveUrl error:&error];
    
   
    //删除暂停时保存的续传文件
    [[NSFileManager defaultManager] removeItemAtPath:sTmpDataPath error:nil];
    
    [[NSOperationQueue mainQueue] addOperationWithBlock:^{
        lblTitle.hidden=YES;
        if (error) {
            NSLog(@"Error is:%@",error.localizedDescription);
            [self setTitle:txtError forState:UIControlStateNormal];
        }else{
            [self setTitle:txtFinish forState:UIControlStateNormal];
        }
    }];
    
    bTaskFinish=YES;
}

@end
