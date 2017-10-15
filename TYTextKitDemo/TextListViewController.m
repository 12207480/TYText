//
//  TextListViewController.m
//  TYTextKitDemo
//
//  Created by tany on 2017/9/25.
//  Copyright © 2017年 tany. All rights reserved.
//

#import "TextListViewController.h"
#import "TextViewCell.h"

@interface TextListViewController ()<UITableViewDataSource,UITableViewDelegate>
@property (nonatomic, weak) UITableView *tableView;
@property (nonatomic, strong) NSArray *itemArray;
@property (nonatomic, strong) NSArray *textArray;
@property (nonatomic, strong) NSArray *renderArray;
@property (nonatomic, assign) BOOL async;

@end

@implementation TextListViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.async = YES;
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc]initWithTitle:@"Async:YES" style:UIBarButtonItemStylePlain target:self action:@selector(changeAsyncAction:)];
    
    [self addTableView];
    
    [self loadData];
}

- (void)addTableView
{
    // 添加tableView
    UITableView *tableView = [[UITableView alloc]init];
    tableView.delaysContentTouches = NO;
    tableView.delegate = self;
    tableView.dataSource = self;
    [self.view addSubview:tableView];
    [tableView registerClass:[TextViewCell class] forCellReuseIdentifier:@"cellId"];
    self.tableView = tableView;
}

- (void)loadData {
    CFAbsoluteTime begin = CFAbsoluteTimeGetCurrent();
    NSMutableArray *itemArray = [NSMutableArray array];
    NSMutableArray *textArray = [NSMutableArray array];
    NSMutableArray *renderArray = [NSMutableArray array];
    for (int i = 0; i < 200; ++i) {
        NSString *str = [NSString stringWithFormat:@"%d Async Display Test Display ✺◟(∗❛ัᴗ❛ั∗)◞✺ 😀😖😐🚋🎊😡🚖🚌💖💗💛💙🏨✺◟(∗❛ัᴗ❛ั∗)◞✺ 😀😖😐😣😡🚖🚌🚋🎊😡🚖🚌💖💗💛💙🏨",i%3 ? i:i*100];
        
        NSMutableAttributedString *text = [[NSMutableAttributedString alloc] initWithString:str];
        text.ty_lineSpacing = 2;
        text.ty_strokeWidth = -3;
        text.ty_strokeColor = [UIColor redColor];
//        text.ty_lineHeightMultiple = 1;
//        text.ty_maximumLineHeight = 15;
//        text.ty_minimumLineHeight = 15;
        TYTextHighlight *textHighlight = [[TYTextHighlight alloc]init];
        textHighlight.color = [UIColor whiteColor];
        textHighlight.backgroundColor = [UIColor redColor];
        [text addTextHighlightAttribute:textHighlight range:NSMakeRange(6,21)];
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
        attachmentView = [[TYTextAttachment alloc]init];
        button = [UIButton buttonWithType:UIButtonTypeSystem];
        [button setTitle:@"button" forState:UIControlStateNormal];
        attachmentView.view = button;
        attachmentView.view.backgroundColor = [UIColor redColor];
        attachmentView.size = CGSizeMake(60, 20);
        //attachmentView.verticalAlignment = TYAttachmentAlignmentBottom;
        [text appendAttributedString:[NSAttributedString attributedStringWithAttachment:attachmentView]];
        text.ty_font = [UIFont systemFontOfSize:10];
        NSShadow *shadow = [NSShadow new];
        shadow.shadowBlurRadius = 1;
        shadow.shadowColor = [UIColor redColor];
        shadow.shadowOffset = CGSizeMake(0, 1);
        //text.ty_shadow = shadow;
        text.ty_characterSpacing = 2;
        TYTextStorage *textStorage = [[TYTextStorage alloc]initWithMutableAttributedString:text];
        TYTextRender *render = [[TYTextRender alloc]init];
        render.textStorage = textStorage;
        [textArray addObject:textStorage];
        [itemArray addObject:text];
        [renderArray addObject:render];
    }
    _itemArray = [itemArray copy];
    _textArray = [textArray copy];
    _renderArray = [renderArray copy];
     CFAbsoluteTime end = CFAbsoluteTimeGetCurrent();
    NSLog(@"useed time %.2f",end - begin);
    [self.tableView reloadData];
}

- (void)viewWillLayoutSubviews
{
    [super viewWillLayoutSubviews];
    self.tableView.frame = self.view.bounds;
}

#pragma mark - UITableViewDataSource

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.itemArray.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    TextViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"cellId" forIndexPath:indexPath];
    cell.label.displaysAsynchronously = _async;
    if (_async) {
        cell.label.hidden = NO;
        cell.uilabel.hidden = YES;
        cell.label.textRender = _renderArray[indexPath.row];
    }else {
        cell.label.hidden = YES;
        cell.uilabel.hidden = NO;
        cell.uilabel.attributedText = _itemArray[indexPath.row];
    }
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 70;
}

- (void)changeAsyncAction:(UIBarButtonItem *)item {
    if ([item.title isEqualToString:@"Async:YES"]) {
        item.title = @"Async:NO";
        self.async = NO;
    }else {
        item.title = @"Async:YES";
        self.async = YES;
    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
