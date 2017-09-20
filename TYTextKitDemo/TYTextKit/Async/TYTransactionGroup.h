//
//  TYTransactionGroup.h
//  TYTextKitDemo
//
//  Created by tany on 2017/9/12.
//  Copyright © 2017年 tany. All rights reserved.
//

#import "TYTransaction.h"
NS_ASSUME_NONNULL_BEGIN

/**
 1.a group of transaction, for which the current transactions are committed together at the end of the next runloop tick.
 2.the transactions always executed in the order they were added to the transaction.because used NSMutableOrderedSet.
 */
@interface TYTransactionGroup : NSObject

+ (void)addTransaction:(id<TYTransaction>)transaction;

+ (void)cancelAllTransactions;

/**
 when next runloop tick ,will call this commit
 */
+ (void)commit;

@end

NS_ASSUME_NONNULL_END
