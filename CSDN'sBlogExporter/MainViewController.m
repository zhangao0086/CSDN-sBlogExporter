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
#import "SpinnerView.h"

@interface MainViewController ()

@property (nonatomic, assign) IBOutlet NSTextView *descriptionTextView;
@property (nonatomic, weak) IBOutlet NSProgressIndicator *indicator;
@property (nonatomic, weak) IBOutlet NSButton *loginButton;
@property (nonatomic, weak) IBOutlet NSButton *exportButton;

@property (nonatomic, strong) IBOutlet NSWindow *loginSheets;
@property (nonatomic, weak) IBOutlet NSTextField *username;
@property (nonatomic, weak) IBOutlet NSTextField *password;
@property (nonatomic, weak) IBOutlet NSTextField *tipsLabel;

@property (nonatomic, strong) NSArray *articleSummarys;
@property (nonatomic, strong) NSURL *exportDirectoryURL;
@property (nonatomic, strong) SpinnerView *spinnerView;

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

-(SpinnerView *)spinnerView{
    if (_spinnerView == nil) {
        _spinnerView = [[SpinnerView alloc] initWithFrame:CGRectMake(0, 0,
                                                                     self.loginSheets.frame.size.width,
                                                                     self.loginSheets.frame.size.height)];
    }
    return _spinnerView;
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
}

-(IBAction)login:(id)sender{
    if ([self.username.stringValue isEqualToString:@""]) {
        self.tipsLabel.stringValue = @"用户名不能为空";
        return;
    }
    if ([self.password.stringValue isEqualToString:@""]) {
        self.tipsLabel.stringValue = @"密码不能为空";
        return;
    }
    [self.loginSheets.contentView addSubview:self.spinnerView];
    [self.spinnerView startAnimation];
    [self.loginSheets makeFirstResponder:nil];
    
    CSDNLoginTracker *loginTracker = [[CSDNLoginTracker alloc] init];
    loginTracker.username = self.username.stringValue;
    loginTracker.password = self.password.stringValue;
    [loginTracker requestWithCompleteBlock:^(NSError *error, id obj) {
        [self.spinnerView stopAnimation];
        if (error == nil) {
            [self cancelSheet:nil];
            [self.loginButton setEnabled:NO];
            [self.exportButton setEnabled:YES];
            self.password.stringValue = @"";
            [self.loginButton setTitle:self.username.stringValue];
            [self resizeLoginButton];
            [CSDNTracker setUsername:self.username.stringValue];
        } else {
            self.tipsLabel.stringValue = MessageInError(error);
        }
    }];
}

#pragma mark - methods
-(void)resizeLoginButton{
    CGSize size =  [self.loginButton.title boundingRectWithSize:CGSizeMake(CGFLOAT_MAX, self.loginButton.frame.size.height)
                                                        options:NSStringDrawingUsesLineFragmentOrigin
                                                     attributes:@{
                                                                  NSFontAttributeName: self.loginButton.font
                                                                  }].size;
    self.loginButton.frame = CGRectMake(self.loginButton.frame.origin.x,
                                        self.loginButton.frame.origin.y,
                                        size.width, self.loginButton.frame.size.height);
}

-(void)startExporting{
    [self addMessageLog:@"开始导出...\n正在访问指定的博客..."];
    [self.indicator startAnimation:nil];
    CSDNAllArticleSummaryTracker *tracker = [CSDNAllArticleSummaryTracker new];
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
