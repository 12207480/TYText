//
//  TYAsyncTransaction.m
//  TYTextKitDemo
//
//  Created by tany on 2017/9/12.
//  Copyright © 2017年 tany. All rights reserved.
//

#import "TYAsyncTransaction.h"
#import <pthread.h>

#define TYAssertMainThread() NSAssert(0 != pthread_main_np(), @"This method must be called on the main thread!")

typedef NS_ENUM(NSUInteger, TYAsyncGCDTransactionOperationState) {
    TYAsyncGCDTransactionOperationStateWaiting,
    TYAsyncGCDTransactionOperationStateCommitted,   // commit doing
    TYAsyncGCDTransactionOperationStateCompleted,
    TYAsyncGCDTransactionOperationStateCanceled,
};

@interface TYAsyncGCDTransactionOperation : NSObject

@property (atomic ,assign) TYAsyncGCDTransactionOperationState state;

@property (nonatomic ,strong) dispatch_queue_t queue;

@property (nonatomic ,copy) void (^operationBlock)(void);

@end

@interface TYAsyncGroupTransaction ()

@property (nonatomic ,strong) dispatch_group_t group;

@property (nonatomic ,strong) dispatch_queue_t queue;

@property (nonatomic ,strong) NSMutableArray *operations;

@property (nonatomic, assign) TYAsyncTransactionState state;

@property (nonatomic ,copy) void (^completionBlock)(void);

@end

@implementation TYAsyncGroupTransaction

- (instancetype)init {
    if (self = [super init]) {
        _operations = [NSMutableArray array];
        _group = dispatch_group_create();
    }
    return self;
}

+ (TYAsyncGroupTransaction *)transaction {
    return [[self alloc]init];
}

+ (TYAsyncGroupTransaction *)transactionWithQueue:(dispatch_queue_t)queue {
    TYAsyncGroupTransaction *transaction = [[self alloc]init];
    transaction.queue = queue;
    return transaction;
}

- (void)addOperationBlock:(void (^)(void))operationBlock {
    [self addOperationBlock:operationBlock toQueue:nil];
}

- (void)addOperationBlock:(void (^)(void))operationBlock toQueue:(dispatch_queue_t)queue {
    TYAssertMainThread();
    TYAsyncGCDTransactionOperation *operation = [[TYAsyncGCDTransactionOperation alloc]init];
    operation.operationBlock = operationBlock;
    operation.queue = queue ? queue : _queue;
    [_operations addObject:operation];
}

- (void)commit {
    TYAssertMainThread();
    if (_state == TYAsyncTransactionStateCanceled) {
        _operations = [NSMutableArray array];
        return;
    }
    _state = TYAsyncTransactionStateCommitted;
    dispatch_queue_t mainQueue = dispatch_get_main_queue();
    NSArray *operations = _operations;
    _operations = [NSMutableArray array];
    for (TYAsyncGCDTransactionOperation *operation in operations) {
        operation.state = TYAsyncGCDTransactionOperationStateCommitted;
        dispatch_queue_t queue = operation.queue ? operation.queue : _queue;
        dispatch_group_async(_group, queue ? queue : mainQueue, ^{
            if (operation.state == TYAsyncTransactionStateCanceled) {
                return ;
            }
            operation.operationBlock();
            operation.state = TYAsyncGCDTransactionOperationStateCompleted;
        });
    }
    dispatch_group_notify(_group, mainQueue, ^{
        if (_state == TYAsyncTransactionStateCanceled) {
            return;
        }
        if (_completionBlock) {
            _completionBlock();
        }
        _state = TYAsyncTransactionStateCompleted;
    });
}

- (void)cancel {
    TYAssertMainThread();
    if (_state == TYAsyncGCDTransactionOperationStateCompleted) {
        return;
    }
    _state = TYAsyncTransactionStateCanceled;
    for (TYAsyncGCDTransactionOperation *operation in _operations) {
        if (operation.state != TYAsyncGCDTransactionOperationStateCompleted) {
            operation.state = TYAsyncGCDTransactionOperationStateCanceled;
        }
    }
}

- (NSUInteger)hash {
    if (!_identifierHash) {
        return [super hash];
    }
    return [_identifierHash hash];
}

- (void)dealloc {
    _operations = nil;
}

@end

@implementation TYAsyncGCDTransactionOperation

@end


@interface TYAsyncQueueTransaction ()

@property (nonatomic, strong) NSOperationQueue *queue;
@property (nonatomic, assign) TYAsyncQueueType queueType;

@property (nonatomic, assign) TYAsyncTransactionState state;

@property (nonatomic ,strong) NSMutableArray *operations;

@property (nonatomic ,copy) void (^completionBlock)(void);
@end

@implementation TYAsyncQueueTransaction

- (instancetype)init {
    if (self = [self initWithQueueType:TYAsyncQueueMain]) {
    }
    return self;
}

- (instancetype)initWithQueueType:(TYAsyncQueueType)queueType {
    if (self = [super init]) {
        _queueType = queueType;
        _operations = [NSMutableArray array];
        if (queueType == TYAsyncQueueMain) {
            _queue = [NSOperationQueue mainQueue];
        }else {
            _queue = [[NSOperationQueue alloc]init];
        }
    }
    return self;
}

+ (TYAsyncQueueTransaction *)transaction {
    return [[self alloc]initWithQueueType:TYAsyncQueueMain];
}

+ (TYAsyncGroupTransaction *)transactionWithQueueType:(TYAsyncQueueType)queueType {
   return [[self alloc]initWithQueueType:queueType];
}

- (void)addOperation:(NSOperation *)operation {
    TYAssertMainThread();
    [_operations addObject:operation];
}

- (void)addOperationBlock:(void (^)(void))operationBlock {
    [self addOperation:[NSBlockOperation blockOperationWithBlock:operationBlock]];
}

- (void)commit {
    TYAssertMainThread();
    if (_state == TYAsyncTransactionStateCanceled) {
        _operations = [NSMutableArray array];
        return;
    }
    _state = TYAsyncTransactionStateCommitted;
    NSMutableArray *operations = _operations;
    _operations = [NSMutableArray array];
    NSOperation *completionOperation = [NSBlockOperation blockOperationWithBlock:^{
        dispatch_async(dispatch_get_main_queue(), ^{
            [self complete];
        });
    }];
    for (NSOperation *operation in operations) {
        [completionOperation addDependency:operation];
    }
    [operations addObject:completionOperation];
    [_queue addOperations:operations waitUntilFinished:NO];
}

- (void)complete {
    TYAssertMainThread();
    if (_state == TYAsyncTransactionStateCanceled) {
        return;
    }
    if (_completionBlock) {
        _completionBlock();
    }
    _state = TYAsyncTransactionStateCompleted;
}

- (void)cancel {
    TYAssertMainThread();
    if (_state == TYAsyncGCDTransactionOperationStateCompleted) {
        return;
    }
    _state = TYAsyncTransactionStateCanceled;
    [_queue cancelAllOperations];
}

- (NSUInteger)hash {
    if (!_identifierHash) {
        return [super hash];
    }
    return [_identifierHash hash];
}

- (void)dealloc {
    _operations = nil;
}

@end
