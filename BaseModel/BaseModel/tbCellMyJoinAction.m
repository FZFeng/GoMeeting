//
//  tbCellJoinAction.m
//  BaseModel
//
//  Created by apple on 15/11/13.
//  Copyright (c) 2015年 Fabius's Studio. All rights reserved.
//

#import "tbCellMyJoinAction.h"

@implementation tbCellMyJoinAction

- (void)awakeFromNib {
    // Initialization code
    self.imgMyJoinAction.layer.masksToBounds=YES;
    self.imgMyJoinAction.layer.cornerRadius =CGRectGetWidth(self.imgMyJoinAction.bounds)/2;//圆形
    self.imgMyJoinAction.contentMode=UIViewContentModeScaleAspectFill;
    //圆角
    self.btnCancelAction.layer.cornerRadius=5.0;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}


@end
