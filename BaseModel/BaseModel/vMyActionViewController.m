//
//  vMyActionViewController.m
//  BaseModel
//
//  Created by apple on 15/11/10.
//  Copyright (c) 2015年 Fabius's Studio. All rights reserved.
//

#import "vMyActionViewController.h"

@implementation vMyActionViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.automaticallyAdjustsScrollViewInsets=NO;
    
    cActionObject=[[ClassAction alloc] init];
    iActionTypeDataEnum=actionDataTypeRunning;
   
    [segmentActionType addTarget:self action:@selector(segmentAction:) forControlEvents:UIControlEventValueChanged];
    
    //注册cell
    UINib *nibMyActionCell=[UINib nibWithNibName:@"tbCellMyAction" bundle:nil];
    [tbMyAction registerNib:nibMyActionCell forCellReuseIdentifier:@"tbCellMyAction"];
    
    tbCellMyAction*celMyAction=[tbMyAction dequeueReusableCellWithIdentifier:@"tbCellMyAction"];
    fRowDataH=CGRectGetHeight(celMyAction.frame);
    
    //去掉左边的空白
    if ([tbMyAction respondsToSelector:@selector(setLayoutMargins:)]) {
        [tbMyAction setLayoutMargins:UIEdgeInsetsZero];
    }
    if ([tbMyAction respondsToSelector:@selector(setSeparatorInset:)]) {
        [tbMyAction setSeparatorInset:UIEdgeInsetsZero];
    }
    
    [self refreshTable];
    //等待加载数据
    [self performSelector:@selector(initTableData) withObject:self afterDelay:0.1];
}

-(void)initTableData{
    arryMyAcctionData=[cActionObject getLocalActionData:actionDataTypeRunning];
    [self refreshTable];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


-(void)viewWillAppear:(BOOL)animated{
    [self.navigationController.navigationBar setHidden:NO];
}

#pragma mark 动态改变tb的bottom约束
-(void)setTbBottomConstant{
    if (arryMyAcctionData.count>0) {
        int iCurTbHeight=arryMyAcctionData.count*fRowDataH;
        if (iCurTbHeight>itbViewH) {
            tbLayoutBottom.constant=0.0;
            tbMyAction.scrollEnabled=YES;
        }else{
            tbLayoutBottom.constant=itbViewH-iCurTbHeight;
            tbMyAction.scrollEnabled=NO;
        }
    }
}

-(void)viewDidLayoutSubviews{
    //根据arryActionJoinor来计算tbview的高度
    if (!bDidLayoutSubviews) {
        bDidLayoutSubviews=YES;
        itbViewH=CGRectGetHeight(tbMyAction.frame)-CGRectGetHeight(segmentActionType.frame);
        [self setTbBottomConstant];
    }
}


#pragma mark tableviewdelegate
-(UITableViewCell*)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{

    tbCellMyAction*celMyAction=[tableView dequeueReusableCellWithIdentifier:@"tbCellMyAction"];
    
    [celMyAction setSelectionStyle:UITableViewCellSelectionStyleNone];
    
    ClassAction *cActionData=[arryMyAcctionData objectAtIndex:indexPath.row];
    
    //遍历图片文件夹并获取第一个图片
    NSString *sImgPath=[NSString stringWithFormat:@"%@%@/",[SystemPlist GetActionImagePath],cActionData.sActionID];
    NSString *sImgName=@"";
    NSArray *arryFiles=[[NSFileManager defaultManager] contentsOfDirectoryAtPath:sImgPath error:nil];
    
    if (arryFiles) {
        sImgName=[NSString stringWithFormat:@"%@%@",sImgPath,[arryFiles firstObject]];
    }
    switch (iActionTypeDataEnum) {
        case 0:{
            //运行中
            //cancel
            celMyAction.btnCancelAction.hidden=NO;
            [celMyAction.btnCancelAction addTarget:self action:@selector(btnCancelActionClick:)  forControlEvents:UIControlEventTouchUpInside];
            celMyAction.btnCancelAction.accessibilityIdentifier=cActionData.sActionID;
            //actionJoinor
            celMyAction.btnActionJoinor.userInteractionEnabled=YES;
            celMyAction.btnActionJoinor.backgroundColor=celMyAction.btnCancelAction.backgroundColor;
            [celMyAction.btnActionJoinor setTitle:cActionData.sActionJoiner forState:UIControlStateNormal];
            [celMyAction.btnActionJoinor setTitleColor:[UIColor lightGrayColor] forState:UIControlStateNormal];
            [celMyAction.btnActionJoinor addTarget:self action:@selector(btnActionJoinorClick:)  forControlEvents:UIControlEventTouchUpInside];
            break;
        }case 1:{
            //已完成
            //cancel
            celMyAction.btnCancelAction.hidden=YES;
            //actionJoinor
            celMyAction.btnActionJoinor.userInteractionEnabled=YES;
            celMyAction.btnActionJoinor.backgroundColor=celMyAction.btnCancelAction.backgroundColor;
            [celMyAction.btnActionJoinor setTitle:cActionData.sActionJoiner forState:UIControlStateNormal];
            [celMyAction.btnActionJoinor setTitleColor:[UIColor lightGrayColor] forState:UIControlStateNormal];
            [celMyAction.btnActionJoinor addTarget:self action:@selector(btnActionJoinorClick:)  forControlEvents:UIControlEventTouchUpInside];
            break;
        }case 2:{
            //已取消
            //cancel
            celMyAction.btnCancelAction.hidden=YES;
            //actionJoinor
            celMyAction.btnActionJoinor.userInteractionEnabled=NO;
            celMyAction.btnActionJoinor.backgroundColor=[UIColor grayColor];
            [celMyAction.btnActionJoinor setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
            break;
        }
        default:
            break;
    }
    celMyAction.imgMyAction.image=[UIImage imageNamed:sImgName];
    celMyAction.lblActionTitle.text=cActionData.sActionTitle;
    celMyAction.lblActionPlace.text=cActionData.sActionPlace;
    celMyAction.lblActionDate.text=cActionData.sActionDate;
    celMyAction.lblActionMan.text=cActionData.sActionManNum;
    celMyAction.lblActionCharge.text=cActionData.sActionCharge;
    
    return celMyAction;
    
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return arryMyAcctionData.count;
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return fRowDataH;
}

//去掉左边的空白
- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if ([cell respondsToSelector:@selector(setSeparatorInset:)]) {
        [cell setSeparatorInset:UIEdgeInsetsZero];
    }
    if ([cell respondsToSelector:@selector(setLayoutMargins:)]) {
        [cell setLayoutMargins:UIEdgeInsetsZero];
    }
    
}

#pragma mark UIAlert delegate
-(void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex{
    if (buttonIndex==1) {
        [cActionObject cancelMyAction:[alertView.accessibilityIdentifier intValue] fatherObject:self returnBlock:^(BOOL bReturnBlock) {
            if (bReturnBlock) {
                arryMyAcctionData=[cActionObject getLocalActionData:actionDataTypeRunning];
                [self refreshTable];
            }
        }];
    }
}

#pragma mark 取消活动
-(void)btnCancelActionClick:(id)sender{
    UIButton *btnObject=sender;
    UIAlertView *alert=[[UIAlertView alloc] initWithTitle:nil message:@"确定要取消?" delegate:self cancelButtonTitle:@"取消" otherButtonTitles:@"确定", nil];
    alert.accessibilityIdentifier=btnObject.accessibilityIdentifier;
    [alert show];
}

#pragma mark 查看活动参与者
-(void)btnActionJoinorClick:(id)sender{
    vActionJoinorViewController *actionJoinorView=[self.storyboard instantiateViewControllerWithIdentifier:@"UIViewActionJoinor"];
    [self.navigationController pushViewController:actionJoinorView animated:YES];
    
}

#pragma mark 操作后刷新tableview
-(void)refreshTable{
    if (!arryMyAcctionData) {
        UILabel *lbl=[[UILabel alloc] initWithFrame:CGRectMake(0, 0, CGRectGetWidth(self.view.frame), 35)];
        lbl.text=@"暂 无 数 据";
        lbl.textAlignment=NSTextAlignmentCenter;
        lbl.font=[UIFont systemFontOfSize:16];
        lbl.textColor=[UIColor grayColor];
        tbMyAction.tableFooterView=lbl;
        tbMyAction.dataSource=nil;
        tbMyAction.scrollEnabled=NO;
    }else{
        tbMyAction.tableFooterView=nil;
        tbMyAction.dataSource=self;
        tbMyAction.scrollEnabled=YES;
    }
    
    if (bDidLayoutSubviews) [self setTbBottomConstant];

    [tbMyAction reloadData];
}

#pragma mark segment的事件
-(void)segmentAction:(id)sender{
    
    NSInteger iSelectIndex=segmentActionType.selectedSegmentIndex;
    switch (iSelectIndex) {
        case 0:{
            iActionTypeDataEnum=actionDataTypeRunning;
            arryMyAcctionData=[cActionObject getLocalActionData:actionDataTypeRunning];
            break;
        }case 1:{
            iActionTypeDataEnum=actionDataTypeFinished;
            arryMyAcctionData=[cActionObject getLocalActionData:actionDataTypeFinished];
            break;
        }case 2:{
            iActionTypeDataEnum=actionDataTypeCanceled;
            arryMyAcctionData=[cActionObject getLocalActionData:actionDataTypeCanceled];
            break;
        }
        default:
            break;
    }
    
    [self refreshTable];
}


@end
