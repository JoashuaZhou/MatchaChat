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

@interface ChatViewController () <UITextFieldDelegate, UIScrollViewDelegate, UITableViewDelegate, UITableViewDataSource, NSFetchedResultsControllerDelegate>

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
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.title = self.headline;
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillShow:) name:UIKeyboardWillShowNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillHide:) name:UIKeyboardWillHideNotification object:nil];
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
    [textField resignFirstResponder];
    return YES;
}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    [self.inputTextField resignFirstResponder];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    id <NSFetchedResultsSectionInfo> info = self.fetchResultsController.sections[section];
    return [info numberOfObjects];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"Chat Cell" forIndexPath:indexPath];
    
    XMPPMessageArchiving_Message_CoreDataObject *object = [self.fetchResultsController objectAtIndexPath:indexPath];
    
    cell.textLabel.text = object.body;
    
    return cell;
}

@end
