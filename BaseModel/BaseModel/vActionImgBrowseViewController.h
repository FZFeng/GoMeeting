//
//  vActionImgBrowseViewController.h
//  BaseModel
//
//  Created by apple on 15/10/30.
//  Copyright (c) 2015年 Fabius's Studio. All rights reserved.
//  Info:浏览图片

#import <UIKit/UIKit.h>
#import "UIImageView+WebCache.h"
@interface vActionImgBrowseViewController : UIViewController<UIScrollViewDelegate>{

    int iScrlW,iScrlH;
    BOOL bDidLayoutSubviews;
    IBOutlet UIScrollView *scrlImg;
    IBOutlet UIPageControl *pageImg;
}
@property(nonatomic) BOOL bActionImageHasDownload;
@property(nonatomic,strong)NSArray *arryActionImagePath;

@end
