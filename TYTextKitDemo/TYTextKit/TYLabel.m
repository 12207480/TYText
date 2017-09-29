//
//  TYLabel.m
//  TYTextKitDemo
//
//  Created by tany on 2017/9/8.
//  Copyright © 2017年 tany. All rights reserved.
//

#import "TYLabel.h"
#import "TYAsyncLayer.h"

@interface TYLabel () <TYAsyncLayerDelegate>

@end

@implementation TYLabel

+ (Class)layerClass {
    return [TYAsyncLayer class];
}

- (instancetype)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        [self configureLabel];
    }
    return self;
}

- (instancetype)initWithCoder:(NSCoder *)aDecoder {
    if (self = [super initWithCoder:aDecoder]) {
        [self configureLabel];
    }
    return self;
}

- (void)configureLabel {
    _clearContentBeforeAsyncDisplay = YES;
    self.layer.contentsScale = [UIScreen mainScreen].scale;
    ((TYAsyncLayer *)self.layer).asyncDelegate = self;
}

- (void)setDisplaysAsynchronously:(BOOL)displaysAsynchronously {
    ((TYAsyncLayer *)self.layer).displaysAsynchronously = displaysAsynchronously;
}

- (BOOL)displaysAsynchronously {
    return ((TYAsyncLayer *)self.layer).displaysAsynchronously;
}

- (void)setLayoutNeedUpdate {
    [self clearTextRender];
    [self clearLayerContent];
    [self setDisplayNeedRedraw];
}

- (void)setDisplayNeedRedraw {
    [self.layer setNeedsDisplay];
}

- (void)clearLayerContent {
    if (_clearContentBeforeAsyncDisplay && self.displaysAsynchronously) {
        self.layer.contents = nil;
    }
}

- (void)clearTextRender {
    _textRender = nil;
}

- (void)setNeedsDisplay {
    [super setNeedsDisplay];
    [self setDisplayNeedRedraw];
}

#pragma mark - Getter && Setter

- (void)setText:(NSString *)text {
    _text = text;
    self.attributedText = [[NSAttributedString alloc]initWithString:text];
}

- (void)setAttributedText:(NSAttributedString *)attributedText {
    _attributedText = attributedText;
    [self setLayoutNeedUpdate];
}

- (void)setTextStorage:(NSTextStorage *)textStorage {
    _textStorage = textStorage;
    [self setLayoutNeedUpdate];
}

#pragma mark - TYAsyncLayerDelegate

- (TYAsyncLayerDisplayTask *)newAsyncDisplayTask {
    __block TYTextRender *textRender = _textRender;
    __block NSTextStorage *textStorage = _textStorage;
    __strong NSAttributedString *attributedText = _attributedText;
    TYAsyncLayerDisplayTask *task = [[TYAsyncLayerDisplayTask alloc]init];
    task.displaying = ^(CGContextRef  _Nonnull context, CGSize size, BOOL isAsynchronously, BOOL (^ _Nonnull isCancelled)(void)) {
        if (!textRender && !textStorage) {
            textStorage = [[NSTextStorage alloc]initWithAttributedString:attributedText];
        }
        if (isCancelled()) return ;
        if (!textRender) {
            textRender = [[TYTextRender alloc]initWithTextStorage:textStorage];
        }
        textRender.size = size;
        if (isCancelled()) return ;
        [textRender drawTextInRect:CGRectMake(0, 0, size.width, size.height)];
    };
    return task;
}

- (void)dealloc {
    _textRender = nil;
}

@end
