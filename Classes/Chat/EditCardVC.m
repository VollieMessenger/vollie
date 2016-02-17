//
//  EditCardVC.m
//  Volley
//
//  Created by Kyle Bendelow on 2/15/16.
//  Copyright © 2016 KZ. All rights reserved.
//

#import "EditCardVC.h"
#import "JSQMessages.h"
#import "ProgressHUD.h"

@interface EditCardVC () <UITextFieldDelegate>
@property (weak, nonatomic) IBOutlet UITextField *titleTextField;
@property (weak, nonatomic) IBOutlet UIButton *cancelButton;

@end

@implementation EditCardVC

- (void)viewDidLoad
{
    [super viewDidLoad];
    [self setUpTextForLabelsAndButtons];
    [self setUpUserInterface];
}

-(void)basicSetUpOfUI
{
    
}

-(void)setUpUserInterface
{
    self.title = @"Manage Card Settings";
    self.navigationItem.backBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"" style:UIBarButtonItemStylePlain target:nil action:nil];
    [self changeButtonAppearanceWith:self.cancelButton];
}

-(void)changeButtonAppearanceWith:(UIButton*)button
{
    [button setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    button.layer.borderColor = [UIColor colorWithWhite:0.829 alpha:1.000].CGColor;
    button.layer.borderWidth = 1;
    button.backgroundColor = [UIColor whiteColor];
    if (button == self.cancelButton)
    {
        button.backgroundColor = [UIColor volleyFamousOrange];
        [button setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    }

}

- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    [self saveNickname];
    return YES;
}

-(void)setUpTextForLabelsAndButtons
{
    self.titleTextField.delegate = self;
    [self.titleTextField setReturnKeyType:UIReturnKeyDone];
    
//    if (self.messageButReallyRoom[@"nickname"])
//    {
//        NSString *string = [NSString stringWithFormat:@" %@", self.messageButReallyRoom[@"nickname"]];
//        //        self.textField.placeholder = self.messageButReallyRoom[@"nickname"];
//        self.textField.placeholder = string;
//    }
}

- (void) saveNickname
{
    PFObject *message = self.set;
    if (self.titleTextField.isFirstResponder)
    {
        if (self.titleTextField.hasText)
        {
            [message setValue:self.titleTextField.text forKey:@"title"];
        }
        else
        {
//            [message removeObjectForKey:];
        }
        [message saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error)
        {
            if (succeeded)
            {
                [self.cardDelegate titleChange:self.titleTextField.text];
                [ProgressHUD showSuccess:@"Saved Nickname"];
                [self.titleTextField resignFirstResponder];
            }
            else
            {
                [ProgressHUD showError:@"Network Error"];
            }
        }];
    }
}




- (IBAction)onCancelButtonTapped:(id)sender
{
    long whereToGo = self.navigationController.viewControllers.count - 2;
    [self.navigationController popToViewController:[self.navigationController.viewControllers objectAtIndex:whereToGo] animated:YES];
//    [self.navigationController dismissViewControllerAnimated:YES completion:nil];
}

@end
