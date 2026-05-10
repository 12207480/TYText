//
//  TYTextRender.h
//  TYTextKitDemo
//
//  Created by tany on 2017/9/26.
//  Copyright © 2017年 tany. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "TYTextAttachment.h"
#import "TYTextAttribute.h"
#import "NSAttributedString+TYText.h"

NS_ASSUME_NONNULL_BEGIN

typedef NS_ENUM(NSUInteger, TYTextVerticalAlignment) {
    TYTextVerticalAlignmentCenter,
    TYTextVerticalAlignmentTop,
    TYTextVerticalAlignmentBottom,
};

@interface TYTextRender : NSObject

@property (nonatomic, strong, nullable) NSTextStorage *textStorage;
@property (nonatomic, strong, readonly) NSTextLayoutManager *layoutManager;
@property (nonatomic, strong, readonly) NSTextContainer *textContainer;
@property (nonatomic, strong, readonly) NSTextContentStorage *contentStorage;

// use in textView,textStorage can edited
@property (nonatomic, assign) BOOL editable;

/**
 render size
 */
@property (nonatomic, assign) CGSize size;

/**
 text vertical alignment. default center
 */
@property (nonatomic, assign) TYTextVerticalAlignment verticalAlignment;

// text is inset within line fragment rectangles.default 0
@property (nonatomic, assign) CGFloat lineFragmentPadding;
@property (nonatomic, assign) NSLineBreakMode lineBreakMode;
@property (nonatomic, assign) NSUInteger maximumNumberOfLines;
@property(nullable, nonatomic, copy) NSAttributedString *truncationToken;

// text highlight 圆角背景由 render 自绘
@property (nonatomic, assign) CGFloat highlightBackgroudRadius;// default 4.0
@property (nonatomic, assign) UIEdgeInsets highlightBackgroudInset;// default zero

/**
 default NO,if YES, only set render size will caculate text bounds and cache
 */
@property (nonatomic, assign) BOOL onlySetRenderSizeWillGetTextBounds;

/**
 visible text bound
 */
@property (nonatomic, assign, readonly) CGRect textBound;

/**
 default YES, if NO every time call attachmentViews will re-get from current attributedString.
 */
@property (nonatomic, assign) BOOL onlySetTextStorageWillGetAttachViews;
@property (nonatomic, strong, readonly, nullable) NSArray<TYTextAttachment *> *attachmentViews;
@property (nonatomic, strong, readonly, nullable) NSSet<TYTextAttachment *> *attachmentViewSet;

// initialize
- (instancetype)initWithAttributedText:(NSAttributedString *)attributedText;
- (instancetype)initWithTextStorage:(NSTextStorage *)textStorage;
- (instancetype)initWithTextContainer:(NSTextContainer *)textContainer;
// if use textView editable = YES
- (instancetype)initWithTextContainer:(NSTextContainer *)textContainer editable:(BOOL)editable;

/**
 return text max size if maximumNumberOfLines 0,oherwise maximumNumberOfLines text size
 */
- (CGSize)textSizeWithRenderWidth:(CGFloat)renderWidth;

/**
 visible text range,must have been set render size
 */
- (NSRange)visibleCharacterRange;

/**
 text's lines
 */
- (NSInteger)numberOfLines;

/**
 text bound for character range,must have been set render size
 */
- (CGRect)boundingRectForCharacterRange:(NSRange)characterRange;
- (CGRect)boundingRectForGlyphRange:(NSRange)glyphRange;

/**
 text character index at piont. 返回 -1 表示未命中。
 */
- (NSInteger)characterIndexForPoint:(CGPoint)point;

/**
 text highlight at index
*/
- (TYTextHighlight *__nullable)textHighlightAtIndex:(NSUInteger)index effectiveRange:(nullable NSRangePointer)range;

/**
 draw text at point
 */
- (void)drawTextAtPoint:(CGPoint)point;

@end


@interface TYTextRender (Rendering)

@property (nonatomic, assign, readonly) CGRect textRectOnRender;
@property (nonatomic, assign, readonly) NSRange visibleCharacterRangeOnRender;
@property (nonatomic, assign, readonly) NSRange truncatedCharacterRangeOnRender;

/**
 在当前 textStorage 上应用 truncationToken（若 lineBreakMode==NSLineBreakByTruncatingTail
 且 maximumNumberOfLines>0 且当前布局会超行）。会修改 textStorage 内容，仅适合 editable=NO 的私有副本。
 */
- (void)setTextStorageTruncationToken;

/**
 高亮当前激活，drawTextAtPoint: 时会自绘圆角背景并叠加 renderingAttributes。
 */
- (void)setTextHighlight:(TYTextHighlight *__nullable)textHighlight range:(NSRange)range;

- (void)drawTextAtPoint:(CGPoint)point isCanceled:(BOOL (^__nullable)(void))isCanceled;

@end

NS_ASSUME_NONNULL_END
