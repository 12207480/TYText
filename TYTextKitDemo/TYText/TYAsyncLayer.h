//
//  TYAsyncLayer.h
//  TYTextKitDemo
//
//  Created by tany on 2017/9/11.
//  Copyright © 2017年 tany. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <QuartzCore/QuartzCore.h>

NS_ASSUME_NONNULL_BEGIN

CGFloat ty_text_screen_scale(void);

@class TYAsyncLayerDisplayTask;
@protocol TYAsyncLayerDelegate <NSObject>
@required

- (TYAsyncLayerDisplayTask *)newAsyncDisplayTask;

@end

// quote YYAsyncLayer
@interface TYAsyncLayer : CALayer

/**
 delegate for asynchronous display of the layer.
 */
@property (nonatomic, weak) id<TYAsyncLayerDelegate> asyncDelegate;

/**
 asynchronous display layer on background thread. default YES
 */
@property (nonatomic, assign) BOOL displaysAsynchronously;

/**
 display layer on main thread.
 */
- (void)displayImmediately;

/**
 cancels any pending asynchronous display.
 */
- (void)cancelAsyncDisplay;

@end

@interface TYAsyncLayerDisplayTask : NSObject


/**
 will display layer on main thread.
 */
@property (nullable, nonatomic, copy) void (^willDisplay)(CALayer *layer);


/**
 is displaying layer's content,will be call on main or background thread.
 */
@property (nullable, nonatomic, copy) void (^displaying)(CGContextRef context, CGSize size, BOOL isAsynchronously, BOOL(^isCancelled)(void));


/**
 did display layer on main thread. if cancle display,finish is NO.
 */
@property (nullable, nonatomic, copy) void (^didDisplay)(CALayer *layer, BOOL finished);

@end

NS_ASSUME_NONNULL_END
