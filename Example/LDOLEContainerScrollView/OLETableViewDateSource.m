//
//  OLETableViewDateSource.m
//  LDOLEContainerScrollView
//
//  Created by asshole on 2017/1/15.
//  Copyright © 2017年 netease. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "OLETableViewDateSource.h"

@interface OLETableViewDateSource ()

@end

@implementation OLETableViewDateSource

#pragma mark UITableViewDataSource

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section;
{
    if (self.index == 2) {
        return 3;
    }
    return 10 + self.index * 100;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView            // Default is 1 if not implemented
{
    return 1;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath;
{
    NSInteger row = indexPath.row;
    static NSString *identifier = @"Cell";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:identifier];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:identifier];
        NSLog(@"alloc %ld_%ld",(long)self.index, (long)row);
    } else {
        NSLog(@"reuse %ld_%ld",(long)self.index, (long)row);
    }
    cell.detailTextLabel.text = [NSString stringWithFormat:@"%ld_%ld",(long)self.index, (long)row];
    UIColor *bgColor;
    
    
    switch ((self.index + row) % 3){
        case 0:
            bgColor = [UIColor redColor];
            break;
        case 1:
            bgColor = [UIColor blueColor];
            break;
        default:
            bgColor = [UIColor greenColor];
            
    }
    cell.contentView.backgroundColor = bgColor;
    return  cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 100;
}


@end
