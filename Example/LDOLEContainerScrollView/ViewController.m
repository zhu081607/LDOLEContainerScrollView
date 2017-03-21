//
//  ViewController.m
//  LDOLEContainerScrollView
//
//  Created by asshole on 2017/1/8.
//  Copyright © 2017年 netease. All rights reserved.
//

#import "ViewController.h"
#import "OLEContainerScrollView.h"
#import "LDPageContainerScrollView.h"
#import "OLETableViewDateSource.h"

@interface ViewController () <LDPageContainerScrollViewDelegate, OLEContainerScrollViewDelegate>

@property (nonatomic, strong) OLEContainerScrollView *containerScrollView;
@property (nonatomic, strong) LDPageContainerScrollView *scrollView;
@property (nonatomic, strong) NSMutableArray *childTableDataSourceArray;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.containerScrollView = [[OLEContainerScrollView alloc] initWithFrame:CGRectMake(0, 0, self.view.bounds.size.width, self.view.bounds.size.height)];
    self.containerScrollView.isNeedRefresh = YES;
    self.containerScrollView.clipsToBounds = NO;
    self.containerScrollView.backgroundColor = [UIColor clearColor];
    self.containerScrollView.layer.borderWidth = 2.0;
    self.containerScrollView.layer.borderColor = [[UIColor blackColor] CGColor];
    [self.view addSubview:self.containerScrollView];
    self.containerScrollView.delegate = self;
    self.containerScrollView.scrollDelegate = self;
    
    
    self.scrollView = [[LDPageContainerScrollView alloc] initWithFrame:self.view.bounds
                                                         sectionTitles:@[@"1", @"2", @"3"]];
    
    self.scrollView.autoresizingMask = UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth;
    self.scrollView.backgroundColor = [UIColor clearColor];
    self.scrollView.pagingEnabled = YES;
    self.scrollView.delegate = self;
    self.scrollView.pageContainerScrollViewdelegate = self;
    self.scrollView.showsHorizontalScrollIndicator = NO;
    self.scrollView.showsVerticalScrollIndicator = NO;
    
    //    self.scrollView.contentSize = CGSizeMake(CGRectGetWidth(self.scrollView.bounds) * segCount, CGRectGetHeight(self.scrollView.bounds));
    self.scrollView.scrollsToTop = NO;
    
    NSMutableArray *childTableViews = [NSMutableArray array];
    self.childTableDataSourceArray = [NSMutableArray array];
    
    for (NSUInteger idx = 0; idx < 3; idx++) {
        UITableView *tableView = [[UITableView alloc] initWithFrame:self.view.bounds style:UITableViewStylePlain];
        tableView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
        OLETableViewDateSource *dataSource = [OLETableViewDateSource new];
        dataSource.index = idx;
        tableView.dataSource = dataSource;
        tableView.delegate = dataSource;
        if (idx == 0) {
            tableView.scrollsToTop = YES;
        } else {
            tableView.scrollsToTop = NO;
        }
        [self.childTableDataSourceArray addObject:dataSource];
        [childTableViews addObject:tableView];
        //        [self.scrollView addSubview:tableView];
    }

    UIView *test1 = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.view.bounds.size.width, 200)];
    test1.backgroundColor = [UIColor blueColor];
    [self.containerScrollView.contentView addSubview:test1];
    [self.view addSubview:self.containerScrollView];

    [self.scrollView setTableViews:childTableViews];
    [self.containerScrollView.contentView addSubview:self.scrollView];
    // Do any additional setup after loading the view, typically from a nib.
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark OLEContainerScrollViewDelegate
- (void)baseViewPullDownToReloadAction
{
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(2 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [self.containerScrollView pullDownToReloadActionFinished];
    });
}

@end
