//
//  DYFViewController.h
//  FirstBmobApp
//
//  Created by apple on 14-9-4.
//  Copyright (c) 2014年 FABIUS. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "UzysAssetsPickerController_Configuration.h"
@interface UzysGroupViewCell : UITableViewCell
@property (nonatomic, strong) ALAssetsGroup *assetsGroup;
- (void)applyData:(ALAssetsGroup *)assetsGroup;
@end
