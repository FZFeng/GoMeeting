//
//  tbCellJoinAction.h
//  BaseModel
//
//  Created by apple on 15/11/13.
//  Copyright (c) 2015年 Fabius's Studio. All rights reserved.
//  Info:参加的活动cell

#import <UIKit/UIKit.h>

@interface tbCellMyJoinAction : UITableViewCell{
}
@property (strong, nonatomic) IBOutlet UIImageView *imgMyJoinAction;
@property (strong, nonatomic) IBOutlet UILabel *lblActionTitle;
@property (strong, nonatomic) IBOutlet UILabel *lblActionMan;
@property (strong, nonatomic) IBOutlet UILabel *lblActionCharge;
@property (strong, nonatomic) IBOutlet UILabel *lblContactPhone;
@property (strong, nonatomic) IBOutlet UIButton *btnCancelAction;



@end
