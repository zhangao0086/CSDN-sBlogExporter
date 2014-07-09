//
//  CSDNAllArticleSummaryTracker.m
//  CSDN'sBlogExporter
//
//  Created by ZhangAo on 14-7-8.
//  Copyright (c) 2014年 ZA. All rights reserved.
//

#import "CSDNAllArticleSummaryTracker.h"
#import "CSDNAllArticleSummarySerializer.h"

@implementation CSDNAllArticleSummaryTracker

-(AFHTTPResponseSerializer *)responseSerializer{
    return [CSDNAllArticleSummarySerializer serializer];
}

-(NSString *)requestURLString{
    assert(self.username);
    return [NSString stringWithFormat:@"http://blog.csdn.net/%@/article/list/9999?viewmode=contents",self.username];
}

@end
