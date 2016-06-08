//
//  DYFViewController.h
//  FirstBmobApp
//
//  Created by apple on 14-9-4.
//  Copyright (c) 2014年 FABIUS. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "UzysAssetsPickerController_Configuration.h"
@interface UzysGroupPickerView : UIView<UITableViewDataSource,UITableViewDelegate,UIGestureRecognizerDelegate>
@property (nonatomic,strong) UITableView *tableView;
@property (nonatomic, strong) NSMutableArray *groups;
@property (nonatomic,strong) UITapGestureRecognizer *tapGestureRecognizer;
@property (nonatomic,copy) intBlock blockTouchCell;
@property (nonatomic,assign) BOOL isOpen;
- (id)initWithGroups:(NSMutableArray *)groups;

- (void)show;
- (void)dismiss:(BOOL)animated;
- (void)toggle;
- (void)reloadData;
@end
