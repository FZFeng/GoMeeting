//
//  UIImage+UIImageScale.m
//  BaseModel
//
//  Created by apple on 15/10/27.
//  Copyright (c) 2015年 Fabius's Studio. All rights reserved.
//

#import "UIImage+UIImageScale.h"
#define sScale @"1.6"

@implementation UIImage (UIImageScale)

//截取部分图像
-(UIImage*)getSubImage:(CGRect)rect
{

    int iW,iH;
    iW=self.size.width;
    iH=self.size.height;
    
    NSString *sImageViewScale=[NSString stringWithFormat:@"%1.1f",iW*1.0/iH*1.0];

    if ([sImageViewScale isEqualToString:sScale]) {
        return self;
    }
    
    CGImageRef subImageRef = CGImageCreateWithImageInRect(self.CGImage, rect);
    CGRect smallBounds = CGRectMake(0, 0, CGImageGetWidth(subImageRef), CGImageGetHeight(subImageRef));
    
    UIGraphicsBeginImageContext(smallBounds.size);
    CGContextRef context = UIGraphicsGetCurrentContext();
    CGContextDrawImage(context, smallBounds, subImageRef);
    UIImage* smallImage = [UIImage imageWithCGImage:subImageRef];
    UIGraphicsEndImageContext();
    
    return smallImage;
}

//等比例缩放
-(UIImage*)scaleToSize:(CGSize)size
{
    CGFloat width = CGImageGetWidth(self.CGImage);
    CGFloat height = CGImageGetHeight(self.CGImage);
    
    float verticalRadio = size.height*1.0/height;
    float horizontalRadio = size.width*1.0/width;
    
    float radio = 1;
    if(verticalRadio>1 && horizontalRadio>1)
    {
        radio = verticalRadio > horizontalRadio ? horizontalRadio : verticalRadio;
    }
    else
    {
        radio = verticalRadio < horizontalRadio ? verticalRadio : horizontalRadio;
    }
    
    width = width*radio;
    height = height*radio;
    
    int xPos = (size.width - width)/2;
    int yPos = (size.height-height)/2;
    
    // 创建一个bitmap的context
    // 并把它设置成为当前正在使用的context
    UIGraphicsBeginImageContext(size);
    
    // 绘制改变大小的图片
    [self drawInRect:CGRectMake(xPos, yPos, width, height)];
    
    // 从当前context中创建一个改变大小后的图片
    UIImage* scaledImage = UIGraphicsGetImageFromCurrentImageContext();
    
    // 使当前的context出堆栈
    UIGraphicsEndImageContext();
    
    // 返回新的改变大小后的图片
    return scaledImage;
}

-(UIImage*)compressToSize:(CGSize)size;
{
    float imageWidth = CGImageGetWidth(self.CGImage);
    float imageHeight = CGImageGetHeight(self.CGImage);
    
    int iY=0,iX = 0;
    
    float widthScale = imageWidth /size.width;
    float heightScale = imageHeight /size.height;
    
    CGFloat imgRatio = imageHeight/imageWidth;
    CGFloat imgViewRatio = size.height/size.width;
    
    if(imgRatio > imgViewRatio){ //截上下，宽一致
        iX=0;
        iY = imageHeight - size.height;
    }else if (imgRatio < imgViewRatio)
        //截左右，高一致
    {
        iX =imageWidth - size.width;
        iY =  0;
    }else
    {
        //得到的图片的长宽比与iamgeView的长宽比一致，不用裁剪
        return self;
    }
    
    
    // 创建一个bitmap的context
    // 并把它设置成为当前正在使用的context
    UIGraphicsBeginImageContext(CGSizeMake(size.width, size.height));
    
    if (widthScale > heightScale) {
        [self drawInRect:CGRectMake(iX, iY, imageWidth /heightScale , size.height)];
    }
    else {
        [self drawInRect:CGRectMake(iX, iY, size.width , imageHeight /widthScale)];
    }
    
    // 从当前context中创建一个改变大小后的图片
    UIImage *newImage = UIGraphicsGetImageFromCurrentImageContext();
    
    // 使当前的context出堆栈
    UIGraphicsEndImageContext();
    
    return newImage;
    
}

@end
