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

#pragma mark - getter setter

- (void)setTextStorage:(NSTextStorage *)textStorage {
    if (_textStorage && _layoutManager) {
        [_textStorage removeLayoutManager:_layoutManager];
    }
    _textStorage = textStorage;
    [_textStorage addLayoutManager:self.layoutManager];
}

- (NSLayoutManager *)layoutManager {
    if (!_layoutManager) {
        _layoutManager = [[NSLayoutManager alloc]init];
        [_layoutManager addTextContainer:self.textContainer];
    }
    return _layoutManager;
}

- (NSTextContainer *)textContainer {
    if (!_textContainer) {
        _textContainer = [[NSTextContainer alloc]init];
        _textContainer.lineFragmentPadding = 0;
        _textContainer.size = _size;
    }
    return _textContainer;
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
    CGRect textBounds = [self.layoutManager boundingRectForGlyphRange:glyphRange
                                                      inTextContainer:self.textContainer];
    CGFloat paddingHeight = (rect.size.height - ceil(textBounds.size.height)) / 2.0f;
    textOffset.y = paddingHeight;
    return textOffset;
}

- (void)drawTextInRect:(CGRect)rect
{
    // Calculate the offset of the text in the view
    NSRange glyphRange = [self.layoutManager glyphRangeForTextContainer:self.textContainer];
    CGPoint textOffset = [self textOffsetForGlyphRange:glyphRange inRect:rect];
    
    // Drawing code
    [self.layoutManager drawBackgroundForGlyphRange:glyphRange atPoint:textOffset];
    [self.layoutManager drawGlyphsForGlyphRange:glyphRange atPoint:textOffset];
}

@end
