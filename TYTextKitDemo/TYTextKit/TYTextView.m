//
//  TYTextView.m
//  TYTextKitDemo
//
//  Created by tany on 2017/10/19.
//  Copyright © 2017年 tany. All rights reserved.
//

#import "TYTextView.h"
#import <pthread.h>

#define TYAssertMainThread() NSAssert(0 != pthread_main_np(), @"This method must be called on the main thread!")

@interface TYTextView ()<TYLayoutManagerEditRender>

@property (nonatomic, strong) TYTextRender *textRender;

@property (nonatomic, strong) NSArray *attachments;

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
    if ([textRender.layoutManager isKindOfClass:[TYLayoutManager class]]) {
        ((TYLayoutManager *)textRender.layoutManager).render = self;
    }
    textRender.editable = YES;
    _textRender = textRender;
}

#pragma mark - private

- (void)addAttachmentViews {
    TYAssertMainThread();
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
    [self textAtrributedDidChange];
    if (delta < 0 && newCharRange.location == 0 && newCharRange.length == 0) {
        [self addAttachmentViews];
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
    }
    return self;
}

- (void)configureGrowingTextView {
    _textDidChange = NO;
    self.scrollsToTop = NO;
    self.showsHorizontalScrollIndicator = NO;
    self.enablesReturnKeyAutomatically = YES;
    
    [self addPlaceHolderLabel];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(textDidChange:) name:UITextViewTextDidChangeNotification object:nil];
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

- (void)setMaxNumOfLines:(NSUInteger)maxNumOfLines {
    _maxNumOfLines = maxNumOfLines;
    _maxTextHeight = ceil(self.font.lineHeight * maxNumOfLines + self.textContainerInset.top + self.textContainerInset.bottom);
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
    self.placeHolderLabel.hidden = self.text.length > 0;
        if (_fisrtCharacterIgnoreBreak && self.text.length == 1) {
            if ([self.text isEqualToString:@"\n"]) {
                self.text = @"";
            }
        }
    
    if (_maxTextLength > 0) {
        // 只有当maxLength字段的值不为无穷大整型也不为0时才计算限制字符数.
        NSString    *toBeString    = self.text;
        UITextRange *selectedRange = [self markedTextRange];
        UITextPosition *position   = [self positionFromPosition:selectedRange.start offset:0];
        if (!position) {
            if (toBeString.length > _maxTextLength) {
                self.text = [toBeString substringToIndex:_maxTextLength]; // 截取最大限制字符数.
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
        if (_maxTextHeight > 0 || _maxNumOfLines > 0) {
            self.scrollEnabled = _maxNumOfLines > 0 && height > _maxTextHeight;
        }
        _textHeight = height;
        if (!self.scrollEnabled) {
            [_growingTextDelegate growingTextView:self didChangeTextHeight:height];
        }
    }
}

- (void)layoutSubviews {
    [super layoutSubviews];
    CGRect beginRect = [self caretRectForPosition:self.beginningOfDocument];
    _placeHolderLabel.frame = CGRectMake(beginRect.origin.x + _placeHolderEdge.left, beginRect.origin.y + _placeHolderEdge.top, CGRectGetWidth(self.frame)-_placeHolderEdge.left - _placeHolderEdge.right - beginRect.origin.x - beginRect.origin.y, beginRect.size.height - _placeHolderEdge.bottom);
    _placeHolderLabel.hidden = self.text.length > 0;
}

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

@end
