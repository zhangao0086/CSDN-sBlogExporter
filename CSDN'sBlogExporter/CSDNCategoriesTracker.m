//
//  CSDNCategoriesTracker.m
//  CSDN'sBlogExporter
//
//  Created by ZhangAo on 14-7-8.
//  Copyright (c) 2014年 ZA. All rights reserved.
//

#import "CSDNCategoriesTracker.h"
#import "CSDNCategorySerializer.h"

@implementation CSDNCategoriesTracker

-(void)requestWithCompleteBlock:(RequestCompleteBlock)completeBlock{
    [super requestWithCompleteBlock:completeBlock];
}

-(AFHTTPResponseSerializer *)responseSerializer{
    return [CSDNCategorySerializer serializer];
}

-(NSString *)requestURLString{
    assert(self.username);
    return [NSString stringWithFormat:@"http://blog.csdn.net/%@",self.username];
}

@end
