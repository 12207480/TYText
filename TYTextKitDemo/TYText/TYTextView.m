//
//  TYTextView.m
//  TYTextKitDemo
//
//  Created by tany on 2017/10/19.
//  Copyright © 2017年 tany. All rights reserved.
//

#import "TYTextView.h"

typedef NS_ENUM(NSUInteger, TYTextViewTouchedState) {
    TYTextViewTouchedStateNone,
    TYTextViewTouchedStateTapped,
    TYTextViewTouchedStateLongPressed,
};

#define kLongPressTimerInterval 0.5
#define kLongPressTimerMoveDistance 5

@interface TYTextView () <NSTextStorageDelegate> {
    struct {
        unsigned int shouldInsertText : 1;
        unsigned int shouldInsertAttributedText : 1;
        unsigned int processEditingForTextStorage : 1;
        unsigned int didTappedTextHighlight : 1;
        unsigned int didLongPressedTextHighlight : 1;
    }_delegateFlags;
}

@property (nonatomic, strong) TYTextRender *textRender;

@property (nonatomic, strong) NSArray<TYTextAttachment *> *attachments;

@property (nonatomic, assign) NSRange highlightRange;
@property (nonatomic, strong, nullable) TYTextHighlight *textHighlight;

@property (nonatomic, strong, nullable) NSTimer *longPressTimer;
@property (nonatomic, assign) NSUInteger longPressTimerCount;

@property (nonatomic, assign) TYTextViewTouchedState touchState;
@property (nonatomic, assign) CGPoint beginTouchPiont;

// override point
- (void)textAtrributedDidChange;

@end

@implementation TYTextView

#pragma mark - Init

- (instancetype)init {
    return [self initWithFrame:CGRectZero textRender:nil];
}

- (instancetype)initWithFrame:(CGRect)frame {
    return [self initWithFrame:frame textRender:nil];
}

- (instancetype)initWithFrame:(CGRect)frame textRender:(TYTextRender *)textRender {
    NSTextContainer *container = textRender.textContainer ?: [self newTextKit2Container];
    if (self = [super initWithFrame:frame textContainer:container]) {
        [self commonInit];
        if (textRender) {
            [self installTextRender:textRender];
        } else {
            [self installTextRender:[self defaultTextRender]];
        }
    }
    return self;
}

- (NSTextContainer *)newTextKit2Container {
    NSTextContentStorage *contentStorage = [[NSTextContentStorage alloc] init];
    NSTextLayoutManager *layoutManager = [[NSTextLayoutManager alloc] init];
    [contentStorage addTextLayoutManager:layoutManager];
    NSTextContainer *container = [[NSTextContainer alloc] init];
    layoutManager.textContainer = container;
    return container;
}

- (instancetype)initWithCoder:(NSCoder *)coder {
    if (self = [super initWithCoder:coder]) {
        [self commonInit];
        [self installTextRender:[self defaultTextRender]];
    }
    return self;
}

- (void)commonInit {
    self.autocorrectionType = UITextAutocorrectionTypeNo;
    _longPressDuring = 2.0;
    _highlightRange = NSMakeRange(0, 0);
}

- (TYTextRender *)defaultTextRender {
    TYTextRender *textRender = [[TYTextRender alloc] initWithTextContainer:self.textContainer editable:YES];
    textRender.lineFragmentPadding = self.textContainer.lineFragmentPadding;
    return textRender;
}

- (void)installTextRender:(TYTextRender *)textRender {
    _textRender = textRender;
    if (!textRender.editable) {
        textRender.editable = YES;
    }
    self.textStorage.delegate = self;
}

#pragma mark - Getter && Setter

- (void)setTextRender:(TYTextRender *)textRender {
    [self installTextRender:textRender];
}

- (void)setDelegate:(id<UITextViewDelegate>)delegate {
    [super setDelegate:delegate];
    _delegateFlags.shouldInsertText = [delegate respondsToSelector:@selector(textView:shouldInsertText:)];
    _delegateFlags.shouldInsertAttributedText = [delegate respondsToSelector:@selector(textView:shouldInsertAttributedText:)];
    _delegateFlags.processEditingForTextStorage = [delegate respondsToSelector:@selector(textView:processEditingForTextStorage:edited:range:changeInLength:invalidatedRange:)];
    _delegateFlags.didTappedTextHighlight = [delegate respondsToSelector:@selector(textView:didTappedTextHighlight:)];
    _delegateFlags.didLongPressedTextHighlight = [delegate respondsToSelector:@selector(textView:didLongPressedTextHighlight:)];
}

#pragma mark - Public

- (void)insertText:(NSString *)text {
    if (!text) {
        return;
    }
    if (_delegateFlags.shouldInsertText && ![((id<TYTextViewDelegate>)self.delegate) textView:self shouldInsertText:text]) {
        return;
    }
    [super insertText:text];
}

- (void)insertAttributedText:(NSAttributedString *)attributedText {
    if (!attributedText) {
        return;
    }
    if (_delegateFlags.shouldInsertAttributedText && ![((id<TYTextViewDelegate>)self.delegate) textView:self shouldInsertAttributedText:attributedText]) {
        return;
    }
    if (attributedText.length == 1 && [attributedText.string isEqualToString:@"\U0000FFFC"]) {
        // fixed textAttachment's font and textAlignment
        NSMutableAttributedString *att = [attributedText mutableCopy];
        att.ty_alignment = self.textAlignment;
        att.ty_font = self.font;
        attributedText = att;
    }
    NSRange selectedRange = self.selectedRange;
    if (selectedRange.length > 0) {
        [self.textStorage replaceCharactersInRange:selectedRange withAttributedString:attributedText];
    } else {
        [self.textStorage insertAttributedString:attributedText atIndex:selectedRange.location];
    }
    self.selectedRange = NSMakeRange(selectedRange.location + attributedText.length, 0);
}

#pragma mark - Private

- (void)configireTextStorage:(NSTextStorage *)textStorage {
    if (_ignoreAboveTextRelatedPropertys) {
        return;
    }
    textStorage.ty_lineBreakMode = _lineBreakMode;
    textStorage.ty_characterSpacing = _characterSpacing;
    textStorage.ty_lineSpacing = _lineSpacing;
    textStorage.ty_alignment = self.textAlignment;
}

- (void)addAttachmentViews {
    NSArray<TYTextAttachment *> *attachments = self.textStorage.attachmentViews;
    if (!_attachments && !attachments) {
        return;
    }
    NSSet<TYTextAttachment *> *attachmentSet = attachments.count > 0 ? [NSSet setWithArray:attachments] : nil;
    for (TYTextAttachment *attachment in _attachments) {
        if (!attachmentSet || ![attachmentSet containsObject:attachment]) {
            [attachment removeFromSuperView:self];
        }
    }
    NSTextLayoutManager *layoutManager = self.textLayoutManager;
    NSTextContentManager *contentManager = layoutManager.textContentManager;
    NSTextContentStorage *contentStorage = [contentManager isKindOfClass:[NSTextContentStorage class]] ? (NSTextContentStorage *)contentManager : nil;
    if (!layoutManager || !contentStorage) {
        _attachments = attachments;
        return;
    }
    [layoutManager ensureLayoutForRange:contentStorage.documentRange];

    for (TYTextAttachment *attachment in attachments) {
        NSUInteger loc = attachment.range.location;
        if (loc == NSNotFound || loc >= self.textStorage.length) {
            [attachment removeFromSuperView:self];
            continue;
        }
        id<NSTextLocation> location = [contentStorage locationFromLocation:contentStorage.documentRange.location withOffset:(NSInteger)loc];
        if (!location) {
            [attachment removeFromSuperView:self];
            continue;
        }
        NSTextLayoutFragment *fragment = [layoutManager textLayoutFragmentForLocation:location];
        if (!fragment) {
            [attachment removeFromSuperView:self];
            continue;
        }
        CGRect frame = [fragment frameForTextAttachmentAtLocation:location];
        if (CGRectIsEmpty(frame)) {
            [attachment removeFromSuperView:self];
            continue;
        }
        frame.origin.x += fragment.layoutFragmentFrame.origin.x + self.textContainerInset.left;
        frame.origin.y += fragment.layoutFragmentFrame.origin.y + self.textContainerInset.top;
        [attachment ty_updatePosition:frame.origin];
        [attachment addToSuperView:self];
        [attachment setFrame:frame];
    }
    _attachments = attachments;
}

- (void)textAtrributedDidChange {

}

- (TYTextHighlight *)textHighlightForPoint:(CGPoint)point effectiveRange:(NSRangePointer)range {
    NSInteger index = [_textRender characterIndexForPoint:point];
    if (index < 0) {
        return nil;
    }
    return [self.textStorage textHighlightAtIndex:(NSUInteger)index effectiveRange:range];
}

- (void)immediatelyDisplayRedraw {
    [_textRender setTextHighlight:_textHighlight range:_highlightRange];
    [self setNeedsDisplay];
}

#pragma mark - LongPress Timer

- (void)startLongPressTimer {
    [self endLongPressTimer];
    _longPressTimer = [NSTimer timerWithTimeInterval:kLongPressTimerInterval
                                              target:self selector:@selector(longPressTimerTick)
                                            userInfo:nil
                                             repeats:YES];
    [[NSRunLoop currentRunLoop] addTimer:_longPressTimer forMode:NSRunLoopCommonModes];
}

- (void)endLongPressTimer {
    if ([_longPressTimer isValid]) {
        [_longPressTimer invalidate];
        _longPressTimer = nil;
    }
    _longPressTimerCount = 0;
}

- (void)longPressTimerTick {
    ++_longPressTimerCount;
    if (!_textHighlight || _touchState == TYTextViewTouchedStateNone || !_delegateFlags.didLongPressedTextHighlight) {
        [self endLongPressTimer];
        return;
    }
    if (_longPressTimerCount * kLongPressTimerInterval >= _longPressDuring) {
        _touchState = TYTextViewTouchedStateLongPressed;
        TYTextHighlight *highlight = _textHighlight;
        [self endLongPressTimer];
        [((id<TYTextViewDelegate>)self.delegate) textView:self didLongPressedTextHighlight:highlight];
        [self endTouch];
    }
}

#pragma mark - Touch Event

- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    _touchState = TYTextViewTouchedStateNone;
    _beginTouchPiont = CGPointZero;
    if (!_textRender || self.isEditable) {
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
    _touchState = TYTextViewTouchedStateTapped;
    if (_delegateFlags.didLongPressedTextHighlight) {
        [self startLongPressTimer];
    }
    [self immediatelyDisplayRedraw];
}

- (void)touchesMoved:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    if (!_textRender || !_textHighlight || self.isEditable) {
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
    if (!_textRender || !_textHighlight || self.isEditable) {
        [self endLongPressTimer];
        [super touchesEnded:touches withEvent:event];
        return;
    }
    UITouch *touch = touches.anyObject;
    CGPoint point = [touch locationInView:self];
    NSRange range = NSMakeRange(0, 0);
    if (_delegateFlags.didTappedTextHighlight && _touchState == TYTextViewTouchedStateTapped) {
        TYTextHighlight *textHighlight = [self textHighlightForPoint:point effectiveRange:&range];
        if (textHighlight == _textHighlight && NSEqualRanges(range, _highlightRange)) {
            [((id<TYTextViewDelegate>)self.delegate) textView:self didTappedTextHighlight:_textHighlight];
        }
    }
    [self endTouch];
}

- (void)touchesCancelled:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    if (!_textRender || !_textHighlight || self.isEditable) {
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
    _touchState = TYTextViewTouchedStateNone;
    _beginTouchPiont = CGPointZero;
}

- (void)layoutSubviews {
    [super layoutSubviews];
    [self addAttachmentViews];
}

#pragma mark - NSTextStorageDelegate

- (void)textStorage:(NSTextStorage *)textStorage didProcessEditing:(NSTextStorageEditActions)editedMask range:(NSRange)editedRange changeInLength:(NSInteger)delta {
    [self configireTextStorage:textStorage];
    [self textAtrributedDidChange];

    NSRange invalidatedRange = NSMakeRange(editedRange.location, MAX(editedRange.length, 0));
    if (_delegateFlags.processEditingForTextStorage) {
        [((id<TYTextViewDelegate>)self.delegate) textView:self processEditingForTextStorage:textStorage edited:editedMask range:editedRange changeInLength:delta invalidatedRange:invalidatedRange];
    }
    // 文本变更后，下一次 layoutSubviews 会同步附件视图。
    [self setNeedsLayout];
}

@end

@interface TYGrowingTextView () {
    BOOL _textDidChange;
}

@property (nonatomic, weak) UILabel *placeHolderLabel;
@property (nonatomic, assign) CGFloat textHeight;
@property (nonatomic, assign) CGFloat maxTextHeight;

@end

@implementation TYGrowingTextView

- (instancetype)initWithFrame:(CGRect)frame textRender:(TYTextRender *)textRender {
    if (self = [super initWithFrame:frame textRender:textRender]) {
        [self configureGrowingTextView];
        [self addPlaceHolderLabel];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(textDidChange:) name:UITextViewTextDidChangeNotification object:nil];
    }
    return self;
}

- (instancetype)initWithCoder:(NSCoder *)coder {
    if (self = [super initWithCoder:coder]) {
        [self configureGrowingTextView];
        [self addPlaceHolderLabel];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(textDidChange:) name:UITextViewTextDidChangeNotification object:nil];
    }
    return self;
}

- (void)configureGrowingTextView {
    _maxNumOfLines = 0;
    _maxTextHeight = 0;
    _maxTextLength = 0;
    _textDidChange = NO;
    self.scrollsToTop = NO;
    self.showsHorizontalScrollIndicator = NO;
    self.enablesReturnKeyAutomatically = YES;
}

- (void)addPlaceHolderLabel {
    UILabel *placeHolderLabel = [[UILabel alloc] init];
    placeHolderLabel.userInteractionEnabled = NO;
    placeHolderLabel.font = self.font ? self.font : [UIFont systemFontOfSize:12];
    placeHolderLabel.textAlignment = NSTextAlignmentLeft;
    [self addSubview:placeHolderLabel];
    _placeHolderLabel = placeHolderLabel;
}

#pragma mark - Getter && Setter

- (void)setTextAlignment:(NSTextAlignment)textAlignment {
    BOOL change = self.textAlignment == textAlignment;
    [super setTextAlignment:textAlignment];
    if (change && self.superview) {
        [self setNeedsLayout];
    }
}

- (void)setMaxNumOfLines:(NSUInteger)maxNumOfLines {
    _maxNumOfLines = maxNumOfLines;
    self.textRender.textContainer.maximumNumberOfLines = maxNumOfLines;
}

- (void)textAtrributedDidChange {
    _textDidChange = YES;
    [self textDidChange];
}

#pragma mark - Notification

- (void)textDidChange:(NSNotification *)notification {
    if (!_textDidChange) {
        [self textDidChange];
    }
    _textDidChange = NO;
}

- (void)textDidChange {
    self.placeHolderLabel.hidden = self.textStorage.length > 0;
    if (_fisrtCharacterIgnoreBreak && self.text.length == 1) {
        if ([self.text isEqualToString:@"\n"]) {
            self.text = @"";
        }
    }

    if (_maxTextLength > 0) {
        NSTextStorage *current = self.textStorage;
        UITextRange *selectedRange = [self markedTextRange];
        UITextPosition *position = [self positionFromPosition:selectedRange.start offset:0];
        if (!position && current.length > _maxTextLength) {
            NSAttributedString *trimmed = [current attributedSubstringFromRange:NSMakeRange(0, _maxTextLength)];
            [current setAttributedString:trimmed];
        }
    }

    if ([_growingTextDelegate respondsToSelector:@selector(growingTextViewDidChangeText:)]) {
        [_growingTextDelegate growingTextViewDidChangeText:self];
    }
    if (![_growingTextDelegate respondsToSelector:@selector(growingTextView:didChangeTextHeight:)]) {
        return;
    }
    CGFloat height = ceilf([self sizeThatFits:CGSizeMake(self.bounds.size.width, MAXFLOAT)].height);
    if (_textHeight != height) {
        if (_maxTextHeight > 0) {
            self.scrollEnabled = height > _maxTextHeight;
        }
        _textHeight = height;
        if (!self.scrollEnabled) {
            [_growingTextDelegate growingTextView:self didChangeTextHeight:height];
        }
    }
}

- (void)layoutSubviews {
    [super layoutSubviews];

    CGFloat orignX, width;
    CGRect beginRect = [self caretRectForPosition:self.beginningOfDocument];
    if (self.textAlignment != NSTextAlignmentRight) {
        orignX = _placeHolderEdge.left + self.contentInset.left + self.textRender.lineFragmentPadding;
        width = CGRectGetWidth(self.frame) - _placeHolderEdge.right - orignX - self.contentInset.right;
    } else {
        [_placeHolderLabel sizeToFit];
        orignX = CGRectGetWidth(self.frame) - CGRectGetWidth(_placeHolderLabel.frame) - _placeHolderEdge.left - self.textRender.lineFragmentPadding - self.contentInset.left;
        width = orignX - (CGRectGetWidth(self.frame) - orignX) - _placeHolderEdge.right - self.contentInset.right;
    }
    _placeHolderLabel.frame = CGRectMake(orignX, beginRect.origin.y + _placeHolderEdge.top, width, beginRect.size.height - _placeHolderEdge.bottom);
    _placeHolderLabel.hidden = self.textStorage.length > 0;
}

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

@end
