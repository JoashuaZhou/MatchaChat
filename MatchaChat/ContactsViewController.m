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

@interface ContactsViewController ()

@property (nonatomic, strong) NSFetchedResultsController *fetchResultController;

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
    
    [self setupSeperator];
}

- (void)setupSeperator
{
    UIView *view = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 0, 1)];
    [view setBackgroundColor:[UIColor lightGrayColor]];
    self.tableView.tableFooterView = view;
}

#pragma mark - Table view data source
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return self.fetchResultController.sections.count;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    id <NSFetchedResultsSectionInfo> sectionInfo = self.fetchResultController.sections[section];
    return [sectionInfo numberOfObjects];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"Contacts" forIndexPath:indexPath];
    
    // Configure the cell...
    XMPPUserCoreDataStorageObject *object = [self.fetchResultController objectAtIndexPath:indexPath];
    cell.textLabel.text = object.displayName;
    
    
    return cell;
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
