//
//  TYTextStorage.h
//  TYTextKitDemo
//
//  Created by tany on 2017/9/26.
//  Copyright © 2017年 tany. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "TYTextParse.h"

NS_ASSUME_NONNULL_BEGIN
@interface TYTextStorage : NSTextStorage

@property (nonatomic, strong, nullable) id<TYTextParse> textParse;

// initialized with copy attributedString
- (instancetype)initWithAttributedString:(NSAttributedString *)attrStr;

// initialized with strong attributedString,not copy,you ensure not use it in other place
- (instancetype)initWithMutableAttributedString:(NSMutableAttributedString *)attrStr;

@end

@interface NSTextStorage (TYTextKit)

- (NSTextStorage *)ty_deepCopy;

@end

NS_ASSUME_NONNULL_END
