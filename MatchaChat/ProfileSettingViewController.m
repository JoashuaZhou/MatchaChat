//
//  ProfileSettingViewController.m
//  MatchaChat
//
//  Created by Joshua Zhou on 14/11/18.
//  Copyright (c) 2014年 Joshua Zhou. All rights reserved.
//

#import "ProfileSettingViewController.h"

@interface ProfileSettingViewController () <UITextFieldDelegate>

@property (weak, nonatomic) IBOutlet UITextField *editTextField;

@end

@implementation ProfileSettingViewController

- (void)viewDidLoad {
    [super viewDidLoad];

    self.title = _titleText;
    self.editTextField.text = self.editText.text;
    
    [self.editTextField becomeFirstResponder];
}

- (IBAction)save:(UIBarButtonItem *)sender {
    if ([self.delegate respondsToSelector:@selector(profileSettingViewControllerDidModifyProfile:)]) {
        [self.editTextField resignFirstResponder];
        self.editText.text = self.editTextField.text;
        [self.delegate profileSettingViewControllerDidModifyProfile:self];
    }
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (IBAction)cancel:(UIBarButtonItem *)sender {
    [self.editTextField resignFirstResponder];
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    [self.editTextField resignFirstResponder];
    [self save:nil];
    return YES;
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
