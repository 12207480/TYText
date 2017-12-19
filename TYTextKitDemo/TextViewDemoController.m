//
//  TextViewDemoController.m
//  TYTextKitDemo
//
//  Created by tany on 2017/10/19.
//  Copyright © 2017年 tany. All rights reserved.
//

#import "TextViewDemoController.h"
#import "TYTextView.h"

@interface TextField : UITextField

@end

@interface TextViewDemoController ()

@property (nonatomic, strong) TYTextView *textView;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *topConstraint;

@end

#define RGB(r,g,b,a)    [UIColor colorWithRed:r/255.0 green:g/255.0 blue:b/255.0 alpha:a]

@implementation TextViewDemoController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    UIBarButtonItem *doneItem = [[UIBarButtonItem alloc]initWithBarButtonSystemItem:UIBarButtonSystemItemDone target:self action:@selector(barItemDoneAction)];
    UIBarButtonItem *editItem = [[UIBarButtonItem alloc]initWithTitle:@"Edit:YES" style:UIBarButtonItemStylePlain target:self action:@selector(barItemEditAction:)];
    self.navigationItem.rightBarButtonItems = @[editItem,doneItem];
    
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
//    textView.placeHolderLabel.text = @"请输入";
//    textView.text = @"这种遮罩是动态的，只要输入😄😄是纯数字那么NSLayoutManager的对象就不会对其进行绘制，而用黑色的遮罩挡住。";
    //textView.contentInset = UIEdgeInsetsMake(10, 10, 10, 10);
    textView.font = [UIFont systemFontOfSize:16];
    // 忽略textView文本相关属性一般用于attributedText
    textView.ignoreAboveTextRelatedPropertys = YES;
    textView.attributedText = [self attributedString];
    textView.layer.borderWidth = 1.0;
    textView.layer.borderColor = [UIColor blackColor].CGColor;
    textView.lineBreakMode = NSLineBreakByCharWrapping;
    //textView.textAlignment = NSTextAlignmentRight;
    [self.view addSubview:textView];
    _textView = textView;
}

- (NSMutableAttributedString *)attributedString {
    NSMutableAttributedString *text = [[NSMutableAttributedString alloc]init];
    
    NSMutableAttributedString *attString = [[NSMutableAttributedString alloc]initWithString:@"\t\t\t\t蒹葭-云歌\n"];
    attString.ty_color = RGB(51, 51, 51, 1);
    NSRange range = [attString.string rangeOfString:@"蒹葭"];
    [attString ty_addFont:[UIFont systemFontOfSize:18] range:range];
    [attString ty_addColor:RGB(206, 39, 206, 1) range:range];
    [text appendAttributedString:attString];
    
    attString = [[NSMutableAttributedString alloc]initWithString:@"\t蒹葭苍苍，[@]。所谓伊人，在水一方。溯洄从之，道阻且长，溯游从之，宛在水中央。\n\t蒹葭萋萋，白露未晞。[@]，在水之湄。溯洄从之，[@]。溯游从之，宛在水中坻。\n\t[@]，[@]。所谓伊人，在水之涘。溯洄从之，道阻且右。溯游从之，[@]。\n注解:\n\t出自《诗经·国风·秦风》，是一首描写对意中人深深的[@]和求而不得的惆怅的诗。\n"];
    attString.ty_color = RGB(51, 51, 51, 1);
    range = [attString.string rangeOfString:@"注解:"];
    [attString ty_addColor:RGB(209, 162, 74, 1) range:range];
    [attString ty_addFont:[UIFont systemFontOfSize:17] range:range];
    
    range = [attString.string rangeOfString:@"《诗经·国风·秦风》"];
    TYTextAttribute *textAttribute = [[TYTextAttribute alloc]init];
    textAttribute.color = RGB(209, 162, 74, 1);
    [attString addTextAttribute:textAttribute range:range];
    TYTextHighlight *textHighlight = [[TYTextHighlight alloc]init];
    textHighlight.color = RGB(206, 39, 206, 1);
    [attString addTextHighlightAttribute:textHighlight range:range];
    
    NSArray *array = [self matcheInString:attString.string regularExpressionWithPattern:@"\\[@\\]"];
    [array enumerateObjectsWithOptions:NSEnumerationReverse usingBlock:^(NSTextCheckingResult *match, NSUInteger idx, BOOL * _Nonnull stop) {
        TextField *textField = [[TextField alloc]initWithFrame:CGRectMake(0, 0, 80, 18)];
        textField.textColor = [UIColor colorWithRed:255.0/255 green:155.0/255 blue:26.0/255 alpha:1];
        textField.textAlignment = NSTextAlignmentCenter;
        textField.font = [UIFont systemFontOfSize:16];
        
        TYTextAttachment *attachmentView = [[TYTextAttachment alloc]init];
        attachmentView.view = textField;
        attachmentView.size = textField.frame.size;
        attachmentView.verticalAlignment = TYAttachmentAlignmentCenter;
        [attString replaceCharactersInRange:[match range] withAttributedString:[NSAttributedString attributedStringWithAttachment:attachmentView]];
    }];
    
    [text appendAttributedString:attString];
    text.ty_font = [UIFont systemFontOfSize:16];
    text.ty_lineSpacing = 2;
    return text;
}

-(NSArray *)matcheInString:(NSString *)string regularExpressionWithPattern:(NSString *)regularExpressionWithPattern
{
    NSError *error;
    NSRange range = NSMakeRange(0,[string length]);
    NSRegularExpression *regex = [NSRegularExpression regularExpressionWithPattern:regularExpressionWithPattern options:NSRegularExpressionCaseInsensitive error:&error];
    NSArray* matches = [regex matchesInString:string options:0 range:range];
    return matches;
}

- (IBAction)buttonAction:(UIButton *)sender {
    if (!_textView.editable) {
        return;
    }
    if (![_textView isFocused]) {
        [_textView becomeFirstResponder];
    }
    NSAttributedString *attString = nil;
    if (sender.tag == 0) {
        TYTextAttachment *attachMent = [[TYTextAttachment alloc]init];
        attachMent.size = CGSizeMake(60, 60);
        attachMent.image = [UIImage imageNamed:@"avatar"];
        //attachMent.verticalAlignment = TYAttachmentAlignmentCenter;
        attString = [NSAttributedString attributedStringWithAttachment:attachMent];
    }else if (sender.tag == 1) {
        UISwitch *switchView = [[UISwitch alloc]init];
        TYTextAttachment *attachMent = [[TYTextAttachment alloc]init];
        attachMent.view = switchView;
        attachMent.size = switchView.bounds.size;
        //attachMent.verticalAlignment = TYAttachmentAlignmentCenter;
        attString = [NSAttributedString attributedStringWithAttachment:attachMent];
    }
    [_textView insertAttributedText:attString];
}

- (void)barItemDoneAction {
    [_textView resignFirstResponder];
}

- (void)barItemEditAction:(UIBarButtonItem *)item {
    if ([item.title isEqualToString:@"Edit:YES"]) {
        _textView.editable = NO;
        [_textView resignFirstResponder];
        item.title = @"Edit:NO";
    }else {
        _textView.editable = YES;
        [_textView becomeFirstResponder];
        item.title = @"Edit:YES";
    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end

@implementation TextField

- (void)drawRect:(CGRect)rect {
    //[super drawRect:rect];
    // Drawing code
    CGContextRef context = UIGraphicsGetCurrentContext();
    //画一条底部线
    CGContextSetRGBStrokeColor(context, 207.0/255, 207.0/255, 207.0/255, 1);//线条颜色
    CGContextMoveToPoint(context, 0, rect.size.height);
    CGContextAddLineToPoint(context, rect.size.width,rect.size.height);
    CGContextStrokePath(context);
}

@end
