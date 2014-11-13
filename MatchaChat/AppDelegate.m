//
//  AppDelegate.m
//  MatchaChat
//
//  Created by Joshua Zhou on 14/11/13.
//  Copyright (c) 2014年 Joshua Zhou. All rights reserved.
//

#import "AppDelegate.h"

@interface AppDelegate () <XMPPStreamDelegate>

@property (nonatomic, strong) CompletionBlock success;
@property (nonatomic, strong) CompletionBlock failure;

@end

@implementation AppDelegate

#pragma mark - AppDelegate方法
- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    // Override point for customization after application launch.
    return YES;
}

- (void)applicationWillResignActive:(UIApplication *)application {
//    [self disconnectFromServer];
}

- (void)applicationDidBecomeActive:(UIApplication *)application {
//    [self connectToServer];
//    [self connectWithAccountName:@"joshua" Password:@"123456" ServerName:@"xxx" Success:nil Failure:nil];
}

#pragma mark - XMPP相关方法
- (void)setupXMPPStream
{
    // 1. alloc init
    _xmppStream = [[XMPPStream alloc] init];
    
    // 2. 设置XMPPStream的代理，添加XMPPStreamDelegate
    [_xmppStream addDelegate:self delegateQueue:dispatch_get_main_queue()];
}

- (void)connectToServer
{
    // 1. 创建XMPPStream
    [self setupXMPPStream];
    
    // 2. 获取账号、服务器名称(连接成功才需要密码，用于验证)
    NSString *accountName = @"joshua@joshuas-macbook-pro.local";
    NSString *hostName = @"joshuas-macbook-pro.local";
    
    // 3. 设置JID、服务器名称
    [_xmppStream setMyJID:[XMPPJID jidWithString:accountName]];
    [_xmppStream setHostName:hostName];
    
    // 4. 连接
    NSError *error = nil;
    [_xmppStream connectWithTimeout:XMPPStreamTimeoutNone error:&error];
    
    if (error) {
        NSLog(@"连接失败: %@", error.localizedDescription);
    }
}

- (void)disconnectFromServer
{
    // 1. 下线状态
    XMPPPresence *presence = [XMPPPresence presenceWithType:@"unavailable"];
    [_xmppStream sendElement:presence];
    
    // 2. 断开与服务器连接
    [_xmppStream disconnect];
    
    NSLog(@"已下线");
}

#pragma mark - XMPPStream Delegate
- (void)xmppStreamDidConnect:(XMPPStream *)sender
{
    NSLog(@"连接成功");
    
    NSString *password = @"123456";     // 在这里才需要密码
    
    // 验证密码
    [_xmppStream authenticateWithPassword:password error:nil];
}

- (void)xmppStreamDidAuthenticate:(XMPPStream *)sender
{
    NSLog(@"密码验证成功");
    
    // 验证成功，就显示上线状态
    
    // 1. alloc init
    XMPPPresence *presence = [XMPPPresence presence];
    
    // 2. 发送在线状态
    [_xmppStream sendElement:presence];
    
    self.success();
}

- (void)xmppStream:(XMPPStream *)sender didNotAuthenticate:(DDXMLElement *)error
{
    NSLog(@"密码验证失败");
    
    self.failure();
}

#pragma mark - 公有方法
- (void)connectWithAccountName:(NSString *)accountName Password:(NSString *)password ServerName:(NSString *)serverName Success:(CompletionBlock)success Failure:(CompletionBlock)failure
{
    // 1. 创建XMPPStream
    [self setupXMPPStream];
    
    // 2. 获取账号、服务器名称(连接成功才需要密码，用于验证)
//    NSString *accountName = @"joshua@joshuas-macbook-pro.local";
//    NSString *hostName = @"joshuas-macbook-pro.local";
    serverName = @"joshuas-macbook-pro.local";
    accountName = [accountName stringByAppendingString:[NSString stringWithFormat:@"@%@", serverName]];
    
    // 3. 设置JID、服务器名称
    [_xmppStream setMyJID:[XMPPJID jidWithString:accountName]];
    [_xmppStream setHostName:serverName];
    
    // 4. 连接
    [_xmppStream connectWithTimeout:XMPPStreamTimeoutNone error:nil];
    
    self.success = success;
    self.failure = failure;
}

@end