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

@interface TYAsyncGroupTransaction : NSObject<TYTransaction>

/**
 if identifierHash is equal, will return equal hash in set(collection).default nil
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

@property (nonatomic, assign, readonly) TYAsyncTransactionState state;

// default main queue
+ (TYAsyncGroupTransaction *)transaction;

+ (TYAsyncGroupTransaction *)transactionWithQueue:(dispatch_queue_t)queue;

/**
 add transaction operation block
 */
- (void)addOperationBlock:(void (^)(void))operationBlock;
/**
 add operation to queue,if queue nil is self.queue.
 */
- (void)addOperationBlock:(void (^)(void))operationBlock toQueue:(dispatch_queue_t)queue;

/**
 when all operationBlock completed,the completion block that will be executed on main thread
 */
- (void)setCompletionBlock:(void (^)(void))completionBlock;

@end

typedef NS_ENUM(NSUInteger, TYAsyncQueueType) {
    TYAsyncQueueMain,
    TYAsyncQueuePrivate,
};

@interface TYAsyncQueueTransaction : NSObject<TYTransaction>

/**
 if identifierHash is equal, will return equal hash in set(collection).default nil
 */
@property (nonatomic, strong) NSString *identifierHash;

@property (nonatomic, strong, readonly) NSOperationQueue *queue;

@property (nonatomic, assign, readonly) TYAsyncQueueType queueType;

@property (nonatomic, assign, readonly) TYAsyncTransactionState state;

// default main queue
+ (TYAsyncQueueTransaction *)transaction;

+ (TYAsyncGroupTransaction *)transactionWithQueueType:(TYAsyncQueueType)queueType;

/**
 add transaction operation
 */
- (void)addOperation:(NSOperation *)operation;

/**
 add transaction operation block
 */
- (void)addOperationBlock:(void (^)(void))operationBlock;

/**
 when all operationBlock completed,the completion block that will be executed on main thread
 */
- (void)setCompletionBlock:(void (^)(void))completionBlock;

@end
