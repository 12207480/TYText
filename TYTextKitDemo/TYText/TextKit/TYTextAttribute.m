//
//  TYTextAttribute.m
//  TYTextKitDemo
//
//  Created by tany on 2017/9/30.
//  Copyright © 2017年 tany. All rights reserved.
//

#import "TYTextAttribute.h"
#import "NSAttributedString+TYText.h"

NSString *const TYTextAttributeName = @"TYTextAttribute";
NSString *const TYTextHighlightAttributeName = @"TYTextHighlightAttribute";

@implementation NSAttributedString (TYTextAttribute)

- (TYTextAttribute *)textAttributeAtIndex:(NSUInteger)index effectiveRange:(nullable NSRangePointer)range {
    return [self ty_attribute:TYTextAttributeName atIndex:index longestEffectiveRange:range];
}

- (TYTextHighlight *)textHighlightAtIndex:(NSUInteger)index effectiveRange:(nullable NSRangePointer)range {
    return [self ty_attribute:TYTextHighlightAttributeName atIndex:index longestEffectiveRange:range];
}

@end

@implementation NSMutableAttributedString (TYTextAttribute)

- (void)addTextAttribute:(TYTextAttribute *)textAttribute range:(NSRange)range {
    NSDictionary *attributes = textAttribute.attributes;
    [attributes enumerateKeysAndObjectsUsingBlock:^(NSString *key, id value, BOOL *stop) {
        [self ty_addAttribute:key value:value range:range];
    }];
    [self ty_addAttribute:textAttribute.attributeName value:textAttribute range:range];
}

- (void)addTextHighlightAttribute:(TYTextHighlight *)textAttribute range:(NSRange)range {
    [self ty_addAttribute:textAttribute.attributeName value:textAttribute range:range];
}

@end

@implementation TYTextAttribute

- (instancetype)init {
    if (self = [self initWithAttributes:nil]) {
    }
    return self;
}

- (instancetype)initWithAttributes:(NSDictionary *)attributes {
    if (self = [super init]) {
        _attributes = attributes ? [[NSMutableDictionary alloc]initWithDictionary:attributes] : [NSMutableDictionary dictionary];
    }
    return self;
}

#pragma mark - getter && setter

- (NSString *)attributeName {
    return TYTextAttributeName;
}

- (UIColor *)color {
    return _attributes[NSForegroundColorAttributeName];
}
- (void)setColor:(UIColor *)color {
    ((NSMutableDictionary *)_attributes)[NSForegroundColorAttributeName] = color;
}

-(UIFont *)font {
    return _attributes[NSFontAttributeName];
}
- (void)setFont:(UIFont *)font {
    ((NSMutableDictionary *)_attributes)[NSFontAttributeName] = font;
}

- (UIColor *)backgroundColor {
    return _attributes[NSBackgroundColorAttributeName];
}
- (void)setBackgroundColor:(UIColor *)backgroundColor {
    ((NSMutableDictionary *)_attributes)[NSBackgroundColorAttributeName] = backgroundColor;
}

- (NSUnderlineStyle)underLineStyle {
    return [_attributes[NSUnderlineStyleAttributeName] integerValue];
}
- (void)setUnderLineStyle:(NSUnderlineStyle)underLineStyle {
    ((NSMutableDictionary *)_attributes)[NSUnderlineStyleAttributeName] = @(underLineStyle);
}

- (UIColor *)underLineColor {
    return _attributes[NSUnderlineColorAttributeName];
}
- (void)setUnderLineColor:(UIColor *)underLineColor {
    ((NSMutableDictionary *)_attributes)[NSUnderlineColorAttributeName] = underLineColor;
}

- (NSUnderlineStyle)lineThroughStyle {
    return [_attributes[NSStrikethroughStyleAttributeName] integerValue];
}
- (void)setLineThroughStyle:(NSUnderlineStyle)lineThroughStyle {
    ((NSMutableDictionary *)_attributes)[NSStrikethroughStyleAttributeName] = @(lineThroughStyle);
}

- (UIColor *)lineThroughColor {
    return _attributes[NSStrikethroughColorAttributeName];
}
- (void)setLineThroughColor:(UIColor *)lineThroughColor {
    ((NSMutableDictionary *)_attributes)[NSStrikethroughColorAttributeName] = lineThroughColor;
}

- (CGFloat)strokeWidth {
    return [_attributes[NSStrokeWidthAttributeName] floatValue];
}
- (void)setStrokeWidth:(CGFloat)strokeWidth {
     ((NSMutableDictionary *)_attributes)[NSStrokeWidthAttributeName] = @(strokeWidth);
}

- (UIColor *)strokeColor {
    return _attributes[NSStrokeColorAttributeName];
}
- (void)setStrokeColor:(UIColor *)strokeColor {
    ((NSMutableDictionary *)_attributes)[NSStrokeColorAttributeName] = strokeColor;
}

- (NSShadow *)shadow {
    return _attributes[NSShadowAttributeName];
}
- (void)setShadow:(NSShadow *)shadow {
    ((NSMutableDictionary *)_attributes)[NSShadowAttributeName] = shadow;
}

@end

@implementation TYTextHighlight

- (NSString *)attributeName {
    return TYTextHighlightAttributeName;
}

@end
