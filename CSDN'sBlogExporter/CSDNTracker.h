//
//  CSDNTracker.h
//  CSDN'sBlogExporter
//
//  Created by ZhangAo on 14-7-8.
//  Copyright (c) 2014年 ZA. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "AFNetworking.h"

#define MessageInError(error)   ([error.userInfo objectForKey:@"errorMessage"])

typedef void(^RequestCompleteBlock)(NSError *error,id obj);
typedef void(^RequestBatchCompleteBlock)(NSError *error,id obj, BOOL batchIsCompleted);

////////////////////////////////////////////////////////////////////////////////

@interface CSDNTracker : NSObject

+(void)setUsername:(NSString *)username;
+(NSString *)username;

-(void)requestWithCompleteBlock:(RequestCompleteBlock)completeBlock;

-(void)requestBatchWithCompleteBlock:(RequestBatchCompleteBlock)completeBlock;

//Subclass
-(NSDictionary *)postParams;  //send request as GET if return nil;defaults to nil.
-(AFHTTPResponseSerializer *)responseSerializer;
-(NSString *)requestURLString;
-(NSArray *)requestBatchURLString;

@end
