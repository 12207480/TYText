//
//  TYTransaction.m
//  TYTextKitDemo
//
//  Created by tany on 2017/9/11.
//  Copyright © 2017年 tany. All rights reserved.
//

#import "TYTransaction.h"

@interface TYTransaction ()

@property (nonatomic, strong) id target;

@property (nonatomic, assign) SEL selector;

@property (nonatomic, strong) id object;

@property (nonatomic, copy) void (^operationBlock)(void);

@property (nonatomic, assign) BOOL isCanceled;

@end

@implementation TYTransaction

+ (TYTransaction *)transactionWithTarget:(id)target selector:(SEL)selector {
    TYTransaction *transaction = [[TYTransaction alloc]init];
    transaction.target = target;
    transaction.selector = selector;
    return transaction;
}

+ (TYTransaction *)transactionWithBlock:(void (^)(void))operationBlock {
    TYTransaction *transaction = [[TYTransaction alloc]init];
    transaction.operationBlock = operationBlock;
    return transaction;
}

+ (TYTransaction *)transactionWithTarget:(id)target selector:(SEL)selector object:(id)object {
    TYTransaction *transaction = [[TYTransaction alloc]init];
    transaction.target = target;
    transaction.selector = selector;
    transaction.object = object;
    return transaction;
}

- (void)commit {
    if (_isCanceled) {
        return;
    }
    if (_target && _selector && [_target respondsToSelector:_selector]) {
    #pragma clang diagnostic push
    #pragma clang diagnostic ignored "-Warc-performSelector-leaks"
        if (!_object) {
            [_target performSelector:_selector];
        }else {
            [_target performSelector:_selector withObject:_object];
        }
        #pragma clang diagnostic pop
        return;
    }
    
    if (_operationBlock) {
        _operationBlock();
    }
}

- (void)cancel {
    _isCanceled = YES;
}

- (NSUInteger)hash {
    if (_identifierHash) {
        return [_identifierHash hash];
    }
    NSUInteger tagert = [_target hash];
    NSUInteger selector = (NSUInteger)((void *)_selector);
    return tagert ^ selector;
}

- (BOOL)isEqual:(id)object {
    if (self == object) {
        return YES;
    }
    if (![object isMemberOfClass:[self class]]) {
        return NO;
    }
    if (_target && _selector) {
        TYTransaction *other = object;
        return other.selector == _selector && other.target == _target;
    }
    return [super isEqual:object];
}

@end
