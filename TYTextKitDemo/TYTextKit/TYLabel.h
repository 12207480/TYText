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
@interface TYLabel : UIView


/**
  asynchronous display of the view's layer.
 */
@property (nonatomic, assign) BOOL displaysAsynchronously;

/**
 clear layer'content,before asynchronously display
 */
@property (nonatomic, assign) BOOL clearContentBeforeAsyncDisplay;

// text
@property (nonatomic, strong, nullable) NSString *text;
@property (nonatomic, strong, nullable) NSAttributedString *attributedText;
@property (nonatomic, strong, nullable) NSTextStorage *textStorage;

/**
 textkit render class
 @discussion suggest use it,will improve performance
 */
@property (nonatomic, strong, nullable) TYTextRender *textRender;

@end
NS_ASSUME_NONNULL_END
