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

typedef NS_ENUM(NSUInteger, TYUserTouchedState) {
    TYUserTouchedStateNone,
    TYUserTouchedStateTapped,
    TYUserTouchedStateLongPressed,
};

#define kLongPressTimerInterval 0.5
#define kLongPressTimerMoveDistance 5

@interface TYLabel () <TYAsyncLayerDelegate> {
    struct {
        unsigned int didTappedTextHighlight : 1;
        unsigned int didLongPressedTextHighlight : 1;
    }_delegateFlags;
}

@property (nonatomic, strong) TYTextRender *textRenderOnDisplay;

@property (nonatomic, strong) NSArray *attachments;

@property (nonatomic, assign) NSRange highlightRange;
@property (nonatomic, strong) TYTextHighlight *textHighlight;

@property (nonatomic, strong) NSTimer *longPressTimer;
@property (nonatomic, assign) NSUInteger longPressTimerCount;

@property (nonatomic, assign) TYUserTouchedState touchState;
@property (nonatomic, assign) CGPoint beginTouchPiont;

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
    _longPressDuring = 2.0;
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

- (void)setDisplayNeedUpdate {
    TYAssertMainThread();
    [self clearTextRender];
    [self clearLayerContent];
    [self setDisplayNeedRedraw];
}

- (void)setDisplayNeedRedraw {
    [self.layer setNeedsDisplay];
}

- (void)immediatelyDisplayRedraw {
    [(TYAsyncLayer *)self.layer displayImmediately];
}

- (void)clearLayerContent {
    if (_clearContentBeforeAsyncDisplay && self.displaysAsynchronously) {
        self.layer.contents = nil;
    }
}

- (void)clearTextRender {
    _textRender = nil;
}

- (void)willMoveToSuperview:(UIView *)newSuperview {
    [super willMoveToSuperview:newSuperview];
    if (!newSuperview) {
        [self endLongPressTimer];
    }
}

#pragma mark - Getter && Setter

- (void)setText:(NSString *)text {
    _text = text;
    self.attributedText = [[NSAttributedString alloc]initWithString:text];
}

- (void)setAttributedText:(NSAttributedString *)attributedText {
    TYAssertMainThread();
    _attributedText = attributedText;
    [self setDisplayNeedUpdate];
}

- (void)setTextStorage:(NSTextStorage *)textStorage {
    TYAssertMainThread();
    _textStorage = textStorage;
    [self setDisplayNeedUpdate];
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

- (void)setDelegate:(id<TYLabelDelegate>)delegate {
    _delegate = delegate;
    _delegateFlags.didTappedTextHighlight = [delegate respondsToSelector:@selector(label:didTappedTextHighlight:)];
    _delegateFlags.didLongPressedTextHighlight = [delegate respondsToSelector:@selector(label:didLongPressedTextHighlight:)];
}

#pragma mark - Private

- (TYTextHighlight *)textHighlightForPoint:(CGPoint)point effectiveRange:(NSRangePointer)range {
    NSInteger index = [_textRenderOnDisplay characterIndexForPoint:point];
    if (index >= 0) {
        return [_textRenderOnDisplay.textStorage textHighlightAtIndex:index effectiveRange:range];
    }
    return nil;
}

#pragma mark - LongPress timer

- (void)startLongPressTimer {
    [self endLongPressTimer];
    _longPressTimer = [NSTimer timerWithTimeInterval:kLongPressTimerInterval
                                              target:self selector:@selector(longPressTimerTick)
                                            userInfo:nil
                                             repeats:YES];
    [[NSRunLoop currentRunLoop] addTimer:_longPressTimer forMode:NSRunLoopCommonModes];
}

- (void)endLongPressTimer {
    if (_longPressTimer && [_longPressTimer isValid]) {
        [_longPressTimer invalidate];
        _longPressTimer = nil;
    }
    _longPressTimerCount = 0;
}

- (void)longPressTimerTick {
    ++_longPressTimerCount;
    if (!_textHighlight || _touchState == TYUserTouchedStateNone || !_delegateFlags.didLongPressedTextHighlight) {
        [self endLongPressTimer];
        return;
    }
    if (_longPressTimerCount*kLongPressTimerInterval >= _longPressDuring) {
        _touchState = TYUserTouchedStateLongPressed;
        [_delegate label:self didLongPressedTextHighlight:_textHighlight];
        [self endTouch];
    }
}

#pragma mark - Touch Event

- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    _touchState = TYUserTouchedStateNone;
    _beginTouchPiont = CGPointZero;
    if (!_textRenderOnDisplay) {
        [super touchesBegan:touches withEvent:event];
        return;
    }
    UITouch *touch = touches.anyObject;
    CGPoint point = [touch locationInView:self];
    NSRange range = NSMakeRange(0, 0);
    _textHighlight = [self textHighlightForPoint:point effectiveRange:&range];
    _highlightRange = range;
    if (!_textHighlight) {
        [super touchesBegan:touches withEvent:event];
        return;
    }
    _beginTouchPiont = point;
    _touchState = TYUserTouchedStateTapped;
    if (_delegateFlags.didLongPressedTextHighlight) {
        [self startLongPressTimer];
    }
    [self immediatelyDisplayRedraw];
}

- (void)touchesMoved:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    if (!_textRenderOnDisplay || !_textHighlight) {
        [super touchesMoved:touches withEvent:event];
        return;
    }
    UITouch *touch = touches.anyObject;
    CGPoint point = [touch locationInView:self];
    NSRange range = NSMakeRange(0, 0);
    TYTextHighlight *textHighlight = [self textHighlightForPoint:point effectiveRange:&range];
    if (textHighlight == _textHighlight) {
        if (fabs(point.x - _beginTouchPiont.x) > kLongPressTimerMoveDistance || fabs(point.y - _beginTouchPiont.y) > kLongPressTimerMoveDistance) {
            [self endLongPressTimer];
        }
        if (_highlightRange.length == 0) {
            _highlightRange = range;
            [self immediatelyDisplayRedraw];
        }
        return;
    }
    [self endLongPressTimer];
    if (_highlightRange.length > 0) {
        _highlightRange = NSMakeRange(0, 0);
        [self immediatelyDisplayRedraw];
    }
}

- (void)touchesEnded:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    if (!_textRenderOnDisplay || !_textHighlight) {
        [self endLongPressTimer];
        [super touchesEnded:touches withEvent:event];
        return;
    }
    UITouch *touch = touches.anyObject;
    CGPoint point = [touch locationInView:self];
    NSRange range = NSMakeRange(0, 0);
    if (_delegateFlags.didTappedTextHighlight && _touchState == TYUserTouchedStateTapped) {
        TYTextHighlight *textHighlight = [self textHighlightForPoint:point effectiveRange:&range];
        if (textHighlight == _textHighlight && NSEqualRanges(range, _highlightRange) ) {
            [_delegate label:self didTappedTextHighlight:_textHighlight];
        }
    }
    [self endTouch];
}

- (void)touchesCancelled:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    if (!_textRenderOnDisplay || !_textHighlight) {
        [self endLongPressTimer];
        [super touchesCancelled:touches withEvent:event];
        return;
    }
    [self endTouch];
}

- (void)endTouch {
    _textHighlight = nil;
    _highlightRange = NSMakeRange(0, 0);
    [self immediatelyDisplayRedraw];
    _touchState = TYUserTouchedStateNone;
    _beginTouchPiont = CGPointZero;
}

#pragma mark - TYAsyncLayerDelegate

- (TYAsyncLayerDisplayTask *)newAsyncDisplayTask {
    __block TYTextRender *textRender = _textRender;
    __block NSTextStorage *textStorage = _textStorage;
    NSAttributedString *attributedText = _attributedText;
    NSArray *attachments = _attachments;
    
    NSRange highlightRange  = _highlightRange;
    TYTextHighlight *textHighlight = _textHighlight;
    
    TYAsyncLayerDisplayTask *task = [[TYAsyncLayerDisplayTask alloc]init];
    // will display
    task.willDisplay = ^(CALayer * _Nonnull layer) {
        if (attachments) {
            NSSet *attachmentSet = textRender.attachmentSet;
            for (TYTextAttachment *attachment in attachments) {
                if (!attachmentSet || ![attachmentSet containsObject:attachment]) {
                    [attachment removeFromSuperView:self];
                }
            }
        }
        _attachments = nil;
        _textRenderOnDisplay = nil;
    };
    
    task.displaying = ^(CGContextRef  _Nonnull context, CGSize size, BOOL isAsynchronously, BOOL (^ _Nonnull isCancelled)(void)) {
        if (!textRender && !textStorage) {
             textRender = [[TYTextRender alloc]initWithAttributedText:attributedText];
        }
        if (isCancelled()) return;
        if (!textRender) {
            textRender = [[TYTextRender alloc]initWithTextStorage:textStorage];
        }
        textRender.size = size;
        if (isCancelled()) return;
        [textRender setTextHighlight:textHighlight range:highlightRange];
        [textRender drawTextAtPoint:CGPointZero isCanceled:isCancelled];
    };
    
    task.didDisplay = ^(CALayer * _Nonnull layer, BOOL finished) {
        _textRenderOnDisplay = textRender;
        NSArray *attachments = textRender.attachments;
        if (!finished || !attachments) {
            if (attachments) {
                for (TYTextAttachment *attachment in attachments) {
                    [attachment removeFromSuperView:self];
                }
            }
            return ;
        }
        
        NSRange visibleRange = textRender.visibleCharacterRangeOnRender;
        for (TYTextAttachment *attachment in attachments) {
            if (NSLocationInRange(attachment.range.location, visibleRange)) {
                CGRect rect = {attachment.position,attachment.size};
                [attachment addToSuperView:self];
                attachment.frame = rect;
            }else {
                [attachment removeFromSuperView:self];
            }
        }
        _attachments = attachments;
        NSAssert(self.subviews.count == attachments.count, @"attachments count incorrect");
    };
    return task;
}

- (void)dealloc {
    _textRender = nil;
    NSLog(@"TYLabel dealloc!");
}

@end
