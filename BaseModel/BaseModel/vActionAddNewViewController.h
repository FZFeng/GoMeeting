//
//  vActionAddNewViewController.h
//  BaseModel
//
//  Created by apple on 15/9/16.
//  Copyright (c) 2015年 Fabius's Studio. All rights reserved.
//  Info: 发布新活动

#import <UIKit/UIKit.h>
#import "FZTextField.h"
#import "FZDatePickerView.h"
#import "FZNoticeView.h"
#import "UzysAssetsPickerController.h"
#import "ClassAction.h"

@interface vActionAddNewViewController : UIViewController<UITextFieldDelegate,UzysAssetsPickerControllerDelegate,UIAlertViewDelegate,UITextViewDelegate,FZDatePickerViewDelegate>{
    
    NSMutableArray *arrySelectImg;
    NSString *sDetailDate; //记录选择的日期
    FZNoticeView *noticeView;

    IBOutlet FZTextField *fztxtDetailTitle;
    IBOutlet FZTextField *fztxtDetailPersion;
    IBOutlet UITextView *txtTDetailExplain;
    IBOutlet FZTextField *fztxtDetailPhone;
    IBOutlet FZTextField *fztxtDetailCharge;
    
    IBOutlet UIButton *btnDetailDate;
    IBOutlet UIButton *btnDetailPlace;
    IBOutlet UIButton *btnDetailPersion;
    IBOutlet UIButton *btnDetailCharge;
    IBOutlet UIButton *btnImageAddNew1;
    IBOutlet UIButton *btnImageAddNew2;
    IBOutlet UIButton *btnImageAddNew3;
    IBOutlet UIButton *btnImageAddNew4;
    
    
    IBOutlet UIButton *btnImageDelete1;
    IBOutlet UIButton *btnImageDelete2;
    IBOutlet UIButton *btnImageDelete3;
    IBOutlet UIButton *btnImageDelete4;
    
}
@property (nonatomic,strong) NSString *sDetailPlace;//记录选择的地点



- (IBAction)btnCancelClick:(id)sender;
- (IBAction)btnSaveActionClick:(id)sender;
- (IBAction)btnDetailPersionClick:(id)sender;
- (IBAction)btnDetailChargeClick:(id)sender;
- (IBAction)btnAddImgClick:(id)sender;
- (IBAction)btnDelImgClick:(id)sender;
- (IBAction)btnDetailDateClick:(id)sender;
@end
