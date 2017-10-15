//
//  TYLayoutManager.m
//  TYTextKitDemo
//
//  Created by tanyang on 2017/10/14.
//  Copyright © 2017年 tany. All rights reserved.
//

#import "TYLayoutManager.h"

@interface TYLayoutManager ()

@property (nonatomic, assign) CGPoint lastDrawPoint;

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
    _highlightBackgroundCornerRadius = 2;
}

- (void)drawBackgroundForGlyphRange:(NSRange)glyphsToShow atPoint:(CGPoint)origin {
    self.lastDrawPoint = origin;
    [super drawBackgroundForGlyphRange:glyphsToShow atPoint:origin];
    self.lastDrawPoint = CGPointZero;
}

- (void)fillBackgroundRectArray:(const CGRect *)rectArray count:(NSUInteger)rectCount forCharacterRange:(NSRange)charRange color:(UIColor *)color {
    if (_highlightBackgroundCornerRadius > 0 && NSIntersectionRange(_highlightRange, charRange).length != charRange.length) {
        [super fillBackgroundRectArray:rectArray count:rectCount forCharacterRange:charRange color:color];
        return;
    }
    for (int i = 0; i < rectCount; ++i) {
        CGRect rect = [self fixedLineHighlightRect:rectArray[i] forCharacterRange:charRange];
        [self fillBackgroundRect:rect radius:_highlightBackgroundCornerRadius bgColor:color];
    }
}

- (CGRect)fixedLineHighlightRect:(CGRect)rect forCharacterRange:(NSRange)charRange {
    NSUInteger index = [self glyphIndexForCharacterAtIndex:charRange.location];
    CGRect lineBounds = [self lineFragmentUsedRectForGlyphAtIndex:index effectiveRange:NULL];
    lineBounds.origin.x += self.lastDrawPoint.x;
    lineBounds.origin.y += self.lastDrawPoint.y;
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
        startDrawY = fmin(startDrawY, lineBounds.origin.y+location.y-font.ascender);
        maxLineHeight = fmax(maxLineHeight, font.lineHeight);
    }
    lineBounds.origin.y = startDrawY;
    lineBounds.size.height = maxLineHeight;
    return CGRectIntersection(lineBounds, rect);
}

- (void)fillBackgroundRect:(CGRect)rect radius:(CGFloat)radius bgColor:(UIColor *)bgColor {
    
    CGFloat x = floor(rect.origin.x);
    CGFloat y  = ceil(rect.origin.y);
    CGFloat width = ceil(rect.size.width);
    CGFloat height = ceil(rect.size.height);
    
    // 获取CGContext
    CGContextRef context = UIGraphicsGetCurrentContext();
    // 移动到初始点
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
    
    // 闭合路径
    CGContextClosePath(context);
    // 填充颜色
    CGContextSetFillColorWithColor(context, bgColor.CGColor);
    CGContextDrawPath(context, kCGPathFill);
}

@end
