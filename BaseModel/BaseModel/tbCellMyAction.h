//
//  tbCellMyActionTableViewCell.h
//  BaseModel
//
//  Created by apple on 15/11/12.
//  Copyright (c) 2015年 Fabius's Studio. All rights reserved.
//  Info:我的活动cell

#import <UIKit/UIKit.h>

@interface tbCellMyAction : UITableViewCell
@property (strong, nonatomic)  IBOutlet UIImageView *imgMyAction;
@property (strong, nonatomic)  IBOutlet UILabel *lblActionTitle;
@property (strong, nonatomic) IBOutlet UILabel *lblActionMan;
@property (strong, nonatomic) IBOutlet UILabel *lblActionCharge;
@property (strong, nonatomic) IBOutlet UILabel *lblActionDate;
@property (strong, nonatomic) IBOutlet UIButton *btnCancelAction;
@property (strong, nonatomic) IBOutlet UILabel *lblActionPlace;
@property (strong, nonatomic) IBOutlet UIButton *btnActionJoinor;


- (IBAction)btnCancelActionClick:(id)sender;
- (IBAction)btnActionJoinorClick:(id)sender;


@end
