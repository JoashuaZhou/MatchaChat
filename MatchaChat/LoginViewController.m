//
//  LoginViewController.m
//  MatchaChat
//
//  Created by Joshua Zhou on 14/11/13.
//  Copyright (c) 2014年 Joshua Zhou. All rights reserved.
//

#import "LoginViewController.h"
#import "AppDelegate.h"

#define adaptKeyboardHeight 120
@interface LoginViewController () <UITextFieldDelegate>

@property (weak, nonatomic) IBOutlet UITextField *accountTextField;
@property (weak, nonatomic) IBOutlet UITextField *passwordTextField;
@property (weak, nonatomic) IBOutlet UITextField *serverNameTextField;
@property (weak, nonatomic) IBOutlet UILabel *errorMessageTextField;
@property (weak, nonatomic) IBOutlet UIView *loginView;

@end

@implementation LoginViewController

// XMPP官方建议用appDelegate助手方法
- (AppDelegate *)appDelegate
{
    return [UIApplication sharedApplication].delegate;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self setupUI];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillShow:) name:UIKeyboardWillShowNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillHide:) name:UIKeyboardWillHideNotification object:nil];
}

- (void)setupUI
{
    UILabel *loginLabel = [[UILabel alloc] init];
    loginLabel.bounds = CGRectMake(0, 0, 260, 80);
    loginLabel.center = self.view.center;
    [loginLabel setText:@"Matcha Chat"];
    [loginLabel setTextColor:[UIColor whiteColor]];
    loginLabel.font = [UIFont fontWithName:@"Party LET" size:70.0];
    [self.view addSubview:loginLabel];
    
    [UIView animateWithDuration:1.0 animations:^{
        loginLabel.transform = CGAffineTransformMakeTranslation(0, -130);
    } completion:^(BOOL finished) {
        [UIView animateWithDuration:0.5 animations:^{
            self.loginView.alpha = 1.0;
        }];
    }];
}

- (IBAction)loginOrRegister:(UIButton *)sender {
    if ([self.accountTextField.text isEqualToString:@""] || [self.passwordTextField.text isEqualToString:@""] || [self.serverNameTextField.text isEqualToString:@""]) {
        [self showErrorMessage];
        return;
    }
    
    [self appDelegate].registration = sender.tag ? YES : NO;
    
    [[self appDelegate] connectWithAccountName:self.accountTextField.text Password:self.passwordTextField.text ServerName:self.serverNameTextField.text Success:^(NSString *message) {
        NSLog(@"%@", message);
    } Failure:^(NSString *message) {
        [self showErrorMessage];
    }];
}


- (void)showErrorMessage
{
    self.errorMessageTextField.hidden = NO;
    
    CAKeyframeAnimation *animation = [CAKeyframeAnimation animation];
    animation.keyPath = @"transform.translation.x";
    animation.values = @[@(-8), @(0), @(-8)];
    animation.repeatCount = 5;
    animation.duration = 0.1;
    [self.errorMessageTextField.layer addAnimation:animation forKey:nil];
}

#pragma mark - 通知中心 & 键盘弹出处理
- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)keyboardWillShow:(NSNotification *)notification
{
//    CGRect keyboardBeginRect = [notification.userInfo[UIKeyboardFrameBeginUserInfoKey] CGRectValue];
//    CGRect keyboardEndRect = [notification.userInfo[UIKeyboardFrameEndUserInfoKey] CGRectValue];
    
    CGFloat translationY = -adaptKeyboardHeight;
    self.view.transform = CGAffineTransformMakeTranslation(0, translationY);
}

- (void)keyboardWillHide:(NSNotification *)notification
{
    //    CGRect keyboardBeginRect = [notification.userInfo[UIKeyboardFrameBeginUserInfoKey] CGRectValue];
    //    CGRect keyboardEndRect = [notification.userInfo[UIKeyboardFrameEndUserInfoKey] CGRectValue];
    
    CGFloat translationY = adaptKeyboardHeight;
    self.view.transform = CGAffineTransformMakeTranslation(0, translationY);
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
