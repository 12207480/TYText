//
//  TYTextRender.h
//  TYTextKitDemo
//
//  Created by tany on 2017/9/26.
//  Copyright © 2017年 tany. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "NSAttributedString+TYTextKit.h"
#import "TYTextStorage.h"
#import "TYTextAttachment.h"
#import "TYTextAttribute.h"
#import "TYLayoutManager.h"

NS_ASSUME_NONNULL_BEGIN
@interface TYTextRender : NSObject

@property (nonatomic, strong, nullable) NSTextStorage *textStorage;
@property (nonatomic, strong, readonly) NSLayoutManager *layoutManager;
@property (nonatomic, strong, readonly) NSTextContainer *textContainer;

/**
 text is inset within line fragment rectangles.default 0
 */
@property (nonatomic, assign) CGFloat lineFragmentPadding;

@property (nonatomic, assign) NSLineBreakMode lineBreakMode;
@property (nonatomic, assign) NSUInteger maximumNumberOfLines;


/**
 text highlight background corner radius. default 4.0
 @discussion only support TYLayoutManager
 */
@property (nonatomic, assign) CGFloat highlightBackgroudRadius;

/**
 text attributed contain attach views or layers
 */
@property (nonatomic, strong, readonly, nullable) NSArray *attachments;
@property (nonatomic, strong, readonly, nullable) NSSet *attachmentSet;
/**
 default YES, otherwise get textStorage'attachViews every time.
 */
@property (nonatomic, assign) BOOL onlySetTextStorageWillGetAttachViews;
/**
 render size
 */
@property (nonatomic, assign) CGSize size;

/**
 visible text bound
 @discussion render should set size before call this
 */
@property (nonatomic, assign, readonly) CGRect textBound;

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

- (instancetype)initWithAttributedText:(NSAttributedString *)attributedText;
- (instancetype)initWithTextStorage:(NSTextStorage *)textStorage;
- (instancetype)initWithTextContainer:(NSTextContainer *)textContainer;

/**
 visible text range
 */
- (NSRange)visibleCharacterRange;

/**
 text bound for character range
 */
- (CGRect)boundingRectForCharacterRange:(NSRange)characterRange;

/**
 text character index at piont
 */
- (NSInteger)characterIndexForPoint:(CGPoint)point;

/**
 set text highlight
 */
- (void)setTextHighlight:(TYTextHighlight *)textHighlight range:(NSRange)range;

/**
 draw text at point
 */
- (void)drawTextAtPoint:(CGPoint)point;
- (void)drawTextAtPoint:(CGPoint)point isCanceled:(BOOL (^__nullable)(void))isCanceled;

@end
NS_ASSUME_NONNULL_END
