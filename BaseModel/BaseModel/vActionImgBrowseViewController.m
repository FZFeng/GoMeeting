//
//  vActionImgBrowseViewController.m
//  BaseModel
//
//  Created by apple on 15/10/30.
//  Copyright (c) 2015年 Fabius's Studio. All rights reserved.
//

#import "vActionImgBrowseViewController.h"

@interface vActionImgBrowseViewController ()

@end

@implementation vActionImgBrowseViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    scrlImg.bounces=NO;
    scrlImg.delegate=self;
    scrlImg.scrollEnabled=YES;
    scrlImg.pagingEnabled=YES;
    scrlImg.showsHorizontalScrollIndicator=NO;
    scrlImg.showsVerticalScrollIndicator=NO;
    pageImg.numberOfPages=_arryActionImagePath.count;
    
    
    //添加关闭窗体button
    UIButton *btnClose=[UIButton buttonWithType:UIButtonTypeCustom];
    btnClose.frame=self.view.frame;
    [btnClose addTarget:self action:@selector(btnCloseClick) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:btnClose];
   
}
-(void)viewDidLayoutSubviews{
    
    if (!bDidLayoutSubviews) {
        bDidLayoutSubviews=YES;
        
        iScrlW=CGRectGetWidth(scrlImg.frame);
        iScrlH=CGRectGetHeight(scrlImg.frame);
        scrlImg.contentSize=CGSizeMake(_arryActionImagePath.count*iScrlW, iScrlH);

        for (int i=0; i<=_arryActionImagePath.count-1; i++) {
            UIImageView *img=[[UIImageView alloc] initWithFrame:CGRectMake(iScrlW*i, 0,iScrlW, iScrlH)];
            NSString *sImagePath=[_arryActionImagePath objectAtIndex:i];
            
            if (_bActionImageHasDownload) {
                //本地图片
                 img.image=[UIImage imageWithContentsOfFile:sImagePath];
            }else{
                //使用sdImage下载
                [img sd_setImageWithURL:[NSURL URLWithString:sImagePath] placeholderImage:[UIImage imageNamed:@"imgActionDefault"]];
            }
             img.contentMode=UIViewContentModeScaleAspectFill;
            [scrlImg addSubview:img];
        }
    }

}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
-(void)btnCloseClick{
    [self dismissViewControllerAnimated:YES completion:nil];
}


//Scrol划动事件
- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView
{
    //更新UIPageControl的当前页
    [pageImg setCurrentPage:scrollView.contentOffset.x/iScrlW];
}
/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
