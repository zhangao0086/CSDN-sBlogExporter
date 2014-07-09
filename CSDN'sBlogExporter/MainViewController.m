//
//  MainViewController.m
//  CSDN'sBlogExporter
//
//  Created by ZhangAo on 14-7-9.
//  Copyright (c) 2014年 ZA. All rights reserved.
//

#import "MainViewController.h"
#import "CSDNArticleSummary.h"
#import "CSDNAllArticleSummaryTracker.h"
#import "CSDNArticleTracker.h"
#import "CSDNLoginTracker.h"

@interface MainViewController ()

@property (nonatomic, weak) IBOutlet NSTextField *username;
@property (nonatomic, assign) IBOutlet NSTextView *descriptionTextView;
@property (nonatomic, weak) IBOutlet NSProgressIndicator *indicator;
@property (nonatomic, weak) IBOutlet NSButton *loginButton;
@property (nonatomic, weak) IBOutlet NSButton *exportButton;

@property (nonatomic, strong) IBOutlet NSWindow *loginSheets;
@property (nonatomic, weak) IBOutlet NSTextField *password;

@property (nonatomic, strong) NSArray *articleSummarys;
@property (nonatomic, strong) NSURL *exportDirectoryURL;

@end

@implementation MainViewController

- (void)awakeFromNib{
    [super awakeFromNib];
}

-(NSWindow *)loginSheets{
    if (_loginSheets == nil) {
        [NSBundle loadNibNamed:@"LoginSheets" owner:self];
    }
    return _loginSheets;
}

-(IBAction)categoriesButtonClicked:(NSButton *)sender{
    NSOpenPanel *openDlg = [NSOpenPanel openPanel];
    [openDlg setCanChooseDirectories:YES];
    [openDlg setAllowsMultipleSelection:NO];
    
    if ([openDlg runModal] == NSOKButton) {
        [sender setEnabled:NO];
        self.exportDirectoryURL = [openDlg URL];
        [self startExporting];
    }
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
    if (returnCode == NSOKButton) {
        
    }
}

-(IBAction)login:(id)sender{
    CSDNLoginTracker *loginTracker = [[CSDNLoginTracker alloc] init];
    loginTracker.username = self.username.stringValue;
    loginTracker.password = self.password.stringValue;
    [loginTracker requestWithCompleteBlock:^(NSError *error, id obj) {
        if (error == nil) {
            
        } else {
            MessageInError(error);
        }
    }];
}

#pragma mark - methods
-(void)startExporting{
    [self addMessageLog:@"开始导出...\n正在访问指定的博客..."];
    [self.indicator startAnimation:nil];
    CSDNAllArticleSummaryTracker *tracker = [CSDNAllArticleSummaryTracker new];
    tracker.username = self.username.stringValue;
    [tracker requestWithCompleteBlock:^(NSError *error, NSArray *articleSummarys) {
        if (error == nil) {
            self.articleSummarys = articleSummarys;
            [self.indicator setDoubleValue:10.0];
            [self.indicator setIndeterminate:NO];
            [self addMessageLog:@"已获取到所有文章的摘要信息"];
            for (CSDNArticleSummary *summary in articleSummarys) {
                [self addMessageLog:@"----%@",summary.articleTitle];
            }
            [self addMessageLog:@"共%d篇文章",articleSummarys.count];
            [self addMessageLog:@"开始导出每一篇文章..."];
            CSDNArticleTracker *articleTracker = [[CSDNArticleTracker alloc] initWithSummarys:self.articleSummarys];
            articleTracker.username = self.username.stringValue;
            [articleTracker requestBatchWithCompleteBlock:^(NSError *error, id obj, BOOL batchIsCompleted) {
                if (error == nil) {
                    if (batchIsCompleted) {
                        
                    } else {
                        [self addMessageLog:@""];
                    }
                }
            }];
        }
    }];
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

@end
