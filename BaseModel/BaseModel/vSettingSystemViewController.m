//
//  vSettingSystemViewController.m
//  BaseModel
//
//  Created by apple on 15/9/4.
//  Copyright (c) 2015年 Fabius's Studio. All rights reserved.
//

#import "vSettingSystemViewController.h"

@interface vSettingSystemViewController ()

@end

@implementation vSettingSystemViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    // Do any additional setup after loading the view.
    
    NSString *currentVersion = [[NSBundle mainBundle] objectForInfoDictionaryKey: (NSString*)kCFBundleVersionKey];
    lblVersion.text=[NSString stringWithFormat:@"系统版本:%@",currentVersion];
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

-(void)viewWillAppear:(BOOL)animated{
    [self.navigationController.navigationBar setHidden:NO];
}

@end
