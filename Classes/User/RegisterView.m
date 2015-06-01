
#import <Parse/Parse.h>
#import <ParseUI/ParseUI.h>
#import "ProgressHUD.h"
#import "AppConstant.h"
#import "pushnotification.h"
#import "RegisterView.h"
#import "VerifyTextView.h"
#import "utilities.h"
#import "messages.h"

@interface RegisterView()

@property (strong, nonatomic) IBOutlet UITableViewCell *cellFirstName;
@property (strong, nonatomic) IBOutlet UITableViewCell *cellLastName;
@property (strong, nonatomic) IBOutlet UITableViewCell *cellPassword;
@property (strong, nonatomic) IBOutlet UITableViewCell *cellButton;
@property (strong, nonatomic) IBOutlet UITableViewCell *cellPhoneNumber;

@property (weak, nonatomic) IBOutlet UITextField *fieldFirstName;
@property (weak, nonatomic) IBOutlet UITextField *fieldLasteName;
@property (weak, nonatomic) IBOutlet UITextField *fieldPassword;
@property (weak, nonatomic) IBOutlet UITextField *fieldPhoneNumber;

@property (weak, nonatomic) IBOutlet UIButton *registerButton;

@property (strong, nonatomic) NSDate *lastTextDate;

@property NSString *phoneNumber;
@property NSString *password;

@property BOOL isTextFieldUp;
@end

@implementation RegisterView

@synthesize cellFirstName, cellPassword, cellButton, cellPhoneNumber, cellLastName, password;
@synthesize fieldFirstName, fieldPassword, fieldLasteName, fieldPhoneNumber, phoneNumber;

- (BOOL)textFieldShouldBeginEditing:(UITextField *)textField
{
    _isTextFieldUp = YES;
    PostNotification(NOTIFICATION_DISABLE_SCROLL_WELCOME);
    return YES;
}

- (BOOL)textFieldShouldEndEditing:(UITextField *)textField
{
    _isTextFieldUp = NO;
    PostNotification(NOTIFICATION_ENABLE_SCROLL_WELCOME);
    return YES;
}

- (IBAction)buttonPolicy:(id)sender
{
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Open Safari?" message:@"To view the terms of service and privacy policy, the app will switch to safari." delegate:self cancelButtonTitle:@"Cancel" otherButtonTitles:@"Open", nil];
    alert.tag = 66;
    [alert show];
}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (alertView.tag == 66 && buttonIndex != alertView.cancelButtonIndex)
    {
        [[UIApplication sharedApplication] openURL:[NSURL URLWithString:@"http://volleymessenger.com/terms-of-use/"]];
    }
}

-(IBAction)didSlideRight:(id)sender
{
    if (!_isTextFieldUp)
    {
    PostNotification(NOTIFICATION_SLIDE_MIDDLE_WELCOME);
    }
    else
    {
        [self.view endEditing:1];
    }
}

- (void)viewDidLoad
{
	[super viewDidLoad];
	self.title = @"Register";

    _registerButton.backgroundColor = [UIColor volleyFamousGreen];

    _lastTextDate = nil;

    UIBarButtonItem *item = [[UIBarButtonItem alloc] initWithTitle:@">"
                                                             style:UIBarButtonItemStylePlain target:self action:@selector(didSlideRight:)];
    item.image = [UIImage imageNamed:ASSETS_BACK_BUTTON_RIGHT];
    self.navigationItem.rightBarButtonItem = item;

	[self.view addGestureRecognizer:[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(dismissKeyboard)]];
	self.tableView.separatorInset = UIEdgeInsetsZero;
}


- (void)dismissKeyboard
{
	[self.view endEditing:YES];
}

#pragma mark - User actions

- (IBAction)actionRegister:(id)sender
{
    [self resignKeyboards];

	NSString *nameFirst		= [fieldFirstName.text capitalizedString];
    NSString *nameLast     = [fieldLasteName.text capitalizedString];
    password	= fieldPassword.text;
    phoneNumber = fieldPhoneNumber.text;

    phoneNumber = [phoneNumber stringByReplacingOccurrencesOfString:@" " withString:@""];
    nameFirst	= [nameFirst stringByReplacingOccurrencesOfString:@" " withString:@""];
    nameLast    = [nameLast stringByReplacingOccurrencesOfString:@" " withString:@""];
//  password	= [password stringByReplacingOccurrencesOfString:@" " withString:@""];

    if (phoneNumber.length < 10 || [phoneNumber isEqualToString:@"Phone Number"])
    {
        [ProgressHUD showError:@"Enter Phone Number"];
        return;
    }

	if ((nameFirst.length != 0) && (phoneNumber.length != 0) && (nameLast.length != 0))
    {
        phoneNumber  = [AppConstant formatPhoneNumberForCountry:phoneNumber];

		[ProgressHUD show:@"Searching for users..." Interaction:1];

        PFQuery *query = [PFUser query];
        [query whereKey:PF_USER_USERNAME equalTo:phoneNumber];
        [query findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
            if (!error) {
                if (objects.count == 1)
                {
                    PFUser *user = objects.firstObject;

                    NSString *fullName = [user valueForKey:PF_USER_FULLNAME];

                    if  (fullName.length)
                    {
                         [ProgressHUD showError:@"Phone Number Already Registered"];
                    }
                    else
                    {
                        //USER FOUND BUT NO NAME YET.
                        [PFUser logInWithUsernameInBackground:phoneNumber password:phoneNumber block:^(PFUser *user, NSError *error)
                        {
                            if (!error)
                            {
                            [ProgressHUD show:@"Sending Text..." Interaction:0];
                            //Save name if user logs in.

                            NSString *fullName = [NSString stringWithFormat:@"%@ %@", nameFirst, nameLast];

                                [user setValue:fullName forKey:PF_USER_FULLNAME];
                                [user setValue:[fullName lowercaseString] forKey:PF_USER_FULLNAME_LOWER];

                            [self sendText:user];

                            }
                            else
                            {
                                [ProgressHUD showError:@"Couldn't sign in existing user \n (Email for assistance)"];
                            }
                            }];
                    }
                }
                else if (objects.count == 0)
                {
#warning AVOID STRANGE CIRCUMSTANCE WHERE USER LOGS IN AS UNREGISTERED USER, FAILS VERIFICATION, THEN SIGNS UP AGAIN AND REPLACES THAT USER, STEALING THEIR INBOX.
                    [ProgressHUD show:@"Registering..."];
                    [PFUser logOut];
                    //Make the anonymouse user the current user
                    PFUser *newUser = [PFUser currentUser];

                    if ([phoneNumber isEqualToString:@"0000000000"])
                    {
                        newUser[PF_USER_PHONEVERIFICATIONCODE] = [NSNumber numberWithLongLong:8675309665];
                    }

                    NSString *fullName = [NSString stringWithFormat:@"%@ %@", nameFirst, nameLast];
                    newUser[PF_USER_FULLNAME] = [fullName capitalizedString];
                    newUser[PF_USER_FULLNAME_LOWER] = [fullName lowercaseString];
                    [newUser saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
                        if (succeeded) {
                            [ProgressHUD show:@"Sending Text..." Interaction:0];
                            [self sendText:newUser];
                        } else [ProgressHUD showError:error.userInfo[@"error"] Interaction:1];
                    }];
                }
            } else {
                [ProgressHUD showError:@"Network Error"];
            }
        }];
    }
    else
    {
        [ProgressHUD showError:@"Enter all information"];
    }
}

- (void) sendText:(PFUser *)userFound
{
    NSDictionary *params = [NSDictionary dictionaryWithObject:phoneNumber forKey:@"phoneNumber"];

    [PFCloud callFunctionInBackground:@"sendVerificationCode" withParameters:params block:^(id object, NSError *error)
    {
        if (!error)
        {

            _lastTextDate = [NSDate date];

            [PFQuery clearAllCachedResults];

            [ProgressHUD showSuccess:@"Text Sent"];

            [self sendFirstConversation];

            VerifyTextView *tableview = [[VerifyTextView alloc] initWithStyle:UITableViewStyleGrouped];
            tableview.title = @"Enter Verification Code";
            tableview.lastTextDate = _lastTextDate;
            tableview.user = userFound;
            tableview.password = password;
            tableview.phoneNumber = phoneNumber;
            [self.navigationController pushViewController:tableview animated:1];

        }
        else
        {
#warning Delete user since phone number was invalid? Replaced by anonymouse
        [[PFUser currentUser] deleteInBackground];
        [ProgressHUD showError:[NSString stringWithFormat:@"Texting Number Invalid"] Interaction:1];
        }
    }];
}

-(void)sendFirstConversation
{
// CREATE A CHATROOM FOR THIS NEW USER.

    PFQuery *query = [PFUser query];
    //Hardcoded Value not good.
    [query whereKey:@"objectId" equalTo:@"eNOdQsJx7i"];
    [query findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
        if (!error) {
            if (objects.count == 1)
            {
                PFUser *user = objects.firstObject;

                PFObject *chatroom = [PFObject objectWithClassName:PF_CHATROOMS_CLASS_NAME];
                PFRelation *arrayOfUsers = [chatroom relationForKey:PF_CHATROOMS_USERS];
                NSArray *arrayOfUsersIds = [NSArray arrayWithObjects:user.objectId, [PFUser currentUser].objectId, nil];
                [arrayOfUsers addObject:[PFUser currentUser]];
                [arrayOfUsers addObject:user];
                [chatroom setValue:@"First user" forKey:PF_CHATROOMS_NAME];
                [chatroom setValue:@(3) forKey:PF_CHATROOMS_ROOMNUMBER];
                [chatroom setValue:arrayOfUsersIds forKey:PF_CHATROOMS_USEROBJECTS];
                [chatroom saveInBackground];

                PFObject *set = [PFObject objectWithClassName:PF_SET_CLASS_NAME];
                [set setValue:chatroom forKey:PF_SET_ROOM];
                [set setValue:@(0) forKey:PF_SET_ROOMNUMBER];
                [set setValue:user forKey:PF_SET_USER];
                [set saveInBackground];

                PFObject *set2 = [PFObject objectWithClassName:PF_SET_CLASS_NAME];
                [set2 setValue:chatroom forKey:PF_SET_ROOM];
                [set2 setValue:@(1) forKey:PF_SET_ROOMNUMBER];
                [set2 setValue:user forKey:PF_SET_USER];
                [set2 saveInBackground];

                PFObject *message = [PFObject objectWithClassName:PF_MESSAGES_CLASS_NAME];
                message[PF_MESSAGES_USER] = [PFUser currentUser];
                message[PF_MESSAGES_ROOM] = chatroom;
                message[PF_MESSAGES_DESCRIPTION] = @"Volley Team";
                message[PF_MESSAGES_HIDE_UNTIL_NEXT] = @NO;
                message[PF_MESSAGES_LASTUSER] = user;
                message[PF_MESSAGES_COUNTER] = @(3);
                message[PF_MESSAGES_LASTPICTUREUSER] = user;
                message[PF_MESSAGES_USER_DONOTDISTURB] = [PFUser currentUser];
                message[PF_MESSAGES_LASTMESSAGE] = @"Hey look here!";

                message[PF_MESSAGES_UPDATEDACTION] = [NSDate date];
                [message saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error)
                 {}];

                NSArray *arrayOfSetences1 = @[@"Welcome to Volley!", @"Have fun converstions without all of your photos getting in the way!"];


                NSArray *arrayOfPictures = [NSArray arrayWithObjects:[UIImage imageNamed:@"Chicago1"],[UIImage imageNamed:@"Chicago2"], nil];


                __block int x = (int)arrayOfPictures.count;
                
                for (UIImage *image in arrayOfPictures)
                {
                    PFObject *picture = [PFObject objectWithClassName:PF_PICTURES_CLASS_NAME];
                    UIImage *thumbnail = ResizeImage(image, image.size.width, image.size.height);
                    PFFile *file = [PFFile fileWithName:@"thumbnail.png" data:UIImageJPEGRepresentation(thumbnail, .2)];
                    PFFile *imageFile = [PFFile fileWithName:@"image.png" data:UIImageJPEGRepresentation(image, .5)];
                    [picture setValue:imageFile forKey:PF_PICTURES_PICTURE];
                    [picture setValue:file forKey:PF_PICTURES_THUMBNAIL];
                    [picture setValue:user forKey:PF_PICTURES_USER];
                    [picture setValue:chatroom forKey:PF_PICTURES_CHATROOM];
                    [picture setValue:set forKey:PF_PICTURES_SETID];
                    [picture setValue:@YES forKey:PF_CHAT_ISUPLOADED];
                    [picture setValue:[NSDate dateWithTimeIntervalSinceNow:[arrayOfPictures indexOfObject:image]] forKey:PF_PICTURES_UPDATEDACTION];
                    [picture setValue:set forKey:PF_PICTURES_SETID];
                    [picture saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
                        if (succeeded) {
                            x--;
                            if (x == 0) {
                                message[PF_MESSAGES_LASTPICTURE] = picture;
                                [message saveInBackground];
//                                [self secondSend:user andChatroom:chatroom andSet:set2];
                            }
                        }
                    }];
                }

                for (NSString *string in arrayOfSetences1)
                {
                    PFObject *comment = [PFObject objectWithClassName:PF_CHAT_CLASS_NAME];
                    [comment setValue:user forKey:PF_CHAT_USER];
                    [comment setValue:string forKey:PF_CHAT_TEXT];
                    [comment setValue:chatroom forKey:PF_CHAT_ROOM];
                    [comment setValue:set forKey:PF_CHAT_SETID];
                    [comment setValue:[NSDate dateWithTimeIntervalSinceNow:[arrayOfSetences1 indexOfObject:string]] forKey:PF_PICTURES_UPDATEDACTION];
                    [comment saveInBackground];
                }

                [self secondSend:user andChatroom:chatroom andSet:set2];

                [self sendLastWithChatroom:chatroom User:user];
            }
        }
    }];
}

-(void) secondSend:(PFUser *)user andChatroom:(PFObject *)chatroom andSet:(PFObject *)set2
{
    NSArray *arrayOfSetences2 = @[@"Click here to see a conversation about a specific set of photos.", @"All the comments here will be the same color for this set."];

    NSArray *arrayOfPictures2 = [NSArray arrayWithObjects:[UIImage imageNamed:@"Chicago3"],[UIImage imageNamed:@"Chicago4"], nil];

    for (NSString *string in arrayOfSetences2)
    {
        PFObject *comment = [PFObject objectWithClassName:PF_CHAT_CLASS_NAME];
        [comment setValue:user forKey:PF_CHAT_USER];
        [comment setValue:string forKey:PF_CHAT_TEXT];
        [comment setValue:chatroom forKey:PF_CHAT_ROOM];
        [comment setValue:set2 forKey:PF_CHAT_SETID];
        [comment setValue:[NSDate dateWithTimeIntervalSinceNow:2 + [arrayOfSetences2 indexOfObject:string]] forKey:PF_PICTURES_UPDATEDACTION];
        [comment saveInBackground];
    }



    __block int x = (int)arrayOfPictures2.count;

    for (UIImage *image in arrayOfPictures2)
    {
        PFObject *picture = [PFObject objectWithClassName:PF_PICTURES_CLASS_NAME];
        UIImage *thumbnail = ResizeImage(image, image.size.width, image.size.height);
        PFFile *file = [PFFile fileWithName:@"thumbnail.png" data:UIImageJPEGRepresentation(thumbnail, .2)];
        PFFile *imageFile = [PFFile fileWithName:@"image.png" data:UIImageJPEGRepresentation(image, .5)];
        [picture setValue:imageFile forKey:PF_PICTURES_PICTURE];
        [picture setValue:file forKey:PF_PICTURES_THUMBNAIL];
        [picture setValue:user forKey:PF_PICTURES_USER];
        [picture setValue:chatroom forKey:PF_PICTURES_CHATROOM];
        [picture setValue:set2 forKey:PF_PICTURES_SETID];
        [picture setValue:@YES forKey:PF_CHAT_ISUPLOADED];
        [picture setValue:[NSDate dateWithTimeIntervalSinceNow:2 + [arrayOfPictures2 indexOfObject:image]] forKey:PF_PICTURES_UPDATEDACTION];
        [picture saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
            if (succeeded) {
                x--;
                if (x == 0) {
//                    [self sendLastWithChatroom:chatroom User:user];
                }
            }
        }];
    }
}

- (void) sendLastWithChatroom:(PFObject *)chatroom User:(PFObject *)user
{

    NSString *blankComment = @"Or create a new set of photos.  They will appear in a different color!  This is gray because it is not tagged to a photo.";
        PFObject *comment = [PFObject objectWithClassName:PF_CHAT_CLASS_NAME];
        [comment setValue:user forKey:PF_CHAT_USER];
        [comment setValue:blankComment forKey:PF_CHAT_TEXT];
        [comment setValue:chatroom forKey:PF_CHAT_ROOM];
        [comment setValue:[NSDate dateWithTimeIntervalSinceNow:3] forKey:PF_PICTURES_UPDATEDACTION];
        [comment saveInBackground];
    

    PFObject *set3 = [PFObject objectWithClassName:PF_SET_CLASS_NAME];
    [set3 setValue:chatroom forKey:PF_SET_ROOM];
    [set3 setValue:@(2) forKey:PF_SET_ROOMNUMBER];
    [set3 setValue:user forKey:PF_SET_USER];
    [set3 saveInBackground];

    UIImage *imagee = [UIImage imageNamed:@"Chicago5"];

    for (UIImage *image in @[imagee])
    {
        PFObject *picture = [PFObject objectWithClassName:PF_PICTURES_CLASS_NAME];
        UIImage *thumbnail = ResizeImage(image, image.size.width, image.size.height);
        PFFile *file = [PFFile fileWithName:@"thumbnail.png" data:UIImageJPEGRepresentation(thumbnail, .2)];
        PFFile *imageFile = [PFFile fileWithName:@"image.png" data:UIImageJPEGRepresentation(image, .5)];
        [picture setValue:imageFile forKey:PF_PICTURES_PICTURE];
        [picture setValue:file forKey:PF_PICTURES_THUMBNAIL];
        [picture setValue:user forKey:PF_PICTURES_USER];
        [picture setValue:chatroom forKey:PF_PICTURES_CHATROOM];
        [picture setValue:set3 forKey:PF_PICTURES_SETID];
        [picture setValue:@YES forKey:PF_CHAT_ISUPLOADED];
        [picture setValue:[NSDate dateWithTimeIntervalSinceNow:3 ] forKey:PF_PICTURES_UPDATEDACTION];
        [picture saveInBackground];
    }

    NSString *string3 = @"You can also save your new photos to an album by clicking the star button!";

    for (NSString *string in @[string3])
    {
        PFObject *comment = [PFObject objectWithClassName:PF_CHAT_CLASS_NAME];
        [comment setValue:user forKey:PF_CHAT_USER];
        [comment setValue:string forKey:PF_CHAT_TEXT];
        [comment setValue:chatroom forKey:PF_CHAT_ROOM];
        [comment setValue:set3 forKey:PF_CHAT_SETID];
        [comment setValue:[NSDate dateWithTimeIntervalSinceNow:3] forKey:PF_PICTURES_UPDATEDACTION];
        [comment saveInBackground];
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

#pragma mark - Table view data source

-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 3;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if (section == 0)
    {
        return 2;
    }
    else
    {
        return 1;
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.section != 2)
    {
        return 60;
    }
    else
    {
        return 90;
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.section == 0)
    {

    if (indexPath.row == 0) return cellFirstName;
    if (indexPath.row == 1) return cellLastName;

    } else if (indexPath.section == 1) {

    if(indexPath.row == 0) return cellPhoneNumber;
//    if(indexPath.row == 1) return cellPassword;

    } else if (indexPath.section == 2) return cellButton;
    return nil;
}

#pragma mark - UITextField delegate
- (void) resignKeyboards
{
    [self.view endEditing:1];
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
	if (textField == fieldFirstName)
	{
		[fieldLasteName becomeFirstResponder];
	}
   else if (textField == fieldLasteName)
    {
        [fieldPhoneNumber becomeFirstResponder];
    }
   else if (textField == fieldPhoneNumber)
    {
        [fieldPassword becomeFirstResponder];
        [self actionRegister:0];
        [textField resignFirstResponder];
    }
//	else if (textField == fieldPassword)
//	{
//        [self actionRegister:nil];
//        [textField resignFirstResponder];
//    }
	return YES;
}

@end
