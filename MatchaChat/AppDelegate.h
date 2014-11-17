//
//  AppDelegate.h
//  MatchaChat
//
//  Created by Joshua Zhou on 14/11/13.
//  Copyright (c) 2014年 Joshua Zhou. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "XMPPFramework.h"

typedef void(^CompletionBlock)(NSString *message);  // 定义一个block
@interface AppDelegate : UIResponder <UIApplicationDelegate>

@property (strong, nonatomic) UIWindow *window;

@property (nonatomic, strong) XMPPStream *xmppStream; // 设为readonly以只供自己修改
@property (nonatomic, strong) XMPPReconnect *xmppReconnect;
@property (nonatomic, strong) XMPPvCardTempModule *xmppvCardTempModule;

@property (nonatomic, assign, getter=isRegistered) BOOL registration;

- (void)connectWithAccountName:(NSString *)accountName Password:(NSString *)password ServerName:(NSString *)serverName Success:(CompletionBlock)success Failure:(CompletionBlock)failure;

@end

