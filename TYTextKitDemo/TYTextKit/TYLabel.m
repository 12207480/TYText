//
//  TYLabel.m
//  TYTextKitDemo
//
//  Created by tany on 2017/9/8.
//  Copyright © 2017年 tany. All rights reserved.
//

#import "TYLabel.h"
#import "TYAsyncLayer.h"
#import <pthread.h>

#define TYAssertMainThread() NSAssert(0 != pthread_main_np(), @"This method must be called on the main thread!")

@interface TYLabel () <TYAsyncLayerDelegate>

@property (nonatomic, strong) NSArray *attachViews;

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
    self.clipsToBounds = YES;
    self.layer.contentsScale = ty_text_screen_scale();
    ((TYAsyncLayer *)self.layer).asyncDelegate = self;
}

- (void)setDisplaysAsynchronously:(BOOL)displaysAsynchronously {
    ((TYAsyncLayer *)self.layer).displaysAsynchronously = displaysAsynchronously;
}

- (BOOL)displaysAsynchronously {
    return ((TYAsyncLayer *)self.layer).displaysAsynchronously;
}

- (void)setLayoutNeedUpdate {
    TYAssertMainThread();
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

#pragma mark - Getter && Setter

- (void)setText:(NSString *)text {
    _text = text;
    self.attributedText = [[NSAttributedString alloc]initWithString:text];
}

- (void)setAttributedText:(NSAttributedString *)attributedText {
    TYAssertMainThread();
    _attributedText = attributedText;
    [self setLayoutNeedUpdate];
}

- (void)setTextStorage:(NSTextStorage *)textStorage {
    TYAssertMainThread();
    _textStorage = textStorage;
    [self setLayoutNeedUpdate];
}

- (void)setTextRender:(TYTextRender *)textRender {
    TYAssertMainThread();
    _textRender = textRender;
    [self clearLayerContent];
    [self setDisplayNeedRedraw];
}

- (void)setFrame:(CGRect)frame {
    TYAssertMainThread();
    CGSize oldSize = self.frame.size;
    [super setFrame:frame];
    if (!CGSizeEqualToSize(self.frame.size, oldSize)) {
        [self clearLayerContent];
        [self setDisplayNeedRedraw];
    }
}

- (void)setBounds:(CGRect)bounds {
    TYAssertMainThread();
    CGSize oldSize = self.bounds.size;
    [super setBounds:bounds];
    if (!CGSizeEqualToSize(self.bounds.size, oldSize)) {
        [self clearLayerContent];
        [self setDisplayNeedRedraw];
    }
}

#pragma mark - TYAsyncLayerDelegate

- (TYAsyncLayerDisplayTask *)newAsyncDisplayTask {
    __block TYTextRender *textRender = _textRender;
    __block NSTextStorage *textStorage = _textStorage;
    __strong NSAttributedString *attributedText = _attributedText;
    NSArray *attachViews = _attachViews;
    TYAsyncLayerDisplayTask *task = [[TYAsyncLayerDisplayTask alloc]init];
    // will display
    task.willDisplay = ^(CALayer * _Nonnull layer) {
        [self clearAttachViews:attachViews];
    };
    
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
        [textRender drawTextAtPoint:CGPointZero isCanceled:isCancelled];
    };
    
    task.didDisplay = ^(CALayer * _Nonnull layer, BOOL finished) {
        NSArray *attachViews = textRender.attachViews;
        if (!finished || !attachViews) {
            [self clearAttachViews:attachViews];
            _attachViews = attachViews;
            return ;
        }
        NSRange visibleRange = [textRender visibleCharacterRange];
        for (TYTextAttachment *attachment in attachViews) {
            if (!NSLocationInRange(attachment.range.location, visibleRange)) {
                [attachment.view removeFromSuperview];
                [attachment.layer removeFromSuperlayer];
                continue;
            }
            CGRect rect = {attachment.position,attachment.size};
            [attachment addToSuperView:self];
            attachment.frame = rect;
        }
        _attachViews = attachViews;
    };
    return task;
}

- (void)clearAttachViews:(NSArray *)attachViews {
    TYAssertMainThread();
    if (!attachViews) {
        return;
    }
    for (TYTextAttachment *attachment in attachViews) {
        [attachment removeFromSuperView];
    }
}

- (void)dealloc {
    _textRender = nil;
}

@end
