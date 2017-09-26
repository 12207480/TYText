//
//  TYTextRender.h
//  TYTextKitDemo
//
//  Created by tany on 2017/9/26.
//  Copyright © 2017年 tany. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "NSAttributedString+TYTextKit.h"

@interface TYTextRender : NSObject

@property (nonatomic, strong) NSTextStorage *textStorage;
@property (nonatomic, strong, readonly) NSLayoutManager *layoutManager;
@property (nonatomic, strong, readonly) NSTextContainer *textContainer;

@property (nonatomic, assign) CGSize size;

- (void)drawTextInRect:(CGRect)rect;

@end
