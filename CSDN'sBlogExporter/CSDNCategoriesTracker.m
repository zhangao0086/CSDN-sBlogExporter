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

-(AFHTTPResponseSerializer *)responseSerializer{
    return [CSDNCategorySerializer serializer];
}

//-(NSString *)requestURLString{
//    assert([CSDNTracker username]);
//    return [NSString stringWithFormat:@"http://blog.csdn.net/%@",[CSDNTracker username]];
//}

@end
