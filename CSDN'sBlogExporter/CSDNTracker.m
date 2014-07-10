//
//  CSDNTracker.m
//  CSDN'sBlogExporter
//
//  Created by ZhangAo on 14-7-8.
//  Copyright (c) 2014年 ZA. All rights reserved.
//

#import "CSDNTracker.h"

@interface CSDNTracker ()
@property (nonatomic, strong) AFHTTPRequestOperationManager *manager;
@end

////////////////////////////////////////////////////////////////////////////////

static NSString *username = nil;

@implementation CSDNTracker

+(void)setUsername:(NSString *)_username{
    assert(_username);
    username = _username;
}

+(NSString *)username{
    assert(username);
    return username;
}

-(AFHTTPRequestOperationManager *)manager{
    if (_manager == nil) {
        _manager = [AFHTTPRequestOperationManager manager];
    }
    return _manager;
}

-(void)requestWithCompleteBlock:(RequestCompleteBlock)completeBlock{
    dispatch_async(dispatch_get_global_queue(0, 0), ^{
        NSString *requestURLString = self.requestURLString;
        assert(requestURLString);
        NSLog(@"请求的url：%@",requestURLString);
        
        [self.manager setResponseSerializer:self.responseSerializer];
        NSDictionary *postParams = self.postParams;
        
        if (postParams == nil) {
            [self.manager GET:requestURLString
                   parameters:nil
                      success:^(AFHTTPRequestOperation *operation, id responseObject) {
                          if (completeBlock) {
                              dispatch_async(dispatch_get_main_queue(), ^{
                                  completeBlock(nil,responseObject);
                              });
                          }
                      }
                      failure:^(AFHTTPRequestOperation *operation, NSError *error) {
                          if (completeBlock) {
                              dispatch_async(dispatch_get_main_queue(), ^{
                                  completeBlock(error,nil);
                              });
                          }
                      }];
        } else {
            NSLog(@"params: %@",postParams);
            [self.manager POST:requestURLString
                    parameters:postParams
                       success:^(AFHTTPRequestOperation *operation, id responseObject) {
                           if (completeBlock) {
                               dispatch_async(dispatch_get_main_queue(), ^{
                                   completeBlock(nil,responseObject);
                               });
                           }
                       } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
                           if (completeBlock) {
                               dispatch_async(dispatch_get_main_queue(), ^{
                                   completeBlock(error,nil);
                               });
                           }
                       }];
        }        
    });
}

-(void)requestBatchWithCompleteBlock:(RequestBatchCompleteBlock)completeBlock{
    NSArray *urlStrings = [self requestBatchURLString];
    assert(urlStrings);
    dispatch_group_t group = dispatch_group_create();
    for (NSString *urlString in urlStrings) {
        dispatch_group_enter(group);
        
        NSURL *URL = [NSURL URLWithString:urlString];
        NSURLRequest *request = [NSURLRequest requestWithURL:URL];
        AFHTTPRequestOperation *operation = [[AFHTTPRequestOperation alloc] initWithRequest:request];
        operation.responseSerializer = self.responseSerializer;
        [operation setCompletionBlockWithSuccess:^(AFHTTPRequestOperation *operation, id responseObject) {
            dispatch_group_leave(group);
            if (completeBlock) {
                completeBlock(nil,responseObject,NO);
            }
        } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
            dispatch_group_leave(group);
            if (completeBlock) {
                completeBlock(error,nil,NO);
            }
        }];
        [operation start];
    }
    dispatch_group_notify(group, dispatch_get_main_queue(), ^{
        if (completeBlock) {
            completeBlock(nil,nil,YES);
        }
    });
}

-(NSDictionary *)postParams{
    return nil;
}

-(AFHTTPResponseSerializer *)responseSerializer{
    [NSException raise:NSInternalInconsistencyException
                format:@"You must override %@ in a subclass!",NSStringFromSelector(_cmd)];
    return nil;
}

-(NSString *)requestURLString{
    return nil;
}

-(NSArray *)requestBatchURLString{
    return nil;
}

- (void)dealloc
{
    NSLog(@"%@ is deallocated",NSStringFromClass(self.class));
}

@end
