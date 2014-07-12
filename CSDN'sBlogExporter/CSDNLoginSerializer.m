//
//  CSDNLoginSerializer.m
//  CSDN'sBlogExporter
//
//  Created by ZhangAo on 14-7-9.
//  Copyright (c) 2014年 ZA. All rights reserved.
//

#import "CSDNLoginSerializer.h"

@interface CSDNLoginResponseSerializer : AFHTTPResponseSerializer

@end

@implementation CSDNLoginResponseSerializer

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
    if (errorMessage == nil) {
        return htmlString;
    } else {
        *error = [NSError errorWithDomain:@"CSDN" code:999 userInfo:@{@"errorMessage": errorMessage}];
        return nil;
    }
}

@end

////////////////////////////////////////////////////////////////////////////////////////////////

@implementation CSDNLoginSerializer

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
    return [CSDNLoginResponseSerializer serializer];
}

-(NSString *)requestURLString{
    return @"https://passport.csdn.net/account/login";
}

@end
