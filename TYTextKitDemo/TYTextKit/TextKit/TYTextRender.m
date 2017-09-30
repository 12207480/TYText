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

@end

@implementation TYTextRender

- (instancetype)init {
    if (self = [super init]) {
        [self addTextContainer];
        [self addLayoutManager];
    }
    return self;
}

- (instancetype)initWithTextContainer:(NSTextContainer *)textContainer {
    if (self = [super init]) {
        NSParameterAssert(textContainer.layoutManager);
        _textContainer = textContainer;
        _layoutManager = textContainer.layoutManager;
        if (_layoutManager.textStorage) {
            _textStorage = _layoutManager.textStorage;
        }
    }
    return self;
}

- (instancetype)initWithTextStorage:(NSTextStorage *)textStorage {
    if (self = [self init]) {
        [textStorage addLayoutManager:_layoutManager];
        _textStorage = textStorage;
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
    if (_textStorage) {
        [_textStorage removeLayoutManager:_layoutManager];
    }
    [textStorage addLayoutManager:_layoutManager];
    _textStorage = textStorage;
}

- (void)setSize:(CGSize)size {
    _size = size;
    if (!CGSizeEqualToSize(_textContainer.size, size)) {
        _textContainer.size = size;
    }
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

- (CGRect)usedBoundingRect {
    return [_layoutManager boundingRectForGlyphRange:[self visibleGlyphRange]
                                     inTextContainer:_textContainer];
}

#pragma mark - draw text

- (CGPoint)textOffsetForGlyphRange:(NSRange)glyphRange atPiont:(CGPoint)point
{
    if (point.y > 0) {
        return point;
    }
    CGPoint textOffset = point;
    CGRect textBounds = [_layoutManager boundingRectForGlyphRange:glyphRange
                                                  inTextContainer:_textContainer];
    CGFloat paddingHeight = (_textContainer.size.height - ceil(textBounds.size.height)) / 2.0f;
    textOffset.y = paddingHeight;
    return textOffset;
}

- (void)drawTextAtPoint:(CGPoint)point {
    [self drawTextAtPoint:point isCanceled:nil];
}
- (void)drawTextAtPoint:(CGPoint)point isCanceled:(BOOL (^)(void))isCanceled
{
    // calculate the offset of the text in the view
    NSRange glyphRange = [self visibleGlyphRange];
    CGPoint textOffset = [self textOffsetForGlyphRange:glyphRange atPiont:point];
    // drawing text
    [_layoutManager enumerateLineFragmentsForGlyphRange:glyphRange usingBlock:^(CGRect rect, CGRect usedRect, NSTextContainer * _Nonnull textContainer, NSRange glyphRange, BOOL * _Nonnull stop) {
        [_layoutManager drawBackgroundForGlyphRange:glyphRange atPoint:textOffset];
        if (isCanceled && isCanceled()) *stop = YES;
        [_layoutManager drawGlyphsForGlyphRange:glyphRange atPoint:textOffset];
        if (isCanceled && isCanceled()) *stop = YES;
    }];
}

@end
