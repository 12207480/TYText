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
@property (weak, nonatomic) IBOutlet TYLabel *label1;
@property (weak, nonatomic) IBOutlet TYLabel *attribuedLabel;

@end


#define RGB(r,g,b,a)    [UIColor colorWithRed:r/255.0 green:g/255.0 blue:b/255.0 alpha:a]

@implementation TextAutolayoutController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    [self addLabel];
    [self addLabel1];
    [self addAttribuedLabel];
}

- (void)addLabel {
    _label.backgroundColor = [UIColor lightGrayColor];
    _label.text = @"这种遮罩是动态的，只要输入😄😄是纯数字那么NSLayoutManager的对象就不会对其进行绘制，而用黑色的遮罩挡住。 ";
    _label.font = [UIFont systemFontOfSize:17];
    //_label.numberOfLines = 2;
    [self.view addSubview:_label];
}

- (void)addLabel1 {
    _label1.preferredMaxLayoutWidth = CGRectGetWidth(self.view.frame);
    _label1.backgroundColor = [UIColor lightGrayColor];
    _label1.text = @"这种遮罩是动态的，只要输入😄😄";
    _label1.font = [UIFont systemFontOfSize:17];
    //_label.numberOfLines = 2;
    [self.view addSubview:_label1];
}

- (void)addAttribuedLabel {
    _attribuedLabel.backgroundColor = [UIColor lightGrayColor];
    _attribuedLabel.attributedText = [self addAttribuetedString];
    //_attribuedLabel.numberOfLines = 2;
    _attribuedLabel.lineBreakMode = NSLineBreakByTruncatingTail;
    [self.view addSubview:_attribuedLabel];
}

- (NSAttributedString *)addAttribuetedString {
    NSMutableAttributedString *attString = [[NSMutableAttributedString alloc] init];
    NSString *text = @"\t总有一天你将破蛹而出，成长得比人们期待的还要美丽。\n\t但这个过程会很痛，会很辛苦，有时候还会觉得灰心。\n\t面对着汹涌而来的现实，觉得自己渺小无力。\n\t但这，也是生命的一部分，做好现在你能做的，然后，一切都会好的。\n\t我们都将孤独地长大，不要害怕。";
    
    NSArray *textArray = [text componentsSeparatedByString:@"\n\t"];
    NSArray *colorArray = @[RGB(213, 0, 0, 1),RGB(0, 155, 0, 1),RGB(103, 0, 207, 1),RGB(209, 162, 74, 1),RGB(206, 39, 206, 1)];
    NSInteger index = 0;
    for (NSString *text in textArray) {
        NSMutableAttributedString *attributedString = [[NSMutableAttributedString alloc]initWithString:text];
        // 设置当前文本字体
        attributedString.ty_color = colorArray[index%5];
        // 设置当前文本颜色
        attributedString.ty_font = [UIFont systemFontOfSize:15+arc4random()%4];
        if (index % 2 == 0) {
            attributedString.ty_underLineStyle = NSUnderlineStyleSingle;
        }
        // 追加(添加到最后)属性文本
        if (index < textArray.count-1) {
            [attributedString appendAttributedString:[[NSAttributedString alloc]initWithString:@"\n\t"]];
        }
        [attString appendAttributedString:attributedString];
        ++index;
    }
    attString.ty_characterSpacing = 2;
    return attString;
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
