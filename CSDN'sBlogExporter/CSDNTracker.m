//
//  CSDNTracker.m
//  CSDN'sBlogExporter
//
//  Created by ZhangAo on 14-7-8.
//  Copyright (c) 2014年 ZA. All rights reserved.
//

#import "CSDNTracker.h"
#import "CSDNLoginSerializer.h"
#import "CSDNAllArticleSummarySerializer.h"
#import "CSDNArticleSerializer.h"

@interface CSDNTracker ()
@property (nonatomic, strong) AFHTTPRequestOperationManager *manager;
@property (nonatomic, copy) NSString *username;
@end

////////////////////////////////////////////////////////////////////////////////

@implementation CSDNBaseSerializer

-(NSString *)requestURLString{
    return nil;
}

-(AFHTTPResponseSerializer *)responseSerializer{
    [NSException raise:NSInternalInconsistencyException
                format:@"You must override %@ in a subclass!",NSStringFromSelector(_cmd)];
    return nil;
}

-(NSDictionary *)postParams{
    return nil;
}

-(NSArray *)requestURLStrings{
    return nil;
}

@end

////////////////////////////////////////////////////////////////////////////////

@implementation CSDNTracker

-(AFHTTPRequestOperationManager *)manager{
    if (_manager == nil) {
        _manager = [AFHTTPRequestOperationManager manager];
        _manager.requestSerializer.timeoutInterval = 30;
    }
    return _manager;
}

-(void)requestSuccess:(id)object isBatch:(BOOL)isBatch serializer:(CSDNBaseSerializer *)serializer{
    if ([serializer isKindOfClass:[CSDNLoginSerializer class]]) {
        if (self.delegate && [self.delegate respondsToSelector:@selector(loginSuccessful)]) {
            [self.delegate loginSuccessful];
        }
    } else if ([serializer isKindOfClass:[CSDNAllArticleSummarySerializer class]]) {
        if (self.delegate && [self.delegate respondsToSelector:@selector(onGetAllArticlesSummarySuccessful:)]) {
            [self.delegate onGetAllArticlesSummarySuccessful:object];
        }
    } else {
        if (self.delegate && [self.delegate
                              respondsToSelector:@selector(requestArticleSuccessful:batchIsCompleted:)]) {
            if (isBatch && object == nil) {
                [self.delegate requestArticleSuccessful:nil batchIsCompleted:YES];
                return;
            }
            [self.delegate requestArticleSuccessful:object batchIsCompleted:NO];
        }
    }
}

-(void)requestFailed:(NSError *)error{
    if (self.delegate && [self.delegate respondsToSelector:@selector(requestFailed:)]) {
        [self.delegate requestFailed:error];
    }
}

-(void)loginWithUsername:(NSString *)username password:(NSString *)password{
    CSDNLoginSerializer *loginSerializer = [CSDNLoginSerializer new];
    loginSerializer.username = username;
    loginSerializer.password = password;
    
    self.username = username;
    
    [self requestWithSerializer:loginSerializer];
}

-(void)requestAllArticlesSummary{
    CSDNAllArticleSummarySerializer *summarySerializer = [CSDNAllArticleSummarySerializer new];
    summarySerializer.username = self.username;
    [self requestWithSerializer:summarySerializer];
}

-(void)requestAllArticlesWithSummaries:(NSArray *)summaries{
    CSDNArticleSerializer *articleSerializer = [CSDNArticleSerializer new];
    articleSerializer.summaries = summaries;
    
    [self requestWithSerializer:articleSerializer];
}

-(void)requestWithSerializer:(CSDNBaseSerializer *)serializer{
    dispatch_async(dispatch_get_global_queue(0, 0), ^{
        NSString *requestURLString = serializer.requestURLString;
        [self.manager setResponseSerializer:serializer.responseSerializer];
        
        if (requestURLString != nil) {
            [self singleRequestByURLString:requestURLString serializer:serializer];
        } else {
            NSArray *batchRequestURLStrings = serializer.requestURLStrings;
            assert(batchRequestURLStrings);
            [self batchRequestByURLStrings:batchRequestURLStrings serializer:serializer];
        }
    });
}

-(void)singleRequestByURLString:(NSString *)requestURLString serializer:(CSDNBaseSerializer *)serializer{
    NSLog(@"请求的url：%@",requestURLString);
    NSDictionary *postParams = serializer.postParams;
    if (postParams == nil) {
        [self.manager GET:requestURLString
               parameters:nil
                  success:^(AFHTTPRequestOperation *operation, id responseObject) {
                      [self requestSuccess:responseObject isBatch:NO serializer:serializer];
                  } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
                      [self requestFailed:error];
                  }];
    } else {
        NSLog(@"params: %@",postParams);
        [self.manager POST:requestURLString
                parameters:postParams
                   success:^(AFHTTPRequestOperation *operation, id responseObject) {
                       [self requestSuccess:responseObject isBatch:NO serializer:serializer];
                   } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
                       [self requestFailed:error];
                   }];
    }
}

-(void)batchRequestByURLStrings:(NSArray *)URLStrings serializer:(CSDNBaseSerializer *)serializer{
    dispatch_group_t group = dispatch_group_create();
    int i = 0;
    for (NSString *urlString in URLStrings) {
        NSLog(@"请求的url：%@",urlString);
        dispatch_group_enter(group);
        double delayInSeconds = 1.0;
        dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, (int64_t)(delayInSeconds * i * NSEC_PER_SEC));
        dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
            NSURL *URL = [NSURL URLWithString:urlString];
            NSURLRequest *request = [NSURLRequest requestWithURL:URL];
            AFHTTPRequestOperation *operation = [[AFHTTPRequestOperation alloc] initWithRequest:request];
            operation.responseSerializer = self.manager.responseSerializer;
            [operation setCompletionBlockWithSuccess:^(AFHTTPRequestOperation *operation, id responseObject) {
                dispatch_group_leave(group);
                [self requestSuccess:responseObject isBatch:YES serializer:serializer];
            } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
                dispatch_group_leave(group);
                [self requestFailed:error];
            }];
            [operation start];
        });
        i++;
    }
    dispatch_group_notify(group, dispatch_get_main_queue(), ^{
        [self requestSuccess:nil isBatch:YES serializer:serializer];
    });
}

@end
