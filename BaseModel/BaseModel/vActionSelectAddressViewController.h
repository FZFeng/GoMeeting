//
//  vActionSelectAddressViewController.h
//  BaseModel
//
//  Created by apple on 15/9/18.
//  Copyright (c) 2015年 Fabius's Studio. All rights reserved.
//  Info:添加活动地址 引用高德地图AMapSearchKit.framework 搜索poi

#import <UIKit/UIKit.h>
#import <CoreLocation/CoreLocation.h>
#import <MapKit/MapKit.h>
#import <AMapSearchKit/AMapSearchKit.h>
#import "PublicClass/PublicFunc.h"
#import "tbCellActionSelectAddress.h"
#import "tbCellActionSelectAddressSearchBar.h"
#import "vActionAddNewViewController.h"

@interface vActionSelectAddressViewController : UIViewController<CLLocationManagerDelegate,UISearchBarDelegate,UITableViewDataSource,UITableViewDelegate,MKMapViewDelegate,AMapSearchDelegate,UITextFieldDelegate>{
    
    CLLocationManager *myLocationManager;
    
    NSMutableArray *arrySearchAddress;
    NSMutableArray *arryMapAddress;
    
    UISearchBar *mySearchBar;
    AMapSearchAPI *aMapSearch;
    
    UIView *viewBgWhenInSearchBar;//在用searchbar 搜索时的背景
    UITableView *tbSearchAddress;
    
    NSString *sLocationCity;//用于定位当前城市 方便poi 的关键字搜索
    
    CLLocationCoordinate2D centerLocationCoordinate;//中心坐标
    
    id iWaittingHUD;
    BOOL bUseSearchBar; //标记是否使用searchbar关键字搜索poi
    
    IBOutlet UIImageView *imgCenterPoint;
    IBOutlet UIView *viewMapInfo;
    IBOutlet MKMapView *mapAddress;
    IBOutlet UITableView *tbMapAddress;
    IBOutlet UINavigationItem *navItemSearchBar;
    
}

- (IBAction)btnBackToCenterPointClick:(id)sender;


@end
