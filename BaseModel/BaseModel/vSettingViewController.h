//
//  vSettingViewController.h
//  BaseModel
//
//  Created by apple on 15/9/2.
//  Copyright (c) 2015年 Fabius's Studio. All rights reserved.
//  Info:设置模块 用户,系统

#import <UIKit/UIKit.h>
#import "SystemPlist.h"
#import "OuterSDKManager.h"
#import "ClassAction.h"

@interface vSettingViewController : UIViewController<UINavigationControllerDelegate>{

    IBOutlet UIButton *btnUserSetting;
    IBOutlet UIImageView *imgHeadLogo;
}
- (IBAction)btnCloseClick:(id)sender;
- (IBAction)btnSystemSettingClick:(id)sender;
- (IBAction)btnLoginOutClick:(id)sender;

@end
