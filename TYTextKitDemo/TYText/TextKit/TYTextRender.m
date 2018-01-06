//
//  TYTextRender.m
//  TYTextKitDemo
//
//  Created by tany on 2017/9/26.
//  Copyright © 2017年 tany. All rights reserved.
//

#import "TYTextRender.h"
#import <pthread.h>

#define TYAssertMainThread() NSAssert(0 != pthread_main_np(), @"This method must be called on the main thread!")

@interface TYTextRender () {
    CGRect _textBound;
    NSArray *_attachmentViews;
    NSSet *_attachmentViewSet;
}

@property (nonatomic, strong) NSLayoutManager *layoutManager;
@property (nonatomic, strong) NSTextContainer *textContainer;
@property (nonatomic, strong) NSTextStorage *textStorageOnRender;

@property (nonatomic, assign) CGRect textRectOnRender;
@property (nonatomic, assign) NSRange visibleCharacterRangeOnRender;
@property (nonatomic, assign) NSRange truncatedCharacterRangeOnRender;

@end

@implementation TYTextRender

- (instancetype)init {
    if (self = [super init]) {
        _onlySetTextStorageWillGetAttachViews = YES;
        [self addTextContainer];
        [self addLayoutManager];
        [self configureRender];
    }
    return self;
}

- (instancetype)initWithAttributedText:(NSAttributedString *)attributedText {
    if (self = [self initWithTextStorage:[[NSTextStorage alloc]initWithAttributedString:attributedText]]) {
    }
    return self;
}

- (instancetype)initWithTextStorage:(NSTextStorage *)textStorage {
    if (self = [self init]) {
        self.textStorage = textStorage;
    }
    return self;
}

- (instancetype)initWithTextContainer:(NSTextContainer *)textContainer {
    if (self = [super init]) {
        NSParameterAssert(textContainer.layoutManager);
        _onlySetTextStorageWillGetAttachViews = YES;
        _textContainer = textContainer;
        _layoutManager = textContainer.layoutManager;
        self.textStorage = _layoutManager.textStorage;
        [self configureRender];
    }
    return self;
}

- (void)addTextContainer {
    NSTextContainer *textContainer = [[NSTextContainer alloc]init];
    _textContainer = textContainer;
}

- (void)addLayoutManager {
    TYLayoutManager *layoutManager = [[TYLayoutManager alloc]init];
    [layoutManager addTextContainer:_textContainer];
    _layoutManager = layoutManager;
}

- (void)configureRender {
    self.highlightBackgroudRadius = 4;
    self.lineFragmentPadding = 0;
}

#pragma mark - Getter && Setter

- (void)setTextStorage:(NSTextStorage *)textStorage {
    _textStorage = textStorage;
    if (_onlySetTextStorageWillGetAttachViews && !_editable) {
        self.attachmentViews = textStorage.attachmentViews;
    }
    self.textStorageOnRender = textStorage;
}

- (void)setTextStorageOnRender:(NSTextStorage *)textStorageOnRender {
    if (textStorageOnRender == _textStorageOnRender) {
        return;
    }
    if (_textStorageOnRender) {
        [_textStorageOnRender removeLayoutManager:_layoutManager];
    }
    [textStorageOnRender addLayoutManager:_layoutManager];
    _textStorageOnRender = textStorageOnRender;
}

- (void)setSize:(CGSize)size {
    _size = size;
    if (!CGSizeEqualToSize(_textContainer.size, size)) {
        _textContainer.size = size;
        if (_onlySetRenderSizeWillGetTextBounds && !_editable) {
            _textBound =  [self boundingRectForGlyphRange:[self visibleGlyphRange]];
        }
    }
}

- (NSInteger)numberOfLines {
    __block NSInteger lineCount = 0;
    NSRange glyphRange = [_layoutManager glyphRangeForTextContainer:_textContainer];
    [_layoutManager enumerateLineFragmentsForGlyphRange:glyphRange usingBlock:^(CGRect rect, CGRect usedRect, NSTextContainer * _Nonnull textContainer, NSRange glyphRange, BOOL * _Nonnull stop) {
        ++lineCount;
    }];
    return lineCount;
}

-(CGFloat)lineFragmentPadding {
    return _textContainer.lineFragmentPadding;
}
- (void)setLineFragmentPadding:(CGFloat)lineFragmentPadding {
    _textContainer.lineFragmentPadding = lineFragmentPadding;
}

-(NSLineBreakMode)lineBreakMode {
    return _textContainer.lineBreakMode;
}
- (void)setLineBreakMode:(NSLineBreakMode)lineBreakMode {
    if (_textContainer.lineBreakMode == lineBreakMode) {
        return;
    }
    _textContainer.lineBreakMode = lineBreakMode;
}

- (NSUInteger)maximumNumberOfLines {
    return _textContainer.maximumNumberOfLines;
}
- (void)setMaximumNumberOfLines:(NSUInteger)maximumNumberOfLines {
    if (_textContainer.maximumNumberOfLines == maximumNumberOfLines) {
        return;
    }
    _textContainer.maximumNumberOfLines = maximumNumberOfLines;
}

- (void)setHighlightBackgroudRadius:(CGFloat)highlightBackgroudRadius {
    _highlightBackgroudRadius = highlightBackgroudRadius;
    if ([_layoutManager isKindOfClass:[TYLayoutManager class]]) {
        ((TYLayoutManager *)_layoutManager).highlightBackgroudRadius = highlightBackgroudRadius;
    }
}

- (void)setHighlightBackgroudInset:(UIEdgeInsets)highlightBackgroudInset {
    _highlightBackgroudInset = highlightBackgroudInset;
    if ([_layoutManager isKindOfClass:[TYLayoutManager class]]) {
        ((TYLayoutManager *)_layoutManager).highlightBackgroudInset = highlightBackgroudInset;
    }
}

- (void)setAttachmentViews:(NSArray *)attachmentViews {
    _attachmentViews = attachmentViews;
    _attachmentViewSet = attachmentViews ? [NSSet setWithArray:attachmentViews] : nil;
}

- (NSArray *)attachmentViews {
    if (_onlySetTextStorageWillGetAttachViews && !_editable) {
        return _attachmentViews;
    }
    _attachmentViews = [_textStorage attachmentViews];
    return _attachmentViews;
}

- (NSSet *)attachmentViewSet {
    if (_onlySetTextStorageWillGetAttachViews && !_editable) {
        return _attachmentViewSet;
    }
    NSArray *attachmentViews = [_textStorage attachmentViews];
    _attachmentViewSet = attachmentViews ? [NSSet setWithArray:attachmentViews] : nil;
    return _attachmentViewSet;
}

#pragma mark - Public

- (NSRange)visibleGlyphRange {
    return [_layoutManager glyphRangeForTextContainer:_textContainer];
}

- (NSRange)visibleCharacterRange {
    return [_layoutManager characterRangeForGlyphRange:[self visibleGlyphRange] actualGlyphRange:nil];
}

- (CGRect)boundingRectForCharacterRange:(NSRange)characterRange {
    NSRange glyphRange = [_layoutManager glyphRangeForCharacterRange:characterRange actualCharacterRange:nil];
    return [self boundingRectForGlyphRange:glyphRange];
}

- (CGRect)boundingRectForGlyphRange:(NSRange)glyphRange {
    return [_layoutManager boundingRectForGlyphRange:glyphRange
                                     inTextContainer:_textContainer];
}

- (CGRect)textBound {
    if (_onlySetRenderSizeWillGetTextBounds && !CGRectIsEmpty(_textBound) && !_editable) {
        return _textBound;
    }
    return [self boundingRectForGlyphRange:[self visibleGlyphRange]];
}

- (CGSize)textSizeWithRenderWidth:(CGFloat)renderWidth {
    if (!_textStorageOnRender) {
        return CGSizeZero;
    }
    CGSize size = _textContainer.size;
    _textContainer.size = CGSizeMake(renderWidth, MAXFLOAT);
    CGSize textSize = [self boundingRectForGlyphRange:[self visibleGlyphRange]].size;
    _textContainer.size = size;
    return CGSizeMake(ceil(textSize.width), ceil(textSize.height));
}

- (NSInteger)characterIndexForPoint:(CGPoint)point{
    CGRect textRect = _textRectOnRender;
    if (!CGRectContainsPoint(textRect, point) && !_editable) {
        return -1;
    }
    CGPoint realPoint = CGPointMake(point.x - textRect.origin.x, point.y - textRect.origin.y);
    CGFloat distanceToPoint = 1.0;
    NSUInteger index = [_layoutManager characterIndexForPoint:realPoint inTextContainer:_textContainer fractionOfDistanceBetweenInsertionPoints:&distanceToPoint];
    return distanceToPoint < 1 ? index : -1;
}

- (void)drawTextAtPoint:(CGPoint)point {
    [self drawTextAtPoint:point isCanceled:nil];
}

@end

@implementation TYTextRender (Rendering)

#pragma mark - draw text

- (void)setTextHighlight:(TYTextHighlight *)textHighlight range:(NSRange)range {
    if (!textHighlight || range.length == 0) {
        if ([_layoutManager isKindOfClass:[TYLayoutManager class]]) {
            TYLayoutManager *layoutManager = (TYLayoutManager *)_layoutManager;
            layoutManager.highlightRange = NSMakeRange(0, 0);
            layoutManager.highlightBackgroudInset = _highlightBackgroudInset;
            layoutManager.highlightBackgroudRadius = _highlightBackgroudRadius;
            layoutManager.highlightBackgroudRadius = _highlightBackgroudRadius;
        }
        self.textStorageOnRender = _textStorage;
        return;
    }
    if ([_layoutManager isKindOfClass:[TYLayoutManager class]]) {
        TYLayoutManager *layoutManager = (TYLayoutManager *)_layoutManager;
        layoutManager.highlightRange = range;
        layoutManager.highlightBackgroudInset = UIEdgeInsetsEqualToEdgeInsets(textHighlight.backgroudInset, UIEdgeInsetsZero)?_highlightBackgroudInset : textHighlight.backgroudInset;
        layoutManager.highlightBackgroudRadius = textHighlight.backgroudRadius > 0 ? textHighlight.backgroudRadius : _highlightBackgroudRadius;
    }
    NSTextStorage *highlightStorage = [_textStorage ty_deepCopy];
    [highlightStorage addTextAttribute:textHighlight range:range];
    self.textStorageOnRender = highlightStorage;
}

- (CGRect)textRectForGlyphRange:(NSRange)glyphRange atPiont:(CGPoint)point
{
    if (glyphRange.length == 0) {
        return CGRectZero;
    }
    CGPoint textOffset = point;
    CGRect textBound = _textBound;
    if (!_onlySetRenderSizeWillGetTextBounds || _editable || CGRectIsEmpty(textBound)) {
        textBound = [self boundingRectForGlyphRange:glyphRange];
    }
    CGSize textSize = CGSizeMake(ceil(textBound.size.width), ceil(textBound.size.height));
    switch (_verticalAlignment) {
        case TYTextVerticalAlignmentTop:
            textOffset.y = point.y;
            break;
        case TYTextVerticalAlignmentBottom:
            textOffset.y = (_textContainer.size.height - textSize.height);
            break;
        default:
            textOffset.y = (_textContainer.size.height - textSize.height) / 2.0;
            break;
    }
    textBound.origin = textOffset;
    textBound.size = textSize;
    return textBound;
}

- (void)drawTextAtPoint:(CGPoint)point isCanceled:(BOOL (^)(void))isCanceled
{
    // calculate the offset of the text in the view
    NSRange glyphRange = [_layoutManager glyphRangeForTextContainer:_textContainer];
    NSRange visibleCharacterRange = [_layoutManager characterRangeForGlyphRange:glyphRange actualGlyphRange:NULL];
    
    NSRange truncatedGlyphRange = [_layoutManager truncatedGlyphRangeInLineFragmentForGlyphAtIndex:NSMaxRange(visibleCharacterRange)-1];
    NSRange truncatedCharacterRange = [_layoutManager characterRangeForGlyphRange:truncatedGlyphRange actualGlyphRange:NULL];
    
    CGRect textRect = [self textRectForGlyphRange:glyphRange atPiont:point];
    _visibleCharacterRangeOnRender = visibleCharacterRange;
    _truncatedCharacterRangeOnRender = truncatedCharacterRange;
    _textRectOnRender = textRect;
    
    // drawing text
    [_layoutManager enumerateLineFragmentsForGlyphRange:glyphRange usingBlock:^(CGRect rect, CGRect usedRect, NSTextContainer * _Nonnull textContainer, NSRange glyphRange, BOOL * _Nonnull stop) {
        [_layoutManager drawBackgroundForGlyphRange:glyphRange atPoint:textRect.origin];
        if (isCanceled && isCanceled()) {*stop = YES; return ;};
        [_layoutManager drawGlyphsForGlyphRange:glyphRange atPoint:textRect.origin];
        if (isCanceled && isCanceled()) {*stop = YES; return ;};
    }];
}

@end

