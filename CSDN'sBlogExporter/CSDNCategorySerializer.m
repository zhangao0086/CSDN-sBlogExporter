//
//  CSDNCategorySerializer.m
//  CSDN'sBlogExporter
//
//  Created by ZhangAo on 14-7-8.
//  Copyright (c) 2014年 ZA. All rights reserved.
//

#import "CSDNCategorySerializer.h"
#import "CSDNCategory.h"

@implementation CSDNCategorySerializer

-(id)responseObjectForResponse:(NSURLResponse *)response data:(NSData *)data error:(NSError *__autoreleasing *)error{
    NSString *htmlString = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
    NSRegularExpression *pattern = [NSRegularExpression rx:@"文章分类.*?<li>.*?</div>"
                                                   options:NSRegularExpressionDotMatchesLineSeparators];
    NSString *divMatch = [htmlString firstMatch:pattern];
    NSArray *matchs = [divMatch matches:RX(@"<a.*?</a>")];
    
    NSMutableArray *categories = [NSMutableArray arrayWithCapacity:matchs.count];
    for (NSString *aLinkString in matchs) {
        CSDNCategory *category = [CSDNCategory new];
        
        RxMatch *nameMatch = [aLinkString firstMatchWithDetails:RX(@"<a.*?>(.*?)</a>")];
        category.name = [nameMatch.groups[1] value];
        
        RxMatch *urlMatch = [aLinkString firstMatchWithDetails:RX(@"href=\"(.*?)\"")];
        category.urlString = [urlMatch.groups[1] value];
        [categories addObject:category];
    }
    return categories;
}

@end
