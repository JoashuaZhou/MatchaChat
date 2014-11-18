//
//  ProfileSettingViewController.m
//  MatchaChat
//
//  Created by Joshua Zhou on 14/11/18.
//  Copyright (c) 2014年 Joshua Zhou. All rights reserved.
//

#import "ProfileSettingViewController.h"

@interface ProfileSettingViewController ()
@property (weak, nonatomic) IBOutlet UITextField *editTextField;

@end

@implementation ProfileSettingViewController

- (void)viewDidLoad {
    [super viewDidLoad];

    self.title = _titleText;
    self.editTextField.text = self.editText.text;
}

- (IBAction)save:(UIBarButtonItem *)sender {
    self.editText.text = self.editTextField.text;
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (IBAction)cancel:(UIBarButtonItem *)sender {
    [self dismissViewControllerAnimated:YES completion:nil];
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
