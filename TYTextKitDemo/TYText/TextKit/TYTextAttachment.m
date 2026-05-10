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
    // 关闭 UITextView 自动 viewProvider，避免它在 attachment 占位字符上盖一层空白 view。
    self.allowsTextAttachmentView = (view == nil && _layer == nil);
}

- (void)setLayer:(CALayer *)layer {
    _layer = layer;
    if (_size.width == 0 && _size.height == 0) {
        self.size = layer.bounds.size;
    }
    self.allowsTextAttachmentView = (_view == nil && layer == nil);
}

#pragma mark - NSTextAttachmentContainer

- (nullable UIImage *)imageForBounds:(CGRect)imageBounds textContainer:(nullable NSTextContainer *)textContainer characterIndex:(NSUInteger)charIndex {
    if (self.image) {
        return self.image;
    }
    // view/layer 类型的附件由 TYLabel / TYTextView 手动放置子视图。
    // TextKit 2 的 NSTextLayoutFragment.drawAtPoint: 在 attachment cell 没有 image 时会绘制浅灰占位矩形，
    // 这里返回 1×1 透明像素，让占位完全不可见。
    if (self.view || self.layer) {
        return [TYTextAttachment ty_transparentPlaceholder];
    }
    return nil;
}

+ (UIImage *)ty_transparentPlaceholder {
    static UIImage *transparent = nil;
    static dispatch_once_t once;
    dispatch_once(&once, ^{
        UIGraphicsBeginImageContextWithOptions(CGSizeMake(1, 1), NO, 1);
        transparent = UIGraphicsGetImageFromCurrentImageContext();
        UIGraphicsEndImageContext();
    });
    return transparent;
}

- (CGRect)attachmentBoundsForTextContainer:(NSTextContainer *)textContainer proposedLineFragment:(CGRect)lineFrag glyphPosition:(CGPoint)position characterIndex:(NSUInteger)charIndex {
    if (_verticalAlignment == TYAttachmentAlignmentBaseline || self.bounds.origin.y > 0) {
        return self.bounds;
    }
    UIFont *font = [self ty_fontAtCharacterIndex:charIndex inTextContainer:textContainer];
    if (!font) {
        return self.bounds;
    }
    CGFloat offset = 0;
    switch (_verticalAlignment) {
        case TYAttachmentAlignmentCenter:
            offset = (_size.height - font.capHeight) / 2;
            break;
        case TYAttachmentAlignmentBottom:
            offset = _size.height - font.capHeight;
        default:
            break;
    }
    return CGRectMake(0, -offset, _size.width, _size.height);
}

#pragma mark - Private

- (UIFont *)ty_fontAtCharacterIndex:(NSUInteger)charIndex inTextContainer:(NSTextContainer *)textContainer {
    NSAttributedString *source = nil;
    // TextKit 2：container → textLayoutManager → textContentManager（NSTextContentStorage）→ attributedString
    NSTextLayoutManager *textLayoutManager = textContainer.textLayoutManager;
    if (textLayoutManager) {
        NSTextContentManager *contentManager = textLayoutManager.textContentManager;
        if ([contentManager isKindOfClass:[NSTextContentStorage class]]) {
            source = ((NSTextContentStorage *)contentManager).attributedString;
        }
    }
    // TextKit 1 回退（目前项目里不再使用，保留以免未来直接嵌入 UITextView.layoutManager 场景）
    if (!source) {
        source = textContainer.layoutManager.textStorage;
    }
    if (!source || charIndex >= source.length) {
        return nil;
    }
    return [source ty_fontAtIndex:charIndex effectiveRange:nil];
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

- (void)ty_updateRange:(NSRange)range {
    self.range = range;
}

- (void)ty_updatePosition:(CGPoint)position {
    self.position = position;
}

@end

@implementation NSAttributedString (TYTextAttachment)

- (NSArray *)attachmentViews {
    NSMutableArray *array = [NSMutableArray array];
    [self enumerateAttribute:NSAttachmentAttributeName inRange:NSMakeRange(0, self.length) options:kNilOptions usingBlock:^(TYTextAttachment *value, NSRange subRange, BOOL *stop) {
        if (value && [value isKindOfClass:[TYTextAttachment class]] && (value.view || value.layer)) {
            [value ty_updateRange:subRange];
            [array addObject:value];
        }
    }];
    return array.count > 0 ? [array copy] : nil;
}

@end
