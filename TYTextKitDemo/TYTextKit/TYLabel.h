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

@property (nonatomic, assign) CGFloat longPressDuring;

// text
@property (nonatomic, strong, nullable) NSString *text;
@property (nonatomic, strong, nullable) NSAttributedString *attributedText;
@property (nonatomic, strong, nullable) NSTextStorage *textStorage;

/**
 textkit render engine
 @discussion suggest use it,will improve performance
 */
@property (nonatomic, strong, nullable) TYTextRender *textRender;


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
