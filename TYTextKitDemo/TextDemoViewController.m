//
//  TextDemoViewController.m
//  TYTextKitDemo
//
//  Created by tany on 2017/9/25.
//  Copyright © 2017年 tany. All rights reserved.
//

#import "TextDemoViewController.h"
#import "TYLabel.h"

@interface TextDemoViewController ()

@property (nonatomic, strong) TYLabel *label;

@end

@implementation TextDemoViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    [self addLabel];
}

- (void)viewWillLayoutSubviews {
    [super viewWillLayoutSubviews];
    CGFloat originY = CGRectGetMaxY(self.navigationController.navigationBar.frame);
    _label.frame = CGRectMake(0, originY, CGRectGetWidth(self.view.frame), 200);
}

- (void)addLabel {
    TYLabel *label = [[TYLabel alloc]init];
    label.backgroundColor = [UIColor lightGrayColor];
    label.text = @"这种遮罩是动态的，只要输入😄😄是纯数字那么NSLayoutManager的对象就不会对其进行绘制，而用黑色的遮罩挡住。 ";
    [self.view addSubview:label];
    _label = label;
}

@end
