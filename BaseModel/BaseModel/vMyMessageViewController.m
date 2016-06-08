//
//  vMyMessageViewController.m
//  BaseModel
//
//  Created by apple on 15/11/12.
//  Copyright (c) 2015年 Fabius's Studio. All rights reserved.
//

#import "vMyMessageViewController.h"

@interface vMyMessageViewController ()

@end

@implementation vMyMessageViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    [self refreshTable];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)viewWillAppear:(BOOL)animated{
    [self.navigationController.navigationBar setHidden:NO];
}


#pragma mark 操作后刷新tableview
-(void)refreshTable{
    if (!arryMyMessageData) {
        UILabel *lbl=[[UILabel alloc] initWithFrame:CGRectMake(0, 0, CGRectGetWidth(self.view.frame), 35)];
        lbl.text=@"暂 无 数 据";
        lbl.textAlignment=NSTextAlignmentCenter;
        lbl.font=[UIFont systemFontOfSize:16];
        lbl.textColor=[UIColor grayColor];
        tbMyMessage.tableFooterView=lbl;
        tbMyMessage.dataSource=nil;
        tbMyMessage.scrollEnabled=NO;
    }else{
        tbMyMessage.tableFooterView=nil;
        tbMyMessage.scrollEnabled=YES;
    }
    
    
    [tbMyMessage reloadData];
}


@end
