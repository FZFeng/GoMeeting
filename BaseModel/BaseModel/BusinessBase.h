//
//  cBusinessBase.h
//  BaseModel
//
//  Created by apple on 15/9/7.
//  Copyright (c) 2015年 Fabius's Studio. All rights reserved.
//  Info:业务操作的基类 定义公共的属性,方法 所以业务类都继承此类

#import <Foundation/Foundation.h>
#import "FZNetworkHelper.h"
#import "SystemPlist.h"
#import "SqliteHelper.h"

@interface BusinessBase : NSObject

//新建sqlite表
-(BOOL)createTable;

//插入数据
-(BOOL)insertData;

//修改数据
-(BOOL)updateData;

//删除数据
-(BOOL)deleteData;

//结果block
typedef void (^blockFunctionReturn)(BOOL bReturnBlock);

@end
