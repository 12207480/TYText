//
//  TYTextStorage.m
//  TYTextKitDemo
//
//  Created by tany on 2017/9/26.
//  Copyright © 2017年 tany. All rights reserved.
//

#import "TYTextStorage.h"

@interface TYTextStorage ()

@property (nonatomic, strong) NSMutableAttributedString *imp;

@end

@implementation TYTextStorage

- (instancetype)init {
    if (self = [super init]) {
        _imp = [[NSMutableAttributedString alloc]init];
    }
    return self;
}

- (instancetype)initWithMutableAttributedString:(NSMutableAttributedString *)attrStr {
    if (self = [super init]) {
        _imp = attrStr;
        [self edited:NSTextStorageEditedAttributes|NSTextStorageEditedCharacters range:NSMakeRange(0,0) changeInLength:_imp.length];
    }
    return self;
}

- (instancetype)initWithAttributedString:(NSAttributedString *)attrStr {
    if (self = [super init]) {
        _imp = [attrStr mutableCopy];
        [self edited:NSTextStorageEditedAttributes|NSTextStorageEditedCharacters range:NSMakeRange(0,0) changeInLength:_imp.length];
    }
    return self;
}

- (instancetype)initWithString:(NSString *)str {
    if (self = [super init]) {
        _imp = [[NSMutableAttributedString alloc]initWithString:str];
        [self edited:NSTextStorageEditedAttributes|NSTextStorageEditedCharacters range:NSMakeRange(0,0) changeInLength:_imp.length];
    }
    return self;
}

- (instancetype)initWithString:(NSString *)str attributes:(NSDictionary<NSAttributedStringKey,id> *)attrs {
    if (self = [super init]) {
        _imp = [[NSMutableAttributedString alloc]initWithString:str attributes:attrs];
        [self edited:NSTextStorageEditedAttributes|NSTextStorageEditedCharacters range:NSMakeRange(0,0) changeInLength:_imp.length];
    }
    return self;
}

#pragma mark - Override

- (NSString *)string
{
    return _imp.string;
}

- (NSDictionary *)attributesAtIndex:(NSUInteger)location effectiveRange:(NSRangePointer)range
{
    return [_imp attributesAtIndex:location effectiveRange:range];
}

- (void)replaceCharactersInRange:(NSRange)range withString:(NSString *)str
{
    [_imp replaceCharactersInRange:range withString:str];
    [self edited:NSTextStorageEditedCharacters range:range
  changeInLength:(NSInteger)str.length - (NSInteger)range.length];
}

- (void)setAttributes:(NSDictionary *)attrs range:(NSRange)range
{
    [_imp setAttributes:attrs range:range];
    [self edited:NSTextStorageEditedAttributes range:range changeInLength:0];
}

- (void)addAttributes:(NSDictionary<NSAttributedStringKey,id> *)attrs range:(NSRange)range {
    [_imp addAttributes:attrs range:range];
    [self edited:NSTextStorageEditedAttributes range:range changeInLength:0];
}

- (void)processEditing {
    [super processEditing];
    if (_textParse) {
        [_textParse parseAttributedText:_imp editedRange:self.editedRange];
    }
}

#pragma mark - Copy

- (id)copyWithZone:(NSZone *)zone {
    TYTextStorage *copy = [[[self class]allocWithZone:zone]init];
    copy.imp = [_imp mutableCopy];
    copy.textParse = _textParse;
    return copy;
}

- (void)dealloc {
    _textParse = nil;
}

@end

@implementation NSTextStorage (TYTextKit)

- (NSTextStorage *)ty_deepCopy {
    if ([self isKindOfClass:[TYTextStorage class]]) {
        return [self copy];
    }else {
        NSMutableAttributedString *string = [self mutableCopy];
        return [[NSTextStorage alloc]initWithAttributedString:string];
    }
}

@end
