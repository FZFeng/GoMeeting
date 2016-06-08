//
//  SqliteHelper.m
//  SqliteDemo
//
//  Created by apple on 15/11/3.
//  Copyright (c) 2015年 Fabius's Studio. All rights reserved.
//

#import "SqliteHelper.h"

#define sDbName @"myDbBase.db"

@implementation SqliteHelper

+(SqliteHelper*)shared{
    static dispatch_once_t once = 0;
    static SqliteHelper *sqliteHelperObj;
    dispatch_once(&once, ^{ sqliteHelperObj = [[SqliteHelper alloc] init]; });
    return sqliteHelperObj;
}

#pragma mark 打开数据库(文件存在打开,否则创建新的并打开)并返回数据库对象
-(sqlite3*)openDB{

    //要返回的数据库对象
    sqlite3 *dbBase;
    
    //数据库文件路径
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentsDirectory = [paths objectAtIndex:0];
    NSString *fileName=[documentsDirectory stringByAppendingPathComponent:sDbName];
    
    if (sqlite3_open([fileName UTF8String], &dbBase)==SQLITE_OK) {
        return dbBase;
    }else{
        //关闭
        sqlite3_close(dbBase);
        return nil;
    }
}

#pragma mark 执行无返回值的sql
+(BOOL)executeNonQuery:(NSString*)sSQL{

    BOOL bReturn;
    //打开数据库并得到数据库对象
    
    sqlite3 *dbBase=[[SqliteHelper shared] openDB];
    if (!dbBase) {
        return NO;
    }
    
    char *sErr;
    if (sqlite3_exec(dbBase, [sSQL UTF8String], nil, nil, &sErr)==SQLITE_OK) {
        bReturn=YES;
    }else{
        NSLog(@"%s",sErr);
        bReturn=NO;
    }
    
    return bReturn;
}

#pragma mark 执行返回值的sql
+(NSArray*)executeQuery:(NSString*)sSQL{
    //要返回的结果集
    NSMutableArray *arryRows=[[NSMutableArray alloc] init];
    
    //打开数据库并得到数据库对象
    sqlite3 *dbBase=[[SqliteHelper shared] openDB];
    if (!dbBase) {
        return nil;
    }
    
    //检查sql语法
    sqlite3_stmt *stmt;
    if (sqlite3_prepare_v2(dbBase, [sSQL UTF8String], -1, &stmt, nil)==SQLITE_OK) {
        //循环获得数据
        while (sqlite3_step(stmt)==SQLITE_ROW) {
            
            //NSMutableArray *arryCurRow=[[NSMutableArray alloc] init];
            int columnCount= sqlite3_column_count(stmt);
            NSMutableDictionary *dic=[NSMutableDictionary dictionary];
            
            
            for (int i=0; i<columnCount; i++) {
                const char *name= sqlite3_column_name(stmt, i);//取得列名
                const unsigned char *value= sqlite3_column_text(stmt, i);//取得某列的值
                if (value) {
                     dic[[NSString stringWithUTF8String:name]]=[NSString stringWithUTF8String:(const char *)value];
                }
            }
            if (dic.count>0) {
                [arryRows addObject:dic];
            }else{
                arryRows=nil;
            }
            
        }
    }else{
        arryRows=nil;
    }
    
    if (arryRows.count==0) arryRows=nil;
    
    //释放句柄
    sqlite3_finalize(stmt);
    return arryRows;
}

#pragma mark 删除和数据库
+(BOOL)dropDB{
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentsDirectory = [paths objectAtIndex:0];
    NSString *fileName=[documentsDirectory stringByAppendingPathComponent:sDbName];
    
    NSFileManager *fileManager = [NSFileManager defaultManager];
    NSError *err;
    BOOL bReturn;
    bReturn=[fileManager removeItemAtPath:fileName error:&err];
    return bReturn;
}

#pragma mark 表是否已存在数据库中
+(sqliteErr)existTb:(NSString*)sTbName{
    
    BOOL bReturn;
    
    NSString *sSQL=[NSString stringWithFormat:@"SELECT COUNT(1) AS iCount FROM sqlite_master where tbl_name='%@'",sTbName];
   
    //打开数据库并得到数据库对象
    sqlite3 *dbBase=[[SqliteHelper shared] openDB];
    if (!dbBase) {
        return sqliteErrDB;
    }
    
    //检查sql语法
    sqlite3_stmt *stmt;
    if (sqlite3_prepare_v2(dbBase, [sSQL UTF8String], -1, &stmt, nil)==SQLITE_OK) {
        bReturn=YES;
    }else{
       bReturn=sqliteErrExist;
    }
    
    //释放句柄
    sqlite3_finalize(stmt);
    return bReturn;
}

@end
