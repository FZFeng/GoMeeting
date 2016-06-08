//
//  DYFViewController.h
//  FirstBmobApp
//
//  Created by apple on 14-9-4.
//  Copyright (c) 2014年 FABIUS. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "UzysAssetsPickerController_Configuration.h"
@class UzysAssetsPickerController;
@protocol UzysAssetsPickerControllerDelegate<NSObject>
- (void)UzysAssetsPickerController:(UzysAssetsPickerController *)picker didFinishPickingAssets:(NSArray *)assets;
@optional
- (void)UzysAssetsPickerControllerDidCancel:(UzysAssetsPickerController *)picker;
@end

@interface UzysAssetsPickerController : UIViewController{
    BOOL bHasLoad;
}
@property (nonatomic, strong) ALAssetsFilter *assetsFilter;
@property (nonatomic, assign) NSInteger maximumNumberOfSelectionVideo;
@property (nonatomic, assign) NSInteger maximumNumberOfSelectionPhoto;
//--------------------------------------------------------------------
@property (nonatomic, assign) NSInteger maximumNumberOfSelectionMedia;

@property (nonatomic, weak) id <UzysAssetsPickerControllerDelegate> delegate;
+ (ALAssetsLibrary *)defaultAssetsLibrary;

@end
