//
//  ChatViewController.m
//  MatchaChat
//
//  Created by Joshua Zhou on 14/11/25.
//  Copyright (c) 2014年 Joshua Zhou. All rights reserved.
//

#import "ChatViewController.h"
#import "AppDelegate.h"
#import <CoreData/CoreData.h>
#import "ChatTableViewCell.h"

@interface ChatViewController () <UITextFieldDelegate, UITableViewDelegate, UITableViewDataSource, NSFetchedResultsControllerDelegate>

@property (weak, nonatomic) IBOutlet UITextField *inputTextField;
@property (nonatomic, strong) NSFetchedResultsController *fetchResultsController;
@property (weak, nonatomic) IBOutlet UITableView *tableView;

@end

@implementation ChatViewController

- (AppDelegate *)appDelegate
{
    return [UIApplication sharedApplication].delegate;
}

- (NSFetchedResultsController *)fetchResultsController
{
    if (!_fetchResultsController) {
        NSManagedObjectContext *context = [[[self appDelegate] xmppMessageArchivingCoreDataStorage] mainThreadManagedObjectContext];
        NSFetchRequest *request = [NSFetchRequest fetchRequestWithEntityName:@"XMPPMessageArchiving_Message_CoreDataObject"];
        NSSortDescriptor *sortDescriptor = [NSSortDescriptor sortDescriptorWithKey:@"timestamp" ascending:YES];
        request.sortDescriptors = @[sortDescriptor];
        request.predicate = [NSPredicate predicateWithFormat:@"bareJidStr = 'mairunqian@joshuas-macbook-pro.local' AND streamBareJidStr = 'joshua@joshuas-macbook-pro.local'"]; // 只获取mairunqian传给joshua的消息;
        _fetchResultsController = [[NSFetchedResultsController alloc] initWithFetchRequest:request managedObjectContext:context sectionNameKeyPath:nil cacheName:nil];
        _fetchResultsController.delegate = self;
        
        NSError *error = nil;
        [_fetchResultsController performFetch:&error];
        if (error) {
            NSLog(@"%@", error.localizedDescription);
        }
    }
    return _fetchResultsController;
}

- (void)controllerDidChangeContent:(NSFetchedResultsController *)controller
{
    [self.tableView reloadData];
    [self scrollToBottomOfTableView];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.title = self.headline;
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillShow:) name:UIKeyboardWillShowNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillHide:) name:UIKeyboardWillHideNotification object:nil];
    
    self.tableView.keyboardDismissMode = UIScrollViewKeyboardDismissModeOnDrag; // scrollView拖动时就dismiss键盘
    [self scrollToBottomOfTableView];
}

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)keyboardWillShow:(NSNotification *)notification
{
    NSDictionary *userInfo = notification.userInfo;
    CGFloat beginY= [userInfo[UIKeyboardFrameBeginUserInfoKey] CGRectValue].origin.y;
    CGFloat endY = [userInfo[UIKeyboardFrameEndUserInfoKey] CGRectValue].origin.y;
    CGFloat animationDuration = [userInfo[UIKeyboardAnimationDurationUserInfoKey] floatValue];

    [UIView animateWithDuration:animationDuration animations:^{
        self.view.transform = CGAffineTransformTranslate(self.view.transform, 0, endY - beginY);
    }];
}

- (void)keyboardWillHide:(NSNotification *)notification
{
    self.view.transform = CGAffineTransformIdentity;
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    XMPPMessage *message = [XMPPMessage messageWithType:@"chat" to:[XMPPJID jidWithString:@"mairunqian@joshuas-macbook-pro.local"]]; // 与presence的type一样
    [message addBody:textField.text]; // 消息内容
    
    [[[self appDelegate] xmppStream] sendElement:message]; // 发送消息
    
    textField.text = nil;
    
    [self scrollToBottomOfTableView];
    return YES;
}

- (void)scrollToBottomOfTableView
{
    id <NSFetchedResultsSectionInfo> info = [self.fetchResultsController.sections firstObject]; // 因为我们只有一个section，所以第一个就行了
    NSIndexPath *indexPath = [NSIndexPath indexPathForRow:[info numberOfObjects] - 1 inSection:0];
    [self.tableView scrollToRowAtIndexPath:indexPath atScrollPosition:UITableViewScrollPositionBottom animated:NO];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    id <NSFetchedResultsSectionInfo> info = self.fetchResultsController.sections[section];
    return [info numberOfObjects];
}

- (ChatTableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    XMPPMessageArchiving_Message_CoreDataObject *object = [self.fetchResultsController objectAtIndexPath:indexPath];
    
    NSString *reuseIdentifier = nil;
    if (object.isOutgoing) {        // 判断是发出去还是受到的消息
        reuseIdentifier = @"My message cell";
    } else
    {
        reuseIdentifier = @"Others message cell";
    }
    
    ChatTableViewCell *cell = [ChatTableViewCell cellForTableView:tableView reuseIdentifier:reuseIdentifier];
    
    cell.model = object;
    
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    XMPPMessageArchiving_Message_CoreDataObject *object = [self.fetchResultsController objectAtIndexPath:indexPath];
    CGSize textSize = [object.body boundingRectWithSize:CGSizeMake(200, MAXFLOAT) options:NSStringDrawingUsesLineFragmentOrigin attributes:@{NSFontAttributeName: [UIFont systemFontOfSize:15.0]} context:nil].size;
    if (textSize.height + 32 > 70) {
        return textSize.height + 32;
    }
    
    return 70;
}

@end
