//
//  CSDNArticleTracker.m
//  CSDN'sBlogExporter
//
//  Created by ZhangAo on 14-7-8.
//  Copyright (c) 2014年 ZA. All rights reserved.
//

#import "CSDNArticleTracker.h"
#import "CSDNArticleSummary.h"
#import "CSDNArticleSerializer.h"

@interface CSDNArticleTracker ()
@property (nonatomic, copy) NSArray *summarys;
@end

/////////////////////////////////////////////////////////////////

@implementation CSDNArticleTracker

- (id)initWithSummarys:(NSArray *)summarys
{
    self = [super init];
    if (self) {
        self.summarys = summarys;
    }
    return self;
}

-(AFHTTPResponseSerializer *)responseSerializer{
    return [CSDNArticleSerializer serializer];
}

-(NSArray *)requestBatchURLString{
    NSMutableArray *urlStrings = [NSMutableArray arrayWithCapacity:self.summarys.count];
    for (CSDNArticleSummary *summary in self.summarys) {
        [urlStrings addObject:[NSString stringWithFormat:@"http://write.blog.csdn.net/postedit/%@",summary.articleId]];
    }
    return urlStrings;
}

@end
