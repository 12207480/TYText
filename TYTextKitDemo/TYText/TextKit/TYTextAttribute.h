//
//  TYTextAttribute.h
//  TYTextKitDemo
//
//  Created by tany on 2017/9/30.
//  Copyright © 2017年 tany. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

UIKIT_EXTERN NSString *const TYTextAttributeName;
UIKIT_EXTERN NSString *const TYTextHighlightAttributeName;

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

@property (nonatomic, strong , readonly) NSString *attributeName;
@property (nonatomic, copy, nullable) NSDictionary<NSString *, id> *attributes;

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
- (instancetype)initWithAttributes:(nullable NSDictionary *)attributes;

@end

@interface TYTextHighlight : TYTextAttribute

@property (nonatomic, assign) UIEdgeInsets backgroudInset;
@property (nonatomic, assign) CGFloat backgroudRadius;
@end

NS_ASSUME_NONNULL_END

