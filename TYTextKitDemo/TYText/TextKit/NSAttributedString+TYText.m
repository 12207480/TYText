//
//  NSMutableAttributedString+TYTextKit.m
//  TYTextKitDemo
//
//  Created by tany on 2017/9/15.
//  Copyright © 2017年 tany. All rights reserved.
//

#import "NSAttributedString+TYText.h"

@implementation NSAttributedString (TYText)

- (id)ty_attribute:(NSString *)attrName atIndex:(NSUInteger)index {
    return [self ty_attribute:attrName atIndex:index effectiveRange:NULL];
}

- (id)ty_attribute:(NSString *)attrName atIndex:(NSUInteger)index effectiveRange:(NSRangePointer)range {
    if (!attrName || self.length == 0) {
        return nil;
    }
    
    if (index >= self.length) {
#ifdef DEBUG
        NSLog(@"%s: attribute %@'s index out of range!",__FUNCTION__,attrName);
#endif
        return nil;
    }
    return [self attribute:attrName atIndex:index effectiveRange:range];
}

- (id)ty_attribute:(NSString *)attrName atIndex:(NSUInteger)index longestEffectiveRange:(NSRangePointer)range {
    if (!attrName || self.length == 0) {
        return nil;
    }
    
    if (index >= self.length) {
#ifdef DEBUG
        NSLog(@"%s: attribute %@'s index out of range!",__FUNCTION__,attrName);
#endif
        return nil;
    }
    return [self attribute:attrName atIndex:index longestEffectiveRange:range inRange:NSMakeRange(0, self.length)];
}

- (UIFont *)ty_font {
    return [self ty_fontAtIndex:0 effectiveRange:NULL];
}
- (UIFont *)ty_fontAtIndex:(NSUInteger)index effectiveRange:(NSRangePointer)range {
    return [self attribute:NSFontAttributeName atIndex:index effectiveRange:range];
}

- (UIColor *)ty_color {
    return [self ty_colorAtIndex:0 effectiveRange:NULL];
}
- (UIColor *)ty_colorAtIndex:(NSUInteger)index effectiveRange:(NSRangePointer)range {
    return [self attribute:NSForegroundColorAttributeName atIndex:index effectiveRange:range];
}

- (UIColor *)ty_backgroundColor {
    return [self ty_backgroundColorAtIndex:0 effectiveRange:NULL];
}
- (UIColor *)ty_backgroundColorAtIndex:(NSUInteger)index effectiveRange:(NSRangePointer)range {
    return [self attribute:NSBackgroundColorAttributeName atIndex:index effectiveRange:range];
}

- (NSParagraphStyle *)ty_paragraphStyle {
    return [self ty_paragraphStyleAtIndex:0 effectiveRange:NULL];
}
- (NSParagraphStyle *)ty_paragraphStyleAtIndex:(NSUInteger)index effectiveRange:(NSRangePointer)range {
    return [self attribute:NSParagraphStyleAttributeName atIndex:index effectiveRange:range];
}
- (NSParagraphStyle *)ty_paragraphStyleDefaultAtIndex:(NSUInteger)index effectiveRange:(NSRangePointer)range {
    NSParagraphStyle *style = [self attribute:NSParagraphStyleAttributeName atIndex:index effectiveRange:range];
    return style ? style : [NSParagraphStyle defaultParagraphStyle];
}

- (CGFloat)ty_lineSpacing {
    return [self ty_lineSpacingAtIndex:0 effectiveRange:NULL];
}
- (CGFloat)ty_lineSpacingAtIndex:(NSUInteger)index effectiveRange:(NSRangePointer)range {
    NSParagraphStyle *style = [self ty_paragraphStyleDefaultAtIndex:index effectiveRange:range];
    return style.lineSpacing;
}

- (CGFloat)ty_paragraphSpacing {
    return [self ty_paragraphSpacingAtIndex:0 effectiveRange:NULL];
}
- (CGFloat)ty_paragraphSpacingAtIndex:(NSUInteger)index effectiveRange:(NSRangePointer)range {
    NSParagraphStyle *style = [self ty_paragraphStyleDefaultAtIndex:index effectiveRange:range];
    return style.paragraphSpacing;
}

- (CGFloat)ty_paragraphSpacingBefore {
    return [self ty_paragraphSpacingBeforeAtIndex:0 effectiveRange:NULL];
}
- (CGFloat)ty_paragraphSpacingBeforeAtIndex:(NSUInteger)index effectiveRange:(NSRangePointer)range {
    NSParagraphStyle *style = [self ty_paragraphStyleDefaultAtIndex:index effectiveRange:range];
    return style.paragraphSpacingBefore;
}

- (NSTextAlignment)ty_alignment {
    return [self ty_alignmentAtIndex:0 effectiveRange:NULL];
}
- (NSTextAlignment)ty_alignmentAtIndex:(NSUInteger)index effectiveRange:(NSRangePointer)range {
    NSParagraphStyle *style = [self ty_paragraphStyleDefaultAtIndex:index effectiveRange:range];
    return style.alignment;
}

- (CGFloat)ty_firstLineHeadIndent {
    return [self ty_firstLineHeadIndentAtIndex:0 effectiveRange:NULL];
}
- (CGFloat)ty_firstLineHeadIndentAtIndex:(NSUInteger)index effectiveRange:(NSRangePointer)range {
    NSParagraphStyle *style = [self ty_paragraphStyleDefaultAtIndex:index effectiveRange:range];
    return style.firstLineHeadIndent;
}

- (CGFloat)ty_headIndent {
    return [self ty_headIndentAtIndex:0 effectiveRange:NULL];
}
- (CGFloat)ty_headIndentAtIndex:(NSUInteger)index effectiveRange:(NSRangePointer)range {
    NSParagraphStyle *style = [self ty_paragraphStyleDefaultAtIndex:index effectiveRange:range];
    return style.headIndent;
}

- (CGFloat)ty_tailIndent {
    return [self ty_tailIndentAtIndex:0 effectiveRange:NULL];
}
- (CGFloat)ty_tailIndentAtIndex:(NSUInteger)index effectiveRange:(NSRangePointer)range {
    NSParagraphStyle *style = [self ty_paragraphStyleDefaultAtIndex:index effectiveRange:range];
    return style.tailIndent;
}

- (NSLineBreakMode)ty_lineBreakMode {
    return [self ty_lineBreakModeAtIndex:0 effectiveRange:NULL];
}
- (NSLineBreakMode)ty_lineBreakModeAtIndex:(NSUInteger)index effectiveRange:(NSRangePointer)range {
    NSParagraphStyle *style = [self ty_paragraphStyleDefaultAtIndex:index effectiveRange:range];
    return style.lineBreakMode;
}

- (CGFloat)ty_minimumLineHeight {
    return [self ty_minimumLineHeightAtIndex:0 effectiveRange:NULL];
}
- (CGFloat)ty_minimumLineHeightAtIndex:(NSUInteger)index effectiveRange:(NSRangePointer)range {
    NSParagraphStyle *style = [self ty_paragraphStyleDefaultAtIndex:index effectiveRange:range];
    return style.minimumLineHeight;
}

- (CGFloat)ty_maximumLineHeight {
    return [self ty_maximumLineHeightAtIndex:0 effectiveRange:NULL];
}
- (CGFloat)ty_maximumLineHeightAtIndex:(NSUInteger)index effectiveRange:(NSRangePointer)range {
    NSParagraphStyle *style = [self ty_paragraphStyleDefaultAtIndex:index effectiveRange:range];
    return style.maximumLineHeight;
}

- (NSWritingDirection)ty_baseWritingDirection {
    return [self ty_baseWritingDirectionAtIndex:0 effectiveRange:NULL];
}
- (NSWritingDirection)ty_baseWritingDirectionAtIndex:(NSUInteger)index effectiveRange:(NSRangePointer)range {
    NSParagraphStyle *style = [self ty_paragraphStyleDefaultAtIndex:index effectiveRange:range];
    return style.baseWritingDirection;
}

- (CGFloat)ty_lineHeightMultiple {
    return [self ty_lineHeightMultipleAtIndex:0 effectiveRange:NULL];
}
- (CGFloat)ty_lineHeightMultipleAtIndex:(NSUInteger)index effectiveRange:(NSRangePointer)range {
    NSParagraphStyle *style = [self ty_paragraphStyleDefaultAtIndex:index effectiveRange:range];
    return style.lineHeightMultiple;
}

- (float)ty_hyphenationFactor {
    return [self ty_hyphenationFactorAtIndex:0 effectiveRange:NULL];
}
- (float)ty_hyphenationFactorAtIndex:(NSUInteger)index effectiveRange:(NSRangePointer)range {
    NSParagraphStyle *style = [self ty_paragraphStyleDefaultAtIndex:index effectiveRange:range];
    return style.hyphenationFactor;
}

- (CGFloat)ty_defaultTabInterval {
    return [self ty_defaultTabIntervalAtIndex:0 effectiveRange:NULL];
}
- (CGFloat)ty_defaultTabIntervalAtIndex:(NSUInteger)index effectiveRange:(NSRangePointer)range {
    NSParagraphStyle *style = [self ty_paragraphStyleDefaultAtIndex:index effectiveRange:range];
    return style.defaultTabInterval;
}

- (CGFloat)ty_characterSpacing {
    return [self ty_characterSpacingAtIndex:0 effectiveRange:NULL];
}
- (CGFloat)ty_characterSpacingAtIndex:(NSUInteger)index effectiveRange:(NSRangePointer)range {
    return [[self attribute:NSKernAttributeName atIndex:index effectiveRange:range] floatValue];
}

- (NSUnderlineStyle)ty_lineThroughStyle {
    return [self ty_lineThroughStyleAtIndex:0 effectiveRange:NULL];
}
- (NSUnderlineStyle)ty_lineThroughStyleAtIndex:(NSUInteger)index effectiveRange:(NSRangePointer)range {
    return [[self attribute:NSStrikethroughStyleAttributeName atIndex:index effectiveRange:range] integerValue];
}

- (UIColor *)ty_lineThroughColor {
    return [self ty_lineThroughColorAtIndex:0 effectiveRange:NULL];
}
- (UIColor *)ty_lineThroughColorAtIndex:(NSUInteger)index effectiveRange:(NSRangePointer)range {
    return [self attribute:NSStrikethroughColorAttributeName atIndex:index effectiveRange:range];
}

- (NSInteger)ty_characterLigature {
    return [self ty_characterLigatureAtIndex:0 effectiveRange:NULL];
}
- (NSInteger)ty_characterLigatureAtIndex:(NSUInteger)index effectiveRange:(NSRangePointer)range {
    id attribute = [self attribute:NSLigatureAttributeName atIndex:index effectiveRange:range];
    return attribute ? [attribute integerValue] : 1;
}

- (NSUnderlineStyle)ty_underLineStyle {
    return [self ty_underLineStyleAtIndex:0 effectiveRange:NULL];
}
- (NSUnderlineStyle)ty_underLineStyleAtIndex:(NSUInteger)index effectiveRange:(NSRangePointer)range {
    return [[self attribute:NSUnderlineStyleAttributeName atIndex:index effectiveRange:range] integerValue];
}

- (UIColor *)ty_underLineColor {
    return [self ty_underLineColorAtIndex:0 effectiveRange:NULL];
}
- (UIColor *)ty_underLineColorAtIndex:(NSUInteger)index effectiveRange:(NSRangePointer)range {
    return [self attribute:NSUnderlineColorAttributeName atIndex:index effectiveRange:range];
}

- (UIColor *)ty_strokeColor {
    return [self ty_strokeColorAtIndex:0 effectiveRange:NULL];
}
- (UIColor *)ty_strokeColorAtIndex:(NSUInteger)index effectiveRange:(NSRangePointer)range {
    return [self attribute:NSStrokeColorAttributeName atIndex:index effectiveRange:range];
}

- (CGFloat)ty_strokeWidth {
    return [self ty_strokeWidthAtIndex:0 effectiveRange:NULL];
}
- (CGFloat)ty_strokeWidthAtIndex:(NSUInteger)index effectiveRange:(NSRangePointer)range {
    return [[self attribute:NSStrokeWidthAttributeName atIndex:index effectiveRange:range] floatValue];
}

- (NSShadow *)ty_shadow {
    return [self ty_shadowAtIndex:0 effectiveRange:NULL];
}
- (NSShadow *)ty_shadowAtIndex:(NSUInteger)index effectiveRange:(NSRangePointer)range {
    return [self attribute:NSShadowAttributeName atIndex:index effectiveRange:range];
}

- (NSTextAttachment *)ty_attachmentIndex:(NSUInteger)index effectiveRange:(NSRangePointer)range {
    return [self attribute:NSAttachmentAttributeName atIndex:index effectiveRange:range];
}

- (id)ty_link {
    return [self ty_linkAtIndex:0 effectiveRange:NULL];
}
- (id)ty_linkAtIndex:(NSUInteger)index effectiveRange:(NSRangePointer)range {
    return [self attribute:NSLinkAttributeName atIndex:index effectiveRange:range];
}

- (CGFloat)ty_baseline {
    return [self ty_baselineAtIndex:0 effectiveRange:NULL];
}
- (CGFloat)ty_baselineAtIndex:(NSUInteger)index effectiveRange:(NSRangePointer)range {
    return [[self attribute:NSBaselineOffsetAttributeName atIndex:index effectiveRange:range] floatValue];
}

- (NSWritingDirection)ty_writingDirectionAtIndex:(NSUInteger)index effectiveRange:(NSRangePointer)range {
    return [[self attribute:NSWritingDirectionAttributeName atIndex:index effectiveRange:range] integerValue];
}

- (CGFloat)ty_obliqueness {
    return [self ty_obliquenessAtIndex:0 effectiveRange:NULL];
}
- (CGFloat)ty_obliquenessAtIndex:(NSUInteger)index effectiveRange:(NSRangePointer)range {
    return [[self attribute:NSObliquenessAttributeName atIndex:index effectiveRange:range] floatValue];
}

- (CGFloat)ty_expansion {
    return [self ty_expansionAtIndex:0 effectiveRange:NULL];
}
- (CGFloat)ty_expansionAtIndex:(NSUInteger)index effectiveRange:(NSRangePointer)range {
    return [[self attribute:NSExpansionAttributeName atIndex:index effectiveRange:range] floatValue];
}

@end

@implementation NSMutableAttributedString (TYTextKit)

#define ty_setParagraphStyleProperty(_property_,_range_) \
[self enumerateAttribute:NSParagraphStyleAttributeName inRange:_range_ options:kNilOptions usingBlock:^(NSParagraphStyle *value, NSRange subRange, BOOL *stop) {\
    NSMutableParagraphStyle *style = nil;\
    if (!value) {\
        style = [[NSMutableParagraphStyle alloc]init];\
        if (style._property_ == _property_) {\
            return ;\
        }\
    } else {\
        if (value._property_ == _property_) {\
        return ;\
        }\
        if ([value isKindOfClass:[NSMutableParagraphStyle class]]) {\
            style = (NSMutableParagraphStyle *)value;\
        }else {\
            style = [value mutableCopy];\
        }\
    }\
    style._property_ = _property_;\
    [self ty_addParagraphStyle:style range:subRange];\
}];\

- (void)ty_addAttribute:(NSString *)attrName value:(id)value range:(NSRange)range {
    if (!attrName || [NSNull isEqual:attrName]) {
        return;
    }
    if (!value || [NSNull isEqual:value]) {
        [self removeAttribute:attrName range:range];
        return;
    }
    [self addAttribute:attrName value:value range:range];
}

- (void)ty_removeAttribute:(NSString *)attrName range:(NSRange)range {
    if (!attrName || [NSNull isEqual:attrName]) {
        return;
    }
    [self removeAttribute:attrName range:range];
}

#pragma mark - Add Attribute

- (void)setTy_font:(UIFont *)font {
    [self ty_addFont:font range:NSMakeRange(0, self.length)];
}
- (void)ty_addFont:(UIFont *)font range:(NSRange)range {
    [self ty_addAttribute:NSFontAttributeName value:font range:range];
}

- (void)setTy_color:(UIColor *)color {
    [self ty_addColor:color range:NSMakeRange(0, self.length)];
}
- (void)ty_addColor:(UIColor *)color range:(NSRange)range {
    [self ty_addAttribute:NSForegroundColorAttributeName value:color range:range];
}

- (void)setTy_backgroundColor:(UIColor *)backgroundColor {
    [self ty_addBackgroundColor:backgroundColor range:NSMakeRange(0, self.length)];
}
- (void)ty_addBackgroundColor:(UIColor *)backgroundColor range:(NSRange)range {
    [self ty_addAttribute:NSBackgroundColorAttributeName value:backgroundColor range:range];
}

- (void)setTy_paragraphStyle:(NSParagraphStyle *)paragraphStyle {
    [self ty_addParagraphStyle:paragraphStyle range:NSMakeRange(0, self.length)];
}
- (void)ty_addParagraphStyle:(NSParagraphStyle *)paragraphStyle range:(NSRange)range {
    [self ty_addAttribute:NSParagraphStyleAttributeName value:paragraphStyle range:range];
}

- (void)setTy_lineSpacing:(CGFloat)lineSpacing {
    [self ty_addLineSpacing:lineSpacing range:NSMakeRange(0, self.length)];
}
- (void)ty_addLineSpacing:(CGFloat)lineSpacing range:(NSRange)range {
    ty_setParagraphStyleProperty(lineSpacing,range);
}

- (void)setTy_paragraphSpacing:(CGFloat)paragraphSpacing {
    [self ty_addParagraphSpacing:paragraphSpacing range:NSMakeRange(0, self.length)];
}
- (void)ty_addParagraphSpacing:(CGFloat)paragraphSpacing range:(NSRange)range {
    ty_setParagraphStyleProperty(paragraphSpacing,range);
}

- (void)setTy_paragraphSpacingBefore:(CGFloat)paragraphSpacingBefore {
    [self ty_addParagraphSpacing:paragraphSpacingBefore range:NSMakeRange(0, self.length)];
}
- (void)ty_addParagraphSpacingBefore:(CGFloat)paragraphSpacingBefore range:(NSRange)range {
    ty_setParagraphStyleProperty(paragraphSpacingBefore,range);
}

- (void)setTy_alignment:(NSTextAlignment)alignment {
    [self ty_addAlignment:alignment range:NSMakeRange(0, self.length)];
}
- (void)ty_addAlignment:(NSTextAlignment)alignment range:(NSRange)range {
    ty_setParagraphStyleProperty(alignment,range);
}

- (void)setTy_firstLineHeadIndent:(CGFloat)firstLineHeadIndent {
    [self ty_addFirstLineHeadIndent:firstLineHeadIndent range:NSMakeRange(0, self.length)];
}
- (void)ty_addFirstLineHeadIndent:(CGFloat)firstLineHeadIndent range:(NSRange)range {
    ty_setParagraphStyleProperty(firstLineHeadIndent,range);
}

- (void)setTy_headIndent:(CGFloat)headIndent {
    [self ty_addHeadIndent:headIndent range:NSMakeRange(0, self.length)];
}
- (void)ty_addHeadIndent:(CGFloat)headIndent range:(NSRange)range {
    ty_setParagraphStyleProperty(headIndent,range);
}

- (void)setTy_tailIndent:(CGFloat)tailIndent {
    [self ty_addTailIndent:tailIndent range:NSMakeRange(0, self.length)];
}
- (void)ty_addTailIndent:(CGFloat)tailIndent range:(NSRange)range {
    ty_setParagraphStyleProperty(tailIndent,range);
}

- (void)setTy_lineBreakMode:(NSLineBreakMode)lineBreakMode {
    [self ty_addLineBreakMode:lineBreakMode range:NSMakeRange(0, self.length)];
}
- (void)ty_addLineBreakMode:(NSLineBreakMode)lineBreakMode range:(NSRange)range {
    ty_setParagraphStyleProperty(lineBreakMode,range);
}

- (void)setTy_minimumLineHeight:(CGFloat)minimumLineHeight {
    [self ty_addMinimumLineHeight:minimumLineHeight range:NSMakeRange(0, self.length)];
}
- (void)ty_addMinimumLineHeight:(CGFloat)minimumLineHeight range:(NSRange)range {
    ty_setParagraphStyleProperty(minimumLineHeight,range);
}

- (void)setTy_maximumLineHeight:(CGFloat)maximumLineHeight {
    [self ty_addMinimumLineHeight:maximumLineHeight range:NSMakeRange(0, self.length)];
}
- (void)ty_addMaximumLineHeight:(CGFloat)maximumLineHeight range:(NSRange)range {
    ty_setParagraphStyleProperty(maximumLineHeight,range);
}

- (void)setTy_baseWritingDirection:(NSWritingDirection)baseWritingDirection {
    [self ty_addBaseWritingDirection:baseWritingDirection range:NSMakeRange(0, self.length)];
}
- (void)ty_addBaseWritingDirection:(NSWritingDirection)baseWritingDirection range:(NSRange)range {
    ty_setParagraphStyleProperty(baseWritingDirection,range);
}

- (void)setTy_lineHeightMultiple:(CGFloat)lineHeightMultiple {
    [self ty_addLineHeightMultiple:lineHeightMultiple range:NSMakeRange(0, self.length)];
}
- (void)ty_addLineHeightMultiple:(CGFloat)lineHeightMultiple range:(NSRange)range {
    ty_setParagraphStyleProperty(lineHeightMultiple,range);
}

- (void)setTy_hyphenationFactor:(float)hyphenationFactor {
    [self ty_addHyphenationFactor:hyphenationFactor range:NSMakeRange(0, self.length)];
}
- (void)ty_addHyphenationFactor:(float)hyphenationFactor range:(NSRange)range {
    ty_setParagraphStyleProperty(hyphenationFactor,range);
}

- (void)setTy_defaultTabInterval:(CGFloat)defaultTabInterval {
    [self ty_addDefaultTabInterval:defaultTabInterval range:NSMakeRange(0, self.length)];
}
- (void)ty_addDefaultTabInterval:(CGFloat)defaultTabInterval range:(NSRange)range {
    ty_setParagraphStyleProperty(defaultTabInterval,range);
}

- (void)setTy_characterSpacing:(CGFloat)characterSpacing {
    [self ty_addCharacterSpacing:characterSpacing range:NSMakeRange(0, self.length)];
}
- (void)ty_addCharacterSpacing:(CGFloat)characterSpacing range:(NSRange)range {
    [self ty_addAttribute:NSKernAttributeName value:@(characterSpacing) range:range];
}

- (void)setTy_lineThroughStyle:(NSUnderlineStyle)lineThroughStyle {
    [self ty_addLineThroughStyle:lineThroughStyle range:NSMakeRange(0, self.length)];
}
- (void)ty_addLineThroughStyle:(NSUnderlineStyle)style range:(NSRange)range {
    [self ty_addAttribute:NSStrikethroughStyleAttributeName value:@(style) range:range];
}

- (void)setTy_lineThroughColor:(UIColor *)lineThroughColor {
    [self ty_addLineThroughColor:lineThroughColor range:NSMakeRange(0, self.length)];
}
- (void)ty_addLineThroughColor:(UIColor *)color range:(NSRange)range {
    [self ty_addAttribute:NSStrikethroughColorAttributeName value:color range:range];
}

- (void)setTy_underLineStyle:(NSUnderlineStyle)underLineStyle {
    [self ty_addUnderLineStyle:underLineStyle range:NSMakeRange(0, self.length)];
}
- (void)ty_addUnderLineStyle:(NSUnderlineStyle)style range:(NSRange)range {
    [self ty_addAttribute:NSUnderlineStyleAttributeName value:@(style) range:range];
}

- (void)setTy_underLineColor:(UIColor *)underLineColor {
    [self ty_addUnderLineColor:underLineColor range:NSMakeRange(0, self.length)];
}
- (void)ty_addUnderLineColor:(UIColor *)color range:(NSRange)range {
    [self ty_addAttribute:NSUnderlineColorAttributeName value:color range:range];
}

- (void)setTy_characterLigature:(NSInteger)characterLigature {
    [self ty_addCharacterLigature:characterLigature range:NSMakeRange(0, self.length)];
}
- (void)ty_addCharacterLigature:(NSInteger)characterLigature range:(NSRange)range {
    [self ty_addAttribute:NSLigatureAttributeName value:@(characterLigature) range:range];
}

- (void)setTy_strokeColor:(UIColor *)strokeColor {
    [self ty_addStrokeColor:strokeColor range:NSMakeRange(0, self.length)];
}
- (void)ty_addStrokeColor:(UIColor *)color range:(NSRange)range {
    [self ty_addAttribute:NSStrokeColorAttributeName value:color range:range];
}

- (void)setTy_strokeWidth:(CGFloat)strokeWidth {
    [self ty_addStrokeWidth:strokeWidth range:NSMakeRange(0, self.length)];
}
- (void)ty_addStrokeWidth:(CGFloat)strokeWidth range:(NSRange)range {
    [self ty_addAttribute:NSStrokeWidthAttributeName value:@(strokeWidth) range:range];
}

- (void)setTy_shadow:(NSShadow *)shadow {
    [self ty_addShadow:shadow range:NSMakeRange(0, self.length)];
}
- (void)ty_addShadow:(NSShadow *)shadow range:(NSRange)range {
    [self ty_addAttribute:NSShadowAttributeName value:shadow range:range];
}

- (void)ty_addAttachment:(NSTextAttachment *)attachment range:(NSRange)range {
    [self ty_addAttribute:NSAttachmentAttributeName value:attachment range:range];
}

- (void)setTy_link:(id)link {
    [self ty_addLink:link range:NSMakeRange(0, self.length)];
}
- (void)ty_addLink:(id)link range:(NSRange)range {
    [self ty_addAttribute:NSLinkAttributeName value:link range:range];
}

- (void)setTy_baseline:(CGFloat)baseline {
    [self ty_addBaseline:baseline range:NSMakeRange(0, self.length)];
}
- (void)ty_addBaseline:(CGFloat)baseline range:(NSRange)range {
    [self ty_addAttribute:NSBaselineOffsetAttributeName value:@(baseline) range:range];
}

- (void)ty_addWritingDirection:(NSWritingDirection)writingDirection range:(NSRange)range {
    [self ty_addAttribute:NSWritingDirectionAttributeName value:@(writingDirection) range:range];
}

- (void)setTy_obliqueness:(CGFloat)obliqueness {
    [self ty_addObliqueness:obliqueness range:NSMakeRange(0, self.length)];
}
- (void)ty_addObliqueness:(CGFloat)obliqueness range:(NSRange)range {
    [self ty_addAttribute:NSObliquenessAttributeName value:@(obliqueness) range:range];
}

- (void)setTy_expansion:(CGFloat)expansion {
    [self ty_addExpansion:expansion range:NSMakeRange(0, self.length)];
}
- (void)ty_addExpansion:(CGFloat)expansion range:(NSRange)range {
    [self ty_addAttribute:NSExpansionAttributeName value:@(expansion) range:range];
}

@end
