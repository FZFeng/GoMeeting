//
//  tbCellActionJoinor.m
//  BaseModel
//
//  Created by apple on 15/11/16.
//  Copyright (c) 2015年 Fabius's Studio. All rights reserved.
//

#import "tbCellActionJoinor.h"

@implementation tbCellActionJoinor

- (void)awakeFromNib {
    // Initialization code
    
    self.imgJoinorHeadLogo.layer.masksToBounds=YES;
    self.imgJoinorHeadLogo.layer.cornerRadius =CGRectGetWidth(self.imgJoinorHeadLogo.bounds)/2;//圆形
    self.imgJoinorHeadLogo.contentMode=UIViewContentModeScaleAspectFill;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
