//
//  TYAsyncLayer.m
//  TYTextKitDemo
//
//  Created by tany on 2017/9/11.
//  Copyright © 2017年 tany. All rights reserved.
//

#import "TYAsyncLayer.h"
#import <stdatomic.h>

static dispatch_queue_t asyncDisplayQueue() {
    static dispatch_queue_t displayQueue = NULL;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        if ([UIDevice currentDevice].systemVersion.floatValue >= 8.0) {
            dispatch_queue_attr_t attr = dispatch_queue_attr_make_with_qos_class(DISPATCH_QUEUE_CONCURRENT, QOS_CLASS_USER_INITIATED, 0);
            displayQueue = dispatch_queue_create("com.yeBlueColor.textkit.render", attr);
        }else {
            displayQueue = dispatch_queue_create("com.yeBlueColor.textkit.render", DISPATCH_QUEUE_CONCURRENT);
            dispatch_set_target_queue(displayQueue, dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH,0));
        }
    });
    return displayQueue;
}

CGFloat ty_text_screen_scale(void) {
    static CGFloat scale;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        scale = [UIScreen mainScreen].scale;
    });
    return scale;
}

@interface TYSentinel : NSObject

- (unsigned int)value;

- (void)increase;

@end

@implementation TYSentinel {
    atomic_uint _value;
}
- (unsigned int)value {
    return atomic_load(&_value);
}
- (void)increase {
    atomic_fetch_add(&_value,1);
}
@end

@implementation TYAsyncLayer {
    TYSentinel *_sentinel;
}

+ (id)defaultValueForKey:(NSString *)key {
    if ([key isEqualToString:@"displaysAsynchronously"]) {
        return @(YES);
    } else {
        return [super defaultValueForKey:key];
    }
}

- (instancetype)init {
    if (self = [super init]) {
        [self configureLayer];
    }
    return self;
}

- (instancetype)initWithCoder:(NSCoder *)aDecoder {
    if (self = [super initWithCoder:aDecoder]) {
        [self configureLayer];
    }
    return self;
}

- (void)configureLayer {
    _sentinel = [[TYSentinel alloc]init];
    _displaysAsynchronously = YES;
    self.contentsScale = ty_text_screen_scale();
    self.opaque = YES;
}

#pragma mark - public

- (void)setNeedsDisplay {
    [_sentinel increase];
    [super setNeedsDisplay];
}

- (void)display {
    if (!_asyncDelegate) {
        [super display];
        return;
    }
    super.contents = super.contents;
    [self displayAsync:_displaysAsynchronously];
}

- (void)displayImmediately {
    [_sentinel increase];;
    if ([NSThread isMainThread]) {
        [self displayAsync:NO];
    }else {
        dispatch_async(dispatch_get_main_queue(), ^{
            [self displayAsync:NO];
        });
    }
}

- (void)cancelAsyncDisplay {
    [_sentinel increase];;
}

- (void)dealloc {
    [_sentinel increase];
    _asyncDelegate = nil;
}

#pragma mark - private

- (void)displayAsync:(BOOL)asynchronously {
    __strong id<TYAsyncLayerDelegate> delegate = _asyncDelegate;
    TYAsyncLayerDisplayTask *task = [delegate newAsyncDisplayTask];
    if (task.willDisplay) {
        task.willDisplay(self);
    }
    CGSize size = self.bounds.size;
    if (!task.displaying || size.width < 0.1 || size.height < 0.1) {
        self.contents = nil;
        if (task.didDisplay) {
            task.didDisplay(self, YES);
        }
        return;
    }
    
    BOOL opaque = self.opaque;
    CGFloat scale = self.contentsScale;
    UIColor *backgroundColor = (opaque && self.backgroundColor) ? [UIColor colorWithCGColor:self.backgroundColor] : nil;
    if (asynchronously) {
        unsigned int value = [_sentinel value];
        TYSentinel *sentinel = _sentinel;
        BOOL (^isCancelled)(void) = ^BOOL(void){
            return value != [sentinel value];
        };
        dispatch_async(asyncDisplayQueue(), ^{
            if (isCancelled()) {
                return ;
            }
            UIGraphicsBeginImageContextWithOptions(size, opaque, scale);
            CGContextRef context = UIGraphicsGetCurrentContext();
            if (!context) {
                UIGraphicsEndImageContext();
                return;
            }
            if (opaque) {
                CGContextSaveGState(context);
                CGContextSetFillColorWithColor(context,backgroundColor.CGColor);
                CGContextAddRect(context, CGRectMake(0, 0, size.width * scale, size.height * scale));
                CGContextFillPath(context);
                CGContextRestoreGState(context);
            }
            task.displaying(context, size, YES, isCancelled);
            if (isCancelled()) {
                UIGraphicsEndImageContext();
                dispatch_async(dispatch_get_main_queue(), ^{
                    if (task.didDisplay) task.didDisplay(self, NO);
                });
                return ;
            }
            UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
            UIGraphicsEndImageContext();
            if (isCancelled()) {
                dispatch_async(dispatch_get_main_queue(), ^{
                    if (task.didDisplay) task.didDisplay(self, NO);
                });
                return;
            }
            dispatch_async(dispatch_get_main_queue(), ^{
                if (isCancelled()) {
                    if (task.didDisplay) task.didDisplay(self, NO);
                } else {
                    self.contents = (__bridge id)(image.CGImage);
                    if (task.didDisplay) task.didDisplay(self, YES);
                }
            });
        });
    } else {
        [_sentinel increase];
        UIGraphicsBeginImageContextWithOptions(size, opaque, scale);
        CGContextRef context = UIGraphicsGetCurrentContext();
        if (opaque) {
            CGContextSaveGState(context);
            CGContextSetFillColorWithColor(context,backgroundColor.CGColor);
            CGContextAddRect(context, CGRectMake(0, 0, size.width * scale, size.height * scale));
            CGContextFillPath(context);
            CGContextRestoreGState(context);
        }
        task.displaying(context, size, NO,^{return NO;});
        UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
        UIGraphicsEndImageContext();
        self.contents = (__bridge id)(image.CGImage);
        if (task.didDisplay) {
            task.didDisplay(self, YES);
        };
    }
}

@end

@implementation TYAsyncLayerDisplayTask
@end
