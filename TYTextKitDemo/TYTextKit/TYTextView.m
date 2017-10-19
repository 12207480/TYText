//
//  TYTextView.m
//  TYTextKitDemo
//
//  Created by tany on 2017/10/19.
//  Copyright © 2017年 tany. All rights reserved.
//

#import "TYTextView.h"

@interface TYTextView ()<TYLayoutManagerEditRender>

@property (nonatomic, strong) TYTextRender *textRender;

@property (nonatomic, strong) NSArray *attachments;

@end

@implementation TYTextView

- (instancetype)initWithFrame:(CGRect)frame textRender:(TYTextRender *)textRender {
    if (self = [super initWithFrame:frame textContainer:textRender.textContainer]) {
        self.textRender = textRender;
    }
    return self;
}

- (instancetype)initWithFrame:(CGRect)frame {
    if (self = [self initWithFrame:frame textRender:[self defaultTextRender]]) {
    }
    return self;
}

- (TYTextRender *)defaultTextRender {
    NSTextStorage *textStorage = [[TYTextStorage alloc]init];
    TYTextRender *textRender = [[TYTextRender alloc]initWithTextStorage:textStorage];
    textRender.lineFragmentPadding = 5.0;
    return textRender;
}

- (void)setTextRender:(TYTextRender *)textRender {
    if ([textRender.layoutManager isKindOfClass:[TYLayoutManager class]]) {
        ((TYLayoutManager *)textRender.layoutManager).render = self;
    }
    textRender.editable = YES;
    _textRender = textRender;
}

- (void)addAttachmentViews {
    NSArray *attachments = _textRender.attachmentViews;
    if (!_attachments && !attachments) {
        return;
    }
    NSSet *attachmentSet = _textRender.attachmentViewSet;
    for (TYTextAttachment *attachment in _attachments) {
        if (!attachmentSet || ![attachmentSet containsObject:attachment]) {
            [attachment removeFromSuperView:self];
        }
    }
    NSRange visibleRange = [_textRender visibleCharacterRange];
    for (TYTextAttachment *attachment in attachments) {
        if (NSLocationInRange(attachment.range.location, visibleRange)) {
            CGRect rect = {attachment.position,attachment.size};
            [attachment addToSuperView:self];
            attachment.frame = rect;
        }else {
            [attachment removeFromSuperView:self];
        }
    }
    _attachments = attachments;
}

#pragma mark - TYLayoutManagerEditRender

- (void)layoutManager:(TYLayoutManager *)layoutManager processEditingForTextStorage:(NSTextStorage *)textStorage edited:(NSTextStorageEditActions)editMask range:(NSRange)newCharRange changeInLength:(NSInteger)delta invalidatedRange:(NSRange)invalidatedCharRange {
    
}

- (void)layoutManager:(TYLayoutManager *)layoutManager drawGlyphsForGlyphRange:(NSRange)glyphsToShow atPoint:(CGPoint)origin {
    [self addAttachmentViews];
}


@end
