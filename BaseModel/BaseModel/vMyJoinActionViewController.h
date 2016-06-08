//
//  vMyJoinActionViewController.h
//  BaseModel
//
//  Created by apple on 15/11/12.
//  Copyright (c) 2015年 Fabius's Studio. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "tbCellMyJoinAction.h"
#import "ClassActionJoinor.h"
#import "SystemPlist.h"
#import "UIImageView+WebCache.h"

@interface vMyJoinActionViewController : UIViewController<UITableViewDataSource,UITableViewDelegate>{

    IBOutlet UITableView *tbMyJoinAction;
    IBOutlet NSLayoutConstraint *tbLayoutBottom;
    IBOutlet UISegmentedControl *segmentJoinActionType;
    
    NSArray *arryMyJoinActionData;
    float fRowDataH,itbViewH;
    ClassActionJoinor *cActionJoinorObject;

    
    BOOL bDidLayoutSubviews;
    int iJoinActionTypeDataEnum;//活动类型枚举
}

@end
