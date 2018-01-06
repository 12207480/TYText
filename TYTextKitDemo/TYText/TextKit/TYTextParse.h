//
//  TYTextParse.h
//  TYTextKitDemo
//
//  Created by tany on 2017/9/26.
//  Copyright © 2017年 tany. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol TYTextParse <NSObject>
@required
/**
 process parse edited text
 @param editedRange The range of text edited changes,{NSNotFound, 0} when there is no changes
 */
- (void)parseAttributedText:(nullable NSMutableAttributedString *)attributedText editedRange:(NSRange)editedRange;

@end

@interface TYTextParse : NSObject<TYTextParse>

@end
