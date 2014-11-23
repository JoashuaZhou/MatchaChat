//
//  ContactsViewController.m
//  MatchaChat
//
//  Created by Joshua Zhou on 14/11/19.
//  Copyright (c) 2014年 Joshua Zhou. All rights reserved.
//

#import "ContactsViewController.h"
#import "AppDelegate.h"
#import <CoreData/CoreData.h>

@interface ContactsViewController () <NSFetchedResultsControllerDelegate, UITextFieldDelegate>

@property (nonatomic, strong) NSFetchedResultsController *fetchResultController;
@property (nonatomic, weak) UIVisualEffectView *shadowView;

@end

@implementation ContactsViewController

- (AppDelegate *)appDelegate
{
    return [UIApplication sharedApplication].delegate;
}

- (NSFetchedResultsController *)fetchResultController
{
    if (!_fetchResultController) {
        NSManagedObjectContext *context = [[[self appDelegate] xmppRosterStorage] mainThreadManagedObjectContext];
        NSFetchRequest *fetchRequest = [NSFetchRequest fetchRequestWithEntityName:@"XMPPUserCoreDataStorageObject"];
        NSSortDescriptor *sort = [NSSortDescriptor sortDescriptorWithKey:@"displayName" ascending:YES];
        fetchRequest.sortDescriptors = @[sort];
        _fetchResultController = [[NSFetchedResultsController alloc] initWithFetchRequest:fetchRequest managedObjectContext:context sectionNameKeyPath:@"displayName" cacheName:@"Contacts"];
        _fetchResultController.delegate = self;
        
        /* 执行一下fetch */
        NSError *error = nil;
        [_fetchResultController performFetch:&error];
        if (error) {
            NSLog(@"%@", error.localizedDescription);
        }
    }
    
    return _fetchResultController;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
//    [self setupSeperator];
}

- (void)setupSeperator
{
    UIView *view = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 0, 1)];
    [view setBackgroundColor:[UIColor lightGrayColor]];
    self.tableView.tableFooterView = view;
}

- (IBAction)addContact:(UIBarButtonItem *)sender {
    UIBlurEffect *blurEffect = [UIBlurEffect effectWithStyle:UIBlurEffectStyleLight];
    UIVisualEffectView *effectView = [[UIVisualEffectView alloc] initWithEffect:blurEffect];
    effectView.frame = self.view.window.bounds;
    effectView.alpha = 0;
    UITapGestureRecognizer *tapRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(exitAddContact)];
    [effectView addGestureRecognizer:tapRecognizer];
    [self.view.window addSubview:effectView];   // 要挡住navBar和tabBar就要在window上addSubView
    self.shadowView = effectView;
    
    UIView *colorView = [[UIView alloc] init];
    colorView.backgroundColor = [UIColor colorWithRed:79/255.0 green:167/255.0 blue:105/255.0 alpha:1.0];
    colorView.layer.cornerRadius = 12.0;
    colorView.center = effectView.center;
    colorView.bounds = CGRectMake(0, 0, 250, 100);
    [effectView addSubview:colorView];
    
    UITextField *textField = [[UITextField alloc] init];
    textField.borderStyle = UITextBorderStyleRoundedRect;
    textField.center = CGPointMake(colorView.bounds.size.width / 2, colorView.bounds.size.height * 0.6);
    textField.bounds = CGRectMake(0, 0, 200, 30);
    NSAttributedString *placeholder = [[NSAttributedString alloc] initWithString:@"用户名" attributes:@{NSForegroundColorAttributeName: [UIColor lightGrayColor], NSFontAttributeName: [UIFont systemFontOfSize:15.0]}];
    textField.attributedPlaceholder = placeholder;
    textField.delegate = self;
    [colorView addSubview:textField];
    
    UILabel *tipLabel = [[UILabel alloc] init];
    NSAttributedString *attributedText = [[NSAttributedString alloc] initWithString:@"添加好友" attributes:@{NSForegroundColorAttributeName: [UIColor lightGrayColor], NSFontAttributeName: [UIFont systemFontOfSize:50.0]}];
    tipLabel.attributedText = attributedText;
    tipLabel.center = CGPointMake(effectView.center.x, colorView.frame.origin.y);
    tipLabel.bounds = CGRectMake(0, 0, 200, 100);
    tipLabel.textAlignment = NSTextAlignmentCenter;
    [effectView addSubview:tipLabel];
    
    [UIView animateWithDuration:1.0 animations:^{
        effectView.alpha = 1.0;
    }];
}

- (void)exitAddContact
{
    [UIView animateWithDuration:0.5 animations:^{
        self.shadowView.alpha = 0;
    } completion:^(BOOL finished) {
        [self.shadowView removeFromSuperview];
    }];
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    if (![textField.text isEqualToString:@""]) {
        [self addContactWithName:textField.text];
    }
    return YES;
}

- (void)addContactWithName:(NSString *)name
{
    NSRange range = [name rangeOfString:@"@"];
    if (range.location == NSNotFound) {
        name = [NSString stringWithFormat:@"%@@%@", name, @"joshuas-macbook-pro.local"];
    }
    
    // 判断是否添加自己?
    
    // 判断是否已经是好友
    
    // 发送添加好友请求
    [[[self appDelegate] xmppRoster] subscribePresenceToUser:[XMPPJID jidWithString:name]];
    
    [self exitAddContact];
}

#pragma mark - Table view data source
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return self.fetchResultController.sections.count;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    /* 这里返回的是一个id <NSFetchedResultsSectionInfo>，而不是NSArray */
    id <NSFetchedResultsSectionInfo> sectionInfo = self.fetchResultController.sections[section];
    return [sectionInfo numberOfObjects];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"Contacts" forIndexPath:indexPath];
    
    // Configure the cell...
    XMPPUserCoreDataStorageObject *object = [self.fetchResultController objectAtIndexPath:indexPath];
    cell.textLabel.text = object.displayName;
    cell.imageView.image = [UIImage imageNamed:@"Male"];//object.photo;
    
    return cell;
}

/* fetchResultController获得新数据时重新刷新表格 */
- (void)controllerDidChangeContent:(NSFetchedResultsController *)controller
{
    [self.tableView reloadData];
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
