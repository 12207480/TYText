//
//  TYTextRender.h
//  TYTextKitDemo
//
//  Created by tany on 2017/9/26.
//  Copyright © 2017年 tany. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "TYTextStorage.h"
#import "TYTextAttachment.h"
#import "TYTextAttribute.h"
#import "TYLayoutManager.h"
#import "NSAttributedString+TYText.h"

NS_ASSUME_NONNULL_BEGIN

typedef NS_ENUM(NSUInteger, TYTextVerticalAlignment) {
    TYTextVerticalAlignmentCenter,
    TYTextVerticalAlignmentTop,
    TYTextVerticalAlignmentBottom,
};

@interface TYTextRender : NSObject

@property (nonatomic, strong, nullable) NSTextStorage *textStorage;
@property (nonatomic, strong, readonly) NSLayoutManager *layoutManager;
@property (nonatomic, strong, readonly) NSTextContainer *textContainer;

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

// text highlight. support TYLayoutManager
@property (nonatomic, assign) CGFloat highlightBackgroudRadius;// default 4.0
@property (nonatomic, assign) UIEdgeInsets highlightBackgroudInset;// default zero

/**
 default NO,if YES, only set render size will caculate text bounds and cache
 @discussion if YES cache text bounds will optimize performance,otherwise every time you call -(CGRect)textBound will re-caculate text bound.
 */
@property (nonatomic, assign) BOOL onlySetRenderSizeWillGetTextBounds;

/**
 visible text bound
 @discussion render should set size before call this, you can set onlySetRenderSizeWillGetTextBounds YES, will cache text bounds
 */
@property (nonatomic, assign, readonly) CGRect textBound;

/**
 default YES, if NO every time call textStorage'attachViews will re-get attachViews.
 */
@property (nonatomic, assign) BOOL onlySetTextStorageWillGetAttachViews;
/**
 text attributed contain attachment views or layers
 */
@property (nonatomic, strong, readonly, nullable) NSArray<TYTextAttachment *> *attachmentViews;
@property (nonatomic, strong, readonly, nullable) NSSet<TYTextAttachment *> *attachmentViewSet;

// initialize
- (instancetype)initWithAttributedText:(NSAttributedString *)attributedText;
- (instancetype)initWithTextStorage:(NSTextStorage *)textStorage;
- (instancetype)initWithTextContainer:(NSTextContainer *)textContainer;

/**
 return text max size if maximumNumberOfLines 0,oherwise maximumNumberOfLines text size
 @param renderWidth text render width
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
 text character index at piont
 */
- (NSInteger)characterIndexForPoint:(CGPoint)point;

/**
 draw text at point
 */
- (void)drawTextAtPoint:(CGPoint)point;

@end


@interface TYTextRender (Rendering)

/**
 text rect on render
 @discussion when text rendered display,will have value
 */
@property (nonatomic, assign, readonly) CGRect textRectOnRender;

/**
 visible text range on render
 @discussion when text rendered display,will have value
 */
@property (nonatomic, assign, readonly) NSRange visibleCharacterRangeOnRender;

/**
 text truncated range on render
 @discussion when text rendered display,if text truncated,the range's length > 0
 */
@property (nonatomic, assign, readonly) NSRange truncatedCharacterRangeOnRender;

/**
 set text highlight
 */
- (void)setTextHighlight:(TYTextHighlight *)textHighlight range:(NSRange)range;

/**
 draw text at point
 */
- (void)drawTextAtPoint:(CGPoint)point isCanceled:(BOOL (^__nullable)(void))isCanceled;

@end

NS_ASSUME_NONNULL_END
