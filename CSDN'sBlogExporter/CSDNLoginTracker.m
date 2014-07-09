//
//  CSDNLoginTracker.m
//  CSDN'sBlogExporter
//
//  Created by ZhangAo on 14-7-9.
//  Copyright (c) 2014年 ZA. All rights reserved.
//

#import "CSDNLoginTracker.h"
#import "CSDNLoginSerializer.h"

@implementation CSDNLoginTracker

-(NSString *)ltTokenByHtmlString:(NSString *)htmlString{
    RxMatch *match = [htmlString firstMatchWithDetails:RX(@"\"lt\" value=\"(.*?)\"")];
    NSString *value = [match.groups[1] value];
    return value;
}

-(NSString *)executionByHtmlString:(NSString *)htmlString{
    RxMatch *match = [htmlString firstMatchWithDetails:RX(@"\"execution\" value=\"(.*?)\"")];
    NSString *value = [match.groups[1] value];
    return value;
}

-(NSDictionary *)postParams{
    NSURLRequest *request = [NSURLRequest requestWithURL:[NSURL URLWithString:self.requestURLString]];
    NSData *data = [NSURLConnection sendSynchronousRequest:request
                          returningResponse:NULL
                                      error:NULL];
    NSString *htmlString = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
    return @{
             @"username": self.username,
             @"password": self.password,
             @"lt": [self ltTokenByHtmlString:htmlString],
             @"execution": [self executionByHtmlString:htmlString],
             @"_eventId": @"submit",
             };
}

-(AFHTTPResponseSerializer *)responseSerializer{
    return [CSDNLoginSerializer serializer];
}

-(NSString *)requestURLString{
    return @"https://passport.csdn.net/account/login";
}

@end
