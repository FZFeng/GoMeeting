//
//  tbCellMyActionTableViewCell.m
//  BaseModel
//
//  Created by apple on 15/11/12.
//  Copyright (c) 2015年 Fabius's Studio. All rights reserved.
//

#import "tbCellMyAction.h"

@implementation tbCellMyAction

- (void)awakeFromNib {
    // Initialization code
    self.imgMyAction.layer.masksToBounds=YES;
    self.imgMyAction.layer.cornerRadius =CGRectGetWidth(self.imgMyAction.bounds)/2;//圆形
    self.imgMyAction.contentMode=UIViewContentModeScaleAspectFill;
    //圆角
    self.btnCancelAction.layer.cornerRadius=5.0;
    self.btnActionJoinor.layer.cornerRadius=5,0;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

- (IBAction)btnCancelActionClick:(id)sender {
}

- (IBAction)btnActionJoinorClick:(id)sender {
}
@end
