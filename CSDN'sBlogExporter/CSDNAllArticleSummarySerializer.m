//
//  CSDNAllArticleSummarySerializer.m
//  CSDN'sBlogExporter
//
//  Created by ZhangAo on 14-7-8.
//  Copyright (c) 2014年 ZA. All rights reserved.
//

#import "CSDNAllArticleSummarySerializer.h"
#import "CSDNArticleSummary.h"

@implementation CSDNAllArticleSummarySerializer

-(id)responseObjectForResponse:(NSURLResponse *)response data:(NSData *)data error:(NSError *__autoreleasing *)error{
    NSString *htmlString = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
    
    NSRegularExpression *pattern = [NSRegularExpression rx:@"<span class=\"link_title\"><a href=\"(.*?)\">(.*?)</a></span>"
                                                   options:NSRegularExpressionDotMatchesLineSeparators];
    NSArray *details = [htmlString matchesWithDetails:pattern];
    
    NSMutableArray *summarys = [NSMutableArray arrayWithCapacity:details.count];
    for (RxMatch *match in details) {
        CSDNArticleSummary *summary = [CSDNArticleSummary new];
        NSString *articleUrl = [match.groups[1] value];
        summary.articleId = [articleUrl componentsSeparatedByString:@"/"].lastObject;
        summary.articleTitle = [[match.groups[2] value] stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
        [summarys addObject:summary];
    }
    return summarys;
}

@end
