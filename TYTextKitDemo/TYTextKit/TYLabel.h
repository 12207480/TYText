//
//  TYLabel.h
//  TYTextKitDemo
//
//  Created by tany on 2017/9/8.
//  Copyright © 2017年 tany. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "TYTextRender.h"

NS_ASSUME_NONNULL_BEGIN

@class TYLabel;
@protocol TYLabelDelegate <NSObject>

@optional

/**
 when user tapped text highlight,will call this
 */
- (void)label:(TYLabel *)label didTappedTextHighlight:(TYTextHighlight *)textHighlight;

/**
 when user long pressed text highlight,will call this
 */
- (void)label:(TYLabel *)label didLongPressedTextHighlight:(TYTextHighlight *)textHighlight;

@end

@interface TYLabel : UIView

@property (nonatomic, weak, nullable) id<TYLabelDelegate> delegate;

/**
asynchronous display of the view's layer. default YES
 */
@property (nonatomic, assign) BOOL displaysAsynchronously;

/**
 clear layer'content,before asynchronously display. default YES
 */
@property (nonatomic, assign) BOOL clearContentBeforeAsyncDisplay;

// text 
@property (nonatomic, strong, nullable) NSString *text;
//if set, the label ignores the common properties. see ignoreLabelCommonPropertys.
@property (nonatomic, strong, nullable) NSAttributedString *attributedText;
@property (nonatomic, strong, nullable) NSTextStorage *textStorage;

/**
 textkit render engine. default nil,if set, the label ignores the common properties. see ignoreAboveLabelRelatePropertys.
 */
@property (nonatomic, strong, nullable) TYTextRender *textRender;

@property (nonatomic, strong, nullable) UIFont *font;       // default nil (17 system font)
@property (nonatomic, strong, nullable) UIColor *textColor; // default nil
@property (nonatomic, strong, nullable) NSShadow *shadow;   // default nil

@property (nonatomic, assign) NSTextAlignment    textAlignment;   // default is NSTextAlignmentNatural (before iOS 9, the default was NSTextAlignmentLeft)
@property (nonatomic, assign) NSLineBreakMode    lineBreakMode;   // default is NSLineBreakByTruncatingTail. used for single and multiple lines of text

// text vertical alignment. default center
@property (nonatomic, assign) TYTextVerticalAlignment verticalAlignment;

// A value of 0 means no limit.default 0
// if the height of the text reaches the # of lines or the height of the view is less than the # of lines allowed, the text will be
// truncated using the line break mode.
@property (nonatomic, assign) NSInteger numberOfLines;

/**
 if you set textRender,will ignore above label relate propertys.defult YES
 */
@property (nonatomic, assign) BOOL ignoreAboveLabelRelatePropertys;

/**
 user long press during time will call delegate. default 2.0
 */
@property (nonatomic, assign) CGFloat longPressDuring;


/**
 next runloop,layer redraw on private thread
 */
- (void)setDisplayNeedRedraw;

/**
 layer redraw on mian thread
 */
- (void)immediatelyDisplayRedraw;

@end
NS_ASSUME_NONNULL_END
