//
//  vMyActionViewController.h
//  BaseModel
//
//  Created by apple on 15/11/10.
//  Copyright (c) 2015年 Fabius's Studio. All rights reserved.
//  Info:我的活动

#import <UIKit/UIKit.h>
#import "SystemPlist.h"
#import "ClassAction.h"
#import "tbCellMyAction.h"
#import "vActionJoinorViewController.h"

@interface vMyActionViewController : UIViewController<UITableViewDataSource,UITableViewDelegate,UIAlertViewDelegate>{

    IBOutlet UISegmentedControl *segmentActionType;
    IBOutlet UITableView *tbMyAction;
    IBOutlet NSLayoutConstraint *tbLayoutBottom;
    
    float fRowDataH,itbViewH;
    ClassAction *cActionObject;
    int iActionTypeDataEnum;//活动类型枚举
    NSArray *arryMyAcctionData;
    BOOL bDidLayoutSubviews;
}

@end
