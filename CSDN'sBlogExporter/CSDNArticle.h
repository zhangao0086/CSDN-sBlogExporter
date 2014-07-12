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
    ArticleSourceTypeReprint = 2,
    ArticleSourceTypeTranslate = 4
}ArticleSourceType;

////////////////////////////////////////////////////////////

@interface CSDNArticle : NSObject

@property (nonatomic, copy) NSString *articleId;
@property (nonatomic, copy) NSString *articleTitle;
@property (nonatomic, copy) NSString *rawContent;
@property (nonatomic, copy) NSString *publishTime;
@property (nonatomic, copy) NSString *categories;
@property (nonatomic, copy) NSString *tags;
@property (nonatomic, assign) ArticleSourceType sourceType;

@end
