//
//  SpinnerView.m
//  CSDN'sBlogExporter
//
//  Created by ZhangAo on 14-7-9.
//  Copyright (c) 2014年 ZA. All rights reserved.
//

#import "SpinnerView.h"

@interface SpinnerView ()

@property (nonatomic, strong) NSProgressIndicator *spinner;

@end

////////////////////////////////////

@implementation SpinnerView

- (id)initWithFrame:(NSRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        CGSize spinnerSize = CGSizeMake(40, 40);
        self.spinner.frame = CGRectMake((self.bounds.size.width - spinnerSize.width)/2,
                                        (self.bounds.size.height - spinnerSize.height)/2,
                                        spinnerSize.width, spinnerSize.height);
        [self addSubview:self.spinner];
        [self setWantsLayer:YES];
        self.layer.backgroundColor = [NSColor lightGrayColor].CGColor;
    }
    return self;
}

-(NSProgressIndicator *)spinner{
    if (_spinner == Nil) {
        _spinner = [[NSProgressIndicator alloc] init];
        _spinner.style = NSProgressIndicatorSpinningStyle;
    }
    return _spinner;
}

- (void)drawRect:(NSRect)dirtyRect
{
	[super drawRect:dirtyRect];
}

-(void)startAnimation{
    self.layer.hidden = NO;
    [self.spinner startAnimation:self.spinner];
}

-(void)stopAnimation{
    self.layer.hidden = YES;
    [self.spinner stopAnimation:self.spinner];
}

@end
