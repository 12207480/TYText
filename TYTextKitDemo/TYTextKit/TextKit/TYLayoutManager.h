//
//  TYLayoutManager.h
//  TYTextKitDemo
//
//  Created by tanyang on 2017/10/14.
//  Copyright © 2017年 tany. All rights reserved.
//

#import <UIKit/UIKit.h>

@class TYLayoutManager;
@protocol TYLayoutManagerEditRender<NSObject>

- (void)layoutManager:(TYLayoutManager *)layoutManager drawGlyphsForGlyphRange:(NSRange)glyphsToShow atPoint:(CGPoint)origin;

- (void)layoutManager:(TYLayoutManager *)layoutManager processEditingForTextStorage:(NSTextStorage *)textStorage edited:(NSTextStorageEditActions)editMask range:(NSRange)newCharRange changeInLength:(NSInteger)delta invalidatedRange:(NSRange)invalidatedCharRange;

@end

@interface TYLayoutManager : NSLayoutManager

@property (nonatomic, weak) id<TYLayoutManagerEditRender> render;

@property (nonatomic, assign) NSRange highlightRange;

@property (nonatomic, assign) CGFloat highlightBackgroudRadius;

@end
