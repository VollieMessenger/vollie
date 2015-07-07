//
//  ManageChatVC.m
//  Volley
//
//  Created by Kyle on 7/7/15.
//  Copyright (c) 2015 KZ. All rights reserved.
//

#import "ManageChatVC.h"
#import "ProgressHUD.h"
#import "AppConstant.h"
#import "ManageChatVC.h"

@interface ManageChatVC ()
@property (strong, nonatomic) IBOutlet UITextField *textField;
@property (strong, nonatomic) IBOutlet UIButton *peopleButton;
@property (strong, nonatomic) IBOutlet UIButton *silenceButton;

@property NSString *labelString;

@end

@implementation ManageChatVC

- (void)viewDidLoad
{
    [super viewDidLoad];
    NSLog(@"%@", self.room);
    [self setUpUserInterface];
    [self setUpTextForLabelsAndButtons];
}

-(void)setUpTextForLabelsAndButtons
{
    if (self.messageButReallyRoom[@"nickname"])
    {
        self.textField.placeholder = self.messageButReallyRoom[@"nickname"];
    }
    NSArray *peopleArray = self.room[@"userObjects"];
    NSString *peopleString = [NSString stringWithFormat:@"%li People in Chat", peopleArray.count];
    [self.peopleButton setTitle:peopleString forState:UIControlStateNormal];
}

-(void)setUpUserInterface
{
    //add borders and stuff here
}

#pragma mark - Navigation

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    ManageChatVC *vc = [segue destinationViewController];
    vc.room = self.room;
    vc.messageButReallyRoom = self.messageButReallyRoom;
}

#pragma mark - Buttons
- (IBAction)onSilenceButtonTapped:(id)sender
{
    [self.messageButReallyRoom fetchIfNeededInBackgroundWithBlock:^(PFObject *object, NSError *error) {
        if (!error) {
            if (!object[PF_MESSAGES_USER_DONOTDISTURB])
            {
                UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Show Push Notifications?" message:nil delegate:self
                                                      cancelButtonTitle:@"Cancel" otherButtonTitles:@"Yes", nil];
                alert.tag = 69;
                [alert show];
            } else {
                UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Silence Push Notifications?" message:nil delegate:self
                                                      cancelButtonTitle:@"Cancel" otherButtonTitles:@"Yes", nil];
                alert.tag = 69;
                [alert show];

            }
        } else [ProgressHUD showError:@"Network Error"];
    }];
}

- (IBAction)onLeaveButtonTapped:(id)sender
{
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Warning" message:@"Leaving the conversation will erase all your content in the conversation, and you will not see the conversation again." delegate:self cancelButtonTitle:@"Cancel" otherButtonTitles:@"Leave", nil];
    alert.tag = 23;
    [alert show];
}

- (IBAction)onFlagButtonTapped:(id)sender
{
    UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Flag this conversation?" message:@"Do you want to flag this conversation and all it's users for objectionable content?" delegate:self cancelButtonTitle:@"Cancel" otherButtonTitles:@"Flag" , nil];
    alertView.tag = 222;
    [alertView show];
}

- (IBAction)onCancelButtonTapped:(id)sender
{
    //code to dismiss and save changes
}

#pragma mark - AlertView Actions
- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{

    if (buttonIndex != alertView.cancelButtonIndex && alertView.tag == 23)
    {
//        [self leaveChatroom];
    }
//
    if (buttonIndex != alertView.cancelButtonIndex && alertView.tag == 222)
    {
        PFObject *chatroom = [self.messageButReallyRoom valueForKey:PF_MESSAGES_ROOM];
        [chatroom fetchIfNeededInBackgroundWithBlock:^(PFObject *object, NSError *error)
         {
             if (!error)
             {
                 [object incrementKey:PF_CHATROOMS_FLAGCOUNT];
                 [object saveInBackground];
             }
         }];
        [ProgressHUD showSuccess:@"Flagged"];
    }

    if (buttonIndex != alertView.cancelButtonIndex && alertView.tag == 69)
    {
        PFObject *message = self.messageButReallyRoom;
        if ([alertView.title isEqualToString:@"Silence Push Notifications?"]) {
            [message removeObjectForKey:PF_MESSAGES_USER_DONOTDISTURB];
        } else {
            [message setValue:[PFUser currentUser] forKey:PF_MESSAGES_USER_DONOTDISTURB];
        }
        [message saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
            if (succeeded)
            {
                [ProgressHUD showSuccess:@"Saved"];
            }
        }];
    }
}


@end
