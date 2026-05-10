//
//  TYTextAttribute.h
//  TYTextKitDemo
//
//  Created by tany on 2017/9/30.
//  Copyright © 2017年 tany. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

UIKIT_EXTERN NSAttributedStringKey const TYTextAttributeName;
UIKIT_EXTERN NSAttributedStringKey const TYTextHighlightAttributeName;

@class TYTextAttribute;
@class TYTextHighlight;
@interface NSAttributedString (TYTextAttribute)

- (TYTextAttribute *__nullable)textAttributeAtIndex:(NSUInteger)index effectiveRange:(nullable NSRangePointer)range;

- (TYTextHighlight *__nullable)textHighlightAtIndex:(NSUInteger)index effectiveRange:(nullable NSRangePointer)range;

@end


@interface NSMutableAttributedString (TYTextAttribute)

- (void)addTextAttribute:(TYTextAttribute *)textAttribute range:(NSRange)range;

- (void)addTextHighlightAttribute:(TYTextHighlight *)textAttribute range:(NSRange)range;

@end

@interface TYTextAttribute : NSObject

@property (nonatomic, strong, readonly) NSAttributedStringKey attributeName;
@property (nonatomic, copy, nullable) NSDictionary<NSAttributedStringKey, id> *attributes;

@property (nonatomic, assign) NSInteger tag;
@property (nonatomic, strong, nullable) NSDictionary *userInfo;

@property (nonatomic, strong, nullable) UIColor *color;
@property (nonatomic, strong, nullable) UIFont *font;
@property (nonatomic, strong, nullable) UIColor *backgroundColor;

// underline
@property (nonatomic, assign) NSUnderlineStyle underLineStyle;
@property (nonatomic, strong, nullable) UIColor *underLineColor;

// line through
@property (nonatomic, assign) NSUnderlineStyle lineThroughStyle;
@property (nonatomic, strong, nullable) UIColor *lineThroughColor;

// stroke
@property (nonatomic, assign) CGFloat strokeWidth;
@property (nonatomic, strong, nullable) UIColor *strokeColor;

// shadow
@property (nonatomic, strong, nullable) NSShadow *shadow;

- (instancetype)init;
- (instancetype)initWithAttributes:(nullable NSDictionary<NSAttributedStringKey, id> *)attributes;

@end

@interface TYTextHighlight : TYTextAttribute

@property (nonatomic, assign) UIEdgeInsets backgroudInset;
@property (nonatomic, assign) CGFloat backgroudRadius;

// TextKit 2 下，高亮背景由 TYTextRender 自行绘制，这里只返回文本前景/下划线等可由 layoutManager
// setRenderingAttributes:forTextRange: 安全覆盖的属性（排除 backgroundColor 等装饰类）。
- (NSDictionary<NSAttributedStringKey, id> *)renderingAttributes;

@end

NS_ASSUME_NONNULL_END
