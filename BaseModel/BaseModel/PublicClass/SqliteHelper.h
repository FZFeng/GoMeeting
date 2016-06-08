//
//  SqliteHelper.h
//  SqliteDemo
//
//  Created by apple on 15/11/3.
//  Copyright (c) 2015年 Fabius's Studio. All rights reserved.
//  Info sqlite管理类

#import <Foundation/Foundation.h>
#import <sqlite3.h>

typedef enum {
    sqliteErrDB=0, //数据库打开失败
    sqliteErrExist //表是否存在

} sqliteErr;

@interface SqliteHelper : NSObject

//执行无返回值的sql
+(BOOL)executeNonQuery:(NSString*)sSQL;

//执行返回值的sql
+(NSArray*)executeQuery:(NSString*)sSQL;

//pragma mark 表是否已存在数据库中
+(sqliteErr)existTb:(NSString*)sTbName;

//删除和数据库
+(BOOL)dropDB;

@end
