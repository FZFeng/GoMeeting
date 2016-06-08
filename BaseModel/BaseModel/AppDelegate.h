//
//  AppDelegate.h
//  BaseModel
//
//  Created by apple on 15/8/24.
//  Copyright (c) 2015年 Fabius's Studio. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MapKit/MapKit.h>
#import <CoreLocation/CoreLocation.h>
#import "SystemPlist.h"
#import "GeTuiSdk.h"
#import "OuterSDKManager.h"
#import "ClassAction.h"
#import "PublicFunc.h"

@interface AppDelegate : UIResponder <UIApplicationDelegate,UIAlertViewDelegate,GeTuiSdkDelegate>{
    GeTuiSdk *geTuiSDKObject;
    CLLocationManager *myLocationManager;
}

@property (strong, nonatomic) UIWindow *window;

@end

