//
//  JZServerViewController.m
//  SocketMessager
//
//  Created by Fincher Justin on 16/6/12.
//  Copyright © 2016年 JustZht. All rights reserved.
//

#import "JZServerViewController.h"
#import "GCDAsyncSocket.h"
#import <ifaddrs.h>
#import <arpa/inet.h>
#import "JZSocketManager.h"

@interface JZServerViewController ()<GCDAsyncSocketDelegate>

@property (nonatomic) int portNumber;
@property (strong,nonatomic) GCDAsyncSocket * socketServer;
@property (weak, nonatomic) IBOutlet UILabel *addressLabel;
@property (weak, nonatomic) IBOutlet UITextView *logTextView;

@property (strong,nonatomic) NSMutableArray *socketArray;

@end

@implementation JZServerViewController
@synthesize socketServer;
@synthesize portNumber;
@synthesize socketArray;

- (void)viewDidLoad
{
    [super viewDidLoad];
    portNumber = 8000;
    
    _logTextView.scrollEnabled= NO;
    
    socketArray = [NSMutableArray array];
    // Do any additional setup after loading the view.
    socketServer = [[GCDAsyncSocket alloc] initWithDelegate:self delegateQueue:dispatch_get_main_queue()];
    NSError *error = nil;
    if (![socketServer acceptOnPort:portNumber error:&error])
    {
        _addressLabel.text = @"Can't Open Socket, Try Again.";
        
    }else
    {
        _addressLabel.text = [NSString stringWithFormat:@"%@:%d",[self getIPAddress],portNumber];
        [NSTimer scheduledTimerWithTimeInterval:2.0
                                         target:self
                                       selector:@selector(boardAllConnectedDevices)
                                       userInfo:nil
                                        repeats:YES];
    }
}

#pragma mark - Delegate
- (void)socket:(GCDAsyncSocket *)sender didAcceptNewSocket:(GCDAsyncSocket *)newSocket
{
    NSLog(@"New Connection");
    NSString *dateString = [NSDateFormatter localizedStringFromDate:[NSDate date]
                                                          dateStyle:NSDateFormatterShortStyle
                                                          timeStyle:NSDateFormatterFullStyle];
    [self updateLogTextView:[NSString stringWithFormat:@"%@\nNew Connection From %@:%hu",dateString,[newSocket connectedHost],[newSocket connectedPort]]];

    [socketArray addObject:newSocket];
}
- (void)socketDidDisconnect:(GCDAsyncSocket *)sock withError:(NSError *)err
{
    NSLog(@"New Disconnect : %@",[err debugDescription]);
    NSString *dateString = [NSDateFormatter localizedStringFromDate:[NSDate date]
                                                          dateStyle:NSDateFormatterShortStyle
                                                          timeStyle:NSDateFormatterFullStyle];
    [self updateLogTextView:[NSString stringWithFormat:@"%@\nSocket Disconnetted From %@:%hu :%@",dateString,[sock connectedHost],[sock connectedPort],[err debugDescription]]];
}
#pragma mark - Boardcast

- (void)boardAllConnectedDevices
{
    NSData *data = [NSKeyedArchiver archivedDataWithRootObject:[self getInfoArrayFromSocketArray:self.socketArray]];
    if (data)
    {
        for (GCDAsyncSocket *socket in self.socketArray)
        {
            [socket writeData:data withTimeout:-1 tag:TAG_DEVICEARRAY];
            [socket readDataWithTimeout:-1 tag:TAG_DEVICEARRAY];
        }
    }
}
- (NSMutableArray *)getInfoArrayFromSocketArray:(NSMutableArray *)allSocketArray
{
    NSMutableArray *infoArray = [NSMutableArray array];
    for (int i = 0; i < [allSocketArray count]; i++)
    {
        GCDAsyncSocket *socket = [allSocketArray objectAtIndex:i];
        NSString *string = [NSString stringWithFormat:@"%@:%hu",[socket connectedHost],[socket connectedPort]];
        [infoArray addObject:string];
    }
    return infoArray;
}

#pragma mark - Stuff
- (void)updateLogTextView:(NSString *)string
{
    _logTextView.text = [_logTextView.text stringByAppendingString:[NSString stringWithFormat:@"\n%@",string]];
}
- (BOOL)prefersStatusBarHidden
{
    return YES;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)closeButtonPressed:(id)sender {
    [self dismissViewControllerAnimated:YES completion:nil];
}


// Get IP Address
- (NSString *)getIPAddress {
    NSString *address = @"error";
    struct ifaddrs *interfaces = NULL;
    struct ifaddrs *temp_addr = NULL;
    int success = 0;
    // retrieve the current interfaces - returns 0 on success
    success = getifaddrs(&interfaces);
    if (success == 0) {
        // Loop through linked list of interfaces
        temp_addr = interfaces;
        while(temp_addr != NULL) {
            if(temp_addr->ifa_addr->sa_family == AF_INET) {
                // Check if interface is en0 which is the wifi connection on the iPhone
                if([[NSString stringWithUTF8String:temp_addr->ifa_name] isEqualToString:@"en0"]) {
                    // Get NSString from C String
                    address = [NSString stringWithUTF8String:inet_ntoa(((struct sockaddr_in *)temp_addr->ifa_addr)->sin_addr)];
                }
            }
            temp_addr = temp_addr->ifa_next;
        }
    }
    // Free memory
    freeifaddrs(interfaces);
    return address;
    
}


#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}


@end
