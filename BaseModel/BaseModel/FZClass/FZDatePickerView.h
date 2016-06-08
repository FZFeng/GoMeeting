//
//  FZDatePickerView.h
//  BaseModel
//
//  Created by apple on 15/10/9.
//  Copyright (c) 2015年 Fabius's Studio. All rights reserved.
//  Info:选择日期view

#import <UIKit/UIKit.h>

@protocol FZDatePickerViewDelegate

-(void)FZDatePickerViewDelegateReturnDate:(NSString*)psReturnDate;

@end

@interface FZDatePickerView : UIView{

    UIDatePicker *datePicker;
    UIView *referView;//将要显示在该视图上
    UIView *mainContentView;
}
@property(nonatomic,strong) id<FZDatePickerViewDelegate> delegate;

//初始化
- (id)initWithReferView:(UIView *)ReferView;
- (void)show;

@end
