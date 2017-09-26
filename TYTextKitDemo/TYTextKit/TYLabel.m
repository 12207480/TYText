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
    _clearContentsBeforeAsynchronouslyDisplay = YES;
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
    [self clearLayerContent];
    [self setDisplayNeedRedraw];
}

- (void)setDisplayNeedRedraw {
    [self.layer setNeedsDisplay];
}

- (void)clearLayerContent {
    if (_clearContentsBeforeAsynchronouslyDisplay && self.displaysAsynchronously) {
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
    NSTextStorage *textStorage = [[NSTextStorage alloc]initWithAttributedString:attributedText];
    [self setTextStorage:textStorage];
}

- (void)setTextStorage:(NSTextStorage *)textStorage {
    [self clearTextRender];
    self.textRender.textStorage = textStorage;
    [self setLayoutNeedUpdate];
}

- (TYTextRender *)textRender {
    if (!_textRender) {
        _textRender = [[TYTextRender alloc]init];
        _textRender.size = self.bounds.size;
    }
    return _textRender;
}

#pragma mark - TYAsyncLayerDelegate

- (TYAsyncLayerDisplayTask *)newAsyncDisplayTask {
    TYAsyncLayerDisplayTask *task = [[TYAsyncLayerDisplayTask alloc]init];
    TYTextRender *textRender = _textRender;
    task.displaying = ^(CGContextRef  _Nonnull context, CGSize size, BOOL isAsynchronously, BOOL (^ _Nonnull isCancelled)(void)) {
        [textRender drawTextInRect:CGRectMake(0, 0, size.width, size.height)];
    };
    return task;
}

- (void)layoutSubviews {
    [super layoutSubviews];
    _textRender.size = self.bounds.size;
}

@end
