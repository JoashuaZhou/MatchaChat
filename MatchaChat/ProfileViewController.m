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

@interface ProfileViewController () <ProfileSettingViewControllerDelegate, UINavigationControllerDelegate, UIImagePickerControllerDelegate>

@property (weak, nonatomic) IBOutlet UIImageView *iconView;
@property (weak, nonatomic) IBOutlet UILabel *nameLabel;
@property (weak, nonatomic) IBOutlet UILabel *descriptionLabel;

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

//    self.iconView.layer.borderWidth = 3.0;
//    self.iconView.layer.borderColor = [[[UIColor whiteColor] colorWithAlphaComponent:0.7] CGColor];
}

#pragma mark - 电子名片相关操作
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

- (void)updateCardInfo
{
    XMPPvCardTemp *card = [[self appDelegate].xmppvCardTempModule myvCardTemp];

    /* 更新资料 */
    card.nickname = self.nameLabel.text;
    
    [[self appDelegate].xmppvCardTempModule updateMyvCardTemp:card];
}

/* 与其他改写资料函数分开的原因是，免得每次同步资料时都同步头像，节省流量 */
- (void)updateCardIcon
{
    XMPPvCardTemp *card = [[self appDelegate].xmppvCardTempModule myvCardTemp];
    card.photo = UIImagePNGRepresentation(self.iconView.image);
    [[self appDelegate].xmppvCardTempModule updateMyvCardTemp:card];
}

- (void)profileSettingViewControllerDidModifyProfile:(ProfileSettingViewController *)profileSettingViewController
{
    [self updateCardInfo];
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [tableView cellForRowAtIndexPath:indexPath];
    if (cell.tag == 0) {    // 我这里设定tag = 0是可编辑的，tag = 1是不可编辑的
        [self performSegueWithIdentifier:@"Modify Profile Segue" sender:cell];   // 其实sender就是传参的东西，你传个什么都可以
    }
}

- (IBAction)tapIcon:(UITapGestureRecognizer *)sender {
    UIAlertController *actionSheetController = [UIAlertController alertControllerWithTitle:nil message:nil preferredStyle:UIAlertControllerStyleActionSheet];
    UIImagePickerController *ipc = [[UIImagePickerController alloc] init];
    [actionSheetController addAction:[UIAlertAction actionWithTitle:@"拍照" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
        ipc.sourceType = UIImagePickerControllerSourceTypeCamera;
        [self presentViewController:ipc animated:YES completion:nil];
    }]];
    [actionSheetController addAction:[UIAlertAction actionWithTitle:@"从照片中选取" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
        ipc.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
        [self presentViewController:ipc animated:YES completion:nil];
    }]];
    [actionSheetController addAction:[UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleCancel handler:nil]];
    ipc.allowsEditing = YES;
    ipc.delegate = self;
    [self presentViewController:actionSheetController animated:YES completion:nil];
}

- (IBAction)tapDescriptionLabel:(UITapGestureRecognizer *)sender {
    [self performSegueWithIdentifier:@"Modify Description Segue" sender:nil];
}

- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info
{
    self.iconView.image = info[UIImagePickerControllerEditedImage];
    [self updateCardIcon];
    
    [picker dismissViewControllerAnimated:YES completion:nil];
}

- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker
{
    [picker dismissViewControllerAnimated:YES completion:nil];
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
        psvc.updatingDescription = NO;
    }
    if ([segue.identifier isEqualToString:@"Modify Nickname Segue"]) {
        psvc.titleText = @"昵称";
        psvc.editText = self.nameLabel;
        psvc.updatingDescription = NO;
    }
    if ([segue.identifier isEqualToString:@"Modify Description Segue"]) {
        psvc.titleText = @"个性签名";
        psvc.editText = self.descriptionLabel;
        psvc.updatingDescription = YES;
    }
}

@end
