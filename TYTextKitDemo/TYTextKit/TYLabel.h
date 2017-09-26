//
//  TYLabel.h
//  TYTextKitDemo
//
//  Created by tany on 2017/9/8.
//  Copyright © 2017年 tany. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "TYTextRender.h"

@interface TYLabel : UIView

@property (nonatomic, assign) BOOL displaysAsynchronously;
@property (nonatomic, assign) BOOL clearContentsBeforeAsynchronouslyDisplay;

@property (nonatomic, strong) NSString *text;
@property (nonatomic, strong) NSAttributedString *attributedText;
@property (nonatomic, strong) TYTextRender *textRender;

@end
