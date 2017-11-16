//
//  NSMutableAttributedString+TYTextKit.h
//  TYTextKitDemo
//
//  Created by tany on 2017/9/15.
//  Copyright © 2017年 tany. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface NSAttributedString (TYText)

#pragma mark - Get Attribute

/**
  an attribute with a given name of the character at a given index
 */
- (nullable id)ty_attribute:(NSString *)attrName atIndex:(NSUInteger)index;
- (nullable id)ty_attribute:(NSString *)attrName atIndex:(NSUInteger)index effectiveRange:(nullable NSRangePointer)range;
- (nullable id)ty_attribute:(NSString *)attrName atIndex:(NSUInteger)index longestEffectiveRange:(nullable NSRangePointer)range;

// attribute property getter

@property (nonatomic, strong, readonly, nullable) UIFont *ty_font;          // 字体
@property (nonatomic, strong, readonly, nullable) UIColor *ty_color;        // 颜色
@property (nonatomic, strong, readonly, nullable) UIColor *ty_backgroundColor; // 背景颜色
// paragraphStyle
@property (nonatomic, strong, readonly, nullable) NSParagraphStyle *ty_paragraphStyle;//  段落样式
@property (nonatomic, assign, readonly) CGFloat ty_lineSpacing;             // 行高
@property (nonatomic, assign, readonly) CGFloat ty_paragraphSpacing;        // 段落底部高度
@property (nonatomic, assign, readonly) CGFloat ty_paragraphSpacingBefore;  // 段落顶部高度
@property (nonatomic, assign, readonly) NSTextAlignment ty_alignment;       // 文本对齐
@property (nonatomic, assign, readonly) CGFloat ty_firstLineHeadIndent;     // 首行缩进
@property (nonatomic, assign, readonly) CGFloat ty_headIndent;              // 首部缩进
@property (nonatomic, assign, readonly) CGFloat ty_tailIndent;              // 尾部缩进
@property (nonatomic, assign, readonly) NSLineBreakMode ty_lineBreakMode;   // 换行模式
@property (nonatomic, assign, readonly) CGFloat ty_minimumLineHeight;       // 最小行高
@property (nonatomic, assign, readonly) CGFloat ty_maximumLineHeight;       // 最大行高
@property (nonatomic, assign, readonly) NSWritingDirection ty_baseWritingDirection; // 文本书写方向
@property (nonatomic, assign, readonly) CGFloat ty_lineHeightMultiple;      // 多行高
@property (nonatomic, assign, readonly) float ty_hyphenationFactor;         // 连字符
@property (nonatomic, assign, readonly) CGFloat ty_defaultTabInterval;      // \t制表符间距

@property (nonatomic, assign, readonly) CGFloat ty_characterSpacing;        // 字符间距
@property (nonatomic, assign, readonly) NSUnderlineStyle ty_lineThroughStyle;// 删除线类型
@property (nonatomic, strong, readonly, nullable) UIColor *ty_lineThroughColor;//删除线颜色
@property (nonatomic, assign, readonly) NSInteger ty_characterLigature;// 连字符 default 1
@property (nonatomic, assign, readonly) NSUnderlineStyle ty_underLineStyle; // 下划线类型
@property (nonatomic, strong, readonly, nullable) UIColor *ty_underLineColor;// 下划线颜色
@property (nonatomic, assign, readonly) CGFloat ty_strokeWidth;             // 文字边线宽度
@property (nonatomic, strong, readonly, nullable) UIColor *ty_strokeColor;  // 文字边线颜色
@property (nonatomic, strong, readonly, nullable) NSShadow *ty_shadow;      // 文字阴影
@property (nonatomic, strong, readonly, nullable) id ty_link;               // 链接
@property (nonatomic, assign, readonly) CGFloat ty_baseline;                // 文字基线偏移
@property (nonatomic, assign, readonly) CGFloat ty_obliqueness;             // 字形倾斜度
@property (nonatomic, assign, readonly) CGFloat ty_expansion;            // 文本横向拉伸属性

#pragma mark - Get Attribute At Index

/**
 get text font attribute at index
 @discussion if not use effectiveRange,you can set NULL
 */
- (UIFont *)ty_fontAtIndex:(NSUInteger)index effectiveRange:(nullable NSRangePointer)range;

/**
 get text color attribute at index
 */
- (UIColor *)ty_colorAtIndex:(NSUInteger)index effectiveRange:(nullable NSRangePointer)range;

/**
 get text backgroundColor attribute at index
 */
- (UIColor *)ty_backgroundColorAtIndex:(NSUInteger)index effectiveRange:(nullable NSRangePointer)range;

/**
 get text paragraph style attribute at index
 */
- (NSParagraphStyle *)ty_paragraphStyleAtIndex:(NSUInteger)index effectiveRange:(nullable NSRangePointer)range;

/**
 get text paragraph line spacing at index
 */
- (CGFloat)ty_lineSpacingAtIndex:(NSUInteger)index effectiveRange:(nullable NSRangePointer)range;

/**
 get text paragraph bottom spacing at index
 */
- (CGFloat)ty_paragraphSpacingAtIndex:(NSUInteger)index effectiveRange:(nullable NSRangePointer)range;

/**
 get text paragraph top spacing at index
 */
- (CGFloat)ty_paragraphSpacingBeforeAtIndex:(NSUInteger)index effectiveRange:(nullable NSRangePointer)range;

/**
 get text paragraph alignment at index
 */
- (NSTextAlignment)ty_alignmentAtIndex:(NSUInteger)index effectiveRange:(nullable NSRangePointer)range;

/**
 get text paragraph firstLineHeadIndent at index
 */
- (CGFloat)ty_firstLineHeadIndentAtIndex:(NSUInteger)index effectiveRange:(nullable NSRangePointer)range;

/**
 get text paragraph headIndent at index
 */
- (CGFloat)ty_headIndentAtIndex:(NSUInteger)index effectiveRange:(nullable NSRangePointer)range;

/**
 get text paragraph tailIndent at index
 */
- (CGFloat)ty_tailIndentAtIndex:(NSUInteger)index effectiveRange:(nullable NSRangePointer)range;

/**
 get text paragraph lineBreak at index
 */
- (NSLineBreakMode)ty_lineBreakModeAtIndex:(NSUInteger)index effectiveRange:(nullable NSRangePointer)range;

/**
 get text paragraph minimumLineHeight at index
 */
- (CGFloat)ty_minimumLineHeightAtIndex:(NSUInteger)index effectiveRange:(nullable NSRangePointer)range;
/**
 get text paragraph maximumLineHeight at index
 */
- (CGFloat)ty_maximumLineHeightAtIndex:(NSUInteger)index effectiveRange:(nullable NSRangePointer)range;

/**
 get text paragraph writingDirection at index
 */
- (NSWritingDirection)ty_baseWritingDirectionAtIndex:(NSUInteger)index effectiveRange:(nullable NSRangePointer)range;

/**
 get text paragraph lineHeightMultiple at index
 */
- (CGFloat)ty_lineHeightMultipleAtIndex:(NSUInteger)index effectiveRange:(nullable NSRangePointer)range;

/**
 get text paragraph hyphenation factor at index
 */
- (float)ty_hyphenationFactorAtIndex:(NSUInteger)index effectiveRange:(nullable NSRangePointer)range;

/**
 get text paragraph Tab spacing at index
 */
- (CGFloat)ty_defaultTabIntervalAtIndex:(NSUInteger)index effectiveRange:(nullable NSRangePointer)range;

/**
 get text character spacing attribute at index
 */
- (CGFloat)ty_characterSpacingAtIndex:(NSUInteger)index effectiveRange:(nullable NSRangePointer)range;

/**
 get text line through style attribute at index
 */
- (NSUnderlineStyle)ty_lineThroughStyleAtIndex:(NSUInteger)index effectiveRange:(nullable NSRangePointer)range;

/**
 get text line through color attribute at index
 */
- (UIColor *)ty_lineThroughColorAtIndex:(NSUInteger)index effectiveRange:(nullable NSRangePointer)range;

/**
 get text character ligature attribute at index
 */
- (NSInteger)ty_characterLigatureAtIndex:(NSUInteger)index effectiveRange:(nullable NSRangePointer)range;

/**
 get text underLine style attribute at index
 */
- (NSUnderlineStyle)ty_underLineStyleAtIndex:(NSUInteger)index effectiveRange:(nullable NSRangePointer)range;

/**
 get text underLine color attribute at index
 */
- (UIColor *)ty_underLineColorAtIndex:(NSUInteger)index effectiveRange:(nullable NSRangePointer)range;

/**
 get text stroke width attribute at index
 */
- (CGFloat)ty_strokeWidthAtIndex:(NSUInteger)index effectiveRange:(nullable NSRangePointer)range;

/**
 get text stroke color attribute at index
 */
- (UIColor *)ty_strokeColorAtIndex:(NSUInteger)index effectiveRange:(nullable NSRangePointer)range;

/**
 get text shadow attribute at index
 */
- (NSShadow *)ty_shadowAtIndex:(NSUInteger)index effectiveRange:(nullable NSRangePointer)range;

/**
 get text attachment attribute at index
 */
- (NSTextAttachment *)ty_attachmentIndex:(NSUInteger)index effectiveRange:(nullable NSRangePointer)range;

/**
 get text link attribute at index
 */
- (id)ty_linkAtIndex:(NSUInteger)index effectiveRange:(nullable NSRangePointer)range;

/**
 get text baseline attribute at index
 */
- (CGFloat)ty_baselineAtIndex:(NSUInteger)index effectiveRange:(nullable NSRangePointer)range;

/**
 get text writing direction attribute at index
 */
- (NSWritingDirection)ty_writingDirectionAtIndex:(NSUInteger)index effectiveRange:(nullable NSRangePointer)range;

/**
 get text obliqueness attribute at index
 */
- (CGFloat)ty_obliquenessAtIndex:(NSUInteger)index effectiveRange:(nullable NSRangePointer)range;

/**
 get text expansion attribute at index
 */
- (CGFloat)ty_expansionAtIndex:(NSUInteger)index effectiveRange:(nullable NSRangePointer)range;

@end


@interface NSMutableAttributedString (TYTextKit)


#pragma mark - Add && Remove Attribute

- (void)ty_addAttribute:(NSString *)name value:(id)value range:(NSRange)range;

- (void)ty_removeAttribute:(NSString *)name range:(NSRange)range;

@property (nonatomic, strong, readwrite, nullable) UIFont *ty_font;
@property (nonatomic, strong, readwrite, nullable) UIColor *ty_color;
@property (nonatomic, strong, readwrite, nullable) UIColor *ty_backgroundColor;
// paragraphStyle
@property (nonatomic, strong, readwrite, nullable) NSParagraphStyle *ty_paragraphStyle;
@property (nonatomic, assign, readwrite) CGFloat ty_lineSpacing;
@property (nonatomic, assign, readwrite) CGFloat ty_paragraphSpacing;
@property (nonatomic, assign, readwrite) CGFloat ty_paragraphSpacingBefore;
@property (nonatomic, assign, readwrite) NSTextAlignment ty_alignment;
@property (nonatomic, assign, readwrite) CGFloat ty_firstLineHeadIndent;
@property (nonatomic, assign, readwrite) CGFloat ty_headIndent;
@property (nonatomic, assign, readwrite) CGFloat ty_tailIndent;
@property (nonatomic, assign, readwrite) NSLineBreakMode ty_lineBreakMode;
@property (nonatomic, assign, readwrite) CGFloat ty_minimumLineHeight;
@property (nonatomic, assign, readwrite) CGFloat ty_maximumLineHeight;
@property (nonatomic, assign, readwrite) NSWritingDirection ty_baseWritingDirection;
@property (nonatomic, assign, readwrite) CGFloat ty_lineHeightMultiple;
@property (nonatomic, assign, readwrite) float ty_hyphenationFactor;
@property (nonatomic, assign, readwrite) CGFloat ty_defaultTabInterval;

@property (nonatomic, assign, readwrite) CGFloat ty_characterSpacing;
@property (nonatomic, assign, readwrite) NSUnderlineStyle ty_lineThroughStyle;
@property (nonatomic, strong, readwrite, nullable) UIColor *ty_lineThroughColor;
@property (nonatomic, assign, readwrite) NSInteger ty_characterLigature;
@property (nonatomic, assign, readwrite) NSUnderlineStyle ty_underLineStyle;
@property (nonatomic, strong, readwrite, nullable) UIColor *ty_underLineColor;
@property (nonatomic, assign, readwrite) CGFloat ty_strokeWidth;
@property (nonatomic, strong, readwrite, nullable) UIColor *ty_strokeColor;
@property (nonatomic, strong, readwrite, nullable) NSShadow *ty_shadow;
@property (nonatomic, strong, readwrite, nullable) id ty_link;
@property (nonatomic, assign, readwrite) CGFloat ty_baseline;
@property (nonatomic, assign, readwrite) CGFloat ty_obliqueness;
@property (nonatomic, assign, readwrite) CGFloat ty_expansion;

#pragma mark - Add Attribute At Range

/**
 add text font
 @discussion 添加文本字体
 */
- (void)ty_addFont:(UIFont *)font range:(NSRange)range;

/**
 add text color
 @discussion 添加文本颜色
 */
- (void)ty_addColor:(UIColor *)color range:(NSRange)range;

/**
 add text background color
 @discussion 添加文本背景色
 */
- (void)ty_addBackgroundColor:(UIColor *)backgroundColor range:(NSRange)range;

/**
 add text paragraph style
 @discussion 添加文本段落格式
 */
- (void)ty_addParagraphStyle:(NSParagraphStyle *)paragraphStyle range:(NSRange)range;

/**
 add text paragraph line spacing
 @discussion 添加文本段落行高
 */
- (void)ty_addLineSpacing:(CGFloat)lineSpacing range:(NSRange)range;

/**
 add text paragraph bottom spacing
 @discussion 添加文本段落底部间距
 */
- (void)ty_addParagraphSpacing:(CGFloat)paragraphSpacing range:(NSRange)range;

/**
 add text paragraph top spacing
 @discussion 添加文本段落顶部间距
 */
- (void)ty_addParagraphSpacingBefore:(CGFloat)paragraphSpacingBefore range:(NSRange)range ;

/**
 add text paragraph alignment
 @discussion 添加段落文本对齐
 */
- (void)ty_addAlignment:(NSTextAlignment)alignment range:(NSRange)range;

/**
 add text paragraph firstLineHeadIndent
 @discussion 添加段落文本首行缩进
 */
- (void)ty_addFirstLineHeadIndent:(CGFloat)firstLineHeadIndent range:(NSRange)range;

/**
 add text paragraph headIndent
 @discussion 添加段落文本首部缩进
 */
- (void)ty_addHeadIndent:(CGFloat)headIndent range:(NSRange)range;

/**
 add text paragraph tailIndent
 @discussion 添加段落文本尾部缩进
 */
- (void)ty_addTailIndent:(CGFloat)tailIndent range:(NSRange)range;

/**
 add text paragraph lineBreakMode
 @discussion 添加段落文本断行方式
 */
- (void)ty_addLineBreakMode:(NSLineBreakMode)lineBreakMode range:(NSRange)range;

/**
 add text paragraph minimumLineHeight
 @discussion 添加段落文本最小行高
 */
- (void)ty_addMinimumLineHeight:(CGFloat)minimumLineHeight range:(NSRange)range;

/**
 add text paragraph maximumLineHeight
 @discussion 添加段落文本最大行高
 */
- (void)ty_addMaximumLineHeight:(CGFloat)maximumLineHeight range:(NSRange)range;

/**
 add text paragraph writingDirection
 @discussion 添加段落文本书写方法
 */
- (void)ty_addBaseWritingDirection:(NSWritingDirection)baseWritingDirection range:(NSRange)range;

/**
 add text paragraph lineHeightMultiple
 @discussion 添加段落文本可变行高,乘因数
 */
- (void)ty_addLineHeightMultiple:(CGFloat)lineHeightMultiple range:(NSRange)range;

/**
 add text paragraph hyphenationFactor
 @discussion 添加段落文本连字符属性
 */
- (void)ty_addHyphenationFactor:(float)hyphenationFactor range:(NSRange)range;

/**
 add text paragraph defaultTabInterval(\t)
 @discussion 添加段落文本制表符(\t)间隔
 */
- (void)ty_addDefaultTabInterval:(CGFloat)defaultTabInterval range:(NSRange)range;

/**
 add text character or letter space
 @discussion 添加文本字间距
 */
- (void)ty_addCharacterSpacing:(CGFloat)characterSpacing range:(NSRange)range;

/**
 add text line through style
 @discussion 添加文本删除线
 */
- (void)ty_addLineThroughStyle:(NSUnderlineStyle)style range:(NSRange)range;

/**
 add text line through color
 @discussion 添加文本删除线颜色
 */
- (void)ty_addLineThroughColor:(UIColor *)color range:(NSRange)range;

/**
 add text under line style
 @discussion 添加文本下划线
 */
- (void)ty_addUnderLineStyle:(NSUnderlineStyle)style range:(NSRange)range;

/**
 add text under line color
 @discussion 添加文本下划线颜色
 */
- (void)ty_addUnderLineColor:(UIColor *)color range:(NSRange)range;

/**
 add text character ligature
 @discussion 添加文本连字符
 @discussion default 1 ,1: default ligatures, 0: no ligatures
 */
- (void)ty_addCharacterLigature:(NSInteger)characterLigature range:(NSRange)range;

/**
 add text stroke color
 @discussion 添加文本边框颜色
 @discussion defalut text color
 */
- (void)ty_addStrokeColor:(UIColor *)color range:(NSRange)range;

/**
 add text stroke width
 @discussion 添加文本边框宽度
 */
- (void)ty_addStrokeWidth:(CGFloat)strokeWidth range:(NSRange)range;

/**
 add text shadow
 @discussion 添加文本阴影
 */
- (void)ty_addShadow:(NSShadow *)shadow range:(NSRange)range;

/**
 add text attachment
 @discussion 添加文本附件
 */
- (void)ty_addAttachment:(NSTextAttachment *)attachment range:(NSRange)range;

/**
 add text link
 @discussion 添加文本链接
 */
- (void)ty_addLink:(id)link range:(NSRange)range;

/**
 add text base line offset see UIBaselineAdjustment
 @discussion 添加文本基线偏移值
 */
- (void)ty_addBaseline:(CGFloat)baseline range:(NSRange)range;

/**
 add text writing direction
 @discussion 添加文本书写方向
 */
- (void)ty_addWritingDirection:(NSWritingDirection)writingDirection range:(NSRange)range;

/**
 add text obliqueness
 @discussion 添加文本字形倾斜度
 */
- (void)ty_addObliqueness:(CGFloat)obliqueness range:(NSRange)range;

/**
 add text expansion
 @discussion 添加文本字横向拉伸
 */
- (void)ty_addExpansion:(CGFloat)expansion range:(NSRange)range;

@end

NS_ASSUME_NONNULL_END
