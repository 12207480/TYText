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

NS_ASSUME_NONNULL_BEGIN
@interface TYTextRender : NSObject

// textkit
@property (nonatomic, strong, nullable) NSTextStorage *textStorage;
@property (nonatomic, strong, readonly) NSLayoutManager *layoutManager;
@property (nonatomic, strong, readonly) NSTextContainer *textContainer;


/**
 text attributed contain attach views or layers
 */
@property (nonatomic, strong, readonly) NSArray *attachViews;
/**
 render size
 */
@property (nonatomic, assign) CGSize size;

/**
 visible text bound
 @discussion if size is zero, it return zero
 */
@property (nonatomic, assign, readonly) CGRect textBound;

/**
 text rect in container
 @discussion when text did render,will have value
 */
@property (atomic, assign, readonly) CGRect textRect;

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
