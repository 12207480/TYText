//
//  TYTextAttachment.h
//  TYTextKitDemo
//
//  Created by tany on 2017/9/26.
//  Copyright © 2017年 tany. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef NS_ENUM(NSUInteger, TYAttachmentAlignment) {
    TYAttachmentAlignmentBaseline,
    TYAttachmentAlignmentCenter,
    TYAttachmentAlignmentBottom
};

NS_ASSUME_NONNULL_BEGIN
@interface TYTextAttachment : NSTextAttachment

//super @property (nonatomic, strong, nullable) UIImage *image;
// used in TYTextRender
@property (nonatomic, strong, nullable) UIView *view;
@property (nonatomic, strong, nullable) CALayer *layer;

/**
 attachment'size
 @discussion must set attach's size or bounds
 */
@property (nonatomic,assign) CGSize size;

/**
 text attachment baseline offset
 */
@property (nonatomic,assign) CGFloat baseline;

/**
 attachment vertical alignment
 @discussion must ensure the font == the line text's font
 */
@property (nonatomic,assign) TYAttachmentAlignment verticalAlignment;

@end


@interface TYTextAttachment (Rendering)

// range in attributed ,after render will have value
@property (nonatomic, assign, readonly) NSRange range;
// attach render positon ,after render will have value
@property (nonatomic, assign, readonly) CGPoint position;

// TYTextRender 会在异步渲染完成后主线程调用这组方法，更新/挂载/摘除附件视图。
- (void)setFrame:(CGRect)frame;
- (void)addToSuperView:(UIView *)superView;
- (void)removeFromSuperView:(UIView *)superView;
// TYTextRender 用来登记 attachment 在 attributed string 中的字符范围和布局帧原点
- (void)ty_updateRange:(NSRange)range;
- (void)ty_updatePosition:(CGPoint)position;

@end


@interface NSAttributedString (TYTextAttachment)

- (NSArray<TYTextAttachment *> *__nullable)attachmentViews;

@end

NS_ASSUME_NONNULL_END
