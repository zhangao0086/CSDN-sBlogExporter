//
//  CSDNLoginSerializer.h
//  CSDN'sBlogExporter
//
//  Created by ZhangAo on 14-7-9.
//  Copyright (c) 2014年 ZA. All rights reserved.
//

#import "CSDNTracker.h"

@interface CSDNLoginSerializer : CSDNBaseSerializer

@property (nonatomic, copy) NSString *username;
@property (nonatomic, copy) NSString *password;

@end
