//
//  TYTextView.m
//  TYTextKitDemo
//
//  Created by tany on 2017/10/19.
//  Copyright © 2017年 tany. All rights reserved.
//

#import "TYTextView.h"

@interface TYTextView ()<TYLayoutManagerEditRender> {
    struct {
        unsigned int shouldInsertText : 1;
        unsigned int shouldInsertAttributedText : 1;
        unsigned int processEditingForTextStorage : 1;
    }_delegateFlags;
}

@property (nonatomic, strong) TYTextRender *textRender;

@property (nonatomic, strong) NSArray *attachments;

// override
- (void)textAtrributedDidChange;

@end

@implementation TYTextView

- (instancetype)initWithFrame:(CGRect)frame textRender:(TYTextRender *)textRender {
    if (self = [super initWithFrame:frame textContainer:textRender.textContainer]) {
        self.textRender = textRender;
        self.autocorrectionType = UITextAutocorrectionTypeNo;
        self.text = @"";
    }
    return self;
}

- (instancetype)initWithFrame:(CGRect)frame textContainer:(NSTextContainer *)textContainer {
    TYTextRender *textRender = [[TYTextRender alloc]initWithTextContainer:textContainer];
    if (self = [self initWithFrame:frame textRender:textRender]) {
    }
    return self;
}

- (instancetype)initWithFrame:(CGRect)frame {
    if (self = [self initWithFrame:frame textRender:[self defaultTextRender]]) {
    }
    return self;
}

#pragma mark - getter && setter

- (TYTextRender *)defaultTextRender {
    NSTextStorage *textStorage = [[TYTextStorage alloc]init];
    TYTextRender *textRender = [[TYTextRender alloc]initWithTextStorage:textStorage];
    textRender.lineFragmentPadding = 5.0;
    return textRender;
}

- (void)setTextRender:(TYTextRender *)textRender {
    if ([textRender.layoutManager isKindOfClass:[TYLayoutManager class]]) {
        ((TYLayoutManager *)textRender.layoutManager).render = self;
    }
    textRender.editable = YES;
    _textRender = textRender;
}

- (void)setDelegate:(id<UITextViewDelegate>)delegate {
    [super setDelegate:delegate];
    _delegateFlags.shouldInsertText = [delegate respondsToSelector:@selector(textView:shouldInsertText:)];
    _delegateFlags.shouldInsertAttributedText = [delegate respondsToSelector:@selector(textView:shouldInsertAttributedText:)];
    _delegateFlags.processEditingForTextStorage = [delegate respondsToSelector:@selector(textView:processEditingForTextStorage:edited:range:changeInLength:invalidatedRange:)];
}

#pragma mark - public

- (void)insertText:(NSString *)text {
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
    
    if (self.selectedRange.length > 0) {
        [_textRender.textStorage replaceCharactersInRange:self.selectedRange withAttributedString:attributedText];
    }else {
        [_textRender.textStorage insertAttributedString:attributedText atIndex:self.selectedRange.location];
    }
    self.selectedRange = NSMakeRange(self.selectedRange.location+attributedText.length, 0);
}

#pragma mark - private

- (void)ifNeedSetTextPropertys:(NSTextStorage *)textStorage {
    if (_ignoreAboveTextRelatedPropertys) {
        return;
    }
    //textStorage.ty_font = self.font;
    textStorage.ty_lineBreakMode = _lineBreakMode;
    textStorage.ty_characterSpacing = _characterSpacing;
    textStorage.ty_lineSpacing = _lineSpacing;
    textStorage.ty_alignment = self.textAlignment;
}

- (void)addAttachmentViews {
    NSArray *attachments = _textRender.attachmentViews;
    if (!_attachments && !attachments) {
        return;
    }
    NSSet *attachmentSet = [NSSet setWithArray:attachments];
    for (TYTextAttachment *attachment in _attachments) {
        if (!attachmentSet || ![attachmentSet containsObject:attachment]) {
            [attachment removeFromSuperView:self];
        }
    }
    NSRange visibleRange = [_textRender visibleCharacterRange];
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
}

- (void)textAtrributedDidChange {
    
}

#pragma mark - TYLayoutManagerEditRender

- (void)layoutManager:(TYLayoutManager *)layoutManager processEditingForTextStorage:(NSTextStorage *)textStorage edited:(NSTextStorageEditActions)editMask range:(NSRange)newCharRange changeInLength:(NSInteger)delta invalidatedRange:(NSRange)invalidatedCharRange {
    [self ifNeedSetTextPropertys:textStorage];
    
    [self textAtrributedDidChange];
    
    if (delta < 0 && newCharRange.location == 0 && newCharRange.length == 0) {
        [self addAttachmentViews];
    }
    
    if (_delegateFlags.processEditingForTextStorage) {
        [((id<TYTextViewDelegate>)self.delegate) textView:self processEditingForTextStorage:textStorage edited:editMask range:newCharRange changeInLength:delta invalidatedRange:invalidatedCharRange];
    }
}

- (void)layoutManager:(TYLayoutManager *)layoutManager drawGlyphsForGlyphRange:(NSRange)glyphsToShow atPoint:(CGPoint)origin {
    [self addAttachmentViews];
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
    UILabel *placeHolderLabel = [[UILabel alloc]init];
    placeHolderLabel.userInteractionEnabled = NO;
    placeHolderLabel.font = self.font ? self.font : [UIFont systemFontOfSize:12];
    placeHolderLabel.textAlignment = NSTextAlignmentLeft;
    [self addSubview:placeHolderLabel];
    _placeHolderLabel = placeHolderLabel;
}

#pragma mark - getter && setter

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
    // 占位文字是否显示
    self.placeHolderLabel.hidden = self.textStorage.length > 0;
        if (_fisrtCharacterIgnoreBreak && self.text.length == 1) {
            if ([self.text isEqualToString:@"\n"]) {
                self.text = @"";
            }
        }
    
    if (_maxTextLength > 0) {
        // 只有当maxLength字段的值不为无穷大整型也不为0时才计算限制字符数.
        NSTextStorage *toBeString    = self.textStorage;
        UITextRange *selectedRange = [self markedTextRange];
        UITextPosition *position   = [self positionFromPosition:selectedRange.start offset:0];
        if (!position) {
            if (toBeString.length > _maxTextLength) {
                // 截取最大限制字符数
                NSAttributedString *attStr = [toBeString attributedSubstringFromRange:NSMakeRange(0,_maxTextLength)];
                self.textRender.textStorage = [[[self.textRender.textStorage class] alloc]initWithAttributedString:attStr];
                if ([self.textRender.textStorage isKindOfClass:[TYTextStorage class]] && [toBeString isKindOfClass:[TYTextStorage class]]) {
                    ((TYTextStorage *)self.textRender.textStorage).textParse = ((TYTextStorage *)toBeString).textParse;
                }
            }
        }
    }

    if ([_growingTextDelegate respondsToSelector:@selector(growingTextViewDidChangeText:)]) {
        [_growingTextDelegate growingTextViewDidChangeText:self];
    }
    
    if (![_growingTextDelegate respondsToSelector:@selector(growingTextView:didChangeTextHeight:)]) {
        return;
    }
    CGFloat height = ceilf([self sizeThatFits:CGSizeMake(self.bounds.size.width, MAXFLOAT)].height);
    if (_textHeight != height) { // 高度不一样，就改变了高度
        // 最大高度，可以滚动
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
    
    // placeHolderLabel
    CGFloat orignX, width;
    CGRect beginRect = [self caretRectForPosition:self.beginningOfDocument];
    if (self.textAlignment != NSTextAlignmentRight) {
        orignX = _placeHolderEdge.left+self.contentInset.left+self.textRender.lineFragmentPadding;
        width = CGRectGetWidth(self.frame) - _placeHolderEdge.right - orignX - self.contentInset.right;
    }else {
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
