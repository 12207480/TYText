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

@interface TYTextRender ()

@property (nonatomic, strong) NSLayoutManager *layoutManager;
@property (nonatomic, strong) NSTextContainer *textContainer;

@property (nonatomic, strong) NSTextStorage *textStorageOnRender;

@end

@implementation TYTextRender

- (instancetype)init {
    if (self = [super init]) {
        [self addTextContainer];
        [self addLayoutManager];
    }
    return self;
}

- (instancetype)initWithAttributedText:(NSAttributedString *)attributedText {
    NSTextStorage *textStorage = [[TYTextStorage alloc]initWithAttributedString:attributedText];;
    if (self = [self initWithTextStorage:textStorage]) {
    }
    return self;
}

- (instancetype)initWithTextStorage:(NSTextStorage *)textStorage {
    if (self = [self init]) {
        [textStorage addLayoutManager:_layoutManager];
        _textStorage = textStorage;
        _textStorageOnRender = textStorage;
    }
    return self;
}

- (instancetype)initWithTextContainer:(NSTextContainer *)textContainer {
    if (self = [super init]) {
        NSParameterAssert(textContainer.layoutManager);
        _textContainer = textContainer;
        _layoutManager = textContainer.layoutManager;
        _textStorage = _layoutManager.textStorage;
        _textStorageOnRender = _textStorage;
    }
    return self;
}

- (void)addTextContainer {
    NSTextContainer *textContainer = [[NSTextContainer alloc]init];
    textContainer.lineFragmentPadding = 0;
    _textContainer = textContainer;
}

- (void)addLayoutManager {
    NSLayoutManager *layoutManager = [[NSLayoutManager alloc]init];
    [layoutManager addTextContainer:_textContainer];
    _layoutManager = layoutManager;
}

#pragma mark - getter setter

- (void)setTextStorage:(NSTextStorage *)textStorage {
    _textStorage = textStorage;
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
    }
}

- (void)setTextHighlight:(TYTextHighlight *)textHighlight range:(NSRange)range {
    if (!textHighlight || range.length == 0) {
        self.textStorageOnRender = _textStorage;
        return;
    }
    NSTextStorage *highlightStorage = nil;
    if ([_textStorage isKindOfClass:[TYTextStorage class]]) {
        highlightStorage = [_textStorage copy];
        [highlightStorage addTextAttribute:textHighlight range:range];
    }else {
        NSMutableAttributedString *string = [[_textStorage attributedSubstringFromRange:NSMakeRange(0, _textStorage.length)] mutableCopy];
        [string addTextAttribute:textHighlight range:range];
        highlightStorage = [[NSTextStorage alloc]initWithAttributedString:string];
    }
    self.textStorageOnRender = highlightStorage;
}

#pragma mark - public

- (NSArray *)attachViews {
    return _textStorage.attachViews;
}

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
    return [_layoutManager boundingRectForGlyphRange:[self visibleGlyphRange]
                                     inTextContainer:_textContainer];
}

- (NSInteger)characterIndexForPoint:(CGPoint)point{
    CGRect textRect = _textRect;
    if (!CGRectContainsPoint(textRect, point)) {
        return -1;
    }
    CGPoint realPoint = CGPointMake(point.x - textRect.origin.x, point.y - textRect.origin.y);
    CGFloat distanceToPoint = 1.0;
    NSUInteger index = [_layoutManager characterIndexForPoint:realPoint inTextContainer:_textContainer fractionOfDistanceBetweenInsertionPoints:&distanceToPoint];
    return distanceToPoint < 1 ? index : -1;
}

#pragma mark - draw text

- (CGRect)textRectForGlyphRange:(NSRange)glyphRange atPiont:(CGPoint)point
{
    if (glyphRange.length == 0) {
        return CGRectZero;
    }
    CGPoint textOffset = point;
    CGRect textBounds = [_layoutManager boundingRectForGlyphRange:glyphRange
                                                  inTextContainer:_textContainer];
    CGSize textSize = CGSizeMake(ceil(textBounds.size.width), ceil(textBounds.size.height));
    if (point.y == 0) {
        textOffset.y = (_textContainer.size.height - ceil(textSize.height)) / 2.0f;
    }
    CGRect textRect = {textOffset,textSize};
    return textRect;
}

- (void)drawTextAtPoint:(CGPoint)point {
    [self drawTextAtPoint:point isCanceled:nil];
}
- (void)drawTextAtPoint:(CGPoint)point isCanceled:(BOOL (^)(void))isCanceled
{
    // calculate the offset of the text in the view
    NSRange glyphRange = [self visibleGlyphRange];
    CGRect textRect = [self textRectForGlyphRange:glyphRange atPiont:point];
    _textRect = textRect;
    // drawing text
    [_layoutManager enumerateLineFragmentsForGlyphRange:glyphRange usingBlock:^(CGRect rect, CGRect usedRect, NSTextContainer * _Nonnull textContainer, NSRange glyphRange, BOOL * _Nonnull stop) {
        [_layoutManager drawBackgroundForGlyphRange:glyphRange atPoint:textRect.origin];
        if (isCanceled && isCanceled()) {
            *stop = YES;
            return;
        }
        [_layoutManager drawGlyphsForGlyphRange:glyphRange atPoint:textRect.origin];
        if (isCanceled && isCanceled()) {
            *stop = YES;
            return;
        }
    }];
}

@end
