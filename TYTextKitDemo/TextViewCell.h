//
//  TextViewCell.h
//  TYTextKitDemo
//
//  Created by tany on 2017/9/25.
//  Copyright © 2017年 tany. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "TYLabel.h"

@interface TextViewCell : UITableViewCell

@property (nonatomic, weak, readonly) TYLabel *label;
@property (nonatomic, weak, readonly) UILabel *uilabel;

@end
