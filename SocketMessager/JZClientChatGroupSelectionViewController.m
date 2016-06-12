//
//  JZClientChatGroupSelectionViewController.m
//  SocketMessager
//
//  Created by Fincher Justin on 16/6/13.
//  Copyright © 2016年 JustZht. All rights reserved.
//

#import "JZClientChatGroupSelectionViewController.h"
#import "JZSocketManager.h"
#import "JZClientChatGroupSelectionTableViewCell.h"
@interface JZClientChatGroupSelectionViewController ()<JZSocketManagerDelegate,UITableViewDelegate,UITableViewDataSource>
@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (weak, nonatomic) IBOutlet UILabel *onlineDevicesLabel;

@property (strong,nonatomic) NSArray *addressArray;

@end

@implementation JZClientChatGroupSelectionViewController
@synthesize onlineDevicesLabel,addressArray;
- (void)viewDidLoad {
    [super viewDidLoad];
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    JZSocketManager *socketManger = [JZSocketManager sharedManager];
    socketManger.delegate = self;
    // Do any additional setup after loading the view.
    
    self.tableView.allowsMultipleSelection = YES;
    [self.tableView registerNib:[UINib nibWithNibName:@"JZClientChatGroupSelectionTableViewCell" bundle:nil] forCellReuseIdentifier:@"JZClientChatGroupSelectionTableViewCell"];
}

#pragma mark - JZSocketManagerDelegate
- (void)didReadData:(NSData *)data withTag:(long)tag
{
    if (tag == TAG_DEVICEARRAY)
    {
        addressArray = [NSKeyedUnarchiver unarchiveObjectWithData:data];
        onlineDevicesLabel.text = [NSString stringWithFormat:@"%lu DEVEICES ONLINE",(unsigned long)[addressArray count]];
        [self reloadTableView];
    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
- (BOOL)prefersStatusBarHidden
{
    return YES;
}
#pragma mark - Table view
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if (addressArray)
    {
        return [addressArray count];
    }else
    {
        return 0;
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    JZClientChatGroupSelectionTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"JZClientChatGroupSelectionTableViewCell" forIndexPath:indexPath];
    
    // Configure the cell...
    
    [cell setLabelText:[addressArray objectAtIndex:indexPath.row]];
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 64.0f;
}
- (void)reloadTableView
{
    NSArray *indexPaths = [self.tableView indexPathsForSelectedRows];
    [self.tableView reloadData];
    for (NSIndexPath *path in indexPaths) {
        [self.tableView selectRowAtIndexPath:path animated:NO scrollPosition:UITableViewScrollPositionNone];
    }
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
