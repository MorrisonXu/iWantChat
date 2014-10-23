//
//  ViewController.m
//  iWantChat
//
//  Created by 徐佳俊 on 14-10-8.
//  Copyright (c) 2014年 morrison. All rights reserved.
//

#import "ChatListTableViewController.h"
#import "ChatListTableViewCell.h"

@interface ChatListTableViewController () <UITableViewDelegate,UITableViewDataSource>

@end

@implementation ChatListTableViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - UITableViewDelegate & ßUITableViewDataSource
// 设置section数和每个section的row数
/*
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}
*/
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return 1;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"ChatListCell";
    ChatListTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier forIndexPath:indexPath];
    
    if (cell==nil) {
        cell=[[ChatListTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
    }
    
    cell.chatPortrait.image = [UIImage imageNamed:@"to.jpg"];
    cell.chatName.text = @"派大星";
    cell.chatPreview.text = @"Hello！";
    return cell;
}

@end
