//
//  ProfileViewController.m
//  MatchaChat
//
//  Created by Joshua Zhou on 14/11/17.
//  Copyright (c) 2014年 Joshua Zhou. All rights reserved.
//

#import "ProfileViewController.h"
#import "AppDelegate.h"
#import "XMPPvCardTemp.h"
#import "ProfileSettingViewController.h"

@interface ProfileViewController () <ProfileSettingViewControllerDelegate>

@property (weak, nonatomic) IBOutlet UIImageView *iconView;
@property (weak, nonatomic) IBOutlet UILabel *nameLabel;

@end

@implementation ProfileViewController

// XMPP官方建议用appDelegate助手方法
// Why?
- (AppDelegate *)appDelegate
{
    return [UIApplication sharedApplication].delegate;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self setupCard];
}

- (void)setupCard
{
    // 1. 从xmppvCardTempModule获得电子名片的模型
    XMPPvCardTemp *card = [[self appDelegate].xmppvCardTempModule myvCardTemp];
    
    if (card) {
        NSLog(@"有电子名片");
        // 查看电子名片包含的信息(.h里面有)
        [self showCardInfo:card];
        
    } else {
        NSLog(@"没有电子名片");
        // 1. 新建名片
        card = [XMPPvCardTemp vCardTemp];
        card.jid = [XMPPJID jidWithString:@"joshua@joshuas-macbook-pro.local"]; // 设置JID
        
        // 2. 保存电子名片(存到数据库), 初次运行会生成sqlite文件
        [[self appDelegate].xmppvCardTempModule updateMyvCardTemp:card];
    }
}

- (void)showCardInfo:(XMPPvCardTemp *)card
{
    if (card.photo) {
        self.iconView.image = [UIImage imageWithData:card.photo];
    }
    if (card.nickname) {
        NSLog(@"nickname: %@", card.nickname);
        self.nameLabel.text = card.nickname;
    }
}

- (void)updateCard
{
    XMPPvCardTemp *card = [[self appDelegate].xmppvCardTempModule myvCardTemp];
    
    card.photo = UIImagePNGRepresentation(self.iconView.image);
    card.nickname = self.nameLabel.text;
    
    [[self appDelegate].xmppvCardTempModule updateMyvCardTemp:card];
}

- (void)profileSettingViewControllerDidModifyProfile:(ProfileSettingViewController *)profileSettingViewController
{
    [self updateCard];
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [tableView cellForRowAtIndexPath:indexPath];
    if (cell.tag == 0) {    // 我这里设定tag = 0是可编辑的，tag = 1是不可编辑的
        [self performSegueWithIdentifier:@"Modify Profile Segue" sender:cell];   // 其实sender就是传参的东西，你传个什么都可以
    }
}


#pragma mark - Navigation

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    UINavigationController *nav = (UINavigationController *)segue.destinationViewController;
    ProfileSettingViewController *psvc = (ProfileSettingViewController *)nav.topViewController;
    psvc.delegate = self;
    if ([segue.identifier isEqualToString:@"Modify Profile Segue"]) {
        UITableViewCell *cell = (UITableViewCell *)sender;
        psvc.titleText = cell.textLabel.text;
        psvc.editText = cell.detailTextLabel;
    }
    if ([segue.identifier isEqualToString:@"Modify Nickname Segue"]) {
        psvc.titleText = @"昵称";
        psvc.editText = self.nameLabel;
    }
}

@end
