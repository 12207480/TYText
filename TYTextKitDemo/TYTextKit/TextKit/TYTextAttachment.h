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

@property (nonatomic, strong, nullable) UIImage *image;
// need used TYTextRender
@property (nonatomic, strong, nullable) UIView *view;
@property (nonatomic, strong, nullable) CALayer *layer;

/**
 attachment'size
 @discussion must set attach's size or bounds
 */
@property (nonatomic,assign) CGSize size;

// range in attributed
@property (nonatomic, assign, readonly) NSRange range;
// attach render positon
@property (atomic, assign, readonly) CGPoint position;

/**
 text attachment baseline offset
 */
@property (nonatomic,assign) CGFloat baseline;

/**
 attachment vertical alignment
 @discussion must ensure the font == the line text's font
 */
@property (nonatomic,assign) TYAttachmentAlignment verticalAlignment;


/**
 if have view or layer, set the frame
 */
- (void)setFrame:(CGRect)frame;
- (void)addToSuperView:(UIView *)superView;
- (void)removeFromSuperView;

@end

@interface NSAttributedString (TYTextAttachment)

- (NSArray *__nullable)attachViews;

@end

NS_ASSUME_NONNULL_END
