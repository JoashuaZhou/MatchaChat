//
//  LoginViewController.m
//  MatchaChat
//
//  Created by Joshua Zhou on 14/11/13.
//  Copyright (c) 2014年 Joshua Zhou. All rights reserved.
//

#import "LoginViewController.h"
#import "AppDelegate.h"
#import "JZNotificationView.h"

#define adaptKeyboardHeight 120
@interface LoginViewController () <UITextFieldDelegate>

@property (weak, nonatomic) IBOutlet UITextField *accountTextField;
@property (weak, nonatomic) IBOutlet UITextField *passwordTextField;
@property (weak, nonatomic) IBOutlet UITextField *serverNameTextField;
@property (weak, nonatomic) IBOutlet UILabel *errorMessageTextField;
@property (weak, nonatomic) IBOutlet UIView *loginView;
@property (weak, nonatomic) IBOutlet UILabel *logoTextField;
@property (weak, nonatomic) IBOutlet UILabel *declarationTextField;

@end

@implementation LoginViewController

// XMPP官方建议用appDelegate助手方法
// Why?
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
    [UIView animateWithDuration:1.0 animations:^{
        self.logoTextField.transform = CGAffineTransformMakeTranslation(0, -130);
    } completion:^(BOOL finished) {
        [UIView animateWithDuration:0.7 animations:^{
            self.loginView.alpha = 1.0;
        } completion:^(BOOL finished) {
            [UIView animateWithDuration:0.5 animations:^{
                self.declarationTextField.alpha = 1.0;
                self.declarationTextField.transform = CGAffineTransformMakeTranslation(0, -16);
            }];
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
        UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
        UITabBarController *tabBarController = [storyboard instantiateInitialViewController];
        [self.view insertSubview:tabBarController.view belowSubview:self.view]; // 先弄个tabbarController.view在本控制器是为了切换时动画的连续，不然可能不连续，因为我们直接把tabbarController设为window.rootViewController了
        // 两个viewController切换时使用转场动画
        [UIView transitionFromView:self.view toView:tabBarController.view duration:1.2 options:UIViewAnimationOptionTransitionCurlUp completion:^(BOOL finished) {
            [[self appDelegate].window setRootViewController:tabBarController];
        }];
//        CATransition *animation = [CATransition animation];
//        animation.type = @"rippleEffect";
//        animation.duration = 5.0;
//        animation.delegate = self;
//        [self.view.layer addAnimation:animation forKey:nil];
    } Failure:^(NSString *message) {
        [self showErrorMessage];
    }];
}

//- (void)animationDidStop:(CAAnimation *)anim finished:(BOOL)flag
//{
//    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
//    UITabBarController *tabBarController = [storyboard instantiateInitialViewController];
//    [[self appDelegate].window setRootViewController:tabBarController];
//}

- (void)showErrorMessage
{
    [JZNotificationView showFailureWithHeadline:@"登录失败" message:@"请检查一下你的用户和密码！"];
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
    
    self.logoTextField.transform = CGAffineTransformTranslate(self.logoTextField.transform, 0, -50);
    self.loginView.transform = CGAffineTransformMakeTranslation(0, -80);
}

- (void)keyboardWillHide:(NSNotification *)notification
{
    self.logoTextField.transform = CGAffineTransformIdentity;
    self.loginView.transform = CGAffineTransformIdentity;
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
