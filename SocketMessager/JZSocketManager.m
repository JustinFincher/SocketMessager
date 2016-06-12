//
//  JZSocketManager.m
//  SocketMessager
//
//  Created by Fincher Justin on 16/6/13.
//  Copyright © 2016年 JustZht. All rights reserved.
//

#import "JZSocketManager.h"
//client side


@interface JZSocketManager ()<GCDAsyncSocketDelegate>

@end

@implementation JZSocketManager
@synthesize socket;

#pragma mark Singleton Methods

+ (id)sharedManager {
    static JZSocketManager *sharedMyManager = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedMyManager = [[self alloc] init];
    });
    return sharedMyManager;
}

- (id)init {
    if (self = [super init])
    {
        socket = [[GCDAsyncSocket alloc] initWithDelegate:self delegateQueue:dispatch_get_main_queue()];
    }
    return self;
}


- (BOOL)connectSocketIP:(NSString *)address
                   port:(NSString *)port
{
    NSError *err = nil;
    if (![socket connectToHost:address onPort:[port intValue] error:&err])
    {
        // If there was an error, it's likely something like "already connected" or "no delegate set"
        NSLog(@"I goofed: %@", err);
        return NO;
    }else
    {
        return YES;
    }
}
- (void)socket:(GCDAsyncSocket *)sender didConnectToHost:(NSString *)host port:(UInt16)port
{
    NSLog(@"Cool, I'm connected! That was easy.");
    [socket readDataWithTimeout:-1 tag:0];
}
- (void)socketDidDisconnect:(GCDAsyncSocket *)sock withError:(NSError *)err
{
    NSLog(@"socketDidDisconnect");
}
- (void)socket:(GCDAsyncSocket *)sender didReadData:(NSData *)data withTag:(long)tag
{
    id<JZSocketManagerDelegate> strongDelegate = self.delegate;
    [strongDelegate didReadData:data withTag:tag];
    
    [socket readDataWithTimeout:-1 tag:0];
}
@end
