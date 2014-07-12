//
//  CSDNAllArticleSummarySerializer.m
//  CSDN'sBlogExporter
//
//  Created by ZhangAo on 14-7-8.
//  Copyright (c) 2014年 ZA. All rights reserved.
//

#import "CSDNAllArticleSummarySerializer.h"
#import "CSDNArticle.h"

@interface CSDNSummariesResponseSerializer : AFHTTPResponseSerializer

@end

@implementation CSDNSummariesResponseSerializer

-(id)responseObjectForResponse:(NSURLResponse *)response data:(NSData *)data error:(NSError *__autoreleasing *)error{
    NSString *htmlString = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
    
    NSRegularExpression *pattern = [NSRegularExpression
                                    rx:@"list_view.*?link_title.*?href=\"(.*?)\">(.*?)</a>.*?link_postdate\">(.*?)</span>"
                                    options:NSRegularExpressionDotMatchesLineSeparators];
    NSArray *details = [htmlString matchesWithDetails:pattern];
    
    NSMutableArray *articles = [NSMutableArray arrayWithCapacity:details.count];
    for (RxMatch *match in details) {
        CSDNArticle *article = [CSDNArticle new];
        NSString *articleUrl = [match.groups[1] value];
        article.articleId = [articleUrl componentsSeparatedByString:@"/"].lastObject;
        article.articleTitle = [[match.groups[2] value] stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
        article.publishTime = [match.groups[3] value];
        [articles addObject:article];
    }
    return articles;
}

@end

////////////////////////////////////////////////////////////////////////////////////////////////

@implementation CSDNAllArticleSummarySerializer


-(AFHTTPResponseSerializer *)responseSerializer{
    return [CSDNSummariesResponseSerializer serializer];
}

-(NSString *)requestURLString{
    return [NSString stringWithFormat:@"http://blog.csdn.net/%@/article/list/9999?viewmode=contents",self.username];
}

@end
