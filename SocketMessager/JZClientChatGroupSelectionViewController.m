//
//  JZClientChatGroupSelectionViewController.m
//  SocketMessager
//
//  Created by Fincher Justin on 16/6/13.
//  Copyright © 2016年 JustZht. All rights reserved.
//

#import "JZClientChatGroupSelectionViewController.h"
#import "JZSocketManager.h"

@interface JZClientChatGroupSelectionViewController ()<JZSocketManagerDelegate>
@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (weak, nonatomic) IBOutlet UILabel *onlineDevicesLabel;

@end

@implementation JZClientChatGroupSelectionViewController
@synthesize onlineDevicesLabel;
- (void)viewDidLoad {
    [super viewDidLoad];
    
    JZSocketManager *socketManger = [JZSocketManager sharedManager];
    socketManger.delegate = self;
    // Do any additional setup after loading the view.
}

#pragma mark - JZSocketManagerDelegate
- (void)didReadData:(NSData *)data withTag:(long)tag
{
    if (tag == TAG_DEVICEARRAY)
    {
        NSArray *array = [NSKeyedUnarchiver unarchiveObjectWithData:data];
        onlineDevicesLabel.text = [NSString stringWithFormat:@"%lu DEVEICES ONLINE",(unsigned long)[array count]];
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

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
