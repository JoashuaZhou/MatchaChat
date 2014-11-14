//
//  NavigationController.m
//  MatchaChat
//
//  Created by Joshua Zhou on 14/11/14.
//  Copyright (c) 2014年 Joshua Zhou. All rights reserved.
//

#import "NavigationController.h"

@interface NavigationController ()

@end

@implementation NavigationController

+ (void)initialize
{
    UINavigationBar *navbar = [UINavigationBar appearance];
    [navbar setBackgroundImage:[UIImage imageNamed:@"NavigationBar"] forBarMetrics:UIBarMetricsDefault];
    [navbar setTitleTextAttributes:@{NSForegroundColorAttributeName: [UIColor whiteColor]}];
}

@end
