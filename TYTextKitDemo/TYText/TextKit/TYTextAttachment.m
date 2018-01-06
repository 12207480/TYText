//
//  TYTextAttachment.m
//  TYTextKitDemo
//
//  Created by tany on 2017/9/26.
//  Copyright © 2017年 tany. All rights reserved.
//

#import "TYTextAttachment.h"
#import "NSAttributedString+TYText.h"
#import <pthread.h>

#define TYAssertMainThread() NSAssert(0 != pthread_main_np(), @"This method must be called on the main thread!")

@interface TYTextAttachment ()
@property (nonatomic, assign) NSRange range;
@property (nonatomic, assign) CGPoint position;
@end

@implementation TYTextAttachment
@dynamic image;

#pragma mark - Setter

- (void)setSize:(CGSize)size {
    _size = size;
    self.bounds = CGRectMake(0, _baseline, _size.width, _size.height);
}

- (void)setBounds:(CGRect)bounds {
    [super setBounds:bounds];
    _size = bounds.size;
}

- (void)setBaseline:(CGFloat)baseline {
    _baseline = baseline;
    self.bounds = CGRectMake(0, _baseline, _size.width, _size.height);
}

- (void)setImage:(UIImage *)image {
    [super setImage:image];
    if (_size.width == 0 && _size.height == 0 ) {
        self.size = image.size;
    }
}

- (void)setView:(UIView *)view {
    _view = view;
    if (_size.width == 0 && _size.height == 0 ) {
        self.size = view.frame.size;
    }
}

#pragma mark - NSTextAttachmentContainer

- (nullable UIImage *)imageForBounds:(CGRect)imageBounds textContainer:(nullable NSTextContainer *)textContainer characterIndex:(NSUInteger)charIndex {
    _position = CGPointMake(imageBounds.origin.x, imageBounds.origin.y - _size.height);
    return self.image;
}

- (CGRect)attachmentBoundsForTextContainer:(NSTextContainer *)textContainer proposedLineFragment:(CGRect)lineFrag glyphPosition:(CGPoint)position characterIndex:(NSUInteger)charIndex {
    if (_verticalAlignment == TYAttachmentAlignmentBaseline || self.bounds.origin.y > 0) {
        return self.bounds;
    }
    CGFloat offset = 0;
    // TO DO: textStorage not thread safe
    UIFont *font = [textContainer.layoutManager.textStorage ty_fontAtIndex:charIndex effectiveRange:nil];
    if (!font) {
        return self.bounds;
    }
    switch (_verticalAlignment) {
        case TYAttachmentAlignmentCenter:
            offset = (_size.height-font.capHeight)/2;
            break;
        case TYAttachmentAlignmentBottom:
            offset = _size.height-font.capHeight;
        default:
            break;
    }
    return CGRectMake(0, -offset, _size.width, _size.height);
}

@end

@implementation TYTextAttachment (Rendering)

- (void)setFrame:(CGRect)frame {
    _view.frame = frame;
    _layer.frame = frame;
}

- (void)addToSuperView:(UIView *)superView {
    TYAssertMainThread();
    if (_view) {
        [superView addSubview:_view];
    }else if (_layer) {
        [superView.layer addSublayer:_layer];
    }
}

- (void)removeFromSuperView:(UIView *)superView {
    TYAssertMainThread();
    if (_view.superview == superView) {
        [_view removeFromSuperview];
    }
    if (_layer.superlayer == superView.layer) {
        [_layer removeFromSuperlayer];
    }
}

@end

@implementation NSAttributedString (TYTextAttachment)

- (NSArray *)attachmentViews {
    NSMutableArray *array = [NSMutableArray array];
    [self enumerateAttribute:NSAttachmentAttributeName inRange:NSMakeRange(0, self.length) options:kNilOptions usingBlock:^(TYTextAttachment *value, NSRange subRange, BOOL *stop) {
        if (value && [value isKindOfClass:[TYTextAttachment class]] && (value.view || value.layer)) {
            ((TYTextAttachment *)value).range = subRange;
            [array addObject:value];
        }
    }];
    return array.count > 0 ? [array copy] : nil;
}

@end
