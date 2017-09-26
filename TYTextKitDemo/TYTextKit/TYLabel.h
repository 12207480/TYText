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

@property (nonatomic, assign) BOOL displaysAsynchronously;
@property (nonatomic, assign) BOOL clearContentBeforeAsyncDisplay;

@property (nonatomic, strong, nullable) NSString *text;
@property (nonatomic, strong, nullable) NSAttributedString *attributedText;
@property (nonatomic, strong, nullable) TYTextRender *textRender;

@end
NS_ASSUME_NONNULL_END
