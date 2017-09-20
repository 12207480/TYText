//
//  TYTransaction.h
//  TYTextKitDemo
//
//  Created by tany on 2017/9/11.
//  Copyright © 2017年 tany. All rights reserved.
//

#import <Foundation/Foundation.h>
NS_ASSUME_NONNULL_BEGIN

@protocol TYTransaction <NSObject>

/**
 when next runloop tick ,transaction group will call this commit
 */
- (void)commit;

- (void)cancel;

@end

/**
 a transaction with a specified target and selector,or block
 */
@interface TYTransaction : NSObject<TYTransaction>


/**
 if identifierHash is equal, will return equal hash in set(collection).default nil
 */
@property (nonatomic, strong) NSString *identifierHash;

+ (TYTransaction *)transactionWithTarget:(id)target selector:(SEL)selector;

+ (TYTransaction *)transactionWithTarget:(id)target selector:(SEL)selector object:(id)object;

+ (TYTransaction *)transactionWithBlock:(void (^)(void))operationBlock;

@end

NS_ASSUME_NONNULL_END
