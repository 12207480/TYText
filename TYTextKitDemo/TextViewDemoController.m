//
//  TextViewDemoController.m
//  TYTextKitDemo
//
//  Created by tany on 2017/10/19.
//  Copyright © 2017年 tany. All rights reserved.
//

#import "TextViewDemoController.h"
#import "TYTextView.h"

@interface TextViewDemoController ()

@property (nonatomic, strong) TYTextView *textView;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *topConstraint;

@end

@implementation TextViewDemoController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc]initWithBarButtonSystemItem:UIBarButtonSystemItemDone target:self action:@selector(barItemDoneAction)];
    
    [self addTextView];
}

- (void)viewWillLayoutSubviews {
    [super viewWillLayoutSubviews];
    CGFloat originY = CGRectGetMaxY(self.navigationController.navigationBar.frame);
    _textView.frame = CGRectMake(0, originY, CGRectGetWidth(self.view.frame), 250);
    self.topConstraint.constant = CGRectGetMaxY(_textView.frame)+ 10;
}


- (void)addTextView {
    TYTextView *textView = [[TYTextView alloc]init];
    textView.text = @"这种遮罩是动态的，只要输入😄😄是纯数字那么NSLayoutManager的对象就不会对其进行绘制，而用黑色的遮罩挡住。 ";
    textView.contentInset = UIEdgeInsetsMake(10, 10, 10, 10);
    textView.backgroundColor = [UIColor lightGrayColor];
    [self.view addSubview:textView];
    _textView = textView;
}
- (IBAction)buttonAction:(UIButton *)sender {
    if (![_textView isFocused]) {
        [_textView becomeFirstResponder];
    }
    NSAttributedString *attString = nil;
    if (sender.tag == 0) {
        TYTextAttachment *attachMent = [[TYTextAttachment alloc]init];
        attachMent.size = CGSizeMake(60, 60);
        attachMent.image = [UIImage imageNamed:@"avatar"];
        attachMent.verticalAlignment = TYAttachmentAlignmentCenter;
        attString = [NSAttributedString attributedStringWithAttachment:attachMent];
    }else if (sender.tag == 1) {
        UISwitch *switchView = [[UISwitch alloc]init];
        TYTextAttachment *attachMent = [[TYTextAttachment alloc]init];
        attachMent.view = switchView;
        attachMent.size = switchView.bounds.size;
        attachMent.verticalAlignment = TYAttachmentAlignmentCenter;
        attString = [NSAttributedString attributedStringWithAttachment:attachMent];
    }
    
    if (_textView.selectedRange.length > 0) {
        [_textView.textStorage replaceCharactersInRange:_textView.selectedRange withAttributedString:attString];
    }else {
        [_textView.textStorage insertAttributedString:attString atIndex:_textView.selectedRange.location];
    }
    _textView.selectedRange = NSMakeRange(_textView.selectedRange.location+attString.length, 0);
}

- (void)barItemDoneAction {
    [_textView resignFirstResponder];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
