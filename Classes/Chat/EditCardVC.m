//
//  EditCardVC.m
//  Volley
//
//  Created by Kyle Bendelow on 2/15/16.
//  Copyright © 2016 KZ. All rights reserved.
//

#import "EditCardVC.h"
#import "JSQMessages.h"

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
//    
//    NSArray *peopleArray = self.room[@"userObjects"];
//    NSString *peopleString = [NSString stringWithFormat:@"%li People in Chat", peopleArray.count];
//    [self.peopleButton setTitle:peopleString forState:UIControlStateNormal];
}




- (IBAction)onCancelButtonTapped:(id)sender
{
//        [self.navigationController popToViewController:[self.navigationController.viewControllers objectAtIndex:1] animated:YES];
    [self.navigationController dismissViewControllerAnimated:YES completion:nil];
}

@end
