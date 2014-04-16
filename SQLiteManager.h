//
//  SQLiteManager.h
//  SQLiteTest2
//
//  Created by 相澤 隆志 on 2014/04/16.
//  Copyright (c) 2014年 相澤 隆志. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface SQLiteManager : NSObject

+ (SQLiteManager*)sharedSQLiteManager;
- (BOOL)createDB:(NSString*)dbfileName;

@end
