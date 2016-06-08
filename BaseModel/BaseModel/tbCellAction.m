//
//  tbCellAction.m
//  BaseModel
//
//  Created by apple on 15/10/19.
//  Copyright (c) 2015年 Fabius's Studio. All rights reserved.
//

#import "tbCellAction.h"

@implementation tbCellAction

- (void)awakeFromNib {
    // Initialization code
    self.imgMain.layer.masksToBounds=YES;
    self.imgMain.layer.cornerRadius =CGRectGetWidth(self.imgMain.bounds)/2;//圆形
    self.imgMain.contentMode=UIViewContentModeScaleAspectFill;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
