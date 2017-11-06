//
//  TextAutolayoutController.m
//  TYTextKitDemo
//
//  Created by tany on 2017/11/6.
//  Copyright © 2017年 tany. All rights reserved.
//

#import "TextAutolayoutController.h"
#import "TYLabel.h"

@interface TextAutolayoutController ()
@property (weak, nonatomic) IBOutlet TYLabel *label;
@property (weak, nonatomic) IBOutlet TYLabel *attribuedLabel;

@end

@implementation TextAutolayoutController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    [self addLabel];
    [self addAttribuedLabel];
}

- (void)addLabel {
    _label.backgroundColor = [UIColor lightGrayColor];
    _label.text = @"这种遮罩是动态的，只要输入😄😄是纯数字那么NSLayoutManager的对象就不会对其进行绘制，而用黑色的遮罩挡住。 ";
    _label.font = [UIFont systemFontOfSize:17];
    //_label.numberOfLines = 2;
    [self.view addSubview:_label];
}

- (void)addAttribuedLabel {
    _attribuedLabel.backgroundColor = [UIColor lightGrayColor];
    _attribuedLabel.attributedText = [self addAttribuetedString];
    //_attribuedLabel.numberOfLines = 2;
    _attribuedLabel.lineBreakMode = NSLineBreakByTruncatingTail;
    [self.view addSubview:_attribuedLabel];
}

- (NSAttributedString *)addAttribuetedString {
    NSString *str = @"哈哈不错啊啊啊Async Displayhttp://baidu.com✺◟(∗❛ัᴗ❛ั∗)◞✺ 😀😖😐🚋🎊😡🚖🚌💖💗💛💙🏨✺◟(∗❛ัᴗ❛ั∗)◞✺ 😀😖😐😣😡🚖🚌🚋🎊😡🚖🚌💖💗💛💙🏨";
    
    NSMutableAttributedString *text = [[NSMutableAttributedString alloc] initWithString:str];
    text.ty_lineSpacing = 2;
    
    TYTextHighlight *textHighlight = [[TYTextHighlight alloc]init];
    textHighlight.color = [UIColor blueColor];
    textHighlight.backgroundColor = [UIColor redColor];
    [text addTextHighlightAttribute:textHighlight range:NSMakeRange(1, 20)];
    
    TYTextAttachment *attachment = [[TYTextAttachment alloc]init];
    attachment.image = [UIImage imageNamed:@"avatar"];
    attachment.size = CGSizeMake(60, 60);
    //[text appendAttributedString:[NSAttributedString attributedStringWithAttachment:attachment]];
    TYTextAttachment *attachment1 = [[TYTextAttachment alloc]init];
    attachment1 = [[TYTextAttachment alloc]init];
    attachment1.image = [UIImage imageNamed:@"avatar"];
    attachment1.size = CGSizeMake(20, 20);
    attachment1.verticalAlignment = TYAttachmentAlignmentCenter;
    [text appendAttributedString:[NSAttributedString attributedStringWithAttachment:attachment1]];
    TYTextAttachment *attachmentView = [[TYTextAttachment alloc]init];
    UIButton *button = [UIButton buttonWithType:UIButtonTypeSystem];
    [button setTitle:@"button" forState:UIControlStateNormal];
    attachmentView.view = button;
    attachmentView.view.backgroundColor = [UIColor redColor];
    attachmentView.size = CGSizeMake(60, 25);
    attachmentView.verticalAlignment = TYAttachmentAlignmentCenter;
    [text appendAttributedString:[NSAttributedString attributedStringWithAttachment:attachmentView]];
    text.ty_font = [UIFont systemFontOfSize:15];
    text.ty_characterSpacing = 2;
    return text;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
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
