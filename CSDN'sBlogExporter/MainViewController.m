//
//  MainViewController.m
//  CSDN'sBlogExporter
//
//  Created by ZhangAo on 14-7-9.
//  Copyright (c) 2014年 ZA. All rights reserved.
//

#import "MainViewController.h"
#import "CSDNArticle.h"
#import "SpinnerView.h"

#import "CSDNTracker.h"

@interface MainViewController () <NSUserNotificationCenterDelegate,CSDNTrackerDelegate>

@property (nonatomic, assign) IBOutlet NSTextView *descriptionTextView;
@property (nonatomic, weak) IBOutlet NSProgressIndicator *indicator;
@property (nonatomic, weak) IBOutlet NSButton *loginButton;
@property (nonatomic, weak) IBOutlet NSButton *exportButton;
@property (nonatomic, weak) IBOutlet NSButton *yamlButton;

@property (nonatomic, strong) IBOutlet NSWindow *loginSheets;
@property (nonatomic, weak) IBOutlet NSTextField *username;
@property (nonatomic, weak) IBOutlet NSTextField *password;

@property (nonatomic, copy) NSString *exportDirectoryUrl;
@property (nonatomic, strong) SpinnerView *spinnerView;

@property (nonatomic, strong) CSDNTracker *tracker;
@property (nonatomic, copy) NSArray *articlesSummary;

@end

@implementation MainViewController

-(instancetype)init{
    self = [super init];
    if (self) {
        self.tracker = [CSDNTracker new];
        self.tracker.delegate = self;
    }
    return self;
}

- (void)awakeFromNib{
    [super awakeFromNib];
}

-(NSWindow *)loginSheets{
    if (_loginSheets == nil) {
        [[NSBundle mainBundle] loadNibNamed:@"LoginSheets" owner:self topLevelObjects:NULL];
    }
    return _loginSheets;
}

-(SpinnerView *)spinnerView{
    if (_spinnerView == nil) {
        _spinnerView = [[SpinnerView alloc] initWithFrame:CGRectMake(0, 0,
                                                                     self.loginSheets.frame.size.width,
                                                                     self.loginSheets.frame.size.height)];
    }
    return _spinnerView;
}

-(IBAction)exportButtonClicked:(id)sender{
    NSOpenPanel *openDlg = [NSOpenPanel openPanel];
    [openDlg setCanChooseDirectories:YES];
    [openDlg setCanChooseFiles:NO];
    [openDlg setAllowsMultipleSelection:NO];
    [openDlg setCanCreateDirectories:YES];
    
    if ([openDlg runModal] == NSOKButton) {
        [sender setEnabled:NO];
        self.exportDirectoryUrl = [[openDlg URL] relativePath];
        [self startExporting];
    }
}

- (BOOL)userNotificationCenter:(NSUserNotificationCenter *)center shouldPresentNotification:(NSUserNotification *)notification
{
    return YES;
}

-(IBAction)showSheet:(id)sender{
    [self.loginSheets makeFirstResponder:self.username];
    
    [[NSApplication sharedApplication] beginSheet:self.loginSheets
                                   modalForWindow:self.mainWindow
                                    modalDelegate:self
                                   didEndSelector:@selector(sheetDidEnd:returnCode:contextInfo:)
                                      contextInfo:(__bridge void *)(self)];
}

-(IBAction)cancelSheet:(id)sender{
    [[NSApplication sharedApplication] endSheet:self.loginSheets returnCode:NSCancelButton];
}

- (void)sheetDidEnd:(NSWindow *)sheet returnCode:(NSInteger)returnCode contextInfo:(void *)contextInfo{
    [sheet orderOut:self];
}

-(void)showTipsTitle:(NSString *)title content:(NSString *)content{
    NSUserNotification *noti = [NSUserNotification new];
    noti.title = title;
    noti.informativeText = content;
    NSUserNotificationCenter *uc = [NSUserNotificationCenter defaultUserNotificationCenter];
    uc.delegate = self;
    [uc deliverNotification:noti];
}

-(IBAction)login:(id)sender{
    if ([self.username.stringValue isEqualToString:@""]) {
        [self showTipsTitle:@"提示" content:@"用户名不能为空"];
        return;
    }
    if ([self.password.stringValue isEqualToString:@""]) {
        [self showTipsTitle:@"提示" content:@"密码不能为空"];
        return;
    }
    [self.loginSheets.contentView addSubview:self.spinnerView];
    [self.spinnerView startAnimation];
    [self.loginSheets makeFirstResponder:nil];
    
    [self.tracker loginWithUsername:self.username.stringValue password:self.password.stringValue];
}

#pragma mark - methods
-(void)startExporting{
    if (self.loginButton.isEnabled) {
        [self showTipsTitle:@"提示" content:@"请先登录"];
        return;
    }
    [self addMessageLog:@"开始导出...\n正在访问指定的博客..."];
    [self.indicator startAnimation:nil];
    
    [self.tracker requestAllArticlesSummary];

}

-(void)addMessageLog:(NSString *)message, ...{
    NSString *originalStr = self.descriptionTextView.string;
    NSString *newStr = nil;
    
    va_list strings;
    va_start(strings, message);
    NSString *str = [[NSString alloc] initWithFormat:message arguments:strings];
    va_end(strings);
    
    if (originalStr.length == 0) {
        newStr = [originalStr stringByAppendingString:str];
    } else {
        newStr = [originalStr stringByAppendingFormat:@"\n%@",str];
    }
    self.descriptionTextView.string = newStr;
    [self.descriptionTextView scrollRangeToVisible:NSMakeRange(self.descriptionTextView.string.length, 0)];
}

-(void)insertYAMLHeaderForArticle:(CSDNArticle *)article fileContent:(NSMutableString *)fileContent{
    [fileContent appendString:@"---\n"];
    [fileContent appendString:@"layout: contentpage\n"];
    [fileContent appendFormat:@"title: %@\n",article.articleTitle];
    if (article.categories != nil) {
        [fileContent appendFormat:@"categories: [%@]\n",article.categories];
    }
    if (article.tags != nil) {
        [fileContent appendFormat:@"tags: [%@]\n",article.tags];
    }
    [fileContent appendFormat:@"date: %@:%02d\n",article.publishTime,rand() % 60];
    [fileContent appendFormat:@"sourceType: %d",article.sourceType];
    [fileContent appendString:@"---\n"];
    [fileContent appendString:@"\n"];
}

-(void)saveArticle:(CSDNArticle *)article{
    [self addMessageLog:@"----正在导出《%@》----已导出",article.articleTitle];
    assert(article.rawContent);
    
    NSMutableString *fileContent = [NSMutableString string];
    
    if (self.yamlButton.state == NSOnState) {
        [self insertYAMLHeaderForArticle:article fileContent:fileContent];
    }
    
    [fileContent appendString:article.rawContent];
    
    NSError *error;
    
    NSString *fileNamePrefix = [[article.publishTime componentsSeparatedByCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]] objectAtIndex:0];
    NSString *fileName = [article.articleTitle stringByReplacingOccurrencesOfString:@" " withString:@"-"];
    NSString *fullFileName = [NSString stringWithFormat:@"%@-%@.html",fileNamePrefix,fileName];
    NSString *filePath = [self.exportDirectoryUrl stringByAppendingPathComponent:fullFileName];
    
    BOOL success = [fileContent writeToFile:filePath atomically:YES encoding:NSUTF8StringEncoding error:&error];
    if (!success) {
        NSLog(@"%@",error.localizedDescription);
    }
    [self addMessageLog:@"----已导出至《%@》",fullFileName];
}

#pragma mark - CSDNTrackerDelegate methods
-(void)loginSuccessful{
    [self.spinnerView stopAnimation];
    [self cancelSheet:nil];
    [self.loginButton setEnabled:NO];
    [self.exportButton setEnabled:YES];
    [self.yamlButton setEnabled:YES];
    self.password.stringValue = @"";
    [self.loginButton setTitle:self.username.stringValue];
    [self.loginButton sizeToFit];
}

-(void)onGetAllArticlesSummarySuccessful:(NSArray *)articlesSummary{
    [self.indicator setDoubleValue:10.0];
    [self.indicator setIndeterminate:NO];
    [self addMessageLog:@"已获取到所有文章的摘要信息"];
    self.articlesSummary = articlesSummary;
    for (CSDNArticle *summary in articlesSummary) {
        [self addMessageLog:@"----%@",summary.articleTitle];
    }
    [self addMessageLog:@"共%d篇文章",articlesSummary.count];
    [self addMessageLog:@"开始导出每一篇文章..."];
    
    [self.tracker requestAllArticlesWithSummaries:articlesSummary];
}

static int i = 0;
-(void)requestArticleSuccessful:(CSDNArticle *)article batchIsCompleted:(BOOL)batchIsCompleted{
    if (batchIsCompleted) {
        [self.indicator setDoubleValue:100.0];
        [self addMessageLog:@"导出完成..."];
        [self addMessageLog:@"已成功导出%d篇",i];
    } else {
        i++;
        [self.indicator incrementBy:90.0 / self.articlesSummary.count];
        [self saveArticle:article];
    }
}

-(void)requestFailed:(NSError *)error{
    [self.spinnerView stopAnimation];
    [self showTipsTitle:@"提示" content:MessageInError(error)];
}

@end
