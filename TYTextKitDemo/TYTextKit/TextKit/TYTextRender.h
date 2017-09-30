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

NS_ASSUME_NONNULL_BEGIN
@interface TYTextRender : NSObject

// textkit
@property (nonatomic, strong, nullable) NSTextStorage *textStorage;
@property (nonatomic, strong, readonly) NSLayoutManager *layoutManager;
@property (nonatomic, strong, readonly) NSTextContainer *textContainer;

/**
 text render size
 */
@property (nonatomic, assign) CGSize size;

- (instancetype)initWithTextStorage:(NSTextStorage *)textStorage;
- (instancetype)initWithTextContainer:(NSTextContainer *)textContainer;

- (CGRect)boundingRectForCharacterRange:(NSRange)characterRange;

- (NSRange)visibleCharacterRange;

/**
 draw text at point
 */
- (void)drawTextAtPoint:(CGPoint)point;
- (void)drawTextAtPoint:(CGPoint)point isCanceled:(BOOL (^__nullable)(void))isCanceled;

@end
NS_ASSUME_NONNULL_END
