//
//  ViewController.m
//  TYTextKitDemo
//
//  Created by tany on 2017/9/8.
//  Copyright © 2017年 tany. All rights reserved.
//

#import "ViewController.h"
#import "TextDemoViewController.h"
#import "AttributedDemoViewController.h"
#import "TextListViewController.h"

@interface tableViewItem : NSObject

@property (nonatomic, strong) NSString *title;

@property (nonatomic, strong) NSString *detailText;

@property (nonatomic, assign) Class destVcClass;

@end

@implementation tableViewItem

@end

@interface ViewController () <UITableViewDataSource,UITableViewDelegate>

@property (nonatomic, weak) UITableView *tableView;

@property (nonatomic, strong) NSMutableArray *itemArray;
@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    self.title = @"TYTextKit Demo";
    [self addTableView];
    
    [self addTableItems];
    
    [self.tableView reloadData];
}

- (NSMutableArray *)itemArray
{
    if (_itemArray == nil) {
        _itemArray = [NSMutableArray array];
    }
    return _itemArray;
}

- (void)addTableView
{
    // 添加tableView
    UITableView *tableView = [[UITableView alloc]init];
    tableView.delegate = self;
    tableView.dataSource = self;
    [self.view addSubview:tableView];
    self.tableView = tableView;
}

- (void)viewWillLayoutSubviews
{
    [super viewWillLayoutSubviews];
   self.tableView.frame = self.view.bounds;
}

- (void)addTableItems
{
    [self addTableItemWithTitle:@"SimpleText" detailText:@"简单文本显示" destVcClass:[TextDemoViewController class]];
    [self addTableItemWithTitle:@"AttributedText" detailText:@"属性文本显示" destVcClass:[AttributedDemoViewController class]];
    [self addTableItemWithTitle:@"AsyncText" detailText:@"异步文本显示" destVcClass:[TextListViewController class]];
}

- (void)addTableItemWithTitle:(NSString *)title detailText:(NSString *)detailText destVcClass:(Class)destVcClass
{
    tableViewItem *item = [[tableViewItem alloc]init];
    item.title = title;
    item.detailText = detailText;
    item.destVcClass = destVcClass;
    
    [self.itemArray addObject:item];
}

#pragma mark - UITableViewDataSource

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.itemArray.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"cell"];
    if (cell == nil) {
        cell = [[UITableViewCell alloc]initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:@"cell"];
        cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    }
    
    tableViewItem *item = self.itemArray[indexPath.row];
    cell.textLabel.text = item.title;
    cell.detailTextLabel.text = item.detailText;
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    tableViewItem *item = self.itemArray[indexPath.row];
    
    if (item.destVcClass ) {
        UIViewController *vc = [[item.destVcClass alloc]init];
        vc.view.backgroundColor = [UIColor whiteColor];
        vc.title = item.title;
        [self.navigationController pushViewController:vc animated:YES];
    }
}


@end
