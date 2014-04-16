//
//  SQLiteManager.m
//  SQLiteTest2
//
//  Created by 相澤 隆志 on 2014/04/16.
//  Copyright (c) 2014年 相澤 隆志. All rights reserved.
//

#import "SQLiteManager.h"
#import <sqlite3.h>

@interface SQLiteManager ()

@property  sqlite3* sqlite;
@property (nonatomic, strong) NSString* dbFileName;
@property (nonatomic, strong) NSString* dbFilePath;
@property (nonatomic, strong) NSString* tableName;
@property  sqlite3_stmt *statement;
@end

@implementation SQLiteManager

static SQLiteManager* gSQLiteManager;
+ (SQLiteManager*)sharedSQLiteManager
{
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        gSQLiteManager = [[SQLiteManager alloc] init];
        gSQLiteManager.dbFileName = @"testDB.aqlite3";
        [gSQLiteManager createDB:gSQLiteManager.dbFileName];
    });
    return gSQLiteManager;
}

- (BOOL)openDB
{
    BOOL result = sqlite3_open([_dbFilePath UTF8String], &_sqlite);
    if( result != SQLITE_OK )
    {
        NSLog(@"DB Open error : %s",sqlite3_errmsg(_sqlite));
    }
    return result;
}

// [
//      {"name":"nameString", "type:"TEXT"}
//      {"name":"nameString", "type:"integer"}
//      {"name":"nameString", "type:"double"}
//      {"name":"nameString", "type:"TEXT"}
//      {"name":"nameString", "type:"TEXT"}
// ]
- (BOOL)createTable:(NSString*)tableName  columns:(NSArray*)params
{
    BOOL result = YES;
    _tableName = tableName;
    NSMutableString* sql = [NSMutableString stringWithFormat:@"CREATE TABLE IF NOT EXISTS %@ (",tableName ];
    for( NSDictionary* param in params ){
        NSString* columnName = [param valueForKey:@"name"];
        NSString* type = [param valueForKey:@"type"];
        [sql appendFormat:@"%@ %@, ",columnName, type];
    }
    NSMutableString *str = [NSMutableString stringWithString:[sql substringToIndex:(sql.length-2)]];
    [str appendString:@");"];
    NSLog(@"sql = %@",str);
    int ret = sqlite3_prepare_v2(_sqlite, [str UTF8String], -1, &_statement, nil);
    if( ret != SQLITE_OK ){
        NSLog(@"sqlite3_prepare_v2 error");
        result = NO;
    }
    ret = sqlite3_step(_statement);
    if( ret  != SQLITE_OK ){
        NSLog(@"sqlite3_step error");
        result = NO;
    }
    ret = sqlite3_finalize(_statement);
    if( ret  != SQLITE_OK ){
        NSLog(@"sqlite3_finalize error");
        result = NO;
    }
    return result;
}

- (BOOL)insertObjectTestData:(NSDictionary*)param, ...
{
    va_list arguments;
    va_start(arguments, param);
    NSDictionary* column = param;
    NSMutableArray* array = [[NSMutableArray alloc] init];
    [array addObject:column];
    while ( column ) {
        column = va_arg(arguments, typeof(NSDictionary*));
        [array addObject:column];
    }
    va_end(arguments);

    NSMutableString* sql = [NSMutableString stringWithFormat:@"insert into %@ (",_tableName ];
    for( NSDictionary* param in array ){
        [sql appendFormat:@"%@ ,", [param valueForKey:@"name"]];
    }
    NSMutableString *str = [NSMutableString stringWithString:[sql substringToIndex:(sql.length-2)]];
    [str appendString:@") values ("];
    for( int i = 0; i < array.count; i ++ ){
        [str appendString:@"?,"];
    }
    NSMutableString* strSql =[NSMutableString stringWithString:[str substringToIndex:(str.length-1)]];
    [strSql appendString:@")"];
    NSLog(@"insert: sql = %@",strSql);
    
}

- (BOOL)createDB:(NSString*)dbfileName
{
    BOOL result = YES;
    _dbFilePath = [self getDocumentDirectoryFilepath:dbfileName];
    NSLog(@"DB file: %@",_dbFilePath);
    BOOL isDir;
    NSFileManager *fileManager = [NSFileManager defaultManager];
    BOOL fileExists = ([fileManager fileExistsAtPath:_dbFilePath isDirectory:&isDir] && !isDir);
    BOOL ret;
    if( fileExists == NO ){
        NSLog(@"File is not exist.");
        ret = [fileManager createFileAtPath:_dbFilePath contents:nil attributes:nil];
        if (!ret) {
            NSLog(@"createFileAtPath error File is not exist.");
            result = NO;
        }
    }else{
        NSLog(@"File is exist.");
    }
    return result;
}

- (NSString*)getDocumentDirectoryFilepath:(NSString*)fileName
{
    NSArray* paths = NSSearchPathForDirectoriesInDomains(
                                                         NSDocumentDirectory,
                                                         NSUserDomainMask,
                                                         YES);
    
    NSString* dbPath = paths[0];
    NSString* dbFilePath = [dbPath stringByAppendingPathComponent:fileName];
    return dbFilePath;
}

@end
