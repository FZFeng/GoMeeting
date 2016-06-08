//
//  vSettingUserInfoViewController.h
//  BaseModel
//
//  Created by apple on 15/9/4.
//  Copyright (c) 2015年 Fabius's Studio. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ClassUser.h"

@interface vSettingUserInfoViewController : UIViewController<UINavigationControllerDelegate,UIImagePickerControllerDelegate>{

    NSData *dataSelectImg;
    NSString *sGender;
    
    IBOutlet UIImageView *imgHeadLogo;
    IBOutlet UITextField *txtUserName;
    IBOutlet UILabel *lblGender;
}
- (IBAction)barBtnItemSaveUserInfoSettingClick:(id)sender;
- (IBAction)btnSetHeadLogoClick:(id)sender;
- (IBAction)btnManClick:(id)sender;
- (IBAction)btnWomanClick:(id)sender;

@end
