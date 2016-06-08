//
//  vMainViewController.h
//  BaseModel
//
//  Created by apple on 15/9/2.
//  Copyright (c) 2015年 Fabius's Studio. All rights reserved.
//  Info:主窗体

#import <UIKit/UIKit.h>
#import "SystemPlist.h"
#import "FZRefreshTableView.h"
#import "tbCellAction.h"
#import "tbCellAd.h"
#import "ClassAction.h"
#import "vActionDetailViewController.h"
#import "vReceRemoteNotificationViewController.h"

@interface vMainViewController : UIViewController<
UITableViewDelegate,
UITableViewDataSource,
FZRefreshTableViewDelegate,
UIScrollViewDelegate,
UINavigationControllerDelegate,
FZScrollAdViewDelegate>{
@public
    IBOutlet FZRefreshTableView *fztbAction;
    
@private
    BOOL _bHasLoad;
    BOOL _bInitData;
    ClassAction *_cActionObject;
    
    NSMutableArray *arryTableData;
    NSMutableArray *arryAdTableData;
    
    // 上,下拉时显示的数据
    NSMutableArray *arryMoreData;
    
    float fTbCellAdHeight;//广告cell的高度
    NSInteger iCurRowIndex;//记录当前数据row号
}
#pragma mark 事件

- (IBAction)barBtnItemUserClick:(id)sender;
- (IBAction)barBtnItemAddNewClick:(id)sender;

@end
