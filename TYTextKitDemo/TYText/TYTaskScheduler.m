//
//  TYTaskScheduler.m
//  TYTextKitDemo
//
//  Created by jufan wang on 2020/8/6.
//  Copyright © 2020 tany. All rights reserved.
//

#import "TYTaskScheduler.h"
#import "TYAsyncLayer.h"

@interface TYTaskScheduleParas : NSObject
@property (nonatomic, strong) TYAsyncLayerDisplayTask *task;
@property (nullable, nonatomic, copy) void (^block)(TYAsyncLayerDisplayTask *task);
@end
@implementation TYTaskScheduleParas
@end

@interface TYTaskScheduler() {
    CFRunLoopObserverRef _pendingListObserver;
}
@property (nonatomic, strong) NSMutableArray<TYTaskScheduleParas *>* tasksArray;
@end

@implementation TYTaskScheduler

+ (instancetype)sharedInstance {
    static dispatch_once_t onceToken;
    static TYTaskScheduler *_taskScheduler = nil;
    dispatch_once(&onceToken, ^{
        _taskScheduler = [[TYTaskScheduler alloc] init];
    });
    return _taskScheduler;
}

- (instancetype)init {
    if (self = [super init]) {
        _tasksArray = [NSMutableArray array];
        _maxScheduleCount = 22;
        [self schedulePendingList];
    }
    return self;
}

- (void)dispatchTask:(TYAsyncLayerDisplayTask *)task
               block:(void (^)(TYAsyncLayerDisplayTask *task))block {
    TYTaskScheduleParas *paras = nil;
    for (TYTaskScheduleParas *pa in self.tasksArray) {
        if (pa.task.layer == task.layer) {
            paras = pa;
            [self.tasksArray removeObject:paras];
            break;
        }
    }
    if (!paras) {
        paras = [[TYTaskScheduleParas alloc] init];
    }
    paras.block = block;
    paras.task = task;
    [self.tasksArray addObject:paras];
    if (self.tasksArray.count > self.maxScheduleCount) {
        [self.tasksArray removeObjectsInRange:NSMakeRange(0, self.tasksArray.count - self.maxScheduleCount)];
    }
}

#pragma mark -- schedule

- (void)clearPendingList {
    if (_pendingListObserver) {
        CFRunLoopRemoveObserver(CFRunLoopGetMain(), _pendingListObserver, kCFRunLoopCommonModes);
        CFRelease(_pendingListObserver);
        _pendingListObserver = NULL;
    }
}

- (void)schedulePendingList {
    // see WebKit for magic numbers, eg http://trac.webkit.org/changeset/166540
    static const CFIndex TYTransactionCommitRunLoopOrder = 2000000;
    static const CFIndex TYTaskSchedulerApplyRunLoopOrder = TYTransactionCommitRunLoopOrder - 1;    
    __weak TYTaskScheduler *weakSelf = self;
    if (!_pendingListObserver) {
        _pendingListObserver = CFRunLoopObserverCreateWithHandler(kCFAllocatorDefault, kCFRunLoopBeforeWaiting | kCFRunLoopExit, YES, TYTaskSchedulerApplyRunLoopOrder, ^(CFRunLoopObserverRef observer, CFRunLoopActivity activity) {
            TYTaskScheduleParas *paras = [weakSelf.tasksArray lastObject];
            if (!paras) return ;
            [weakSelf.tasksArray removeObject:paras];
            if (paras.block) {
                paras.block(paras.task);
            }
        });
        CFRunLoopAddObserver(CFRunLoopGetMain(), _pendingListObserver,  kCFRunLoopCommonModes);
    }
}

- (void)dealloc {
    [self clearPendingList];
}

@end


