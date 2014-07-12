//
//  CSDNArticleSerializer.m
//  CSDN'sBlogExporter
//
//  Created by ZhangAo on 14-7-8.
//  Copyright (c) 2014年 ZA. All rights reserved.
//

#import "CSDNArticleSerializer.h"
#import "CSDNArticle.h"
#import "NSString+HTML.h"

@interface CSDNArticleResponseSerializer : AFHTTPResponseSerializer
@property (nonatomic, copy) NSArray *summaries;
@end

#define RxForDotMatches(pattern)                        [NSRegularExpression rx:pattern \
                                                        options:NSRegularExpressionDotMatchesLineSeparators]

@implementation CSDNArticleResponseSerializer

-(NSString *)rawContentByHtmlString:(NSString *)htmlString{
    RxMatch *match = [htmlString firstMatchWithDetails:RxForDotMatches(@"<textarea.*?>(.*?)</textarea>")];
    NSString *rawDecodedContent = [match.groups[1] value];
    return [rawDecodedContent stringByDecodingHTMLEntities];
}

-(NSString *)tagsByHtmlString:(NSString *)htmlString{
    RxMatch *match = [htmlString firstMatchWithDetails:RxForDotMatches(@"tag2:'(.*?)'")];
    return [[match.groups[1] value] stringByReplacingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
}

-(NSString *)categoriesByHtmlString:(NSString *)htmlString{
    RxMatch *match = [htmlString firstMatchWithDetails:RxForDotMatches(@"tags:'(.*?)'")];
    return [[match.groups[1] value] stringByReplacingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
}

-(int)sourceTypeByHtmlString:(NSString *)htmlString{
    RxMatch *match = [htmlString firstMatchWithDetails:RxForDotMatches(@"type:'(\\d)'")];
    return [[match.groups[1] value] intValue];
}

-(id)responseObjectForResponse:(NSURLResponse *)response data:(NSData *)data error:(NSError *__autoreleasing *)error{
    NSString *htmlString = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
    
    NSString *articleId = [response.URL.path componentsSeparatedByString:@"/"].lastObject;
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"articleId == %@",articleId];
    CSDNArticle *article = [self.summaries filteredArrayUsingPredicate:predicate].lastObject;
    
    if (htmlString != nil) {
        article.rawContent = [self rawContentByHtmlString:htmlString];
        
        NSString *jsonData = [htmlString firstMatch:RxForDotMatches(@"jsonData=\\{.*\\}")];
        article.tags = [self tagsByHtmlString:jsonData];
        article.categories = [self categoriesByHtmlString:jsonData];
        article.sourceType = [self sourceTypeByHtmlString:jsonData];
    }
    
    return article;
}

@end
////////////////////////////////////////////////////////////////////////////////////////////////

@implementation CSDNArticleSerializer

-(AFHTTPResponseSerializer *)responseSerializer{
    CSDNArticleResponseSerializer *responseSerializer = [CSDNArticleResponseSerializer serializer];
    responseSerializer.summaries = self.summaries;
    return responseSerializer;
}

-(NSArray *)requestURLStrings{
    NSMutableArray *urlStrings = [NSMutableArray arrayWithCapacity:self.summaries.count];
    for (CSDNArticle *summary in self.summaries) {
        [urlStrings addObject:[NSString stringWithFormat:@"http://write.blog.csdn.net/postedit/%@",summary.articleId]];
    }
    return urlStrings;
}

@end
