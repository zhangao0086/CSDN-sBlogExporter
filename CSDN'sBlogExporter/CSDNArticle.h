//
//  CSDNArticle.h
//  CSDN'sBlogExporter
//
//  Created by ZhangAo on 14-7-9.
//  Copyright (c) 2014年 ZA. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef enum {
    ArticleSourceTypeOriginal = 1,
    ArticleSourceTypeReprint,
    ArticleSourceTypeTranslate
}ArticleSourceType;

////////////////////////////////////////////////////////////

@interface CSDNArticle : NSObject

@property (nonatomic, copy) NSString *articleTitle;
@property (nonatomic, copy) NSString *rawContent;
@property (nonatomic, copy) NSString *publishTime;
@property (nonatomic, copy) NSArray *categories;
@property (nonatomic, copy) NSArray *tags;
@property (nonatomic, assign) ArticleSourceType sourceType;

@end
