//
//  SelectChatroomView.m
//  Volley
//
//  Created by benjaminhallock@gmail.com on 1/12/15.
//  Copyright (c) 2015 KZ. All rights reserved.
//

#import "DidFavoriteVIew.h"

#import <Parse/Parse.h>

#import "AppConstant.h"

#import "ProgressHUD.h"

#import "UIColor+JSQMessages.h"

#import "AppDelegate.h"

#import "utilities.h"

#import "messages.h"

#import "JSQMessagesKeyboardController.h"

#import "pushnotification.h"

#import "ChatView.h"

#import "CreateChatroomView.h"

#import "MessagesCellDot.h"

@interface DidFavoriteView ()
<UITextViewDelegate, UITableViewDataSource, UITableViewDelegate, UIAlertViewDelegate>

@property UITapGestureRecognizer *tap;

@property IBOutlet UITableView *tableView;

@property IBOutlet UIButton *composeButton;

@property NSMutableArray *messages;

@property PFObject *selectedRoom;

@property PFObject *selectedSet;

@property PFObject *selectedMessage;

@property NSString *selectedText;//For next view title;

@property NSMutableArray *arrayOfReusableCells;

@property BOOL didViewJustLoad;

@property NSMutableArray *savedPhotoObjects;

@property int randomNumber;

@property (strong, nonatomic) JSQMessagesKeyboardController *keyboardController;

@property BOOL justCreatedChatroom;

@property BOOL didSendPictures;

@property int countDownToPhotoRefresh;

@property PFObject *selectAlbum;

@property IBOutlet UIButton *buttonSave;

@end

@implementation DidFavoriteView

@synthesize tap;

- (IBAction)didSelectCompose:(id)sender
{
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"New Album" message:0 delegate:self cancelButtonTitle:@"Cancel" otherButtonTitles:@"Save", nil];
    alert.alertViewStyle = UIAlertViewStylePlainTextInput;
    [alert textFieldAtIndex:0].placeholder = @"Name...";
    [alert show];
}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (buttonIndex != alertView.cancelButtonIndex && [alertView textFieldAtIndex:0].hasText) {
        PFObject *album = [PFObject objectWithClassName:PF_ALBUMS_CLASS_NAME];
        [album setValue:[[alertView textFieldAtIndex:0].text capitalizedString] forKey:PF_ALBUMS_NICKNAME];
        [album setValue:[PFUser currentUser] forKey:PF_ALBUMS_USER];
        [album saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
            if (succeeded) {
                [self.messages addObject:album];

                NSIndexPath *indexpath = [NSIndexPath indexPathForRow:self.messages.count - 1 inSection:0];
                [self.tableView insertRowsAtIndexPaths:@[indexpath] withRowAnimation:UITableViewRowAnimationAutomatic];

                [self updateEmptyView];
            }
        }];
    }
    else
    {
        [alertView dismissWithClickedButtonIndex:0 animated:1];
    }
}

- (IBAction)saveAlbum:(id)sender
{
    //Add Set to selected album relation.
    if (!self.selectAlbum){
        [ProgressHUD showError:@"No Album Selected"];
    }
    else
    {
        if (_isMovingAlbum){
            //Finding favorite object to move album.
#warning COULD PASS FAVORITE OBJECT TRHOUGH THE CUSTOM CHAT VIEW.
            PFQuery *query = [PFQuery queryWithClassName:PF_FAVORITES_CLASS_NAME];
            [query whereKey:PF_FAVORITES_SET equalTo:self.set];
            [query whereKey:PF_FAVORITES_ALBUM equalTo:self.album];
            [query findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error)
            {
                if (!error)
                {
                    //Delete all duplicates if they exist (they shouldn't), move one to new album, change last set of album to nil, and set new album set to this set.
                    BOOL didFavorite = false;
                    for (PFObject *favorite in objects)
                    {
                        if (!didFavorite)
                        {
                            didFavorite = YES;

                            [favorite setValue:self.selectAlbum forKey:PF_FAVORITES_ALBUM];
                            [self.selectAlbum setValue:[favorite valueForKey:PF_FAVORITES_SET] forKey:PF_ALBUMS_SET];
//                            [self.album removeObjectForKey:PF_ALBUMS_SET];

                            [favorite saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
                                if (succeeded)
                                {
                                [self.selectAlbum saveInBackground];

//                              [self.album saveInBackground];
                                    NSLog(@"1");
                                    PostNotification(NOTIFICATION_REFRESH_FAVORITES);

//                                    PostNotification(NOTIFICATION_REFRESH_ALBUMS);
                                    
                                [self actionDismiss];

                                [ProgressHUD showSuccess:@"Moved"];

                                }
                                }];
                        } else {
                            [favorite deleteInBackground];
                        }
                    }
                } else {
                    [ProgressHUD showError:@"Network Error"];
                }
            }];

        }
        else // SAVING NOT MOVING/////////////////////////////////////////////////////
        {
            //Checking for duplicates before saving.

            PFQuery *query = [PFQuery queryWithClassName:PF_FAVORITES_CLASS_NAME];
            [query whereKey:PF_FAVORITES_ALBUM equalTo:self.selectAlbum];
            [query whereKey:PF_FAVORITES_SET equalTo:self.set];
            [query findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
                if (!error)
                {
                    if (objects.count == 0)
                    {
                        //No favorite found, creating an object.
                        PFObject *favorite = [PFObject objectWithClassName:PF_FAVORITES_CLASS_NAME];
                        [favorite setObject:self.selectAlbum forKey:PF_FAVORITES_ALBUM];
                        [favorite setObject:self.set forKey:PF_FAVORITES_SET];
                        [favorite setObject:[PFUser currentUser] forKey:PF_FAVORITES_USER];
                        [favorite saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error){
                            if (succeeded)
                            {
                                [self.selectAlbum setObject:self.set forKey:PF_ALBUMS_SET];
                                [self.selectAlbum saveInBackground];

//                                PostNotification(NOTIFICATION_REFRESH_ALBUMS);

                                [self dismissViewControllerAnimated:1 completion:0];

                                [ProgressHUD showSuccess:@"Saved"];
                            } else {
                                [ProgressHUD showError:@"Network Error"];
                            }
                            NSLog(@"2");
//                            PostNotification(NOTIFICATION_REFRESH_FAVORITES);
                        }];
                    }
                    else //Duplicate found, pretending to save.
                    {
                        [self dismissViewControllerAnimated:1 completion:0];
                        [ProgressHUD showSuccess:@"Saved"];
                    }
                } else {
                        [ProgressHUD showError:@"Network Error"];
                }
            }];
        }
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    MessagesCellDot *cell = [tableView dequeueReusableCellWithIdentifier:@"MessagesCell"];
    if (!cell) cell = [[MessagesCellDot alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"MessagesCell"];

    [self.arrayOfReusableCells addObject:cell];
    [cell format];

    UIColor *green = [UIColor volleyFamousGreen];
    cell.labelDescription.textColor = green;
    cell.imageUser.layer.borderColor = green.CGColor;

    cell.labelInitials.hidden = YES;

    PFObject *album = [self.messages objectAtIndex:indexPath.row];

    cell.labelLastMessage.text = @"";
    cell.labelDescription.text = album[PF_ALBUMS_NICKNAME];

    if ([album valueForKey:PF_ALBUMS_SET])
    {
    PFObject *set =[album valueForKey:PF_ALBUMS_SET];
    PFUser *user = [set objectForKey:PF_SET_USER];

    [user fetchInBackgroundWithBlock:^(PFObject *object, NSError *error) {
        if (!error) {
            NSString *nam = [object valueForKey:PF_USER_FULLNAME];
            NSMutableArray *array = [NSMutableArray arrayWithArray:[nam componentsSeparatedByString:@" "]];
            [array removeObject:@" "];
            NSString *first = array.firstObject;
            NSString *last = array.lastObject;
            first = [first stringByPaddingToLength:1 withString:nam startingAtIndex:0];
            last = [last stringByPaddingToLength:1 withString:nam startingAtIndex:0];
            nam = [first stringByAppendingString:last];
            cell.labelInitials.text = nam;
        }
    }];

    PFObject *picture = [set valueForKey:PF_SET_LASTPICTURE];
    if (picture){
        [picture fetchIfNeededInBackgroundWithBlock:^(PFObject *object, NSError *error)
            {
            if (!error)
            {
                PFFile *file = [picture valueForKey:PF_PICTURES_THUMBNAIL];
                cell.imageUser.file = file;
                [cell.imageUser loadInBackground:^(UIImage *image, NSError *error) {
                    if (!error) {
                        cell.labelInitials.hidden = NO;
                    }
                }];

    //            [file getDataInBackgroundWithBlock:^(NSData *data, NSError *error) {
    //                if (!error) {
    //                    cell.imageUser.image = [UIImage imageWithData:data];
    //                    cell.labelInitials.hidden = NO;
    //                }
    //            }];
                }
            }];
        }
    }

    return cell;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    UIView *view = [[UIView alloc] initWithFrame:CGRectMake(0, 0, tableView.frame.size.width,75)];
    view.backgroundColor = [UIColor colorWithRed:239/255.0f green:239/255.0f blue:244/255.0f alpha:1];
    UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(0, 50, tableView.frame.size.width, 25)];
    label.text = @"   MY ALBUMS";
    label.backgroundColor = [UIColor clearColor];
    label.font = [UIFont fontWithName:@"Arial Rounded MT Bold" size:14];
    label.textColor = [UIColor lightGrayColor];
    [view addSubview:label];
    UIView *view2 = [[UIView alloc] initWithFrame:CGRectMake(0, 0, tableView.frame.size.width, 50)];
    //  [self.composeButton setFrame:CGRectMake(0, 0, self.tableView.frame.size.width, 40)];
    [view2 addSubview:self.composeButton];
    [view addSubview:view2];
    return view;
}


- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.messages.count;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:0];
    MessagesCellDot *cell = [tableView cellForRowAtIndexPath: indexPath];
    PFObject *album = [self.messages objectAtIndex:indexPath.row];

    for (MessagesCellDot *cell in self.arrayOfReusableCells){
        cell.backgroundColor = [UIColor whiteColor];
        cell.labelDescription.textColor = [UIColor blackColor];
        cell.labelLastMessage.textColor = [UIColor lightGrayColor];
        cell.imageUser.layer.borderColor = [UIColor whiteColor].CGColor;
    }
    
    if (cell && album)
    {
        if (self.buttonSave.isHidden){
            self.buttonSave.hidden = NO;
            self.buttonSave.alpha = 0;
            [UIView animateWithDuration:.3f animations:^{
                [UIView setAnimationCurve:UIViewAnimationCurveEaseInOut];
                self.buttonSave.alpha = 1;
            }];
        }

        self.selectAlbum = album;
        self.selectedText = cell.labelDescription.text;
        cell.imageUser.layer.borderColor = [UIColor whiteColor].CGColor;
        cell.labelInitials.backgroundColor = [UIColor volleyFamousGreen];
        cell.backgroundColor = [UIColor volleyFamousOrange];
        cell.labelDescription.textColor = [UIColor whiteColor];
        cell.labelLastMessage.textColor = [UIColor whiteColor];
    }
}

-(void)textFieldDidBeginEditing:(UITextField *)textField {

}

-(BOOL)textFieldShouldReturn:(UITextField *)textField {
    [textField resignFirstResponder];
    return YES;
}

-(void)actionDismiss {
    [self dismissViewControllerAnimated:1 completion:0];
}

-(void)viewDidDisappear:(BOOL)animated
{
    [(AppDelegate *)[[UIApplication sharedApplication] delegate] scrollView].scrollEnabled = NO;
}

- (void)viewDidLoad
{
    [super viewDidLoad];

    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(actionDismiss) name:NOTIFICATION_CLICKED_PUSH object:0];

    [self.tableView registerNib:[UINib nibWithNibName:@"MessagesCellDot" bundle:0] forCellReuseIdentifier:@"MessagesCell"];

    _composeButton.backgroundColor = [UIColor whiteColor];


    UIBarButtonItem *close =  [[UIBarButtonItem alloc] initWithTitle:@"Close " style:UIBarButtonItemStylePlain target:self
                                                              action:@selector(actionDismiss)];
    close.image = [UIImage imageNamed:ASSETS_CLOSE];
    self.navigationItem.rightBarButtonItem = close;

    _composeButton.imageView.tintColor = [UIColor volleyFamousGreen];
    _composeButton.imageView.image = [_composeButton.imageView.image imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
    _composeButton.titleLabel.textColor = [UIColor volleyFamousGreen];
    _composeButton.tintColor = [UIColor volleyFamousGreen];

    self.navigationController.navigationBarHidden = 0;

    self.view.backgroundColor = [UIColor whiteColor];

    self.messages = [NSMutableArray new];

    [self loadMessages];

    UIBarButtonItem *backButton = [[UIBarButtonItem alloc]
                                   initWithTitle: @""
                                   style: UIBarButtonItemStylePlain
                                   target: nil action: nil];
    [self.navigationItem setBackBarButtonItem: backButton];

    self.didViewJustLoad = YES;


    self.arrayOfReusableCells = [NSMutableArray new];

}

- (BOOL)textViewShouldBeginEditing:(UITextView *)textView
{
    [self.view addGestureRecognizer:tap];
    return YES;
}

- (void)textViewDidEndEditing:(UITextView *)textView
{
    [self.view removeGestureRecognizer:tap];
}

-(void)textViewDidChangeSelection:(UITextView *)textView {
    if ([textView.text containsString:@"\n"]) {
        [textView deleteBackward];
        [textView resignFirstResponder];
    }
}


- (void)updateEmptyView
{
    if (self.messages.count == 0)
    {
        UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(0, 80, self.view.frame.size.width, 70)];
        label.text = @"No albums";
        label.textAlignment = NSTextAlignmentCenter;
        label.textColor = [UIColor lightGrayColor];
        [self.tableView addSubview:label];
    }
    else
    {
        for (UILabel *label in self.tableView.subviews) {
            if ([label isKindOfClass:[UILabel class]]) {
                [label removeFromSuperview];
            }
        }
    }
}

- (void)loadMessages
// LOAD MESSAGES FROM INBOX INSTEAD.
{
    if ([PFUser currentUser])
    {
        PFQuery *query = [PFQuery queryWithClassName:PF_ALBUMS_CLASS_NAME];
        [query whereKey:PF_ALBUMS_USER equalTo:[PFUser currentUser]];
        [query includeKey:PF_ALBUMS_SET];
        [query includeKey:PF_ALBUMS_USER];
        if (_isMovingAlbum) {
            [query whereKey:@"objectId" notEqualTo:self.album.objectId];
        }
        [query orderByAscending:PF_ALBUMS_NICKNAME];
        [query setCachePolicy:kPFCachePolicyCacheThenNetwork];
        [query findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
            if (!error) {
                _messages = [NSMutableArray arrayWithArray:objects];
                [self updateEmptyView];
                [self.tableView reloadData];
            }
        }];
        
    }
}

@end
