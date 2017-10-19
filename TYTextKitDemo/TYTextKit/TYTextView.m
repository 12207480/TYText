//
//  TYTextView.m
//  TYTextKitDemo
//
//  Created by tany on 2017/10/19.
//  Copyright © 2017年 tany. All rights reserved.
//

#import "TYTextView.h"

@interface TYTextView ()

@property (nonatomic, strong) TYTextRender *textRender;

@end

@implementation TYTextView

- (instancetype)initWithFrame:(CGRect)frame textRender:(TYTextRender *)textRender {
    if (self = [super initWithFrame:frame textContainer:textRender.textContainer]) {
        self.textRender = textRender;
    }
    return self;
}

- (instancetype)initWithFrame:(CGRect)frame {
    if (self = [self initWithFrame:frame textRender:[self defaultTextRender]]) {
    }
    return self;
}

- (TYTextRender *)defaultTextRender {
    NSTextStorage *textStorage = [[TYTextStorage alloc]init];
    TYTextRender *textRender = [[TYTextRender alloc]initWithTextStorage:textStorage];
    textRender.lineFragmentPadding = 5.0;
    return textRender;
}

- (void)setTextRender:(TYTextRender *)textRender {
    _textRender = textRender;
    textRender.editable = YES;
}

- (void)drawRect:(CGRect)rect {
    [super drawRect:rect];
    
}

@end
