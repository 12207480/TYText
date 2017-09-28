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
    TYAttachmentAlignmentTop,
    TYAttachmentAlignmentCenter,
    TYAttachmentAlignmentBottom
};

NS_ASSUME_NONNULL_BEGIN
@interface TYTextAttachment : NSTextAttachment


@property (nonatomic, strong, nullable) NSString *imageName;
@property (nonatomic, strong, nullable) UIImage *image;

@property (nonatomic, strong, nullable) UIView *view;
@property (nonatomic, strong, nullable) CALayer *layer;

/**
 text attachment baseline offset
 */
@property (nonatomic,assign) CGFloat baseline;

/**
 attachment vertical alignment
 */
@property (nonatomic,assign) TYAttachmentAlignment verticalAlignment;

/**
 attachment'size
 */
@property (nonatomic,assign) CGSize size;

@end
NS_ASSUME_NONNULL_END
