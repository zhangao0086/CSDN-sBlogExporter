//
//  CSDNLoginSerializer.m
//  CSDN'sBlogExporter
//
//  Created by ZhangAo on 14-7-9.
//  Copyright (c) 2014年 ZA. All rights reserved.
//

#import "CSDNLoginSerializer.h"

@implementation CSDNLoginSerializer

-(NSString *)errorMessageByHtmlString:(NSString *)htmlString{
    RxMatch *match = [htmlString firstMatchWithDetails:RX(@"error-message\">(.*?)<")];
    if (match.value == nil) {
        return nil;
    }
    return [match.groups[1] value];
}

-(id)responseObjectForResponse:(NSURLResponse *)response data:(NSData *)data error:(NSError *__autoreleasing *)error{
    NSString *htmlString = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];

    NSString *errorMessage = [self errorMessageByHtmlString:htmlString];
    if ([errorMessage isEqualToString:@""]) {
        return htmlString;
    } else {
        *error = [NSError errorWithDomain:@"CSDN" code:999 userInfo:@{@"errorMessage": errorMessage}];
        return nil;
    }
}

@end
