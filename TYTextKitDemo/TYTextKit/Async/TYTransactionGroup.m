//
//  TYTransactionGroup.m
//  TYTextKitDemo
//
//  Created by tany on 2017/9/12.
//  Copyright © 2017年 tany. All rights reserved.
//

#import "TYTransactionGroup.h"
#import <pthread.h>

#define TYAssertMainThread() NSAssert(0 != pthread_main_np(), @"This method must be called on the main thread!")

@interface TYTransactionGroup ()

@property (nonatomic, strong) NSMutableOrderedSet *orderSet;

@end

@implementation TYTransactionGroup

+ (TYTransactionGroup *)mainGroup {
    static TYTransactionGroup *group;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        group = [[self alloc] init];
    });
    return group;
}

- (instancetype)init {
    if (self = [super init]) {
        _orderSet = [NSMutableOrderedSet orderedSet];
         [self addRunloopObserver];
    }
    return self;
}

#pragma mark - public

+ (void)addTransaction:(id<TYTransaction>)transaction {
    [[self mainGroup] addTransaction:transaction];
}

+ (void)cancel {
    [[self mainGroup] cancel];
}

+ (void)commit {
    [[self mainGroup] commit];
}

#pragma mark - private

static void TYRunloopObserverCallBack(CFRunLoopObserverRef observer, CFRunLoopActivity activity, void *info) {
    TYTransactionGroup *group = (__bridge TYTransactionGroup *)info;
    [group commit];
}

- (void)addRunloopObserver {
    TYAssertMainThread();
    CFRunLoopRef runloop = CFRunLoopGetCurrent();
    CFRunLoopObserverContext context = {
        0,           // version
        (__bridge void *)self,  // info
        &CFRetain,   // retain
        &CFRelease,  // release
        NULL         // copyDescription
    };
    CFRunLoopObserverRef observer = CFRunLoopObserverCreate(CFAllocatorGetDefault(), kCFRunLoopBeforeWaiting | kCFRunLoopExit,true,0xFFFFFF,&TYRunloopObserverCallBack, &context);
    CFRunLoopAddObserver(runloop, observer, kCFRunLoopCommonModes);
    CFRelease(observer);
}

- (void)addTransaction:(id<TYTransaction>)transaction {
    TYAssertMainThread();
    [_orderSet addObject:transaction];
}

- (void)cancel {
    TYAssertMainThread();
    [_orderSet removeAllObjects];
}

- (void)commit {
    TYAssertMainThread();
    if (_orderSet.count == 0) {
        return;
    }
    NSMutableOrderedSet *orderSet = _orderSet;
    _orderSet = [NSMutableOrderedSet orderedSet];
    for (id<TYTransaction> transaction in orderSet) {
        [transaction commit];
    }
}

- (void)dealloc {
    _orderSet = nil;
}

@end
