//
//  TYLayoutManager.m
//  TYTextKitDemo
//
//  Created by tanyang on 2017/10/14.
//  Copyright © 2017年 tany. All rights reserved.
//

#import "TYLayoutManager.h"

@interface TYLayoutManager () {
    CGPoint _lastDrawPoint;
}

@end

@implementation TYLayoutManager

- (instancetype)init {
    if (self = [super init]) {
        [self configure];
    }
    return self;
}

- (instancetype)initWithCoder:(NSCoder *)coder {
    if (self = [super initWithCoder:coder]) {
         [self configure];
    }
    return self;
}

- (void)configure {
    _highlightBackgroudRadius = 2;
}

- (void)drawBackgroundForGlyphRange:(NSRange)glyphsToShow atPoint:(CGPoint)origin {
    _lastDrawPoint = origin;
    [super drawBackgroundForGlyphRange:glyphsToShow atPoint:origin];
    _lastDrawPoint = CGPointZero;
}

- (void)fillBackgroundRectArray:(const CGRect *)rectArray count:(NSUInteger)rectCount forCharacterRange:(NSRange)charRange color:(UIColor *)color {
    if (_highlightRange.length == 0 || NSIntersectionRange(_highlightRange, charRange).length > charRange.length) {
        [super fillBackgroundRectArray:rectArray count:rectCount forCharacterRange:charRange color:color];
        return;
    }
    for (int i = 0; i < rectCount; ++i) {
        CGRect rect = [self fixedLineHighlightRect:rectArray[i] forCharacterRange:charRange];
        [self fillBackgroundRect:rect radius:_highlightBackgroudRadius bgColor:color];
    }
}

- (CGRect)fixedLineHighlightRect:(CGRect)rect forCharacterRange:(NSRange)charRange {
    NSUInteger index = [self glyphIndexForCharacterAtIndex:charRange.location];
    CGRect lineBounds = [self lineFragmentUsedRectForGlyphAtIndex:index effectiveRange:NULL];
    lineBounds.origin.x += _lastDrawPoint.x;
    lineBounds.origin.y += _lastDrawPoint.y;
    CGFloat startDrawY = CGFLOAT_MAX;
    CGFloat maxLineHeight = 0.0f;
    for (NSInteger charIndex = charRange.location; charIndex<NSMaxRange(charRange); ++charIndex) {
        UIFont *font = [self.textStorage attribute:NSFontAttributeName
                                           atIndex:charIndex
                                    effectiveRange:nil];
        if (!font) {
            font = [UIFont systemFontOfSize:12];
        }
        NSUInteger glyphIndex = [self glyphIndexForCharacterAtIndex:charIndex];
        CGPoint location = [self locationForGlyphAtIndex:glyphIndex];
        CGFloat height = [self attachmentSizeForGlyphAtIndex:glyphIndex].height;
        startDrawY = fmin(startDrawY, lineBounds.origin.y+location.y-(height > 0 ?height :font.ascender));
        maxLineHeight = fmax(maxLineHeight, height > 0? height:font.lineHeight);
    }
    lineBounds.origin.y = startDrawY;
    lineBounds.size.height = maxLineHeight;
    return CGRectIntersection(lineBounds, rect);
}

- (void)fillBackgroundRect:(CGRect)rect radius:(CGFloat)radius bgColor:(UIColor *)bgColor {
    
    CGFloat x = floor(rect.origin.x)-_highlightBackgroudInset.left;
    CGFloat y  = ceil(rect.origin.y)-_highlightBackgroudInset.top;
    CGFloat width = ceil(rect.size.width)+_highlightBackgroudInset.left+_highlightBackgroudInset.right;
    CGFloat height = ceil(rect.size.height)+_highlightBackgroudInset.top+_highlightBackgroudInset.bottom;

    CGContextRef context = UIGraphicsGetCurrentContext();
    CGContextMoveToPoint(context, x + radius, y);
    
    // 绘制第1条线和第1个1/4圆弧
    CGContextAddLineToPoint(context, x + width - radius, y);
    CGContextAddArc(context,x+ width - radius,y+ radius, radius, -0.5 * M_PI, 0.0, 0);
    
    // 绘制第2条线和第2个1/4圆弧
    CGContextAddLineToPoint(context, x + width,y + height - radius);
    CGContextAddArc(context,x+ width - radius,y+ height - radius, radius, 0.0, 0.5 * M_PI, 0);
    
    // 绘制第3条线和第3个1/4圆弧
    CGContextAddLineToPoint(context, x+radius, y+height);
    CGContextAddArc(context, x+radius,y+ height - radius, radius, 0.5 * M_PI, M_PI, 0);
    
    // 绘制第4条线和第4个1/4圆弧
    CGContextAddLineToPoint(context, x,y+ radius);
    CGContextAddArc(context,x+ radius,y+ radius, radius, M_PI, 1.5 * M_PI, 0);
    
    CGContextClosePath(context);
    CGContextSetFillColorWithColor(context, bgColor.CGColor);
    CGContextDrawPath(context, kCGPathFill);
}

- (void)processEditingForTextStorage:(NSTextStorage *)textStorage edited:(NSTextStorageEditActions)editMask range:(NSRange)newCharRange changeInLength:(NSInteger)delta invalidatedRange:(NSRange)invalidatedCharRange {
    [super processEditingForTextStorage:textStorage edited:editMask range:newCharRange changeInLength:delta invalidatedRange:invalidatedCharRange];
    if (_render) {
        [_render layoutManager:self processEditingForTextStorage:textStorage edited:editMask range:newCharRange changeInLength:delta invalidatedRange:invalidatedCharRange];
    }
}

- (void)drawGlyphsForGlyphRange:(NSRange)glyphsToShow atPoint:(CGPoint)origin {
    [super drawGlyphsForGlyphRange:glyphsToShow atPoint:origin];
    if (_render) {
        [_render layoutManager:self drawGlyphsForGlyphRange:glyphsToShow atPoint:origin];
    }
}

@end
