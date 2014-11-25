//
//  AppDelegate.m
//  MatchaChat
//
//  Created by Joshua Zhou on 14/11/13.
//  Copyright (c) 2014年 Joshua Zhou. All rights reserved.
//

#import "AppDelegate.h"
#import "LoginViewController.h"
#import "XMPPvCardCoreDataStorage.h"
#import "XMPPvCardTempModule.h"

@interface AppDelegate () <XMPPStreamDelegate, XMPPRosterDelegate>

@property (nonatomic, strong) CompletionBlock success;
@property (nonatomic, strong) CompletionBlock failure;
@property (nonatomic, copy) NSString *password;
@property (nonatomic, strong) XMPPCapabilities *xmppCapabilities;

@end

@implementation AppDelegate

#pragma mark - AppDelegate方法
- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    
    /* XCode 6.1的Bug，不能在Storyboard中设置 */
    UITabBarController *tabBarController = (UITabBarController *)self.window.rootViewController;
    ((UITabBarItem *)tabBarController.tabBar.items[0]).selectedImage = [UIImage imageNamed:@"tabbar_mainframeHL"];
    ((UITabBarItem *)tabBarController.tabBar.items[1]).selectedImage = [UIImage imageNamed:@"tabbar_contactsHL"];
    ((UITabBarItem *)tabBarController.tabBar.items[2]).selectedImage = [UIImage imageNamed:@"tabbar_meHL"];

    application.statusBarStyle = UIStatusBarStyleLightContent;
    
    LoginViewController *loginVC = [[LoginViewController alloc] initWithNibName:@"LoginViewControllerView" bundle:[NSBundle mainBundle]];
    [self.window setRootViewController:loginVC];
    
    // 1. 创建XMPPStream
    [self setupXMPPStream];     // 整个app生命周期，XMPPStream就应该只被实例化一次
    return YES;
}

- (void)applicationWillResignActive:(UIApplication *)application {
    [self disconnectFromServer];    // 重要：如果你不disconnect，再次connect就会连接不上！因为XMPPStream是长连接
}

- (void)applicationDidBecomeActive:(UIApplication *)application {
//    [self connectToServer];
//    [self connectWithAccountName:@"joshua" Password:@"123456" ServerName:@"xxx" Success:nil Failure:nil];
}

- (void)applicationWillTerminate:(UIApplication *)application
{
    [self disconnectFromServer];
}

- (void)dealloc
{
    [self teardownStream];
}

#pragma mark - XMPP相关方法
- (void)setupXMPPStream
{
    // 0. 断言
    NSAssert(_xmppStream == nil, @"出错啦！_xmpp这里不为nil");
    
    // 1. alloc init
    _xmppStream = [[XMPPStream alloc] init];
    
    // 2. 扩展模块(记得去XMPPFramework.h取消评论想要扩展的模块的.h)
    // 2.1 这里扩展的模块是自动重连(看它.h，还有判断是不是wifi环境下才重连的方法)
    _xmppReconnect = [[XMPPReconnect alloc] init];
    [_xmppReconnect activate:_xmppStream];
    
    // 2.2 电子名片模块
    _xmppvCardTempModule = [[XMPPvCardTempModule alloc] initWithvCardStorage:[XMPPvCardCoreDataStorage sharedInstance]];    // 看XMPPvCardCoreDataStorage.h他会告诉你最好用单例，即sharedInstance
    _xmppvCardAvatarModule = [[XMPPvCardAvatarModule alloc] initWithvCardTempModule:_xmppvCardTempModule];
    [_xmppvCardTempModule activate:_xmppStream];
    [_xmppvCardAvatarModule activate:_xmppStream];
    
    // 2.3 花名册模块
    _xmppRosterStorage = [[XMPPRosterCoreDataStorage alloc] init];
    _xmppRoster = [[XMPPRoster alloc] initWithRosterStorage:_xmppRosterStorage];  // XMPPRosterCoreDataStorage.h说不一定要用sharedInstance，因为你有可能有很多xmppStream
    [_xmppRoster setAutoAcceptKnownPresenceSubscriptionRequests:YES]; // XMPP的好友机制是像新浪微博那种订阅制的，就是我关注你，你不一定要关注我。如果设置为YES，就是QQ那种双向订阅的。
    [_xmppRoster setAutoFetchRoster:YES]; // 如果好友更新名片，就自动从服务器更新。如果设置为NO，就不会自动更新，要每次登陆才更新
    [_xmppRoster activate:_xmppStream];
    
    // 2.4 实体能力模块(增强性能)
    _xmppCapabilities = [[XMPPCapabilities alloc] initWithCapabilitiesStorage:[[XMPPCapabilitiesCoreDataStorage alloc] init]];
    [_xmppCapabilities activate:_xmppStream];
    
    // 2.5 文本消息
    _xmppMessageArchivingCoreDataStorage = [[XMPPMessageArchivingCoreDataStorage alloc] init];
    _xmppMessageArchiving = [[XMPPMessageArchiving alloc] initWithMessageArchivingStorage:_xmppMessageArchivingCoreDataStorage];
    [_xmppMessageArchiving activate:_xmppStream];
    
    // 3. 设置XMPPStream的代理，添加XMPPStreamDelegate
    [_xmppStream addDelegate:self delegateQueue:dispatch_get_main_queue()];
    [_xmppRoster addDelegate:self delegateQueue:dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0)];
}

//- (void)connectToServer
//{
//    // 2. 获取账号、服务器名称(连接成功才需要密码，用于验证)
//    NSString *accountName = @"joshua@joshuas-macbook-pro.local";
//    NSString *hostName = @"joshuas-macbook-pro.local";
//    
//    // 3. 设置JID、服务器名称
//    [_xmppStream setMyJID:[XMPPJID jidWithString:accountName]];
//    [_xmppStream setHostName:hostName];
//    
//    // 4. 连接
//    NSError *error = nil;
//    [_xmppStream connectWithTimeout:XMPPStreamTimeoutNone error:&error];
//    if (error) {
//        NSLog(@"连接失败: %@", error.localizedDescription);
//    }
//}

- (void)disconnectFromServer
{
    // 1. 下线状态
    XMPPPresence *presence = [XMPPPresence presenceWithType:@"unavailable"];
    [_xmppStream sendElement:presence];
    
    // 2. 断开与服务器连接
    [_xmppStream disconnect];
    
    NSLog(@"已下线");
}

// 销毁XMPPStream并注销已注册的扩展模块
- (void)teardownStream
{
    // 1. 删除代理
    [_xmppStream removeDelegate:self];
    [_xmppRoster removeDelegate:self];
    
    // 2. 取消激活在setupStream方法中激活的扩展模块
    [_xmppReconnect deactivate];
    [_xmppvCardTempModule deactivate];
    [_xmppRoster deactivate];
    [_xmppCapabilities deactivate];
    [_xmppvCardAvatarModule deactivate];
    [_xmppMessageArchiving deactivate];
    
    // 3. 断开XMPPStream的连接
    [_xmppStream disconnect];
    
    // 4. 内存清理
    _xmppStream = nil;
    _xmppReconnect = nil;
    _xmppvCardTempModule = nil;
    _xmppRoster = nil;
    _xmppRosterStorage = nil;
    _xmppCapabilities = nil;
    _xmppvCardAvatarModule = nil;
    _xmppMessageArchiving = nil;
    _xmppMessageArchivingCoreDataStorage = nil;
}

#pragma mark - XMPPStream Delegate
- (void)xmppStreamDidConnect:(XMPPStream *)sender
{
    NSLog(@"连接成功");
    
    self.password = @"123456";
    
    // 验证密码/注册是同一级别的，你必须先要connect，才可以authenticate或者register
    NSError *error = nil;
    if (!self.isRegistered) {
        [_xmppStream authenticateWithPassword:self.password error:&error];
    } else {
        [_xmppStream registerWithPassword:self.password error:&error];
    }
    
    if (error) {
        NSLog(@"%@", error.localizedDescription);
    }
}

- (void)xmppStreamDidAuthenticate:(XMPPStream *)sender
{
    NSLog(@"密码验证成功");
    
    // 验证成功，就显示上线状态
    
    // 1. alloc init
    XMPPPresence *presence = [XMPPPresence presence];   // 默认的type是"available"
    
    // 2. 发送在线状态
    [_xmppStream sendElement:presence];
    
    self.success(@"密码认证成功！");
}

- (void)xmppStream:(XMPPStream *)sender didNotAuthenticate:(DDXMLElement *)error
{
    NSLog(@"密码验证失败");
    
    self.failure(@"密码错误！");
}

- (void)xmppStreamDidRegister:(XMPPStream *)sender
{
    self.registration = NO;
    
    self.success(@"账户注册成功！");
    
    // 注册完后自动帮用户登录
    [_xmppStream connectWithTimeout:XMPPStreamTimeoutNone error:nil];
}

- (void)xmppStream:(XMPPStream *)sender didNotRegister:(DDXMLElement *)error
{
    self.registration = NO;
    
    self.failure(@"账户注册失败！");
}

- (void)xmppStream:(XMPPStream *)sender didReceiveMessage:(XMPPMessage *)message
{
    NSLog(@"%@", message);  // 这里还可以返回正在输入和停止输入的状态
}

- (void)xmppRoster:(XMPPRoster *)sender didReceivePresenceSubscriptionRequest:(XMPPPresence *)presence
{
    NSLog(@"收到用户请求：%@", presence);
    
    if ([presence.type isEqualToString:@"subscribe"]) {
        XMPPJID *from = [presence from];
        [_xmppRoster acceptPresenceSubscriptionRequestFrom:from andAddToRoster:YES];    // 自动接受好友申请
    }
}

#pragma mark - 公有方法
- (void)connectWithAccountName:(NSString *)accountName Password:(NSString *)password ServerName:(NSString *)serverName Success:(CompletionBlock)success Failure:(CompletionBlock)failure
{
    // 1. 如果XMPPStream当前已经连接，直接返回
    if ([_xmppStream isConnected]) {
        return;
    }
    //    在C语言中if判断真假：非零即真，如果_xmppStream==nil下面这段代码，与上面的代码结果不同。
    //    if (![_xmppStream isDisconnected]) {
    //        return;
    //    }
    
    // 2. 获取账号、服务器名称(连接成功才需要密码，用于验证)
    self.password = password;
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
