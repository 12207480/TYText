//
//  AttributedDemoViewController.m
//  TYTextKitDemo
//
//  Created by tany on 2017/9/25.
//  Copyright © 2017年 tany. All rights reserved.
//

#import "AttributedDemoViewController.h"
#import "TYLabel.h"

@interface AttributedDemoViewController ()

@property (nonatomic, strong) TYLabel *label;
@property (nonatomic, assign) BOOL layouted;

@end

@implementation AttributedDemoViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc]initWithTitle:@"change" style:UIBarButtonItemStyleDone target:self action:@selector(changeAction)];
    [self addLabel];
}

- (void)viewWillLayoutSubviews {
    [super viewWillLayoutSubviews];
    if (_layouted) {
        return;
    }
    CGFloat originY = CGRectGetMaxY(self.navigationController.navigationBar.frame);
    _label.frame = CGRectMake(0, originY, CGRectGetWidth(self.view.frame), 200);
    if (originY > 0) {
        _layouted = YES;
    }
}

- (void)addLabel {
    TYLabel *label = [[TYLabel alloc]init];
    label.backgroundColor = [UIColor lightGrayColor];
    label.attributedText = [self addAttribuetedString];
    [self.view addSubview:label];
    _label = label;
}

- (NSAttributedString *)addAttribuetedString {
    NSString *str = @"哈哈不错啊啊啊Async Display Test Display ✺◟(∗❛ัᴗ❛ั∗)◞✺ 😀😖😐🚋🎊😡🚖🚌💖💗💛💙🏨✺◟(∗❛ัᴗ❛ั∗)◞✺ 😀😖😐😣😡🚖🚌🚋🎊😡🚖🚌💖💗💛💙🏨";
    
    NSMutableAttributedString *text = [[NSMutableAttributedString alloc] initWithString:str];
    text.ty_lineSpacing = 1;
    //text.ty_strokeWidth = -2;
    //text.ty_strokeColor = [UIColor redColor];
    //text.ty_lineHeightMultiple = 1.5;
    //        text.ty_maximumLineHeight = 12;
    //        text.ty_minimumLineHeight = 12;
    
    TYTextHighlight *textHighlight = [[TYTextHighlight alloc]init];
    textHighlight.color = [UIColor whiteColor];
    textHighlight.backgroundColor = [UIColor redColor];
    [text addTextHighlightAttribute:textHighlight range:NSMakeRange(0, 9)];
    
    TYTextAttachment *attachment = [[TYTextAttachment alloc]init];
    attachment.image = [UIImage imageNamed:@"avatar"];
    attachment.size = CGSizeMake(60, 60);
    //        if (i%2) {
    //            [text appendAttributedString:[NSAttributedString attributedStringWithAttachment:attachment]];
    //        }
    attachment = [[TYTextAttachment alloc]init];
    attachment.image = [UIImage imageNamed:@"avatar"];
    attachment.size = CGSizeMake(20, 20);
    attachment.verticalAlignment = TYAttachmentAlignmentCenter;
    [text appendAttributedString:[NSAttributedString attributedStringWithAttachment:attachment]];
    TYTextAttachment *attachmentView = [[TYTextAttachment alloc]init];
    UIButton *button = [UIButton buttonWithType:UIButtonTypeSystem];
    [button setTitle:@"button" forState:UIControlStateNormal];
    attachmentView.view = button;
    attachmentView.view.backgroundColor = [UIColor redColor];
    attachmentView.size = CGSizeMake(60, 10);
    attachmentView.verticalAlignment = TYAttachmentAlignmentCenter;
    [text appendAttributedString:[NSAttributedString attributedStringWithAttachment:attachmentView]];
    text.ty_font = [UIFont systemFontOfSize:15];
    text.ty_characterSpacing = 1;
    return text;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)changeAction {
    _label.frame = CGRectMake(_label.frame.origin.x, _label.frame.origin.y+ 10, _label.frame.size.width - 20, _label.frame.size.height);
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
