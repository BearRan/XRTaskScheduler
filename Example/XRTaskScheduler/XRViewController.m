//
//  XRViewController.m
//  XRTaskScheduler
//
//  Created by Bear on 05/29/2021.
//  Copyright (c) 2021 Bear. All rights reserved.
//

#import "XRViewController.h"
#import "XRDemoModel.h"

@interface XRViewController () <UITableViewDelegate, UITableViewDataSource>

@property (nonatomic, strong) UITableView *mainTableView;
@property (nonatomic, strong) NSMutableArray <XRDemoModel *> *dataArray;

@end

@implementation XRViewController

- (void)viewDidLoad
{
    [super viewDidLoad];

    [self.view addSubview:self.mainTableView];
    self.mainTableView.frame = self.view.bounds;
    
    [self createData];
    [self.mainTableView reloadData];
}

- (void)createData {
    XRDemoModel *tmpModel;
    
    {
        tmpModel = [XRDemoModel new];
        tmpModel.name = @"正序测试";
        tmpModel.demoVCName = @"";
        [self.dataArray addObject:tmpModel];
    }
    
    {
        tmpModel = [XRDemoModel new];
        tmpModel.name = @"倒序测试";
        tmpModel.demoVCName = @"";
        [self.dataArray addObject:tmpModel];
    }
    
    {
        tmpModel = [XRDemoModel new];
        tmpModel.name = @"优先级测试";
        tmpModel.demoVCName = @"";
        [self.dataArray addObject:tmpModel];
    }
    
    {
        tmpModel = [XRDemoModel new];
        tmpModel.name = @"并发测试";
        tmpModel.demoVCName = @"";
        [self.dataArray addObject:tmpModel];
    }
    
    {
        tmpModel = [XRDemoModel new];
        tmpModel.name = @"最大任务量测试";
        tmpModel.demoVCName = @"";
        [self.dataArray addObject:tmpModel];
    }
    
    {
        tmpModel = [XRDemoModel new];
        tmpModel.name = @"指定队列测试";
        tmpModel.demoVCName = @"";
        [self.dataArray addObject:tmpModel];
    }
}

#pragma mark - UITableViewDelegate
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.dataArray.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *cellId = @"cellId";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellId];
    if (!cell) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellId];
    }
    
    XRDemoModel *tmpModel = self.dataArray[indexPath.row];
    cell.textLabel.text = tmpModel.name;
    
    return cell;
}

#pragma mark - Setter & Getter
- (UITableView *)mainTableView {
    if (!_mainTableView) {
        _mainTableView = [UITableView new];
        _mainTableView.delegate = self;
        _mainTableView.dataSource = self;
    }
    
    return _mainTableView;
}

- (NSMutableArray<XRDemoModel *> *)dataArray {
    if (!_dataArray) {
        _dataArray = [NSMutableArray new];
    }
    
    return _dataArray;
}

@end
