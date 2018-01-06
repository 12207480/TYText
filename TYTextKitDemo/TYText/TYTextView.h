//
//  TYTextView.h
//  TYTextKitDemo
//
//  Created by tany on 2017/10/19.
//  Copyright © 2017年 tany. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "TYTextRender.h"

@class TYTextView;
@protocol TYTextViewDelegate <UITextViewDelegate>
@optional

// insert text
- (BOOL)textView:(TYTextView *)textView shouldInsertText:(NSString *)text;
- (BOOL)textView:(TYTextView *)textView shouldInsertAttributedText:(NSAttributedString *)attributedText;

// editing text
- (void)textView:(TYTextView *)textView processEditingForTextStorage:(NSTextStorage *)textStorage edited:(NSTextStorageEditActions)editMask range:(NSRange)newCharRange changeInLength:(NSInteger)delta invalidatedRange:(NSRange)invalidatedCharRange;

// user tapped text highlight,when text edited is NO
- (void)textView:(TYTextView *)textView didTappedTextHighlight:(TYTextHighlight *)textHighlight;

// user long pressed text highlight,when text edited is NO
- (void)textView:(TYTextView *)textView didLongPressedTextHighlight:(TYTextHighlight *)textHighlight;

@end

@interface TYTextView : UITextView

@property (nonatomic, strong, readonly) TYTextRender *textRender;

// text related propertys
//super @property (nonatomic, assign) NSTextAlignment textAlignment;
@property (nonatomic, assign) CGFloat characterSpacing;
@property (nonatomic, assign) CGFloat lineSpacing;
@property (nonatomic, assign) NSLineBreakMode lineBreakMode;

/**
 ignore the above text related propertys. default NO
 忽略上面的文本相关属性设置.
 */
@property (nonatomic, assign) BOOL ignoreAboveTextRelatedPropertys;

/**
 user long press during time will call delegate. default 2.0
 */
@property (nonatomic, assign) CGFloat longPressDuring;

- (instancetype)initWithFrame:(CGRect)frame;
- (instancetype)initWithFrame:(CGRect)frame textRender:(TYTextRender *)textRender;

/**
 insert a character into the displayed text.
 */
- (void)insertText:(NSString *)text;
/**
 insert attributed string into the displayed text.
 */
- (void)insertAttributedText:(NSAttributedString *)attributedText;

@end

@class TYGrowingTextView;
@protocol GrowingTextViewDelegate <NSObject>

// text height did change
- (void)growingTextView:(TYGrowingTextView *)growingTextView didChangeTextHeight:(CGFloat)textHeight;

// text did change
- (void)growingTextViewDidChangeText:(TYGrowingTextView *)growingTextView;

@end

// grow height text view
@interface TYGrowingTextView : TYTextView

@property (nonatomic, weak) id<GrowingTextViewDelegate> growingTextDelegate;

// placeHolder
@property (nonatomic, weak, readonly) UILabel *placeHolderLabel;
@property (nonatomic, assign) UIEdgeInsets placeHolderEdge;

// max num line of text default 0
@property (nonatomic, assign) NSUInteger maxNumOfLines;
// max text length default 0
@property (nonatomic, assign) NSInteger maxTextLength;

// default NO
@property (nonatomic, assign) BOOL fisrtCharacterIgnoreBreak;

@end
