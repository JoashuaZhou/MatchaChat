//
//  ChatTableViewCell.m
//  MatchaChat
//
//  Created by Joshua Zhou on 14/11/26.
//  Copyright (c) 2014年 Joshua Zhou. All rights reserved.
//

#import "ChatTableViewCell.h"
#import "AppDelegate.h"

@interface ChatTableViewCell ()

@property (weak, nonatomic) IBOutlet UIImageView *iconView;
@property (weak, nonatomic) IBOutlet UILabel *messageLabel;

@end

@implementation ChatTableViewCell

- (AppDelegate *)appDelegate
{
    return [UIApplication sharedApplication].delegate;
}

+ (instancetype)cellForTableView:(UITableView *)tableView reuseIdentifier:(NSString *)reuseIdentifier
{
    ChatTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:reuseIdentifier];
    if (!cell) {
        cell = [[ChatTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:reuseIdentifier];
    }
    
    return cell;
}

- (void)setModel:(XMPPMessageArchiving_Message_CoreDataObject *)model
{
    _model = model;
    
    NSData *photoData = nil;
    if (model.isOutgoing) {
        photoData = [[[self appDelegate] xmppvCardAvatarModule] photoDataForJID:[XMPPJID jidWithString:model.streamBareJidStr]];
    } else {
        photoData = [[[self appDelegate] xmppvCardAvatarModule] photoDataForJID:model.bareJid];
    }
    self.iconView.image = [UIImage imageWithData:photoData];
    
    self.messageLabel.text = model.body;
}

@end
