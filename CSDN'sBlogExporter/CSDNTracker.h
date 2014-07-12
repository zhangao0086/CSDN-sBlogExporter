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

@protocol CSDNTrackerDelegate <NSObject>
//登录成功
-(void)loginSuccessful;

//获取文章摘要成功
-(void)onGetAllArticlesSummarySuccessful:(NSArray *)articlesSummary;

//获取每一篇文章
-(void)requestArticleSuccessful:(id)object batchIsCompleted:(BOOL)batchIsCompleted;

-(void)requestFailed:(NSError *)error;

@end

////////////////////////////////////////////////////////////////////////////////

@interface CSDNBaseSerializer : NSObject

-(AFHTTPResponseSerializer *)responseSerializer;

-(NSDictionary *)postParams;  //send request as GET if return nil;defaults to nil.

-(NSString *)requestURLString;
-(NSArray *)requestURLStrings;

@end

////////////////////////////////////////////////////////////////////////////////

@interface CSDNTracker : NSObject

@property (nonatomic, assign) id<CSDNTrackerDelegate> delegate;

-(void)loginWithUsername:(NSString *)username password:(NSString *)password;

-(void)requestAllArticlesSummary;

-(void)requestAllArticlesWithSummaries:(NSArray *)summary;

@end
