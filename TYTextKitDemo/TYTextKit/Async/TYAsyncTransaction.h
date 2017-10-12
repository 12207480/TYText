//
//  TYAsyncTransaction.h
//  TYTextKitDemo
//
//  Created by tany on 2017/9/12.
//  Copyright © 2017年 tany. All rights reserved.
//

#import "TYTransaction.h"

typedef NS_ENUM(NSUInteger, TYAsyncTransactionState) {
    TYAsyncTransactionStateWaiting,
    TYAsyncTransactionStateCommitted,   // commit doing
    TYAsyncTransactionStateCompleted,
    TYAsyncTransactionStateCanceled,
};

@protocol TYAsyncTransaction <TYTransaction>

@property (nonatomic, assign, readonly) TYAsyncTransactionState state;

/**
 async transaction
 */
+ (id<TYAsyncTransaction> *)transaction;

/**
 add transaction operation block
 */
- (void)addOperationBlock:(void (^)(void))operationBlock;

/**
 completion block on main thread
 @discussion when all operationBlock completed,will executed the completion block
 */
- (void)setCompletionBlock:(void (^)(void))completionBlock;

@end

/**
 a async transaction with operation and completion block
 */
@interface TYGroupAsyncTransaction : NSObject<TYAsyncTransaction>

/**
 object hash identifier
 @discussion if identifierHash is equal, will return equal hash in set(collection).default nil
 */
@property (nonatomic, strong) NSString *identifierHash;

/**
 transaction operation group
 */
@property (nonatomic ,strong, readonly) dispatch_group_t group;
/**
 transaction operation queue,if is nil ,will call on main queue.
 */
@property (nonatomic ,strong, readonly) dispatch_queue_t queue;

// async queue
+ (TYGroupAsyncTransaction *)transaction;

+ (TYGroupAsyncTransaction *)transactionWithQueue:(dispatch_queue_t)queue;

/**
 add operation to queue,if queue nil is self.queue.
 */
- (void)addOperationBlock:(void (^)(void))operationBlock toQueue:(dispatch_queue_t)queue;

@end

typedef NS_ENUM(NSUInteger, TYAsyncQueueType) {
    TYAsyncQueueMain,
    TYAsyncQueuePrivate,
};

@interface TYQueueAsyncTransaction : NSObject<TYAsyncTransaction>

/**
 object hash identifier
 @discussion if identifierHash is equal, will return equal hash in set(collection).default nil
 */
@property (nonatomic, strong) NSString *identifierHash;

@property (nonatomic, strong, readonly) NSOperationQueue *queue;

@property (nonatomic, assign, readonly) TYAsyncQueueType queueType;

// async queue
+ (TYQueueAsyncTransaction *)transaction;

+ (TYQueueAsyncTransaction *)transactionWithQueueType:(TYAsyncQueueType)queueType;

/**
 add transaction operation
 */
- (void)addOperation:(NSOperation *)operation;

@end
