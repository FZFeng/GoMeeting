//
//  vActionJoinorViewController.h
//  BaseModel
//
//  Created by apple on 15/11/16.
//  Copyright (c) 2015年 Fabius's Studio. All rights reserved.
//  Info:活动参与者

#import <UIKit/UIKit.h>
#import "tbCellActionJoinor.h"

@interface vActionJoinorViewController : UIViewController<UITableViewDelegate,UITableViewDataSource>{

    IBOutlet UITableView *tbActionJoinor;
    
    IBOutlet NSLayoutConstraint *tbLayoutBottom;
    
    NSArray *arryActionJoinor;
    float fRowDataH;
    BOOL bDidLayoutSubviews;
}

@end
