//
//  vSettingViewController.m
//  BaseModel
//
//  Created by apple on 15/9/2.
//  Copyright (c) 2015年 Fabius's Studio. All rights reserved.
//

#import "vSettingViewController.h"

#define sLoginOut @"成功退出登录"

@interface vSettingViewController ()

@end

@implementation vSettingViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    if (![[SystemPlist GetHeadLogo] isEqualToString:@""]) {
        UIImage *img=[[UIImage alloc] initWithContentsOfFile:[SystemPlist GetHeadLogo]];
        [imgHeadLogo setImage:img];
    }
    self.navigationController.delegate=self;
}

//此方法会多次调用
-(void)viewDidLayoutSubviews{
    //圆角
    imgHeadLogo.layer.masksToBounds=YES;
    imgHeadLogo.layer.cornerRadius =imgHeadLogo.frame.size.height/2;
    imgHeadLogo.contentMode=UIViewContentModeScaleAspectFill;
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

#pragma mark 关闭
- (IBAction)btnCloseClick:(id)sender {
    [self dismissViewControllerAnimated:YES completion:nil];
}

#pragma mark 系统设置
- (IBAction)btnSystemSettingClick:(id)sender {
    
}

#pragma mark 登录退出
- (IBAction)btnLoginOutClick:(id)sender {
    //第三方，也退出登录
    if ([SystemPlist GetLoginType]==LoginTypeSdk ) {
         [OuterSDKManager LoginOutWithToken:sdkTypeSinaweibo];
    }
    [SystemPlist InitSystemPlist];
    //清除用户活动数据
    ClassAction *cActionObject=[[ClassAction alloc] init];
    [cActionObject deleteActionDataAndImage];
     
    [PublicFunc ShowSuccessHUD:sLoginOut view:self.view];
    [self performSelector:@selector(dismissView) withObject:nil afterDelay:1.0];
}
-(void)dismissView{
    [self dismissViewControllerAnimated:YES completion:nil];
}

#pragma mark navigationController 回调
-(void)navigationController:(UINavigationController *)navigationController willShowViewController:(UIViewController *)viewController animated:(BOOL)animated{
    if ([viewController.restorationIdentifier isEqualToString:@"UIViewSetting"]) {
        [navigationController.navigationBar setHidden:YES];
    }}

-(void)navigationController:(UINavigationController *)navigationController didShowViewController:(UIViewController *)viewController animated:(BOOL)animated{
    if ([viewController.restorationIdentifier isEqualToString:@"UIViewSetting"]) {
        [navigationController.navigationBar setHidden:YES];
    }else{
        [navigationController.navigationBar setHidden:NO];
    }
}

@end
