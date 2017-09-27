//
//  TYTextRender.h
//  TYTextKitDemo
//
//  Created by tany on 2017/9/26.
//  Copyright © 2017年 tany. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "NSAttributedString+TYTextKit.h"
#import "TYTextStorage.h"

NS_ASSUME_NONNULL_BEGIN
@interface TYTextRender : NSObject

@property (nonatomic, strong, nullable) NSTextStorage *textStorage;
@property (nonatomic, strong, readonly) NSLayoutManager *layoutManager;
@property (nonatomic, strong, readonly) NSTextContainer *textContainer;

@property (nonatomic, assign) CGSize size;

- (instancetype)initWithTextContainer:(NSTextContainer *)textContainer;

- (void)drawTextInRect:(CGRect)rect;

@end
NS_ASSUME_NONNULL_END
