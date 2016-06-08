//
//  UIImage+UIImageScale.h
//  BaseModel
//
//  Created by apple on 15/10/27.
//  Copyright (c) 2015年 Fabius's Studio. All rights reserved.
//

#import <UIKit/UIKit.h>


@interface UIImage (UIImageScale)

-(UIImage*)getSubImage:(CGRect)rect;
-(UIImage*)scaleToSize:(CGSize)size;

-(UIImage*)compressToSize:(CGSize)size;

@end
