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
    NSTextStorage *textStorage = [[NSTextStorage alloc]initWithAttributedString:attributedText];
    if (self = [self initWithTextStorage:textStorage]) {
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

#pragma mark - getter setter

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
            _textBound =  [_layoutManager boundingRectForGlyphRange:[self visibleGlyphRange]
                                                    inTextContainer:_textContainer];
        }
    }
}

- (NSInteger)numberOfLines {
    __block NSInteger lineCount = 0;
    NSRange glyphRange = [self visibleGlyphRange];
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

#pragma mark - public

- (NSRange)visibleGlyphRange {
    return [_layoutManager glyphRangeForTextContainer:_textContainer];
}

- (NSRange)visibleCharacterRange {
    return [_layoutManager characterRangeForGlyphRange:[self visibleGlyphRange] actualGlyphRange:nil];
}

- (CGRect)boundingRectForCharacterRange:(NSRange)characterRange {
    NSRange glyphRange = [_layoutManager glyphRangeForCharacterRange:characterRange actualCharacterRange:nil];
    return [_layoutManager boundingRectForGlyphRange:glyphRange
                                     inTextContainer:_textContainer];
}

- (CGRect)textBound {
    if (_onlySetRenderSizeWillGetTextBounds && !CGRectIsEmpty(_textBound) && !_editable) {
        return _textBound;
    }
    return [_layoutManager boundingRectForGlyphRange:[self visibleGlyphRange]
                                     inTextContainer:_textContainer];
}

- (CGSize)textSizeWithRenderWidth:(CGFloat)renderWidth {
    CGSize size = _textContainer.size;
    _textContainer.size = CGSizeMake(renderWidth, MAXFLOAT);
    CGSize textSize = [_layoutManager boundingRectForGlyphRange:[self visibleGlyphRange]
                                            inTextContainer:_textContainer].size;
    _textContainer.size = size;
    return CGSizeMake(ceil(textSize.width), ceil(textSize.height));
}

- (NSInteger)characterIndexForPoint:(CGPoint)point{
    CGRect textRect = _textRectOnRender;
    if (!CGRectContainsPoint(textRect, point)) {
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
    if ([_layoutManager isKindOfClass:[TYLayoutManager class]]) {
        ((TYLayoutManager *)_layoutManager).highlightRange = range;
    }
    if (!textHighlight || range.length == 0) {
        self.textStorageOnRender = _textStorage;
        return;
    }
    NSTextStorage *highlightStorage = nil;
    if ([_textStorage isKindOfClass:[TYTextStorage class]]) {
        highlightStorage = [_textStorage copy];
        [highlightStorage addTextAttribute:textHighlight range:range];
    }else {
        NSMutableAttributedString *string = [_textStorage mutableCopy];
        [string addTextAttribute:textHighlight range:range];
        highlightStorage = [[NSTextStorage alloc]initWithAttributedString:string];
    }
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
        textBound = [_layoutManager boundingRectForGlyphRange:glyphRange
                                               inTextContainer:_textContainer];
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
    NSRange glyphRange = [self visibleGlyphRange];
    _visibleCharacterRangeOnRender = [_layoutManager characterRangeForGlyphRange:glyphRange actualGlyphRange:NULL];
    _textRectOnRender = [self textRectForGlyphRange:glyphRange atPiont:point];
    CGPoint positon = _textRectOnRender.origin;
    
    // drawing text
    [_layoutManager enumerateLineFragmentsForGlyphRange:glyphRange usingBlock:^(CGRect rect, CGRect usedRect, NSTextContainer * _Nonnull textContainer, NSRange glyphRange, BOOL * _Nonnull stop) {
        [_layoutManager drawBackgroundForGlyphRange:glyphRange atPoint:positon];
        if (isCanceled && isCanceled()) {*stop = YES; return ;};
        [_layoutManager drawGlyphsForGlyphRange:glyphRange atPoint:positon];
        if (isCanceled && isCanceled()) {*stop = YES; return ;};
    }];
}

@end

