//
//  CSDNCategory.m
//  CSDN'sBlogExporter
//
//  Created by ZhangAo on 14-7-8.
//  Copyright (c) 2014年 ZA. All rights reserved.
//

#import "CSDNCategory.h"

@implementation CSDNCategory

-(NSString *)description{
    return [NSString stringWithFormat:@"URL String=%@\nname=%@",self.urlString,self.name];
}

@end
