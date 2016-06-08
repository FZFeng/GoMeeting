//
//  tbCellAction.h
//  BaseModel
//
//  Created by apple on 15/10/19.
//  Copyright (c) 2015年 Fabius's Studio. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "UIImageView+WebCache.h"

@interface tbCellAction : UITableViewCell

@property (strong, nonatomic) IBOutlet  UIImageView *imgMain;
@property (strong, nonatomic) IBOutlet UILabel *lblTitle;
@property (strong, nonatomic) IBOutlet UILabel *lblPlace;
@property (strong, nonatomic) IBOutlet UILabel *lblDate;

@property (strong, nonatomic) IBOutlet UILabel *lblBookNum;
@property (strong, nonatomic) IBOutlet UILabel *lblPersion;
@property (strong, nonatomic) IBOutlet UILabel *lblCharge;

@end
