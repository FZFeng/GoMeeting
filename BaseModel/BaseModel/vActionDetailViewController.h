//
//  vActionDetailViewController.h
//  BaseModel
//
//  Created by apple on 15/10/20.
//  Copyright (c) 2015年 Fabius's Studio. All rights reserved.
//  Info:活动详细

#import <UIKit/UIKit.h>
#import "PublicFunc.h"
#import "FZTextField.h"
#import "SystemPlist.h"
#import "ClassAction.h"
#import "ClassActionJoinor.h"
#import "UIImage+UIImageScale.h"
#import "vActionImgBrowseViewController.h"
#import "vMainViewController.h"
#import "UIImageView+WebCache.h"

#import <CoreLocation/CoreLocation.h>
#import <MapKit/MapKit.h>

@interface vActionDetailViewController : UIViewController<UITableViewDataSource,UITableViewDelegate,UIScrollViewDelegate,CLLocationManagerDelegate>{
    UITableView *tbActionDetail;
    
    UIImageView *imgView;
    UIButton *btnJoinAction;
    
    NSInteger iViewW,iViewH,iImageHeight,iActionDetailHeight;
    BOOL bShowBtn;
    NSString *sAction;
    NSMutableArray *arryActionInfo;
    
    //选择联系手机模块
    UIView *viewAddContactPhone;
    UIView *viewAddContactPhoneInfo;
    FZTextField *fztxtContactPhone;
    UILabel *lblContactPhoneNote;
    UIButton *btnContactPhone;
    
    //处理地图
    CLLocationManager *myLocationManager;
    NSString *sActionPlace;
    //等待提示
    id showHUD;
    
}
//@property(nonatomic) BOOL bActionImageHasDownload;
//@property(nonatomic,strong)NSArray *arryActionImagePath;
@property(nonatomic,strong)ClassAction *cActionData;
@end
