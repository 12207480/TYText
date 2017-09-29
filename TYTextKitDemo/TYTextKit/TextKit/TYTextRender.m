//
//  TYTextRender.m
//  TYTextKitDemo
//
//  Created by tany on 2017/9/26.
//  Copyright © 2017年 tany. All rights reserved.
//

#import "TYTextRender.h"

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

#pragma mark - draw text

- (CGPoint)textOffsetForGlyphRange:(NSRange)glyphRange inRect:(CGRect)rect
{
    CGPoint textOffset = CGPointZero;
    CGRect textBounds = [_layoutManager boundingRectForGlyphRange:glyphRange
                                                      inTextContainer:_textContainer];
    CGFloat paddingHeight = (rect.size.height - ceil(textBounds.size.height)) / 2.0f;
    textOffset.y = paddingHeight;
    return textOffset;
}

- (void)drawTextInRect:(CGRect)rect
{
    // calculate the offset of the text in the view
    NSRange glyphRange = [_layoutManager glyphRangeForTextContainer:_textContainer];
    CGPoint textOffset = [self textOffsetForGlyphRange:glyphRange inRect:rect];
    
    // drawing code
    [_layoutManager drawBackgroundForGlyphRange:glyphRange atPoint:textOffset];
    [_layoutManager drawGlyphsForGlyphRange:glyphRange atPoint:textOffset];
}

@end
