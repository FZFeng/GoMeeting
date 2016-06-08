//
//  vMainViewController.m
//  BaseModel
//
//  Created by apple on 15/9/2.
//  Copyright (c) 2015年 Fabius's Studio. All rights reserved.
//

#import "vMainViewController.h"
#define iGap 2.5


@implementation vMainViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.automaticallyAdjustsScrollViewInsets=NO;
    
    _cActionObject=[[ClassAction alloc] init];
}

-(void)viewDidLayoutSubviews{
    //这过程会被调用多次 用bHasLoad确保在ViewDidLoad时只加载一次
    if (_bHasLoad==NO) {
        _bHasLoad=YES;
        fztbAction = [fztbAction  initWithFrame:fztbAction.bounds pullingDelegate:self UITableViewStyle:UITableViewStyleGrouped];
        fztbAction.dataSource=self;
        fztbAction.delegate=self;
        //首次加载
        [fztbAction InitRefreshData];
        
        //tbMapAddress 注册自定义类型的cell
        UINib *tbCellActionNib = [UINib nibWithNibName:@"tbCellAction" bundle:nil];
        [fztbAction registerNib:tbCellActionNib forCellReuseIdentifier:@"tbCellAction"];
        
        //row高度 非动态row高度 直接用rowHeight 而不用-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
        tbCellAction *cellAction = (tbCellAction*)[fztbAction dequeueReusableCellWithIdentifier:@"tbCellAction"];
        fztbAction.rowHeight=CGRectGetHeight(cellAction.bounds);
        fztbAction.sectionFooterHeight=0;
        
        //注册广告的 cell
        //tbMapAddress 注册自定义类型的cell
        UINib *tbCellAdNib = [UINib nibWithNibName:@"tbCellAd" bundle:nil];
        [fztbAction registerNib:tbCellAdNib forCellReuseIdentifier:@"tbCellAd"];
        
        tbCellAd *cellAd = (tbCellAd*)[fztbAction dequeueReusableCellWithIdentifier:@"tbCellAd"];
        fTbCellAdHeight=CGRectGetHeight(cellAd.bounds);
        
        _bInitData=YES;
        
    }
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

#pragma mark 个人信息
- (IBAction)barBtnItemUserClick:(id)sender {
    
    NSString *sViewId=@"";
    BOOL bLogin=[SystemPlist GetLogin];
    
    if (bLogin) {
        //已经登录
        sViewId=@"UINavSetting";
    }else{
        sViewId=@"UINavUserLoad";
    }

    UINavigationController *navObject=[self.storyboard instantiateViewControllerWithIdentifier:sViewId];
    ;
    [self presentViewController:navObject animated:YES completion:nil];

}

#pragma mark 增加新活动
- (IBAction)barBtnItemAddNewClick:(id)sender {
    
    NSString *sViewId=@"";
    BOOL bLogin=[SystemPlist GetLogin];
    
    if (bLogin) {
        //已经登录
        sViewId=@"UINavActionAddNew";
    }else{
        sViewId=@"UINavUserLoad";
    }
    
    UINavigationController *navObject=[self.storyboard instantiateViewControllerWithIdentifier:sViewId];
    navObject.delegate=self;
    [self presentViewController:navObject animated:YES completion:nil];
}

#pragma mark FZRefreshTableViewDelegate回调
// 加载数据中
- (void) addDataing
{
    for (int x = 0; x < [arryMoreData count]; x++)
    {
        [arryTableData addObject:[arryMoreData objectAtIndex:x]];
    }
}

- (void) insertDataing
{
    //因为第一项为广告所以从第1项开始
    for (int x = 1; x < [arryMoreData count]+1; x++)
    {
        [arryTableData insertObject:[arryMoreData objectAtIndex:x-1] atIndex:x];
    }
}

-(void)pullingDownRefreshing:(refreshingReBlock)pBlock{
    if (_bInitData) {
        //第一次初始化的数据
        [_cActionObject getServerActionData:refreshTypeInit sLocalUpdateDate:nil returnBlock:^(NSArray *arryServerActionData,NSArray *arryAdActionData,BOOL bNeedClearData,NSString *sErrMsg) {
            if ([sErrMsg isEqualToString:@""]) {
                arryTableData=[arryServerActionData mutableCopy];
                arryAdTableData=[arryAdActionData mutableCopy];
                if (arryTableData.count>0) {
                    pBlock(FinishedLoadingMessageHasUpdateNum,arryTableData.count,nil);
                    [arryTableData insertObject:@"" atIndex:0];//第一项为广告项
                    _bInitData=NO;
                }else{
                    pBlock(FinishedLoadingNoDataUpdate,0,nil);
                }
            }else{
                //错误
                pBlock(FinishedLoadingMessageError,0,sErrMsg);
                _bInitData=YES;
            }
        }];
    }else{
        _bInitData=NO;
        //获取最近一次的最前一条记录的更新日期
        NSString *sUpdateDate=((ClassAction*)[arryTableData objectAtIndex:1]).sDate;
        
        //获取最新数据
        [_cActionObject getServerActionData:refreshTypeDown sLocalUpdateDate:sUpdateDate returnBlock:^(NSArray *arryServerActionData,NSArray *arryAdActionData,BOOL bNeedClearData,NSString *sErrMsg) {
            
            if ([sErrMsg isEqualToString:@""]) {
                if (bNeedClearData) [arryTableData removeAllObjects];
                arryMoreData=[arryServerActionData mutableCopy];
                arryAdTableData=[arryAdActionData mutableCopy];
                if (arryMoreData.count>0) {
                    pBlock(FinishedLoadingMessageHasUpdateNum,arryMoreData.count,nil);
                    //插入新数据
                    [self insertDataing];
                }else{
                    pBlock(FinishedLoadingNoDataUpdate,0,nil);
                }

            }else{
                //错误
                pBlock(FinishedLoadingMessageError,0,sErrMsg);
            }
        }];
    }
}

-(void)pullingUpLoading:(refreshingReBlock)pBlock{
    //获取最近一次的最前一条记录的更新日期
    NSString *sUpdateDate=((ClassAction*)[arryTableData lastObject]).sDate;
    
    //获取最新数据
    [_cActionObject getServerActionData:refreshTypeUp sLocalUpdateDate:sUpdateDate returnBlock:^(NSArray *arryServerActionData,NSArray *arryAdActionData,BOOL bNeedClearData,NSString *sErrMsg){
        
        if ([sErrMsg isEqualToString:@""]) {
            if (bNeedClearData) [arryTableData removeAllObjects];
            arryMoreData=[arryServerActionData mutableCopy];
            arryAdTableData=[arryAdActionData mutableCopy];
            if (arryMoreData.count>0) {
                pBlock(FinishedLoadingMessageHasUpdateNum,arryMoreData.count,nil);
                //插入新数据
                [self addDataing];
            }else{
                pBlock(FinishedLoadingNoDataUpdate,0,nil);
            }

        }else{
            //错误
            pBlock(FinishedLoadingMessageError,0,sErrMsg);
        }
    }];
}

#pragma mark - Scroll
- (void)scrollViewDidScroll:(UIScrollView *)scrollView{
    [fztbAction tableViewDidScroll:scrollView];
}

- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate{
    [fztbAction tableViewDidEndDragging:scrollView];
}


#pragma mark Table view data source
-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    
    iCurRowIndex=indexPath.section;
    ClassAction *cActionData=[arryTableData objectAtIndex:indexPath.section];
    
    //活动到期检查
    [_cActionObject checkActionEnable:[cActionData.sActionID intValue] fatherObject:self returnBlock:^(BOOL bReturnBlock, int iActionJoiner) {
        if (bReturnBlock) {
            
            if (iActionJoiner>0) {
                //更新最新的参加活动人数
                cActionData.iActionJoiner=iActionJoiner;
                NSString *sStr=[[cActionData.sActionJoiner componentsSeparatedByString:@":"] firstObject];
                cActionData.sActionJoiner=[NSString stringWithFormat:@"%@:%d",sStr,cActionData.iActionJoiner];
                
                [arryTableData replaceObjectAtIndex:iCurRowIndex withObject:cActionData];
                [fztbAction reloadData];
            }
            
            vActionDetailViewController *actionDetailView=[self.storyboard instantiateViewControllerWithIdentifier:@"UIViewActionDetail"];
            actionDetailView.cActionData=cActionData;
            
            UIBarButtonItem *backItem=[[UIBarButtonItem alloc] initWithTitle:@"" style:UIBarButtonItemStyleDone target:nil action:nil];
            [self.navigationItem setBackBarButtonItem:backItem];
            [self.navigationController pushViewController:actionDetailView animated:YES];
        }else{
            if (![fztbAction isLoadingData]) {
                
                //删除指定iActionID中数据源的数据
                [arryTableData removeObjectAtIndex:indexPath.section];
                
                //获取数据
                [fztbAction RefreshData];
                
                [fztbAction reloadData];
            }
        }
    }];
 }
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return arryTableData.count;
}
// Customize the number of rows in the table view.
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {;
    return 1;
}

-(CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section{
    return 1;
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    if (indexPath.section==0) {
        return fTbCellAdHeight;
    }else{
        return fztbAction.rowHeight;
    }
}


// Customize the appearance of table view cells.
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    if (indexPath.section==0) {
        tbCellAd *cell = (tbCellAd*)[tableView dequeueReusableCellWithIdentifier:@"tbCellAd"];
        
        cell.fzscrladviewAction.bTimerOn=YES;
        cell.fzscrladviewAction.fTimerFrequency=3.0;
        cell.fzscrladviewAction.bEnableClick=YES;
        cell.fzscrladviewAction.delegate=self;
        cell.fzscrladviewAction.bNetworkImage=YES;
        NSMutableArray *arryAdImageUrl=[[NSMutableArray alloc] init];
        
        for (ClassAction *cActionData in arryAdTableData) {
            [arryAdImageUrl addObject:cActionData.sAdActionImageUrl];
        }
        cell.fzscrladviewAction.arryAdImage=arryAdImageUrl;
        [cell setSelectionStyle:UITableViewCellSelectionStyleNone];
        return cell;
    }else{
        tbCellAction *actionCell = (tbCellAction*)[tableView dequeueReusableCellWithIdentifier:@"tbCellAction"];
        [actionCell setSelectionStyle:UITableViewCellSelectionStyleNone];
        ClassAction *cActionData=[arryTableData objectAtIndex:indexPath.section];
        
        //检查本地是否已保存图片
        if (cActionData.bActionImageHasDownload) {
            actionCell.imgMain.image=[UIImage imageNamed:[cActionData.arryActionImagePath firstObject]];
        }else{
            //使用sdImage下载
            [actionCell.imgMain sd_setImageWithURL:[NSURL URLWithString:[cActionData.arryActionImagePath firstObject]] placeholderImage:[UIImage imageNamed:@"imgActionDefault"]];
        }
        
        actionCell.lblTitle.text=cActionData.sActionTitle;
        actionCell.lblPlace.text=cActionData.sActionPlace;
        actionCell.lblDate.text=cActionData.sActionDate;
        actionCell.lblBookNum.text=cActionData.sActionJoiner;
        actionCell.lblPersion.text=cActionData.sActionManNum;
        actionCell.lblCharge.text=cActionData.sActionCharge;
        
        return actionCell;
    }
}
#pragma mark FZScrollAdViewDelegate 回调
-(void)delegateClick:(int)iSelectIndex{
    NSString *sAdUrl=((ClassAction*)[arryAdTableData objectAtIndex:iSelectIndex]).sAdActionUrl;
    
    if (sAdUrl.length>0) {
        vReceRemoteNotificationViewController *receRemoteNotificationView=[self.storyboard instantiateViewControllerWithIdentifier:@"UIViewReceRemoteNotification"];
        receRemoteNotificationView.sGetUrl=sAdUrl;
        UIBarButtonItem *backItem=[[UIBarButtonItem alloc] initWithTitle:@"" style:UIBarButtonItemStyleDone target:nil action:nil];
        [self.navigationItem setBackBarButtonItem:backItem];
        [self.navigationController pushViewController:receRemoteNotificationView animated:YES];
    }
}

@end
