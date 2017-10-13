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

// initialized with  mutableCopy attrStr
- (instancetype)initWithAttributedString:(NSAttributedString *)attrStr;
// initialized with strong attrStr,not mutableCopy,you ensure not use it in other place
- (instancetype)initWithMutableAttributedString:(NSMutableAttributedString *)attrStr;

@end

NS_ASSUME_NONNULL_END
