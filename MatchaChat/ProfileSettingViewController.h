//
//  ProfileSettingViewController.h
//  MatchaChat
//
//  Created by Joshua Zhou on 14/11/18.
//  Copyright (c) 2014年 Joshua Zhou. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ProfileSettingViewController : UIViewController

@property (nonatomic, copy) NSString *titleText;
@property (nonatomic, weak) UILabel *editText;  // 新的传参方式，与ProfileViewController指向同一块内存区域

@end
