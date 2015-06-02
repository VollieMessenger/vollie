

#import <Parse/Parse.h>
#import "ProgressHUD.h"

#import "AppConstant.h"
#import "messages.h"
#import "utilities.h"

#import "ChatroomUsersView.h"
#import "ChatView.h"

#import <AddressBook/AddressBook.h>
#import <AddressBookUI/AddressBookUI.h>


@interface ChatroomUsersView() <UITextFieldDelegate, UIActionSheetDelegate>
@property PFObject *room;
@property NSMutableDictionary *arrayOfNamesAndNumbers;
@property NSMutableArray *arrayOfNames;
@property UITextField *textField;
@end

@implementation ChatroomUsersView

@synthesize textField, arrayOfNamesAndNumbers;

- (id)initWithRoom:(PFObject *)room
{
    self = [super initWithStyle:UITableViewStyleGrouped];
    if (self)
    {
        _room = room;
    }
    return self;
}

- (void)didTap:(UITapGestureRecognizer *)tap
{
    [self saveNickname];
}

- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (buttonIndex != actionSheet.cancelButtonIndex)
    {
        if ([[actionSheet buttonTitleAtIndex:buttonIndex] isEqualToString:@"Hide"])
        {
            UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Hide this conversation?" message:@"Temporarily hide the conversation from your inbox until a new message appears?" delegate:self cancelButtonTitle:@"Cancel" otherButtonTitles:@"Hide" , nil];
            alertView.tag = 32;
            [alertView show];
        }

        if ([[actionSheet buttonTitleAtIndex:buttonIndex] isEqualToString:@"Flag"])
        {
            UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Flag this conversation?" message:@"Do you want to flag this conversation and all it's users for objectionable content?" delegate:self cancelButtonTitle:@"Cancel" otherButtonTitles:@"Flag" , nil];
            alertView.tag = 222;
            [alertView show];
        }
        if ([[actionSheet buttonTitleAtIndex:buttonIndex] isEqualToString:@"Leave"])
        {
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Warning" message:@"Leaving the conversation will erase all your content in the conversation, and you will not see the conversation again." delegate:self cancelButtonTitle:@"Cancel" otherButtonTitles:@"Leave", nil];
            alert.tag = 23;
            [alert show];
        }
        if ([[actionSheet buttonTitleAtIndex:buttonIndex] isEqualToString:@"Silence"] || [[actionSheet buttonTitleAtIndex:buttonIndex] isEqualToString:@"Un-Silence"])
        {
            [self actionSilencePush];
        }
    }
}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{

    if (buttonIndex != alertView.cancelButtonIndex && alertView.tag == 23)
    {
        [self leaveChatroom];
    }

    if (buttonIndex != alertView.cancelButtonIndex && alertView.tag == 222)
    {
    PFObject *chatroom = [self.message valueForKey:PF_MESSAGES_ROOM];
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

    if (buttonIndex != alertView.cancelButtonIndex && alertView.tag == 32)
    {
        //Hide
        [self.message setValue:@YES forKey:PF_MESSAGES_HIDE_UNTIL_NEXT];
        [self.message saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
            if (!error)
            {
                [ProgressHUD showSuccess:@"Hidden"];
            }
        }];
    }

    if (buttonIndex != alertView.cancelButtonIndex && alertView.tag == 69)
    {

        PFObject *message = _message;
        if ([alertView.title isEqualToString:@"Silence Push Notifications?"]) {
            [message removeObjectForKey:PF_MESSAGES_USER_DONOTDISTURB];
        } else {
            [message setValue:[PFUser currentUser] forKey:PF_MESSAGES_USER_DONOTDISTURB];
        }
        [message saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
            if (succeeded) {
                [ProgressHUD showSuccess:@"Saved"];
            }
        }];
    }
}

-(void)hideChatroomAction
{

    UIActionSheet *action = [[UIActionSheet alloc] initWithTitle:nil delegate:self cancelButtonTitle:@"Cancel" destructiveButtonTitle:nil
                                               otherButtonTitles:@"Hide", nil];
    action.tag = 1;
    [action showInView:self.view];
}

- (void)showActionSheet
{
    [_message fetchIfNeededInBackgroundWithBlock:^(PFObject *object, NSError *error) {
        if (!error) {
            if (!object[PF_MESSAGES_USER_DONOTDISTURB])
            {
                UIActionSheet *action = [[UIActionSheet alloc] initWithTitle:nil delegate:self cancelButtonTitle:@"Cancel" destructiveButtonTitle:nil
                                                           otherButtonTitles:@"Un-Silence", @"Hide", @"Leave", @"Flag", nil];
                action.tag = 12;
                [action showInView:self.view];

            } else {

                UIActionSheet *action = [[UIActionSheet alloc] initWithTitle:nil delegate:self cancelButtonTitle:@"Cancel" destructiveButtonTitle:nil
                                                           otherButtonTitles:@"Silence", @"Hide", @"Leave", @"Flag", nil];
                action.tag = 12;
                [action showInView:self.view];

            }
        } else [ProgressHUD showError:@"Network Error"];
    }];
}

- (void)actionDimiss
{
    [self dismissViewControllerAnimated:1 completion:0];
   // [self.navigationController popToRootViewControllerAnimated:1];
}

- (void)viewDidDisappear:(BOOL)animated
{
    PostNotification(NOTIFICATION_DISABLESCROLLVIEW);
}

- (void)viewDidLoad
{
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(actionDimiss) name:NOTIFICATION_CLICKED_PUSH object:0];
    
    self.tableView.userInteractionEnabled = NO;
    _arrayOfNames = [NSMutableArray new];

    [self loadUsers];

    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(didTap:)];
    [self.view addGestureRecognizer:tap];

    UIBarButtonItem *close =  [[UIBarButtonItem alloc] initWithTitle:@"Close " style:UIBarButtonItemStyleBordered target:self action:@selector(actionDimiss)];

    close.image = [UIImage imageNamed:ASSETS_CLOSE];
    self.navigationItem.rightBarButtonItem = close;

    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"More" style:UIBarButtonItemStyleDone target:self action:@selector(showActionSheet)];

    [super viewDidLoad];
    [self.tableView setRowHeight:66];
    self.tableView.separatorInset = UIEdgeInsetsZero;

    /*
    UIButton *button = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, self.tableView.frame.size.width, 50)];
    button.titleLabel.font = [UIFont fontWithName:@"Arial Rounded MT Bold" size:14];
    [button setTitle:@"HIDE CONVERSATION" forState:UIControlStateNormal];
    button.titleLabel.textColor = [UIColor whiteColor];
    [button addTarget:self action:@selector(hideChatroomAction) forControlEvents:UIControlEventTouchUpInside];
    button.backgroundColor = [UIColor volleyFamousOrange];

    UIButton *button2 = [[UIButton alloc] initWithFrame:CGRectMake(0, 60, self.tableView.frame.size.width, 50)];
    button2.titleLabel.font = [UIFont fontWithName:@"Arial Rounded MT Bold" size:14];
    [button2 setTitle:@"LEAVE CONVERSATION" forState:UIControlStateNormal];
    button2.titleLabel.textColor = [UIColor whiteColor];
    [button2 addTarget:self action:@selector(leaveChatromoAction) forControlEvents:UIControlEventTouchUpInside];
    button2.backgroundColor = [UIColor volleyFamousOrange];

    UIView *view2 = [[UIView alloc] initWithFrame:CGRectMake(0, self.view.frame.size.height - 150, self.view.frame.size.width, 110)];
    [view2 addSubview:button];
    [view2 addSubview:button2];
    view2.backgroundColor = [UIColor whiteColor];

//    [self.tableView setTableFooterView:view2];
    [self.view addSubview:view2];
*/

    //original:
//    UIView *view = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.tableView.frame.size.width, 70)];
//    view.backgroundColor = [UIColor groupTableViewBackgroundColor];
//    textField = [[UITextField alloc] initWithFrame:CGRectMake(0, 10, self.tableView.frame.size.width, 50)];
//    UIView *spacerView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 10, 10)];

    UIView *view = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.tableView.frame.size.width, 110)];
    view.backgroundColor = [UIColor groupTableViewBackgroundColor];
    UILabel *groupNamelabel = [[UILabel alloc] initWithFrame:CGRectMake(5, 0, 120, 30)];
    groupNamelabel.backgroundColor = [UIColor clearColor];
    groupNamelabel.textColor=[UIColor blackColor];
    groupNamelabel.font = [UIFont fontWithName:@"ArialRoundedMTBold" size:15];
    groupNamelabel.text = @"Room Name:";
    groupNamelabel.textColor = [UIColor volleyFamousGreen];
    [view addSubview:groupNamelabel];
    UILabel *namesLabel = [[UILabel alloc] initWithFrame:CGRectMake(5, 80, 120, 30)];
    namesLabel.backgroundColor = [UIColor clearColor];
    namesLabel.textColor=[UIColor blackColor];
    namesLabel.font = [UIFont fontWithName:@"ArialRoundedMTBold" size:15];
    namesLabel.text = @"People In Room:";
    namesLabel.textColor = [UIColor volleyFamousGreen];
    [view addSubview:namesLabel];
    textField = [[UITextField alloc] initWithFrame:CGRectMake(0, 30, self.tableView.frame.size.width, 50)];
    UIView *spacerView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 10, 10)];
//    textField.layer.borderWidth = .25;
    [textField setLeftViewMode:UITextFieldViewModeAlways];
    [textField setLeftView:spacerView];
    textField.placeholder = @"Personal Nickname";
    textField.delegate = self;
    textField.returnKeyType = UIReturnKeyDone;
    textField.inputAccessoryView = [UIView new];
    textField.backgroundColor = [UIColor whiteColor];

    if (_message[PF_MESSAGES_NICKNAME])
    {
        textField.text = _message[PF_MESSAGES_NICKNAME];
    }
    [view addSubview:textField];
    [self.tableView setTableHeaderView:view];
}

- (void) loadUsers
{
    PFRelation *userss = [_room relationForKey:PF_CHATROOMS_USERS];
    PFQuery *query = [userss query];
    [query whereKey:@"objectId" notEqualTo:[PFUser currentUser].objectId];
    //Load cache here???
//  [query setCachePolicy:kPFCachePolicyCacheThenNetwork];
    [query findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
        if (!error) {
            NSMutableArray *array = [NSMutableArray arrayWithArray:objects];
            for (PFUser *user in array) {
                if (user.objectId != [PFUser currentUser].objectId) {
                    NSString *string = [user valueForKey:PF_USER_FULLNAME];
                    if (string.length && string && [[user valueForKey:PF_USER_ISVERIFIED] isEqualToNumber:@YES]) {
                        [_arrayOfNames addObject:string];
                    } else {
                        [_arrayOfNames addObject:[NSString stringWithFormat:@"%@* - pending",[user valueForKey:PF_USER_USERNAME]]];
                    }
                }
            }
            [self.tableView reloadData];
            [self getAllContacts];
            self.tableView.userInteractionEnabled = YES;
        }}];
}

- (void)loadUsers2
{
    NSArray *copyOfNames = [NSArray arrayWithArray:_arrayOfNames];
    for (NSString *phoneNumber in copyOfNames) {
        if ([phoneNumber containsString:@"pending"]) {
            NSString *phoneNumber2 = [phoneNumber stringByReplacingOccurrencesOfString:@"* - pending" withString:@""];
            //Array of arrays
            for (NSArray *numbers in arrayOfNamesAndNumbers.allValues)
            {
                if ([numbers containsObject:phoneNumber2])
                {
                    NSArray *savedArray = numbers;
                    NSArray *names = [NSArray arrayWithArray:[arrayOfNamesAndNumbers allKeysForObject:savedArray]];
                    phoneNumber2 = [names.firstObject stringByAppendingString:@" - pending*"];

                    if (phoneNumber2.length)
                    {
                        [_arrayOfNames removeObject:phoneNumber];
                        [_arrayOfNames addObject:phoneNumber2];
                    }
                }
            }
        }
    }
    [self.tableView reloadData];
}

- (void) leaveChatroom
{
//Just delete my stuff, and get me out of here.
    [ProgressHUD show:@"Leaving..." Interaction:0];

    PFQuery *query = [PFQuery queryWithClassName:PF_CHAT_CLASS_NAME];
    [query whereKey:PF_CHAT_ROOM equalTo:_room];
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
                [query2 whereKey:PF_CHAT_ROOM equalTo:_room];
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
                                    PFRelation *userss = [_room relationForKey:PF_CHATROOMS_USERS];
                                    [userss removeObject:[PFUser currentUser]];
                                    [[_room valueForKey:PF_CHATROOMS_USEROBJECTS] removeObject:[PFUser currentUser].objectId];

                                    [[userss query] countObjectsInBackgroundWithBlock:^(int number, NSError *error) {
                                        if (!error) {
                                            if (number == 0) {

                                            [_room deleteInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
                                                if (succeeded)
                                                {
                                                    PostNotification(NOTIFICATION_ENABLESCROLLVIEW);
                                                }
                                            }];

                                            }
                                            else
                                            {

                                                [_room saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
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
                                    [self actionDimiss];
                                }
                            }];
                        }
                    }}];
        } else {
            [ProgressHUD showError:@"Network Error"];
        }
            }];
}

- (void) dismiss
{
    [self dismissViewControllerAnimated:1 completion:0];
//    [self.navigationController popViewControllerAnimated:1];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
}

#pragma mark - User actions

- (void)actionSilencePush
{
    NSLog(@"hit the silence button");
        [_message fetchIfNeededInBackgroundWithBlock:^(PFObject *object, NSError *error) {
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

#pragma mark - Table view data source
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [self saveNickname];
    [tableView deselectRowAtIndexPath:indexPath animated:0];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"cell"];
    if (cell == nil) cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"cell"];
    cell.textLabel.text = _arrayOfNames[indexPath.row];
//    if ([cell.textLabel.text containsString:@"pending"])
        cell.textLabel.textColor = [UIColor darkTextColor];
        cell.backgroundColor = [UIColor whiteColor];
    return cell;
}

/*
- (NSString *)tableView:(UITableView *)tableView titleForDeleteConfirmationButtonForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return @"Block";
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    [ProgressHUD showError:@"Not Setup"];
}
*/

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return _arrayOfNames.count;
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    [self saveNickname];
    return YES;
}


- (void) saveNickname
{
    PFObject *message = _message;
    if (textField.isFirstResponder) {
    if (textField.hasText) {
        [message setValue:textField.text forKey:PF_MESSAGES_NICKNAME];
    }else {
        [message removeObjectForKey:PF_MESSAGES_NICKNAME];
    }
    [message saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
        if (succeeded) {
            PostNotification(NOTIFICATION_REFRESH_INBOX);
            [ProgressHUD showSuccess:@"Saved Nickname"];
            [textField resignFirstResponder];
        } else [ProgressHUD showError:@"Network Error"];
    }];
    }
}


- (void)getAllContacts
{
    arrayOfNamesAndNumbers = [NSMutableDictionary new];

    CFErrorRef *error = nil;

    dispatch_queue_t abQueue = dispatch_queue_create("myabqueue", DISPATCH_QUEUE_SERIAL);
    dispatch_set_target_queue(abQueue, dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0));



    ABAddressBookRef addressBook = ABAddressBookCreateWithOptions(NULL, error);
    __block BOOL accessGranted = NO;

    if (ABAddressBookGetAuthorizationStatus() == kABAuthorizationStatusAuthorized) {

        accessGranted = YES;

    } else if (ABAddressBookGetAuthorizationStatus() == kABAuthorizationStatusNotDetermined) {

        if (ABAddressBookRequestAccessWithCompletion != NULL) { // we're on iOS 6
            dispatch_semaphore_t sema = dispatch_semaphore_create(0);
            ABAddressBookRequestAccessWithCompletion(addressBook, ^(bool granted, CFErrorRef error) {
                accessGranted = granted;

                dispatch_semaphore_signal(sema);
            });
            dispatch_semaphore_wait(sema, DISPATCH_TIME_FOREVER);
        }
        else { // we're on iOS 5 or older
            accessGranted = YES;
        }
    }

    if (!accessGranted) {

        dispatch_async(dispatch_get_main_queue(), ^{

            if([[[UIDevice currentDevice] systemVersion] floatValue]<8.0)
            {
                UIAlertView* curr1=[[UIAlertView alloc] initWithTitle:@"Contacts not enabled." message:@"Settings -> Volley -> Contacts" delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
                [curr1 show];
            }
            else
            {
                UIAlertView* curr2=[[UIAlertView alloc] initWithTitle:@"Contacts not enabled." message:@"Settings -> Volley -> Contacts" delegate:self cancelButtonTitle:@"OK" otherButtonTitles:@"Settings", nil];
                curr2.tag=121;
                [curr2 show];
            }
        });
    } else {

        ABAddressBookRef addressBook = ABAddressBookCreateWithOptions(NULL, error);
        ABRecordRef source = ABAddressBookCopyDefaultSource(addressBook);
        CFArrayRef allPeople = ABAddressBookCopyArrayOfAllPeopleInSourceWithSortOrdering(addressBook, source, kABPersonSortByFirstName);
        CFIndex nPeople = ABAddressBookGetPersonCount(addressBook);
        nPeople = CFArrayGetCount(allPeople);
     //   NSMutableArray* items = [NSMutableArray arrayWithCapacity:nPeople];

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

            for(CFIndex i=0;i<ABMultiValueGetCount(multiPhones);i++)
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

                if (phoneNumber.length) {
                    [theirPhoneNumbers addObject:(NSString *)phoneNumber];
                }
            }

            if (name.length && theirPhoneNumbers.count) {
                NSDictionary *dict = [NSDictionary dictionaryWithObject:[NSArray arrayWithArray:theirPhoneNumbers] forKey:name];
                [arrayOfNamesAndNumbers addEntriesFromDictionary:dict];
            }
        }
        
        dispatch_async(dispatch_get_main_queue(), ^{
            [self loadUsers2];
        });
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


@end
