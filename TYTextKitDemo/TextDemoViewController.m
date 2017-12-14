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

@property (nonatomic, strong) TYLabel *label1;
@property (nonatomic, strong) TYLabel *label2;

@end

@implementation TextDemoViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    [self addLabel1];
    [self addLabel2];
}

- (void)viewWillLayoutSubviews {
    [super viewWillLayoutSubviews];
    CGFloat originY = CGRectGetMaxY(self.navigationController.navigationBar.frame);
    _label1.frame = CGRectMake(0, originY, CGRectGetWidth(self.view.frame), 150);
    _label2.frame = CGRectMake(0, CGRectGetMaxY(_label1.frame)+100, CGRectGetWidth(self.view.frame), 200);
}

- (void)addLabel1 {
    TYLabel *label = [[TYLabel alloc]init];
    label.backgroundColor = [UIColor lightGrayColor];
    label.text = @"总有一天你将破蛹而出，成长得比人们期待的还要美丽。但这个过程会很痛，会很辛苦，有时候还会觉得灰心。面对着汹涌而来的现实，觉得自己渺小无力。\n但这，也是生命的一部分。做好现在你能做的，然后，一切都会好的。我们都将孤独地长大，不要害怕。";
    label.font = [UIFont systemFontOfSize:17];
    label.numberOfLines = 3;
    label.verticalAlignment = TYTextVerticalAlignmentTop;
    [self.view addSubview:label];
    _label1 = label;
}

- (void)addLabel2 {
    TYLabel *label = [[TYLabel alloc]init];
    label.backgroundColor = [UIColor lightGrayColor];
    label.text = @"总有一天你将破蛹而出，成长得比人们期待的还要美丽。但这个过程会很痛，会很辛苦，有时候还会觉得灰心。面对着汹涌而来的现实，觉得自己渺小无力。\n但这，也是生命的一部分。做好现在你能做的，然后，一切都会好的。我们都将孤独地长大，不要害怕。";
    label.font = [UIFont systemFontOfSize:17];
    label.verticalAlignment = TYTextVerticalAlignmentCenter;
    [self.view addSubview:label];
    _label2 = label;
}

@end
