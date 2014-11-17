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

@interface ProfileViewController ()

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
    XMPPvCardTemp *card = [self appDelegate].xmppvCardTempModule.myvCardTemp;
    
    if (card) {
        NSLog(@"有电子名片");
        // 查看电子名片包含的信息(.h里面有)
        
        
    } else {
        NSLog(@"没有电子名片");
        // 1. 新建名片
        card = [XMPPvCardTemp vCardTemp];
        card.jid = [XMPPJID jidWithString:@"haha"];
        
        // 2. 保存电子名片(存到数据库), 初次运行会生成sqlite文件
        [[self appDelegate].xmppvCardTempModule updateMyvCardTemp:card];
    }
}

#pragma mark - Table view data source

/*
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:<#@"reuseIdentifier"#> forIndexPath:indexPath];
    
    // Configure the cell...
    
    return cell;
}
*/

/*
// Override to support conditional editing of the table view.
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    // Return NO if you do not want the specified item to be editable.
    return YES;
}
*/

/*
// Override to support editing the table view.
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        // Delete the row from the data source
        [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
    } else if (editingStyle == UITableViewCellEditingStyleInsert) {
        // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
    }   
}
*/

/*
// Override to support rearranging the table view.
- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath {
}
*/

/*
// Override to support conditional rearranging of the table view.
- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath {
    // Return NO if you do not want the item to be re-orderable.
    return YES;
}
*/

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
