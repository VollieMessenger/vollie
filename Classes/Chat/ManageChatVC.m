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
#import "AppDelegate.h"
#import "ManageChatVC.h"
#import "utilities.h"

@interface ManageChatVC () <UITextFieldDelegate>

@property (strong, nonatomic) IBOutlet UITextField *textField;
@property (strong, nonatomic) IBOutlet UIButton *peopleButton;
@property (strong, nonatomic) IBOutlet UIButton *silenceButton;
@property (strong, nonatomic) IBOutlet UIButton *flagButton;
@property (strong, nonatomic) IBOutlet UIButton *cancelButton;
@property (strong, nonatomic) IBOutlet UIButton *leaveButton;

@property NSString *labelString;

@end

@implementation ManageChatVC

- (void)viewDidLoad
{
    [super viewDidLoad];
    [self setUpUserInterface];
    [self setUpTextForLabelsAndButtons];
}

-(void)setUpTextForLabelsAndButtons
{
    self.textField.delegate = self;
    [self.textField setReturnKeyType:UIReturnKeyDone];

    if (self.messageButReallyRoom[@"nickname"])
    {
        NSString *string = [NSString stringWithFormat:@" %@", self.messageButReallyRoom[@"nickname"]];
//        self.textField.placeholder = self.messageButReallyRoom[@"nickname"];
        self.textField.placeholder = string;
    }

    NSArray *peopleArray = self.room[@"userObjects"];
    NSString *peopleString = [NSString stringWithFormat:@"%li People in Chat", peopleArray.count];
    [self.peopleButton setTitle:peopleString forState:UIControlStateNormal];
}

-(void)setUpUserInterface
{
    self.title = @"Manage Chat";
    self.navigationItem.backBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"" style:UIBarButtonItemStylePlain target:nil action:nil];
    [self changeButtonAppearanceWith:self.peopleButton];
    [self changeButtonAppearanceWith:self.cancelButton];
    [self changeButtonAppearanceWith:self.flagButton];
    [self changeButtonAppearanceWith:self.silenceButton];
    [self changeButtonAppearanceWith:self.leaveButton];
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
//
//    if (button == self.peopleButton)
//    {
//        //        button.backgroundColor = [UIColor colorWithRed:.850 green:.850 blue:.850 alpha:1];
////        button.backgroundColor = [UIColor volleyFamousOrange];
//        [button setTitleColor:[UIColor volleyFamousOrange] forState:UIControlStateNormal];
//    }
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
    [self silenceOrUnsilence];
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
     [self.navigationController popToRootViewControllerAnimated:1];
//    [self.navigationController dismissViewControllerAnimated:YES completion:nil];
    [self saveNickname];
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    [self saveNickname];
    return YES;
}

#pragma mark - AlertView Actions
- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{

    if (buttonIndex != alertView.cancelButtonIndex && alertView.tag == 23)
    {
        [self leaveChatroom];
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

#pragma mark "Complicated Methods"

- (void) leaveChatroom
{
    //Just delete my stuff, and get me out of here.
    [ProgressHUD show:@"Leaving..." Interaction:0];

    PFQuery *query = [PFQuery queryWithClassName:PF_CHAT_CLASS_NAME];
    [query whereKey:PF_CHAT_ROOM equalTo:self.room];
    [query whereKey:PF_CHAT_USER equalTo:[PFUser currentUser]];
    [query findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error)
     {
         if (!error)
         {
             for (PFObject *object in objects)
             {
                 [object deleteInBackground];
             }

             PFQuery *query2 = [PFQuery queryWithClassName:PF_MESSAGES_CLASS_NAME];
             [query2 whereKey:PF_CHAT_ROOM equalTo:self.room];
             [query2 whereKey:PF_CHAT_USER equalTo:[PFUser currentUser]];

             [query2 findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error)
              {
                  if (!error)
                  {
                      if (objects.count != 1) NSLog(@"DUPLICATE MESSAGE FOR SOME REASON");

                      for (PFObject *object in objects)
                      {
                          [object deleteInBackgroundWithBlock:^(BOOL succeeded, NSError *error)
                           {
                               if (succeeded)
                               {
                                   //REMOVE USER FROM PFRELATION
                                   PFRelation *userss = [self.room relationForKey:PF_CHATROOMS_USERS];
                                   [userss removeObject:[PFUser currentUser]];
                                   [[_room valueForKey:PF_CHATROOMS_USEROBJECTS] removeObject:[PFUser currentUser].objectId];

                                   [[userss query] countObjectsInBackgroundWithBlock:^(int number, NSError *error) {
                                       if (!error) {
                                           if (number == 0) {

                                               [self.room deleteInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
                                                   if (succeeded)
                                                   {
                                                       PostNotification(NOTIFICATION_ENABLESCROLLVIEW);
                                                   }
                                               }];

                                           }
                                           else
                                           {

                                               [self.room saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
                                                   if (succeeded) {
                                                       PostNotification(NOTIFICATION_ENABLESCROLLVIEW);
                                                   }

                                               }];
                                           }
                                       }
                                   }];

                                   PostNotification(NOTIFICATION_LEAVE_CHATROOM);
                                   [ProgressHUD showSuccess:@"Deleted All Content"];
                                   //Refresh inbox, popchatview.
//                                   [self actionDimiss];
                                   PostNotification(NOTIFICATION_REFRESH_INBOX);
                                   [self.navigationController popToRootViewControllerAnimated:1];

                               }
                           }];
                      }
                  }}];
         } else {
             [ProgressHUD showError:@"Network Error"];
         }
     }];
}

- (void) saveNickname
{
    PFObject *message = self.messageButReallyRoom;
    if (self.textField.isFirstResponder) {
        if (self.textField.hasText)
        {
            [message setValue:self.textField.text forKey:PF_MESSAGES_NICKNAME];
        }
        else
        {
            [message removeObjectForKey:PF_MESSAGES_NICKNAME];
        }
        [message saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
            if (succeeded)
            {
                PostNotification(NOTIFICATION_REFRESH_INBOX);
                [ProgressHUD showSuccess:@"Saved Nickname"];
                [self.textField resignFirstResponder];
            }
            else
            {
                [ProgressHUD showError:@"Network Error"];
            }
        }];
    }
}

-(void)silenceOrUnsilence
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


@end
