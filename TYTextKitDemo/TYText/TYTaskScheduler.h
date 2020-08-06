//
//  TYTaskScheduler.h
//  TYTextKitDemo
//
//  Created by jufan wang on 2020/8/6.
//  Copyright © 2020 tany. All rights reserved.
//

#import <Foundation/Foundation.h>

@class TYAsyncLayerDisplayTask;

@interface TYTaskScheduler : NSObject

+ (instancetype)sharedInstance;

@property (nonatomic, assign) NSInteger maxScheduleCount;

- (void)dispatchTask:(TYAsyncLayerDisplayTask *)task
               block:(void (^)(TYAsyncLayerDisplayTask *task))block;

@end
