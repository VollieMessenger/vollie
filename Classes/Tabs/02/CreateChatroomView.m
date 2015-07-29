
#import <Parse/Parse.h>

#import "ProgressHUD.h"

#import "AppConstant.h"

#import "messages.h"

#import "utilities.h"

#import "AppDelegate.h"

#import "CreateChatroomView.h"

#import "CreateChatroomView2.h"

#import "ChatView.h"

#import <AddressBook/AddressBook.h>

#import <AddressBookUI/AddressBookUI.h>

#import "pushnotification.h"

#import "MomentsVC.h"

@interface CreateChatroomView () <CreateChatroom2Delegate,MFMailComposeViewControllerDelegate,MFMessageComposeViewControllerDelegate>
{
    NSMutableArray *users;

    NSMutableArray *usersObjectIds;

    NSMutableDictionary *lettersForWords;

    NSArray *sortedKeys;

    UITextField *labelForContactsIndicator;

    int x;

    NSString *peopleWaiting;
}
@property (strong, nonatomic) IBOutlet UIView *viewHeader;

@property (strong, nonatomic) UISearchBar *searchBar;

@property (strong, nonatomic) IBOutlet UITextField *searchTextField;

@property (strong, nonatomic) IBOutlet UIButton *searchCloseButton;

@property NSMutableArray *searchMessages;

@property (strong, nonatomic) NSMutableArray *arrayOfSelectedUsers;

@property (strong, nonatomic) NSMutableArray *arrayofSelectedPhoneNumbers;

@property UITapGestureRecognizer *tap;

@property NSMutableArray *numbers;

@property UITableViewCell *selectedCell;

@property BOOL isSearching;

@property (strong, nonatomic)  NSMutableDictionary *arrayOfNamesAndNumbers;

@property IBOutlet UIButton *buttonSend;

@property BOOL isNotGoingBack;

@property IBOutlet UIButton *buttonSendArrow;

@end

@implementation CreateChatroomView

@synthesize delegate, arrayOfNamesAndNumbers, numbers;

@synthesize viewHeader, searchBar, tap;


//You just hit send in the contacts view.
- (void)sendBackArrayOfPhoneNumbers:(NSMutableArray *)array andDidPressSend:(BOOL)send andText:(NSString *)text
{
    _arrayofSelectedPhoneNumbers = array;
    if (send) {
        [self sendWithTextMessage];
    }
}

- (IBAction)didPressSendButton:(UIButton *)sender
{
    self.buttonSend.userInteractionEnabled = NO;
    [self preSendCheck];
}

- (void)actionContacts
{
    CreateChatroomView2 *contacts = [[CreateChatroomView2 alloc] init];
    contacts.delegate = self;
    _isNotGoingBack = YES;
    contacts.isTherePicturesToSend = _isTherePicturesToSend;
    contacts.arrayofSelectedPhoneNumbers = _arrayofSelectedPhoneNumbers;
    contacts.arrayOfNamesAndNumbers = arrayOfNamesAndNumbers;
    [self showViewController:contacts sender:self];
}

-(void)viewDidAppear:(BOOL)animated
{
    [self togglePhoneNumbersCountIndicator];
}

-(void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];

    [self closeSearch:0];
    [self setNavigationBarColor];


    if (!_isNotGoingBack && !_isTherePicturesToSend)
    {
        [self setNavigationBarColor];
    }
    else
    {
        _isNotGoingBack = NO;
        [self setNavigationBarColor];
    }

    [self togglePhoneNumbersCountIndicator];
}

- (void)viewDidLoad
{
    self.buttonSendArrow.frame = CGRectMake(self.view.frame.size.width/2 - 12, self.view.frame.size.height - 30, 25, 25);

    self.tableView.sectionIndexColor = [UIColor lightGrayColor];

//    [self.navigationController.navigationBar setTintColor:[UIColor volleyFamousGreen]];
    [self.navigationController.navigationBar setBarTintColor:[UIColor colorWithWhite:.98 alpha:1]];
    [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleDefault animated:1];

    self.navigationController.navigationBar.titleTextAttributes =  @{
                                                                     NSForegroundColorAttributeName: [UIColor volleyFamousGreen],
                                                                     NSFontAttributeName: [UIFont fontWithName:@"Helvetica Neue" size:20.0f],
                                                                     NSShadowAttributeName:[NSShadow new]
                                                                     };

    [super viewDidLoad];
    [self.tableView setRowHeight:55];
    _searchCloseButton.hidden = YES;

    UIBarButtonItem *item = [[UIBarButtonItem alloc] initWithTitle:@""
                                                             style:UIBarButtonItemStyleBordered target:self action:@selector(actionContacts)];
    item.image = [UIImage imageNamed:ASSETS_NEW_PEOPLE];
    self.navigationItem.rightBarButtonItem = item;

    UIView *spacerView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 10, 10)];
    [_searchTextField setLeftViewMode:UITextFieldViewModeAlways];
    [_searchTextField setLeftView:spacerView];

#warning FETCHING CONTACTS
    [self getAllContacts];

    self.view.backgroundColor = [UIColor whiteColor];
    self.tableView.backgroundColor = [UIColor whiteColor];

    self.title = @"New Message";
    self.tableView.tableHeaderView = viewHeader;

    UIBarButtonItem *backButton = [[UIBarButtonItem alloc]
                                   initWithTitle: @"Back"
                                   style: UIBarButtonItemStyleBordered
                                   target: nil action: nil];
    [self.navigationItem setBackBarButtonItem: backButton];

    self.searchBar.placeholder = @"Search...";


    UIButton *button = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, 30, 30)];

    users = [[NSMutableArray alloc] init];
    usersObjectIds = [NSMutableArray new];
    _searchMessages = [NSMutableArray new];
    self.arrayOfSelectedUsers = [NSMutableArray new];
    _arrayofSelectedPhoneNumbers = [NSMutableArray new];
    [_arrayOfSelectedUsers addObject:[PFUser currentUser]];

    tap = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(didTap:)];
    tap.delegate = self;
}


- (void) didTap:(UITapGestureRecognizer *)tap
{

}


- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    [textField resignFirstResponder];
    return YES;
}

- (void)textViewDidChange:(UITextView *)textView
{
    if ([textView.text containsString:@"\n"]) {
        [textView resignFirstResponder];
        [textView deleteBackward];
        [textView scrollsToTop];
        [self.view removeGestureRecognizer:tap];
    } else {
        [self searchUsers:textView.text];
    }
}

- (void)textViewDidEndEditing:(UITextView *)textView
{
    [[UIApplication sharedApplication] setStatusBarHidden:0 withAnimation:UIStatusBarAnimationSlide];
    [self.view removeGestureRecognizer:tap];
}

- (BOOL)textViewShouldBeginEditing:(UITextView *)textView
{
    [self.view addGestureRecognizer:tap];
    return YES;
}

- (void) preSendCheck
{
    if (_arrayofSelectedPhoneNumbers.count > 0)
    {
        x = (int)_arrayofSelectedPhoneNumbers.count;

        //Looking for users in chatroom that already exist, so we don't make any new users.
        PFQuery *query = [PFUser query];
        [query whereKey:@"isVerified" equalTo:@NO];
        [query whereKey:PF_USER_USERNAME containedIn:_arrayofSelectedPhoneNumbers];
        [query findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
            if (!error) {

                NSMutableArray *arrayOfNumbersCopy = [NSMutableArray arrayWithArray:_arrayofSelectedPhoneNumbers];

                // If users were found, add them to selectedUsers;
                for (PFUser *user in objects)
                {
                    NSString *phoneNumber = [user valueForKey:PF_USER_USERNAME];
                    [arrayOfNumbersCopy removeObject:phoneNumber];
                    [_arrayOfSelectedUsers addObject:user];
                    x--;
                    //If all the users were found with phonenumbers, we can send. Otherwise create more phone numbers;
                    if (x == 0) {
                        [self actionSend];
                        return;
                    }
                }

                //For the rest of the phone numbers, create an account.
                for (NSString *phoneNumber in arrayOfNumbersCopy) {
                    [self saveNewUserWithPhoneNumber:phoneNumber];
                }
            } else {
            }
            return;
        }];
        [self sendWithTextMessage];

    } else {// No phone numbers

        [self actionSend];
    }
}

- (void) saveNewUserWithPhoneNumber:(NSString *)phoneNumber
{
    //    NSURL *url = [NSURL URLWithString: [NSString stringWithFormat:@"http://%@:%@@https://api.parse.com/1/users", @"", @""]];
    NSURL *url = [NSURL URLWithString:@"https://api.parse.com/1/users"];
#warning WHAT DOES THIS STRING LOOK LIKE.
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:url];
    [request setURL:url];
    [request setHTTPMethod:@"POST"];
    [request setValue:@"application/json" forHTTPHeaderField:@"Content-Type"];
    [request setValue:@"8pudwEbafadgRNuy7DOBKBb2ObVH1dUzDZ8SuRtQ" forHTTPHeaderField:@"X-Parse-REST-API-Key"];
    [request setValue:@"elq3rKjkGscvsbeeb21QP0GkuMfuEe3Zb8f3bvcq" forHTTPHeaderField:@"X-Parse-Application-Id"];

    NSDictionary *dict = @{@"username":phoneNumber,@"password":phoneNumber, PF_USER_ISVERIFIED: @NO};
    NSError *error;
    NSData *postBody = [NSJSONSerialization dataWithJSONObject:dict options:NSJSONWritingPrettyPrinted error:&error];

    [request setHTTPBody:postBody];

    // Send request to Parse and parse returned data
    [NSURLConnection sendAsynchronousRequest:request
                                       queue:[NSOperationQueue mainQueue]
                           completionHandler:^(NSURLResponse *response, NSData *data, NSError *connectionError) {
                               if (!connectionError) {
                                   NSDictionary *responseDictionary = [NSJSONSerialization JSONObjectWithData:data options:0 error:nil];


                                   NSString *objectId = [responseDictionary valueForKey:@"objectId"];

                                   [_arrayOfSelectedUsers addObject:[PFUser objectWithoutDataWithObjectId:objectId]];
                                   x--;
                                   //If we finished all the phone numbers, create the chatroom;
                                   if (x == 0){
                                       [self actionSend];
                                   }

                               } else {
                               }
                           }];
}

-(void) setNavigationBarColor
{
    [self.navigationController.navigationBar setTintColor:[UIColor whiteColor]];
    [self.navigationController.navigationBar setBarTintColor:[UIColor volleyFamousGreen]];
//    [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleLightContent animated:1];
    [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleDefault animated:1];

    self.navigationController.navigationBar.titleTextAttributes =  @{
                                                                     NSForegroundColorAttributeName: [UIColor whiteColor],
                                                                     NSFontAttributeName: [UIFont fontWithName:@"Helvetica Neue" size:20.0f],
                                                                     NSShadowAttributeName:[NSShadow new]
                                                                     };
}

- (void)sendWithTextMessage
{
    //Includes current user already.
    if (self.invite) {
        if ([MFMessageComposeViewController canSendText]) {
            MFMessageComposeViewController * msgComposer = [[MFMessageComposeViewController alloc] init];
            msgComposer.recipients = self.arrayOfSelectedUsers;
            msgComposer.body = [NSString stringWithFormat:@"You should download Vollie so we can talk to each other! Download it from the App Store here: %@.",[NSURL URLWithString:@"https://appsto.re/us/D13q5.i"]];
            msgComposer.messageComposeDelegate = self;
            [self presentViewController:msgComposer animated:YES completion:nil];
            return;
        }
    }
    
    if (_arrayOfSelectedUsers.count < 2)
    {
        [ProgressHUD showError:@"Vollie User(s) Required"];
        self.buttonSend.userInteractionEnabled = NO;
        return;
    }
    else if (_arrayofSelectedPhoneNumbers.count == 0)
    {
        //No phone numbers
        [self actionSend];
        return;
    }

    //Sending Text if phone numbers selected
    peopleWaiting = @"";

    for (PFUser *user in _arrayOfSelectedUsers)
    {
        if (user != [PFUser currentUser])
        {
            NSString *userName = [user valueForKey:PF_USER_FULLNAME];
            if (userName.length && userName)
            {
                peopleWaiting = [peopleWaiting stringByAppendingString:userName];
                peopleWaiting = [peopleWaiting stringByAppendingString:@", "];
            }
        }
    }

    if (peopleWaiting.length > 2)
    {
        peopleWaiting = [peopleWaiting substringToIndex:peopleWaiting.length - 2];
        peopleWaiting = [NSString stringWithFormat:@"%@ and I are waiting for you to Vollie www.volleymessenger.com", peopleWaiting];
    }


    if (_isTherePicturesToSend)
    {
        [[NSNotificationCenter defaultCenter] postNotificationName:NOTIFICATION_APP_MAIL_SEND object:self userInfo:@{@"string": peopleWaiting, @"people": _arrayofSelectedPhoneNumbers}];
    }

    [self preSendCheck];
}

- (void)messageComposeViewController:(MFMessageComposeViewController *)controller didFinishWithResult:(MessageComposeResult)result {
    [controller dismissViewControllerAnimated:YES completion:nil];
}

- (IBAction)actionSend
{
    if (_arrayOfSelectedUsers.count > 0)
    {
        //Create chatroom object
        if (_isTherePicturesToSend)
        {
        [ProgressHUD show:@"Sending..." Interaction:0];
        }

        //New Chatroom
        PFObject *chatroom = [PFObject objectWithClassName:PF_CHATROOMS_CLASS_NAME];
        PFRelation *usersInRelation = [chatroom relationForKey:PF_CHATROOMS_USERS];
        NSMutableArray *arrayOfUserIds = [NSMutableArray new];

        //Create list of names in chatroom.
        __block NSString *stringOfNames = @"";
        __block NSString *stringWithoutUser = @"";
        __block int count = (int)_arrayOfSelectedUsers.count;
        for (PFUser *user  in _arrayOfSelectedUsers)
        {
            
#warning MAY BE TOO SLOW WITHOUT BLOCK
        [user fetchInBackgroundWithBlock:^(PFObject *object, NSError *error)
            {
            if (!error)
            {
                if (object == [PFUser currentUser])
                {
                    [usersInRelation addObject:[PFUser currentUser]];
                    [arrayOfUserIds addObject:[PFUser currentUser].objectId];
                }
                else
                {
                    [usersInRelation addObject:object];
                    [arrayOfUserIds addObject:object.objectId];
                }

            NSString *fullName = [user objectForKey:PF_USER_FULLNAME];
            NSString *phoneNumber = [user valueForKey:PF_USER_USERNAME];

            if (fullName.length && fullName)
            {
                stringOfNames = [stringOfNames stringByAppendingString:[NSString stringWithFormat:@"%@, ", fullName]];

                if (object != [PFUser currentUser])
                {
                    stringWithoutUser = [stringWithoutUser stringByAppendingString:[NSString stringWithFormat:@"%@, ", fullName]];
                }
            }
            else
            {
                stringOfNames = [stringOfNames stringByAppendingString:[NSString stringWithFormat:@"%@, ", phoneNumber]];

                if (object != [PFUser currentUser])
                {
                    stringWithoutUser = [@"*" stringByAppendingString:stringWithoutUser];
                }
            }
                count--;
                if (count == 0)
                {
                    if (stringOfNames.length > 2 && stringWithoutUser.length > 2)
                    {
                        stringOfNames = [stringOfNames substringToIndex:stringOfNames.length - 2];
                        stringWithoutUser = [stringWithoutUser substringToIndex:stringWithoutUser.length - 2];
                    }

                    [chatroom setValue:stringOfNames forKey:PF_CHATROOMS_NAME];

                    [chatroom setValue:arrayOfUserIds forKey:PF_CHATROOMS_USEROBJECTS];

                    [chatroom setValue:@(0) forKey:PF_CHATROOMS_ROOMNUMBER];

                    //NEXT
                    [self findChatroomAndSend:chatroom andUserIds:arrayOfUserIds andString:stringWithoutUser];
                }
        }
        else
        {
        }
        }];

        }//end for loop

}}


//AFTER ACTIONSEND
- (void)findChatroomAndSend:(PFObject *)chatroom andUserIds:(NSArray *)arrayOfUserIds andString:(NSString *)stringWithoutUser
{
    PFQuery *query2 = [PFQuery queryWithClassName:PF_CHATROOMS_CLASS_NAME];


    [query2 whereKey:PF_CHATROOMS_USEROBJECTS containsAllObjectsInArray:arrayOfUserIds];
    
#warning IF YOU LEAVE A CHATROOM, YOUR NAME IS NO LONGER ON THAT LIST, SO A NEW CHATROOM WITH THE SAME PEOPLE WILL BE FRESH.

    [query2 findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error)
     {
         if (!error)
         {
             if (objects.count > 0)
             {
                 //Because all the people could be contained in the array, but there could be more, we must check if the array is identical, i don't believe order matters in this case.
                 // FOUND CHATROOM
                 for (PFObject *chatroommm in objects)
                 {
                     NSArray *arrayOfIds = [chatroommm objectForKey:PF_CHATROOMS_USEROBJECTS];

#warning CURRENT USER IS NOT CONTAINED IN ARRAYOFUSERIDS, BUT AFTERWARDS IT SAVES FINE

                     //Since arrays are ordered, we use this helper method to check the un-ordered comparison of the array.
                     if ([self isSameValues:arrayOfIds and:arrayOfUserIds])
                     {
                         //FOUND A IDENTICAL CHATROOM
                         [chatroom deleteInBackground];//NEEDED?

#warning UNHIDE ALL MESSAGES RELATED TO THIS CHATROOM
                         if (_isTherePicturesToSend)
                         {
                             [delegate sendObjectsWithSelectedChatroom:chatroommm andText:stringWithoutUser andComment:0];
                         }
                         else
                         {
                             [self actionSaveAndOpen:chatroommm andText:stringWithoutUser andComment:0];
                             //Find message and open it.
                         }
                         return;
                         break;
                     }
                 }

                 //Chat didn't exist, even with the extra people checker above.
                 [chatroom saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error)
                  {
                     if (succeeded && !error)
                     {
                         //Create message so each user gets an alert.
                         if (_isTherePicturesToSend)
                         {
                             CreateMessageItem(chatroom, _arrayOfSelectedUsers);
                             [delegate sendObjectsWithSelectedChatroom:chatroom andText:stringWithoutUser andComment:0];
                         }
                         else
                         {
                             CreateMessageItem(chatroom, _arrayOfSelectedUsers);
                             [self actionSaveAndOpen:chatroom andText:stringWithoutUser andComment:0];
                             //                                Open new chatroom.
                         }
                     }
                 }];

             }
             else if (objects.count == 0)
             {

                 //No chatroom contained all those Users listed, creating such chatroom.
                 [chatroom saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
                     if (succeeded && !error) {
                         //Create message so each user gets an alert.
                         if (_isTherePicturesToSend)
                         {
                             CreateMessageItem(chatroom, _arrayOfSelectedUsers);
                             [delegate sendObjectsWithSelectedChatroom:chatroom andText:stringWithoutUser andComment:0];
                         }
                         else
                         {
                             CreateMessageItem(chatroom, _arrayOfSelectedUsers);
                             [self actionSaveAndOpen:chatroom andText:stringWithoutUser andComment:0];
                         }
                     }}];
             }
         } else {
             [ProgressHUD showError:@"Network Error"];
         }
     }];
}

- (BOOL)isSameValues:(NSArray*)array1 and:(NSArray*)array2
{
    NSCountedSet *set1 = [NSCountedSet setWithArray:array1];
    NSCountedSet *set2 = [NSCountedSet setWithArray:array2];
    return [set1 isEqualToSet:set2];
}

- (IBAction)actionSaveAndOpen:(PFObject *)chatroom andText:(NSString *)text andComment:(NSString *)comment
{
    //Save the photos, dismiss the view, open the chatview, slideRight in background, refresh when all is saved and done.x
    if (chatroom)
    {
        PostNotification(NOTIFICATION_REFRESH_INBOX);
        [self openChatroomWithRoom:chatroom title:text comment:self.sendingMessage];
    }
    else
    {
        self.buttonSend.userInteractionEnabled = YES;
        [ProgressHUD showError:@"No Chatroom Selected"];
    }
}

-(void)openChatroomWithRoom:(PFObject *)chatroom title:(NSString *)title comment:(NSString *)comment
{
    NSLog(@"sending message %@",self.sendingMessage);
    [ProgressHUD dismiss];
    
    PFObject *set = [PFObject objectWithClassName:PF_SET_CLASS_NAME];
    [set setValue:chatroom forKey:PF_SET_ROOM];
    [set setValue:[PFUser currentUser] forKey:PF_SET_USER];
    //            [set saveInBackground];
    
    //            ParseVolliePackage *package = [ParseVolliePackage new];
    //            self.package;
    if (self.photos.count)
    {
        [self.package sendPhotosWithPhotosArray:self.photos
                                        andText:self.sendingMessage
                                        andRoom:chatroom
                                         andSet:set];
    }
    else
    {
        [self.package checkForTextAndSendItWithText:self.sendingMessage
                                            andRoom:chatroom
                                             andSet:set];
    }

     [self.navigationController.navigationBar setTintColor:[UIColor volleyFamousGreen]];

     [self.navigationController popToViewController:[self.navigationController.viewControllers objectAtIndex:0] animated:YES];

    
//    [chatroom fetchInBackgroundWithBlock:^(PFObject *object, NSError *error)
//     {
//         if (!error)
//         {
//             ParseVolliePackage * package;
//             //             [ProgressHUD show:@"Sending..." Interaction:NO];
//             int numberOfSets = [[object valueForKey:PF_CHATROOMS_ROOMNUMBER] intValue];
//             //             NSLog(@"%i is the number of sets", numberOfSets);
//             PFObject * selectedSet = [PFObject objectWithClassName:PF_SET_CLASS_NAME];
//             if (numberOfSets == 0)
//             {
//                 [selectedSet setValue:@(0) forKey:PF_SET_ROOMNUMBER];
//                 //i mean when would this happen? If we're creatin a new room? meh....
//             }
//             else
//             {
//                 [selectedSet setValue:@(numberOfSets) forKey:PF_SET_ROOMNUMBER];
//                 //                 NSLog(@"%@ set roomnumber", [self.selectedSet objectForKey:PF_SET_ROOMNUMBER]);
//             }
//             
//             [chatroom setValue:@(numberOfSets + 1) forKey:PF_CHATROOMS_ROOMNUMBER];
//             [selectedSet setValue:chatroom forKey:PF_SET_ROOM];
//             [selectedSet setValue:[PFUser currentUser] forKey:PF_SET_USER];
//             
//             if (self.photos.count)
//             {
//                 //                 [self createParseObjectsWithPhotosArray];
//                 //                 ParseVolliePackage *volliePackage = [ParseVolliePackage new];
//                 
//                 [package sendPhotosWithPhotosArray:self.photos
//                                                 andText:self.sendingMessage
//                                                 andRoom:chatroom
//                                                  andSet:selectedSet];
//                 
//                 [self.navigationController popToViewController:[self.navigationController.viewControllers objectAtIndex:0] animated:YES];
//             }
//             else
//             {
//                 //                 ParseVolliePackage *volliePackage = [ParseVolliePackage new];
//                 [package checkForTextAndSendItWithText:self.sendingMessage
//                                                     andRoom:chatroom
//                                                      andSet:selectedSet];
//                 
//                 [self.navigationController popToViewController:[self.navigationController.viewControllers objectAtIndex:0] animated:YES];
//             }
//         }
//         else
//         {
//             [ProgressHUD showError:@"Network Error"];
//         }
//     }];
//    MomentsVC *chatView = [[MomentsVC alloc] init];
//    chatView.room = chatroom;
//    PostNotification(NOTIFICATION_REFRESH_INBOX);
//    [self setNavigationBarColor];
//
//    [self.navigationController popViewControllerAnimated:0];
//
//    [[NSNotificationCenter defaultCenter] postNotificationName:NOTIFICATION_OPEN_CHAT_VIEW object:chatView userInfo:@{@"view": chatView}];
//
//    self.buttonSend.userInteractionEnabled = YES;
//
//    if (!_isTherePicturesToSend && self.arrayofSelectedPhoneNumbers.count)
//    {
//        [[NSNotificationCenter defaultCenter] postNotificationName:NOTIFICATION_APP_MAIL_SEND object:self userInfo:@{@"string": peopleWaiting, @"people": _arrayofSelectedPhoneNumbers}];
//    }
}


#pragma mark - Backend methods

- (void)loadUsers
{
    PFQuery *query = [PFUser query];
    [query whereKey:PF_USER_OBJECTID notEqualTo:[PFUser currentUser].objectId];
    [query orderByAscending:PF_USER_FULLNAME];
    //Including the Volley Team by default
    [numbers addObject:@"0000000000"];
    [query whereKey:PF_USER_USERNAME containedIn:numbers];
    [query whereKey:PF_USER_ISVERIFIED equalTo:@YES];
    [query setCachePolicy:kPFCachePolicyCacheThenNetwork];
    //    [query setMaxCacheAge:3];
    [query findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error)
     {
         if (error == nil)
         {
             for (PFUser *user in objects)
             {
                 NSString *phoneNumber = [user objectForKey:PF_USER_USERNAME];

                 if (phoneNumber.length == 0) phoneNumber = nil;

                 if ([numbers containsObject:phoneNumber])
                 {
                     if (![usersObjectIds containsObject:user.objectId])
                     {
                         [users addObject:user];
                         [usersObjectIds addObject:user.objectId];

                         for (NSArray *objects in arrayOfNamesAndNumbers.allValues)
                         {
                             if ([objects containsObject:phoneNumber])
                             {
                                 [arrayOfNamesAndNumbers removeObjectsForKeys: [arrayOfNamesAndNumbers allKeysForObject:objects]];
                             }
                         }
#warning COULD REMOVE MULTIPLE PEOPLE WHO HAVE SAME PHONE NUMBER;
                     }
                 }
             }//END FOR LOOP
             [self wordsFromLetters:users];
         }
         else {
             if ([query hasCachedResult]) [ProgressHUD showError:@"Network error."];
         }
     }];
}

- (void)updateEmptyView
{
    if (users.count == 0) {
        UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(0, 100, self.view.frame.size.width, 70)];
        [label setNumberOfLines:2];
        label.text = @"No Contacts On Vollie";
        label.textAlignment = NSTextAlignmentCenter;
        label.textColor = [UIColor lightGrayColor];
        [self.view addSubview:label];
    } else {
        for (UILabel *label in self.view.subviews) {
            if ([label isKindOfClass:[UILabel class]]) {
                [label removeFromSuperview];
            }
        }
    }
}


#pragma mark - Table view data source

- (void)wordsFromLetters:(NSArray *)words
{
    NSMutableArray *arrayOfUsedLetters = [NSMutableArray new];
    lettersForWords = [NSMutableDictionary new];

    NSMutableDictionary *namesToUsers = [NSMutableDictionary new];

    for (PFUser *user in users) {
        NSDictionary *dict = [NSDictionary dictionaryWithObject:user forKey:[user valueForKey:PF_USER_FULLNAME]];
        [namesToUsers addEntriesFromDictionary:dict];
    }

    NSString *letters = @"abcdefghijklmnopqrstuvwxyz";

    int i = 0;
    while (i < (int)namesToUsers.count)
    {
        NSString *word = [namesToUsers.allKeys objectAtIndex:i];
        PFUser *user = [namesToUsers objectForKey:word];
        NSString *letter = [[word substringToIndex:1] uppercaseString];

        if (![letters containsString:[letter lowercaseString]]) {
            letter = @"#";
        }
        if ([arrayOfUsedLetters containsObject:letter])
        {
            [(NSMutableArray *)[lettersForWords objectForKey:letter] addObject:user];
        } else {
            NSDictionary *dict = [NSDictionary dictionaryWithObject:[NSMutableArray arrayWithObject:user] forKey:letter];
            [lettersForWords addEntriesFromDictionary:dict];
            [arrayOfUsedLetters addObject:letter];
        }
        i++;
    }

    sortedKeys = [[lettersForWords allKeys] sortedArrayUsingSelector: @selector(caseInsensitiveCompare:)];

    [self updateEmptyView];
    [self.tableView reloadData];
}

-(void)inviteWordsFromLetters:(NSDictionary *)words{
    NSMutableArray *arrayOfUsedLetters = [NSMutableArray new];
    lettersForWords = [NSMutableDictionary new];
    
    NSString *letters = @"abcdefghijklmnopqrstuvwxyz";
    
    int i = 0;
    while (i < (int)words.count)
    {
        NSString *name = [words.allKeys objectAtIndex:i];
        NSString *number = [words objectForKey:name][0];
        NSString *letter = [[name substringToIndex:1] uppercaseString];
        if (![letters containsString:[letter lowercaseString]]) {
            letter = @"#";
        }
        if ([arrayOfUsedLetters containsObject:letter])
        {
            [(NSMutableDictionary *)[lettersForWords objectForKey:letter] setObject:number forKey:name];
        } else {
            NSDictionary *dict = [NSDictionary dictionaryWithObject:[@{name:number}mutableCopy] forKey:letter];
            [lettersForWords addEntriesFromDictionary:dict];
            [arrayOfUsedLetters addObject:letter];
        }
        i++;
    }
    
    sortedKeys = [[lettersForWords allKeys] sortedArrayUsingSelector:@selector(caseInsensitiveCompare:)];
    
    [self.tableView reloadData];
}

- (NSArray *)sectionIndexTitlesForTableView:(UITableView *)tableView
{
    if (_isSearching) return nil;
//    return sortedKeys;
        return @[@"#",@"A",@"B",@"C",@"D",@"E",@"F",@"G",@"H",@"I",@"J",@"K",@"L",@"M",@"N",@"O",@"P",@"Q",@"R",@"S",@"T",@"U",@"V",@"W",@"X",@"Y",@"Z"];
}

- (NSInteger)tableView:(UITableView *)tableView sectionForSectionIndexTitle:(NSString *)title atIndex:(NSInteger)index
{
    if (_isSearching) return 0;
    return [sortedKeys indexOfObject:title];
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    if (_isSearching) return 1;
    return sortedKeys.count;
}

-(NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    if (_isSearching) return @"Searching...";
    return [@"  " stringByAppendingString:[sortedKeys objectAtIndex:section]];
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    return 40;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section

{
    if (_isSearching){
        return _searchMessages.count;
    } else {
        NSString *key = [sortedKeys objectAtIndex:section];
        NSArray *array = [lettersForWords objectForKey:key];
        return array.count;
//        return 1;
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"cell"];
    if (cell == nil) cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"cell"];


    PFUser *selectedUser;
    NSString *inviteUser;

    if (_isSearching && _searchMessages.count)
    {
        selectedUser = _searchMessages[indexPath.row];

    }
    else
    {
        NSString *key = [sortedKeys objectAtIndex:indexPath.section];
        NSArray *arrayOfNamesForLetter = self.invite ? [[[lettersForWords objectForKey:key] allKeys] sortedArrayUsingSelector:@selector(caseInsensitiveCompare:)] : [lettersForWords objectForKey:key];
        if (arrayOfNamesForLetter.count) {
            selectedUser = arrayOfNamesForLetter[indexPath.row];
            if (self.invite) inviteUser = arrayOfNamesForLetter[indexPath.row];
        }
    }
    
    cell.textLabel.text = self.invite ? inviteUser : selectedUser[PF_USER_FULLNAME];

    if ([_arrayOfSelectedUsers containsObject:selectedUser])
    {
        UIImageView *imageView = [[UIImageView alloc] initWithImage:[[UIImage imageNamed:@"checkmark"] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal]];
        imageView.tintColor = [UIColor volleyFamousOrange];
        cell.accessoryView = imageView;
        cell.accessoryView.tintColor = [UIColor volleyFamousOrange];
        cell.accessoryType = UITableViewCellAccessoryCheckmark;
    }
    else
    {
        cell.accessoryView = nil;
        cell.accessoryType = UITableViewCellAccessoryNone;
    }

    cell.backgroundColor = [UIColor colorWithRed:1 green:1 blue:1 alpha:.95f];
    cell.textLabel.textColor = [UIColor blackColor];
    cell.textLabel.font = [UIFont systemFontOfSize:18];
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    UITableViewCell *cell = [tableView cellForRowAtIndexPath:indexPath];
    //    cell.selectionStyle = UITableViewCellSelectionStyleNone;

    if (self.buttonSend.isHidden)
    {
        self.buttonSend.hidden = NO;
        self.buttonSend.alpha = 0;
        self.buttonSendArrow.hidden = NO;
        self.buttonSendArrow.alpha = 0;
        [UIView animateWithDuration:.3f animations:^{
            [UIView setAnimationCurve:UIViewAnimationCurveEaseInOut];
            self.buttonSend.alpha = 1;
            self.buttonSendArrow.alpha = 1;
            [self.tableView setFrame:CGRectMake(0, 0, [UIScreen mainScreen].bounds.size.width, [UIScreen mainScreen].bounds.size.height -self.buttonSend.frame.size.height)];
        }];
    }

    PFUser *selectedUser;
    if (_isSearching && _searchMessages.count)
    {
        selectedUser = [_searchMessages objectAtIndex:indexPath.row];
    }
    else
    {
        NSString *key = [sortedKeys objectAtIndex:indexPath.section];
        NSDictionary *phoneNumbers;
        NSArray *arrayOfNamesForLetter;
        if (self.invite) {
            phoneNumbers = [lettersForWords objectForKey:key];
            NSLog(@"%@",phoneNumbers);
        } else {
            arrayOfNamesForLetter = [lettersForWords objectForKey:key];;
        }
        
        if (arrayOfNamesForLetter.count||phoneNumbers.count)
        {
            if (self.invite) {
                selectedUser = phoneNumbers[cell.textLabel.text];
            } else {
                selectedUser = arrayOfNamesForLetter[indexPath.row];
            }
        }
    }

    if (cell.accessoryView == nil && cell.accessoryType == UITableViewCellAccessoryNone)
    {
        if (self.invite && [self.arrayOfSelectedUsers[0] isKindOfClass:[PFUser class]]) {
            [self.arrayOfSelectedUsers removeObjectAtIndex:0];
        }
        if (_arrayOfSelectedUsers.count > 100) [ProgressHUD showError:@"100 People Only"];
        else
        {
            [self.arrayOfSelectedUsers addObject:selectedUser];
            [self togglePhoneNumbersCountIndicator];
            UIImage *image = self.invite ? [[UIImage imageNamed:@"text-message-icon"] imageWithRenderingMode:UIImageRenderingModeAutomatic] : [[UIImage imageNamed:@"checkmark"] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal];
            cell.accessoryView = [[UIImageView alloc] initWithImage:image];
            cell.accessoryView.tintColor = [UIColor volleyFamousOrange];
            cell.accessoryType = UITableViewCellAccessoryCheckmark;
        }
    }else{
        [self.arrayOfSelectedUsers removeObject:selectedUser];
        cell.accessoryView = nil;
        cell.accessoryType = UITableViewCellAccessoryNone;
    }
    
    if (self.arrayOfSelectedUsers.count == 1 && [self.arrayOfSelectedUsers[0] isKindOfClass:[PFUser class]]){
        self.buttonSend.hidden = YES;
        self.buttonSend.alpha = 1;
        self.buttonSendArrow.hidden = YES;
        self.buttonSendArrow.alpha = 1;
        [UIView animateWithDuration:.3f animations:^{
            [UIView setAnimationCurve:UIViewAnimationCurveEaseInOut];
            self.buttonSend.alpha = 0;
            self.buttonSendArrow.alpha = 0;
            [self.tableView setFrame:CGRectMake(0, 0, [UIScreen mainScreen].bounds.size.width, [UIScreen mainScreen].bounds.size.height)];
        }];
    }
}

- (void)togglePhoneNumbersCountIndicator
{
    [labelForContactsIndicator removeFromSuperview];

    if (_arrayofSelectedPhoneNumbers.count && !self.buttonSend.isHidden)
    {
        labelForContactsIndicator = [[UITextField alloc] initWithFrame:CGRectMake(0, (self.view.frame.size.height - 106), self.tableView.frame.size.width, 44)];

        NSString *string = [NSString stringWithFormat:@"✚ %lu contacts invited", (unsigned long)_arrayofSelectedPhoneNumbers.count];

        //        if (_arrayOfSelectedUsers.count)
        //        {
        //            for (PFUser *user in _arrayOfSelectedUsers)
        //            {
        //                if (user != [PFUser currentUser]) {
        //                [user fetchIfNeededInBackgroundWithBlock:^(PFObject *object, NSError *error) {
        //                    NSString *string = [object valueForKey:PF_USER_FULLNAME];
        //                    if (![_arrayofSelectedPhoneNumbers containsObject:string])
        //                    {
        //                        string = [string stringByAppendingString:@", "];
        //                        string = [string stringByAppendingString:[user valueForKey:PF_USER_USERNAME]];
        //                        string = [string substringToIndex:string.length - 2];
        //                    }
        //                }];
        //            }
        //            }
        //        }

        labelForContactsIndicator.userInteractionEnabled = NO;
        labelForContactsIndicator.textColor = [UIColor whiteColor];
        labelForContactsIndicator.font = [UIFont boldSystemFontOfSize:16];
        labelForContactsIndicator.text = string;

        UIView *spacerView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 10, 10)];
        [labelForContactsIndicator setLeftViewMode:UITextFieldViewModeAlways];
        [labelForContactsIndicator setLeftView:spacerView];
        labelForContactsIndicator.backgroundColor = [UIColor volleyFamousGreen];
        labelForContactsIndicator.textColor = [UIColor whiteColor];
        [self.view addSubview:labelForContactsIndicator];
    }
}

#pragma mark -SEARCH

- (void)searchUsers:(NSString *)search_lower
{
    for (PFUser *user in users) {
        if ([[[user valueForKey:PF_USER_FULLNAME] lowercaseString] containsString:search_lower])
        {
            [self.searchMessages addObject:user];
        }
    }
    [_tableView reloadData];
}

- (IBAction)textFieldDidChange:(UITextField *)textField
{
    if ([textField.text length] > 0)
    {
        [_searchMessages removeAllObjects];
        _isSearching = YES;
        [self searchUsers:[textField.text lowercaseString]];
    } else {
        _isSearching = NO;
        [_tableView reloadData];
    }
}

- (void)textFieldDidBeginEditing:(UITextField *)textField
{
    textField.text =@"";
    self.searchMessages = [NSMutableArray new];
    _isSearching = YES;
    _searchCloseButton.hidden = NO;
}

- (void)textFieldDidEndEditing:(UITextField *)textField
{
    _isSearching = NO;
    _searchCloseButton.hidden = YES;
    [textField resignFirstResponder];
    textField.text = @"";
    [_tableView reloadData];
}

- (IBAction)closeSearch:(id)sender
{
    [_searchTextField resignFirstResponder];
}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if ([alertView.title isEqualToString:@"Multiple Unknown Phone Numbers"])
    {
        NSString *phoneNumber = [alertView buttonTitleAtIndex:buttonIndex];
        if (phoneNumber.length && _selectedCell.accessoryType == UITableViewCellAccessoryNone)
        {
            _selectedCell.accessoryView = [[UIImageView alloc]initWithImage:[UIImage imageNamed:@"email"]];
            _selectedCell.accessoryType = UITableViewCellAccessoryCheckmark;
            [_arrayofSelectedPhoneNumbers addObject:phoneNumber];
        }
    }

    if ([alertView.title isEqualToString:@"Contacts not enabled."] && buttonIndex == 1)
    {
        //code for opening settings app in iOS 8
        [self.navigationController popToRootViewControllerAnimated:0];
        [[UIApplication sharedApplication] openURL:[NSURL  URLWithString:UIApplicationOpenSettingsURLString]];
    }
}

- (void)getAllContacts
{
    numbers = [NSMutableArray new];
    arrayOfNamesAndNumbers = [NSMutableDictionary new];

    NSString *currentUserName = [PFUser currentUser].username;

    CFErrorRef *error = nil;

    dispatch_queue_t abQueue = dispatch_queue_create("myabqueue", DISPATCH_QUEUE_SERIAL);
    dispatch_set_target_queue(abQueue, dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0));


    ABAddressBookRef addressBook = ABAddressBookCreateWithOptions(NULL, error);
    __block BOOL accessGranted = NO;

    if (ABAddressBookGetAuthorizationStatus() == kABAuthorizationStatusAuthorized) {

        accessGranted = YES;

    } else if (ABAddressBookGetAuthorizationStatus() == kABAuthorizationStatusNotDetermined) {
        if (&ABAddressBookRequestAccessWithCompletion != NULL) { // we're on iOS 6
            dispatch_semaphore_t sema = dispatch_semaphore_create(0);
            ABAddressBookRequestAccessWithCompletion(addressBook, ^(bool granted, CFErrorRef error) {
                accessGranted = granted;

                dispatch_semaphore_signal(sema);
            });
            dispatch_semaphore_wait(sema, DISPATCH_TIME_FOREVER);
        } else { // we're on iOS 5 or older
            accessGranted = YES;
        }
    }

    if (!accessGranted) {

        dispatch_async(dispatch_get_main_queue(), ^{

            if([[[UIDevice currentDevice] systemVersion] floatValue]<8.0){
                UIAlertView* curr1=[[UIAlertView alloc] initWithTitle:@"Contacts not enabled." message:@"Settings -> Vollie -> Contacts" delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
                [curr1 show];
            } else {
                UIAlertView* curr2=[[UIAlertView alloc] initWithTitle:@"Contacts not enabled." message:@"Settings -> Vollie -> Contacts" delegate:self cancelButtonTitle:@"OK" otherButtonTitles:@"Settings", nil];
                curr2.tag=121;
                [curr2 show];
            }
        });
    } else {

        CFArrayRef allPeople = ABAddressBookCopyArrayOfAllPeople(addressBook);
        CFIndex nPeople = ABAddressBookGetPersonCount(addressBook); 
        //        NSMutableArray* items = [NSMutableArray arrayWithCapacity:nPeople];

        //START ITERATING THROUGH PEOPLE
        //GRAB PHONE NUMBERS, CHECK FOR USERS, THEN GRAB NAMES FOR NON-USER NUMBER, ONLY ONE NAME PER MULT-PHONENUMBER;

        for (int i = 0; i < nPeople; i++) {
            ABRecordRef person = CFArrayGetValueAtIndex(allPeople, i);
            NSString *firstname = (__bridge NSString *)(ABRecordCopyValue(person, kABPersonFirstNameProperty));
            NSString *lastname = (__bridge NSString *)(ABRecordCopyValue(person, kABPersonLastNameProperty));

            NSString *name = [NSString new];

            if (!firstname) {
                name = lastname;
            } else if (!lastname) {
                name = firstname;
            } else {
                name = [NSString stringWithFormat:@"%@ %@", firstname, lastname];
            }

            //COMBINE NAME KEY WITH PHONE NUMBER OBJECTS IN DICTIONARY.

            ABMultiValueRef multiPhones = ABRecordCopyValue(person, kABPersonPhoneProperty);
            // CFStringRef phoneNumberRef = ABMultiValueCopyValueAtIndex(multiPhones, 0);
            //  phoneNumberRef = ABMultiValueCopyValueAtIndex(multiPhones, ABMultiValueGetIndexForIdentifier(multiPhones, 0));

            NSMutableArray *theirPhoneNumbers = [NSMutableArray new];

            for(CFIndex i=0; i<ABMultiValueGetCount(multiPhones); i++)
            {
                CFStringRef phoneNumberRef = ABMultiValueCopyValueAtIndex(multiPhones, i);
                NSString *phoneNumber = (__bridge NSString *) phoneNumberRef;


                phoneNumber = [[phoneNumber componentsSeparatedByCharactersInSet:
                                [[NSCharacterSet decimalDigitCharacterSet] invertedSet]]
                               componentsJoinedByString:@""];

                if (phoneNumber.length == 10)
                {
                    phoneNumber = [AppConstant formatPhoneNumberForCountry:phoneNumber];
                }

                if (![phoneNumber hasPrefix:@"+"])
                {
                    phoneNumber = [@"+" stringByAppendingString:phoneNumber];
                }

                if (phoneNumber.length > 0)
                {
                    [theirPhoneNumbers addObject:(NSString *)phoneNumber];
                    [numbers addObject:phoneNumber];
                }
            }

            if ([theirPhoneNumbers containsObject:currentUserName])
            {
                //Prevent current user???
            } else {
                if (name.length && theirPhoneNumbers.count)
                {
                    NSDictionary *dict = [NSDictionary dictionaryWithObject:[NSArray arrayWithArray:theirPhoneNumbers] forKey:name];
                    [arrayOfNamesAndNumbers addEntriesFromDictionary:dict];
                }
            }
        }
        
        if (self.invite){
            [self inviteWordsFromLetters:arrayOfNamesAndNumbers];
        } else {
            dispatch_async(dispatch_get_main_queue(), ^{
                [self loadUsers];
            });
        }
    }
}

- (NSString *)formatPhoneNumberForCountry:(NSString *)phoneNumber
{
    NSDictionary *dictCodes = [NSDictionary dictionaryWithObjectsAndKeys:@"972", @"IL",
                               @"93", @"AF", @"355", @"AL", @"213", @"DZ", @"1", @"AS",
                               @"376", @"AD", @"244", @"AO", @"1", @"AI", @"1", @"AG",
                               @"54", @"AR", @"374", @"AM", @"297", @"AW", @"61", @"AU",
                               @"43", @"AT", @"994", @"AZ", @"1", @"BS", @"973", @"BH",
                               @"880", @"BD", @"1", @"BB", @"375", @"BY", @"32", @"BE",
                               @"501", @"BZ", @"229", @"BJ", @"1", @"BM", @"975", @"BT",
                               @"387", @"BA", @"267", @"BW", @"55", @"BR", @"246", @"IO",
                               @"359", @"BG", @"226", @"BF", @"257", @"BI", @"855", @"KH",
                               @"237", @"CM", @"1", @"CA", @"238", @"CV", @"345", @"KY",
                               @"236", @"CF", @"235", @"TD", @"56", @"CL", @"86", @"CN",
                               @"61", @"CX", @"57", @"CO", @"269", @"KM", @"242", @"CG",
                               @"682", @"CK", @"506", @"CR", @"385", @"HR", @"53", @"CU",
                               @"537", @"CY", @"420", @"CZ", @"45", @"DK", @"253", @"DJ",
                               @"1", @"DM", @"1", @"DO", @"593", @"EC", @"20", @"EG",
                               @"503", @"SV", @"240", @"GQ", @"291", @"ER", @"372", @"EE",
                               @"251", @"ET", @"298", @"FO", @"679", @"FJ", @"358", @"FI",
                               @"33", @"FR", @"594", @"GF", @"689", @"PF", @"241", @"GA",
                               @"220", @"GM", @"995", @"GE", @"49", @"DE", @"233", @"GH",
                               @"350", @"GI", @"30", @"GR", @"299", @"GL", @"1", @"GD",
                               @"590", @"GP", @"1", @"GU", @"502", @"GT", @"224", @"GN",
                               @"245", @"GW", @"595", @"GY", @"509", @"HT", @"504", @"HN",
                               @"36", @"HU", @"354", @"IS", @"91", @"IN", @"62", @"ID",
                               @"964", @"IQ", @"353", @"IE", @"972", @"IL", @"39", @"IT",
                               @"1", @"JM", @"81", @"JP", @"962", @"JO", @"77", @"KZ",
                               @"254", @"KE", @"686", @"KI", @"965", @"KW", @"996", @"KG",
                               @"371", @"LV", @"961", @"LB", @"266", @"LS", @"231", @"LR",
                               @"423", @"LI", @"370", @"LT", @"352", @"LU", @"261", @"MG",
                               @"265", @"MW", @"60", @"MY", @"960", @"MV", @"223", @"ML",
                               @"356", @"MT", @"692", @"MH", @"596", @"MQ", @"222", @"MR",
                               @"230", @"MU", @"262", @"YT", @"52", @"MX", @"377", @"MC",
                               @"976", @"MN", @"382", @"ME", @"1", @"MS", @"212", @"MA",
                               @"95", @"MM", @"264", @"NA", @"674", @"NR", @"977", @"NP",
                               @"31", @"NL", @"599", @"AN", @"687", @"NC", @"64", @"NZ",
                               @"505", @"NI", @"227", @"NE", @"234", @"NG", @"683", @"NU",
                               @"672", @"NF", @"1", @"MP", @"47", @"NO", @"968", @"OM",
                               @"92", @"PK", @"680", @"PW", @"507", @"PA", @"675", @"PG",
                               @"595", @"PY", @"51", @"PE", @"63", @"PH", @"48", @"PL",
                               @"351", @"PT", @"1", @"PR", @"974", @"QA", @"40", @"RO",
                               @"250", @"RW", @"685", @"WS", @"378", @"SM", @"966", @"SA",
                               @"221", @"SN", @"381", @"RS", @"248", @"SC", @"232", @"SL",
                               @"65", @"SG", @"421", @"SK", @"386", @"SI", @"677", @"SB",
                               @"27", @"ZA", @"500", @"GS", @"34", @"ES", @"94", @"LK",
                               @"249", @"SD", @"597", @"SR", @"268", @"SZ", @"46", @"SE",
                               @"41", @"CH", @"992", @"TJ", @"66", @"TH", @"228", @"TG",
                               @"690", @"TK", @"676", @"TO", @"1", @"TT", @"216", @"TN",
                               @"90", @"TR", @"993", @"TM", @"1", @"TC", @"688", @"TV",
                               @"256", @"UG", @"380", @"UA", @"971", @"AE", @"44", @"GB",
                               @"1", @"US", @"598", @"UY", @"998", @"UZ", @"678", @"VU",
                               @"681", @"WF", @"967", @"YE", @"260", @"ZM", @"263", @"ZW",
                               @"591", @"BO", @"673", @"BN", @"61", @"CC", @"243", @"CD",
                               @"225", @"CI", @"500", @"FK", @"44", @"GG", @"379", @"VA",
                               @"852", @"HK", @"98", @"IR", @"44", @"IM", @"44", @"JE",
                               @"850", @"KP", @"82", @"KR", @"856", @"LA", @"218", @"LY",
                               @"853", @"MO", @"389", @"MK", @"691", @"FM", @"373", @"MD",
                               @"258", @"MZ", @"970", @"PS", @"872", @"PN", @"262", @"RE",
                               @"7", @"RU", @"590", @"BL", @"290", @"SH", @"1", @"KN",
                               @"1", @"LC", @"590", @"MF", @"508", @"PM", @"1", @"VC",
                               @"239", @"ST", @"252", @"SO", @"47", @"SJ", @"963", @"SY",
                               @"886", @"TW", @"255", @"TZ", @"670", @"TL", @"58", @"VE",
                               @"84", @"VN", @"1", @"VG", @"1", @"VI", nil];

    NSLocale *locale = [NSLocale currentLocale];
    NSString *countryCode = [locale objectForKey:NSLocaleCountryCode];
    NSString *callingCode = [dictCodes objectForKey:countryCode];
    
    NSCharacterSet *validCharacters = [[NSCharacterSet characterSetWithCharactersInString:@"+0123456789"] invertedSet];
    
    NSString *newString = [[phoneNumber componentsSeparatedByCharactersInSet:validCharacters]componentsJoinedByString:@""];
    
    NSString *newString2 = newString;
    
    if (![newString hasPrefix:@"+"])
    {
        newString2 = [NSString stringWithFormat:@"+%@%@",callingCode,newString];
    }
    
    NSString *substring = [newString2 substringFromIndex:1];
    NSString *removeExtraPlusSigns = [substring stringByReplacingOccurrencesOfString:@"+" withString:@""];
    NSString *finalPhone = [NSString stringWithFormat:@"+%@",removeExtraPlusSigns];
    
    return finalPhone;
}

-(void)messagesInputToolbar:(JSQMessagesInputToolbar *)toolbar didPressLeftBarButton:(UIButton *)sender {}

@end
