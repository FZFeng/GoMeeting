//
//  vMyJoinActionViewController.m
//  BaseModel
//
//  Created by apple on 15/11/12.
//  Copyright (c) 2015年 Fabius's Studio. All rights reserved.
//

#import "vMyJoinActionViewController.h"

@interface vMyJoinActionViewController ()

@end

@implementation vMyJoinActionViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    cActionJoinorObject=[[ClassActionJoinor alloc] init];
    arryMyJoinActionData=[[NSArray alloc] init];
    iJoinActionTypeDataEnum=joinActionDataTypeRunning;
    
    [segmentJoinActionType addTarget:self action:@selector(segmentAction:) forControlEvents:UIControlEventValueChanged];

    //注册nib
    UINib *nibMyJoinActionCell=[UINib nibWithNibName:@"tbCellMyJoinAction" bundle:nil];
    [tbMyJoinAction registerNib:nibMyJoinActionCell forCellReuseIdentifier:@"tbCellMyJoinAction"];
    
    tbCellMyJoinAction*celMyJoinAction=[tbMyJoinAction dequeueReusableCellWithIdentifier:@"tbCellMyJoinAction"];
    fRowDataH=CGRectGetHeight(celMyJoinAction.frame);
    
    //去掉左边的空白
    if ([tbMyJoinAction respondsToSelector:@selector(setLayoutMargins:)]) {
        [tbMyJoinAction setLayoutMargins:UIEdgeInsetsZero];
    }
    if ([tbMyJoinAction respondsToSelector:@selector(setSeparatorInset:)]) {
        [tbMyJoinAction setSeparatorInset:UIEdgeInsetsZero];
    }
    
    [self refreshTable];
    //等待加载数据
    [self performSelector:@selector(getTableData) withObject:self afterDelay:0.1];

}

-(void)getTableData{
    [cActionJoinorObject getJoinActionData:[SystemPlist GetID] joinActionDataType:iJoinActionTypeDataEnum fatherObject:self returnBlock:^(NSArray *arryActionJoinorData) {
        if (arryActionJoinorData) {
            arryMyJoinActionData=arryActionJoinorData;
        }else{
            arryMyJoinActionData=nil;
        }
         [self refreshTable];
    }];
   
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark 操作后刷新tableview
-(void)refreshTable{
    if (!arryMyJoinActionData || arryMyJoinActionData.count==0) {
        UILabel *lbl=[[UILabel alloc] initWithFrame:CGRectMake(0, 0, CGRectGetWidth(self.view.frame), 35)];
        lbl.text=@"暂 无 数 据";
        lbl.textAlignment=NSTextAlignmentCenter;
        lbl.font=[UIFont systemFontOfSize:16];
        lbl.textColor=[UIColor grayColor];
        tbMyJoinAction.tableFooterView=lbl;
        tbMyJoinAction.dataSource=nil;
        tbMyJoinAction.scrollEnabled=NO;
    }else{
        tbMyJoinAction.tableFooterView=nil;
        tbMyJoinAction.dataSource=self;
        tbMyJoinAction.scrollEnabled=YES;
    }
    
    if (bDidLayoutSubviews) [self setTbBottomConstant];
    
    [tbMyJoinAction reloadData];
}

#pragma mark 动态改变tb的bottom约束
-(void)setTbBottomConstant{
    if (arryMyJoinActionData.count>0) {
        int iCurTbHeight=arryMyJoinActionData.count*fRowDataH;
        if (iCurTbHeight>itbViewH) {
            tbLayoutBottom.constant=0.0;
            tbMyJoinAction.scrollEnabled=YES;
        }else{
            tbLayoutBottom.constant=itbViewH-iCurTbHeight;
            tbMyJoinAction.scrollEnabled=NO;
        }
    }
}

-(void)viewDidLayoutSubviews{
    //根据arryActionJoinor来计算tbview的高度
    if (!bDidLayoutSubviews) {
        bDidLayoutSubviews=YES;
        itbViewH=CGRectGetHeight(tbMyJoinAction.frame)-CGRectGetHeight(segmentJoinActionType.frame);
        [self setTbBottomConstant];
    }
}


#pragma mark tableviewdelegate
-(UITableViewCell*)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    
    tbCellMyJoinAction*celMyJoinAction=[tableView dequeueReusableCellWithIdentifier:@"tbCellMyJoinAction"];
    [celMyJoinAction setSelectionStyle:UITableViewCellSelectionStyleNone];
    
    ClassActionJoinor *cActionJoinorData=[[ClassActionJoinor alloc] init];
    cActionJoinorData=[arryMyJoinActionData objectAtIndex:indexPath.row];
    
    celMyJoinAction.btnCancelAction.accessibilityIdentifier=cActionJoinorData.sActionID;
    [celMyJoinAction.btnCancelAction addTarget:self action:@selector(btnCancelJoinActionClick:)  forControlEvents:UIControlEventTouchUpInside];

    if (iJoinActionTypeDataEnum==joinActionDataTypeRunning) {
        celMyJoinAction.btnCancelAction.hidden=NO;
    }else{
        celMyJoinAction.btnCancelAction.hidden=YES;
    }
    celMyJoinAction.lblActionTitle.text=cActionJoinorData.sActionTitle;
    celMyJoinAction.lblActionMan.text=cActionJoinorData.sActionJoiner;
    celMyJoinAction.lblActionCharge.text=cActionJoinorData.sActionCharge;
    celMyJoinAction.lblContactPhone.text=cActionJoinorData.sActionContactPhone;
    //使用sdImage下载
    [celMyJoinAction.imgMyJoinAction sd_setImageWithURL:[NSURL URLWithString:cActionJoinorData.sActionImagePath] placeholderImage:[UIImage imageNamed:@"imgActionDefault"]];

    return celMyJoinAction;
    
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return arryMyJoinActionData.count;
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return fRowDataH;
}
-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    //电话
    ClassActionJoinor *cActionJoinorData=[[ClassActionJoinor alloc] init];
    cActionJoinorData=[arryMyJoinActionData objectAtIndex:indexPath.row];
    NSString *sTel=[[cActionJoinorData.sActionContactPhone componentsSeparatedByString:@":"] lastObject];
    [[UIApplication sharedApplication] openURL:[NSURL URLWithString:[NSString stringWithFormat:@"telprompt://%@", sTel]]];

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
#pragma mark 取消活动
-(void)btnCancelJoinActionClick:(id)sender{
    UIButton *btnObject=sender;
    UIAlertView *alert=[[UIAlertView alloc] initWithTitle:nil message:@"确定要取消?" delegate:self cancelButtonTitle:@"取消" otherButtonTitles:@"确定", nil];
    alert.accessibilityIdentifier=btnObject.accessibilityIdentifier;
    [alert show];
}

#pragma mark UIAlert delegate
-(void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex{
    if (buttonIndex==1) {
        [cActionJoinorObject cancelJoinAction:[alertView.accessibilityIdentifier intValue] sUserID:[SystemPlist GetID] fatherObject:self returnBlock:^(BOOL bReturnBlock) {
            if (bReturnBlock) {
                iJoinActionTypeDataEnum=joinActionDataTypeRunning;
                [self getTableData];
            }
        }];
    }
}

#pragma mark segment的事件
-(void)segmentAction:(id)sender{
    
    NSInteger iSelectIndex=segmentJoinActionType.selectedSegmentIndex;
    switch (iSelectIndex) {
        case 0:{
            iJoinActionTypeDataEnum=joinActionDataTypeRunning;
            break;
        }case 1:{
            iJoinActionTypeDataEnum=joinActionDataTypeFinished;
            break;
        }case 2:{
            iJoinActionTypeDataEnum=joinActionDataTypeBeCanceled;
            break;
        }case 3:{
            iJoinActionTypeDataEnum=joinActionDataTypeMyCanceled;
            break;
        }
        default:
            break;
    }
    
    [self getTableData];
}


-(void)viewWillAppear:(BOOL)animated{
    [self.navigationController.navigationBar setHidden:NO];
}


@end
