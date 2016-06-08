//
//  vActionJoinorViewController.m
//  BaseModel
//
//  Created by apple on 15/11/16.
//  Copyright (c) 2015年 Fabius's Studio. All rights reserved.
//

#import "vActionJoinorViewController.h"

@interface vActionJoinorViewController ()

@end

@implementation vActionJoinorViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    self.automaticallyAdjustsScrollViewInsets=NO;
    
    //注册nib
    UINib *nibActionJoinor=[UINib nibWithNibName:@"tbCellActionJoinor" bundle:nil];
    [tbActionJoinor registerNib:nibActionJoinor forCellReuseIdentifier:@"tbCellActionJoinor"];
    
    
    tbCellActionJoinor*cellActionJoinor=[tbActionJoinor dequeueReusableCellWithIdentifier:@"tbCellActionJoinor"];
    fRowDataH=CGRectGetHeight(cellActionJoinor.frame);
    
    arryActionJoinor=[[NSArray alloc] initWithObjects:@"1",@"1", nil];

}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)viewDidLayoutSubviews{
    
    //根据arryActionJoinor来计算tbview的高度
    if (!bDidLayoutSubviews) {
        bDidLayoutSubviews=YES;
        
        if (arryActionJoinor.count>0) {
            int iCurTbHeight=arryActionJoinor.count*fRowDataH;
            if (iCurTbHeight>CGRectGetHeight(tbActionJoinor.frame)) {
                tbLayoutBottom.constant=0.0;
                tbActionJoinor.scrollEnabled=YES;
            }else{
                tbLayoutBottom.constant=CGRectGetHeight(tbActionJoinor.frame)-iCurTbHeight;
                tbActionJoinor.scrollEnabled=NO;
            }
        }
    }
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

#pragma mark tableviewdelegate
-(UITableViewCell*)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    
    tbCellActionJoinor*cellActionJoinor=[tableView dequeueReusableCellWithIdentifier:@"tbCellActionJoinor"];
    [cellActionJoinor setSelectionStyle:UITableViewCellSelectionStyleNone];
    
    
    return cellActionJoinor;
    
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return arryActionJoinor.count;
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return fRowDataH;
}


@end
