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

typedef NS_ENUM(NSUInteger, TYLabelTouchedState) {
    TYLabelTouchedStateNone,
    TYLabelTouchedStateTapped,
    TYLabelTouchedStateLongPressed,
};

#define kLongPressTimerInterval 0.5
#define kLongPressTimerMoveDistance 5

@interface TYLabel () <TYAsyncLayerDelegate> {
    struct {
        unsigned int didTappedTextHighlight : 1;
        unsigned int didLongPressedTextHighlight : 1;
    }_delegateFlags;
}

@property (nonatomic, strong) NSTextStorage *textStorageOnRender;
@property (nonatomic, strong) TYTextRender *textRenderOnDisplay;

@property (nonatomic, strong) NSArray *attachments;

@property (nonatomic, assign) NSRange highlightRange;
@property (nonatomic, strong) TYTextHighlight *textHighlight;

@property (nonatomic, strong) NSTimer *longPressTimer;
@property (nonatomic, assign) NSUInteger longPressTimerCount;

@property (nonatomic, assign) TYLabelTouchedState touchState;
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

#pragma mark - Configure

- (void)configureLabel {
    _longPressDuring = 2.0;
    _clearContentBeforeAsyncDisplay = YES;
    _ignoreAboveAtrributedRelatePropertys = YES;
    _ignoreAboveRenderRelatePropertys = YES;
    _numberOfLines = 0;
    _lineBreakMode = NSLineBreakByTruncatingTail;
    _verticalAlignment = TYTextVerticalAlignmentCenter;
    self.opaque = NO;
    self.backgroundColor = [UIColor clearColor];
    self.layer.contentsScale = ty_text_screen_scale();
    ((TYAsyncLayer *)self.layer).asyncDelegate = self;
}

- (void)configureTextAttribute {
    if (_ignoreAboveAtrributedRelatePropertys && !_text) {
        return;
    }
    _textAlignment = [[[UIDevice currentDevice] systemVersion] floatValue] >= 9 ?NSTextAlignmentNatural : NSTextAlignmentLeft;
}

#pragma mark - Display

- (void)setDisplayNeedUpdate {
    TYAssertMainThread();
    [self clearTextRender];
    [self clearLayerContent];
    [self setDisplayNeedRedraw];
}

- (void)setDisplayNeedRedraw {
    [self.layer setNeedsDisplay];
}

- (void)displayRedrawIfNeed {
    [self clearLayerContent];
    [self setDisplayNeedRedraw];
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

- (BOOL)displaysAsynchronously {
    return ((TYAsyncLayer *)self.layer).displaysAsynchronously;
}

- (void)setDisplaysAsynchronously:(BOOL)displaysAsynchronously {
    ((TYAsyncLayer *)self.layer).displaysAsynchronously = displaysAsynchronously;
}

- (void)setText:(NSString *)text {
    TYAssertMainThread();
    _text = text;
    _textStorageOnRender = [[NSTextStorage alloc]initWithString:text];
    _attributedText = nil;
    _textStorage = nil;
    [self configureTextAttribute];
    [self setDisplayNeedUpdate];
    [self invalidateIntrinsicContentSize];
}

- (void)setAttributedText:(NSAttributedString *)attributedText {
    TYAssertMainThread();
    _attributedText = attributedText;
    _textStorageOnRender = [[NSTextStorage alloc]initWithAttributedString:attributedText];
    _text = nil;
    [self configureTextAttribute];
    [self setDisplayNeedUpdate];
    [self invalidateIntrinsicContentSize];
}

- (void)setTextStorage:(NSTextStorage *)textStorage {
    TYAssertMainThread();
    _textStorage = textStorage;
    _textStorageOnRender = textStorage;
    _text = nil;
    [self configureTextAttribute];
    [self setDisplayNeedUpdate];
    [self invalidateIntrinsicContentSize];
}

- (void)setTextRender:(TYTextRender *)textRender {
    TYAssertMainThread();
    _textRender = textRender;
    _textStorageOnRender = textRender.textStorage;
    _text = nil;
    [self configureTextAttribute];
    [self clearLayerContent];
    [self setDisplayNeedRedraw];
    [self invalidateIntrinsicContentSize];
}

- (void)setFont:(UIFont *)font {
    _font = font;
    if (_ignoreAboveAtrributedRelatePropertys && !_text) {
        return;
    }
    _textStorageOnRender.ty_font = font;
    [self displayRedrawIfNeed];
    [self invalidateIntrinsicContentSize];
}

- (void)setTextColor:(UIColor *)textColor {
    _textColor = textColor;
    if (_ignoreAboveAtrributedRelatePropertys && !_text) {
        return;
    }
    _textStorageOnRender.ty_color = textColor;
    [self displayRedrawIfNeed];
}

- (void)setShadow:(NSShadow *)shadow {
    _shadow = shadow;
    if (_ignoreAboveAtrributedRelatePropertys && !_text) {
        return;
    }
    _textStorageOnRender.ty_shadow = shadow;
    [self displayRedrawIfNeed];
}

- (void)setCharacterSpacing:(CGFloat)characterSpacing {
    _characterSpacing = characterSpacing;
    if (_ignoreAboveAtrributedRelatePropertys && !_text) {
        return;
    }
    _textStorageOnRender.ty_characterSpacing = characterSpacing;
    [self displayRedrawIfNeed];
    [self invalidateIntrinsicContentSize];
}

- (void)setLineSpacing:(CGFloat)lineSpacing {
    _lineSpacing = lineSpacing;
    if (_ignoreAboveAtrributedRelatePropertys && !_text) {
        return;
    }
    _textStorageOnRender.ty_lineSpacing = lineSpacing;
    [self displayRedrawIfNeed];
    [self invalidateIntrinsicContentSize];
}

- (void)setTextAlignment:(NSTextAlignment)textAlignment {
    _textAlignment = textAlignment;
    if (_ignoreAboveAtrributedRelatePropertys && !_text) {
        return;
    }
    _textStorageOnRender.ty_alignment = textAlignment;
    [self displayRedrawIfNeed];
}

- (void)setLineBreakMode:(NSLineBreakMode)lineBreakMode {
    _lineBreakMode = lineBreakMode;
    if (_ignoreAboveRenderRelatePropertys && _textRender) {
        return;
    }
    [self displayRedrawIfNeed];
    [self invalidateIntrinsicContentSize];
}

- (void)setNumberOfLines:(NSInteger)numberOfLines {
    _numberOfLines = numberOfLines;
    if (_ignoreAboveRenderRelatePropertys && _textRender) {
        return;
    }
    [self displayRedrawIfNeed];
    [self invalidateIntrinsicContentSize];
}

- (void)setVerticalAlignment:(TYTextVerticalAlignment)verticalAlignment {
    _verticalAlignment = verticalAlignment;
    if (_ignoreAboveRenderRelatePropertys && _textRender) {
        return;
    }
    [self displayRedrawIfNeed];
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
    TYAssertMainThread();
    _delegate = delegate;
    _delegateFlags.didTappedTextHighlight = [delegate respondsToSelector:@selector(label:didTappedTextHighlight:)];
    _delegateFlags.didLongPressedTextHighlight = [delegate respondsToSelector:@selector(label:didLongPressedTextHighlight:)];
}

#pragma mark - Layout Size

- (CGSize)sizeThatFits:(CGSize)size {
    return [self contentSizeWithWidth:size.width];
}

- (CGSize)intrinsicContentSize {
    CGFloat width = _preferredMaxLayoutWidth > 0 ? _preferredMaxLayoutWidth : CGRectGetWidth(self.frame);
    return [self contentSizeWithWidth:width>0?width:10000];
}

// get content size
- (CGSize)contentSizeWithWidth:(CGFloat)width {
    if (_textRender) {
        if (ABS(_textRender.size.width - width)<0.1 || _textRender.size.height == 0 || _textRender.size.width == 0) {
            return [_textRender textSizeWithRenderWidth:width];
        }
        return _textRender.size;
    }
    BOOL ignoreAboveRenderRelatePropertys = _ignoreAboveRenderRelatePropertys && _textRender;
    NSTextStorage *textStorage = [_textStorageOnRender ty_deepCopy];
    TYTextRender *textRender = [[TYTextRender alloc]initWithTextStorage:textStorage];
    if (!ignoreAboveRenderRelatePropertys) {
        [self configureTextRender:textRender verticalAlignment:_verticalAlignment numberOfLines:_numberOfLines lineBreakMode:_lineBreakMode];
    }
    return [textRender textSizeWithRenderWidth:width];
}

#pragma mark - Private

- (TYTextHighlight *)textHighlightForPoint:(CGPoint)point effectiveRange:(NSRangePointer)range {
    NSInteger index = [_textRenderOnDisplay characterIndexForPoint:point];
    if (index < 0) {
        return nil;
    }
    return [_textRenderOnDisplay.textStorage textHighlightAtIndex:index effectiveRange:range];
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
    if (!_textHighlight || _touchState == TYLabelTouchedStateNone || !_delegateFlags.didLongPressedTextHighlight) {
        [self endLongPressTimer];
        return;
    }
    if (_longPressTimerCount*kLongPressTimerInterval >= _longPressDuring) {
        _touchState = TYLabelTouchedStateLongPressed;
        [_delegate label:self didLongPressedTextHighlight:_textHighlight];
        [self endTouch];
    }
}

#pragma mark - Touch Event

- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    _touchState = TYLabelTouchedStateNone;
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
    _touchState = TYLabelTouchedStateTapped;
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
    if (_delegateFlags.didTappedTextHighlight && _touchState == TYLabelTouchedStateTapped) {
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
    _touchState = TYLabelTouchedStateNone;
    _beginTouchPiont = CGPointZero;
}

#pragma mark - TYAsyncLayerDelegate

- (TYAsyncLayerDisplayTask *)newAsyncDisplayTask {
    __block TYTextRender *textRender = _textRender;
    __block NSTextStorage *textStorage = _textStorageOnRender;
    NSArray *attachments = _attachments;
    NSRange highlightRange  = _highlightRange;
    TYTextHighlight *textHighlight = _textHighlight;
    
    BOOL ignoreAboveRenderRelatePropertys = _ignoreAboveRenderRelatePropertys && textRender;
    TYTextVerticalAlignment verticalAlignment = _verticalAlignment;
    NSInteger numberOfLines = _numberOfLines;
    NSLineBreakMode lineBreakMode = _lineBreakMode;
    
    TYAsyncLayerDisplayTask *task = [[TYAsyncLayerDisplayTask alloc]init];
    // will display
    task.willDisplay = ^(CALayer * _Nonnull layer) {
        if (attachments) {
            NSSet *attachmentSet = textRender.attachmentViewSet;
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
        if (!textRender) {
            textRender = [[TYTextRender alloc]initWithTextStorage:textStorage];
            if (isCancelled()) return;
        }
        if (!textStorage) {
            return;
        }
        if (!ignoreAboveRenderRelatePropertys) {
            [self configureTextRender:textRender verticalAlignment:verticalAlignment numberOfLines:numberOfLines lineBreakMode:lineBreakMode];
        }
        textRender.size = size;
        if (isCancelled()) return;
        [textRender setTextHighlight:textHighlight range:highlightRange];
        [textRender drawTextAtPoint:CGPointZero isCanceled:isCancelled];
    };
    task.didDisplay = ^(CALayer * _Nonnull layer, BOOL finished) {
        _textRenderOnDisplay = textRender;
        NSArray *attachments = textRender.attachmentViews;
        if (!finished || !attachments) {
            if (attachments) {
                for (TYTextAttachment *attachment in attachments) {
                    [attachment removeFromSuperView:self];
                }
            }
            return ;
        }
        NSRange visibleRange = textRender.visibleCharacterRangeOnRender;
        NSRange truncatedRange = textRender.truncatedCharacterRangeOnRender;
        for (TYTextAttachment *attachment in attachments) {
            if (NSLocationInRange(attachment.range.location, visibleRange) && (truncatedRange.length == 0 || !NSLocationInRange(attachment.range.location, truncatedRange))) {
                if (textRender.maximumNumberOfLines > 0 && attachment.range.location != 0 && CGPointEqualToPoint(attachment.position, CGPointZero)) {
                    [attachment removeFromSuperView:self];
                }else {
                    CGRect rect = {attachment.position,attachment.size};
                    if (NSMaxRange(attachment.range) == NSMaxRange(visibleRange) && CGRectGetMaxX(rect) - CGRectGetWidth(self.frame) > 1) {
                        [attachment removeFromSuperView:self];
                    }else {
                        [attachment addToSuperView:self];
                        attachment.frame = rect;
                    }
                }
            }else {
                [attachment removeFromSuperView:self];
            }
        }
        _attachments = attachments;
    };
    return task;
}

- (void)configureTextRender:(TYTextRender *)textRender
          verticalAlignment:(TYTextVerticalAlignment)verticalAlignment
              numberOfLines:(NSInteger)numberOfLines
              lineBreakMode:(NSLineBreakMode)lineBreakMode {
    textRender.verticalAlignment = verticalAlignment;
    textRender.maximumNumberOfLines = numberOfLines;
    textRender.lineBreakMode = lineBreakMode;
}

- (void)dealloc {
    _textRender = nil;
//    NSLog(@"TYLabel dealloc!");
}

@end
