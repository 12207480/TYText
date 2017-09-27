//
//  TYTextStorage.h
//  TYTextKitDemo
//
//  Created by tany on 2017/9/26.
//  Copyright © 2017年 tany. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "TYTextParse.h"

@interface TYTextStorage : NSTextStorage

@property (nonatomic, strong) id<TYTextParse> textParse;

// will mutableCopy attrStr
- (instancetype)initWithAttributedString:(NSAttributedString *)attrStr;
// not mutableCopy,will assign attrStr
- (instancetype)initWithMutableAttributedString:(NSMutableAttributedString *)attrStr;

@end
