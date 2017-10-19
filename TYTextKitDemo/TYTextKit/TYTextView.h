//
//  TYTextView.h
//  TYTextKitDemo
//
//  Created by tany on 2017/10/19.
//  Copyright © 2017年 tany. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "TYTextRender.h"

@interface TYTextView : UITextView

@property (nonatomic, strong, readonly) TYTextRender *textRender;

- (instancetype)initWithFrame:(CGRect)frame textRender:(TYTextRender *)textRender;

@end
