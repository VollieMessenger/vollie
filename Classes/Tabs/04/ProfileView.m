

#import <Parse/Parse.h>

#import <ParseUI/ParseUI.h>

#import "ProgressHUD.h"

#import "AppConstant.h"

//#import "camera.h"

#import "pushnotification.h"

#import "utilities.h"

#import "AppDelegate.h"

#import "ProfileView.h"

#import "MasterLoginRegisterView.h"

@interface ProfileView () <UITextFieldDelegate>

@property (strong, nonatomic) IBOutlet UITableViewCell *cellName;

@property (strong, nonatomic) IBOutlet UITableViewCell *cellPhoneNumber;

@property (strong, nonatomic) IBOutlet UITableViewCell *cellTOS;

@property (strong, nonatomic) IBOutlet UITableViewCell *cellPP;

@property (strong, nonatomic) IBOutlet UITableViewCell *nameCell;

@property (weak, nonatomic) IBOutlet UITextField *nameTextField;

@property (strong, nonatomic) IBOutlet UITextField *fieldPhoneNumber;

@property (strong, nonatomic) IBOutlet UITableViewCell *cellButton;

@property (strong, nonatomic) IBOutlet UITableViewCell *cellVibrate;

@property (strong, nonatomic) IBOutlet UITextField *fieldName;

@property (strong, nonatomic) IBOutlet UISwitch *switchVibrate;

@property (strong, nonatomic) IBOutlet UIButton *buttonLogout;

@property UIActionSheet *changeNameActionSheet;

@property NSString *userNameString;

@end

@implementation ProfileView

@synthesize cellName, cellButton, cellVibrate;

@synthesize fieldName;


- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    [textField resignFirstResponder];
    
    NSString *changeNameString = [NSString stringWithFormat:@"Are you sure you want to change your name to %@? Your name will be seen like this by all users.", self.userNameString];
    self.changeNameActionSheet = [[UIActionSheet alloc] initWithTitle:changeNameString delegate:self cancelButtonTitle:@"Cancel" destructiveButtonTitle:nil
                                               otherButtonTitles:@"Change Name", nil];
    [self.changeNameActionSheet showInView:self.view];
//    [action showInView:self.view];
    
//    [self changeUsername];
    return YES;
}

- (void)viewDidDisappear:(BOOL)animated
{
    [super viewDidDisappear:animated];
    PostNotification(NOTIFICATION_ENABLESCROLLVIEW);
}

- (void)viewDidLoad
{
    _buttonLogout.backgroundColor = [UIColor whiteColor];

	[super viewDidLoad];

    self.tableView.alwaysBounceVertical = YES;
    
    self.nameTextField.delegate = self;
    
    self.nameTextField.layer.borderWidth = 0;
    self.nameTextField.borderStyle = UITextBorderStyleNone;

    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(actionDismiss) name:NOTIFICATION_CLICKED_PUSH object:0];

    cellButton.backgroundColor = [UIColor clearColor];

    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    if ([userDefaults boolForKey:PF_KEY_SHOULDVIBRATE]) {
        [_switchVibrate setOn:1 animated:1];
    } else {
        [_switchVibrate setOn:0 animated:1];
    }

	self.title = @"Settings";

//   UIBarButtonItem *close =  [[UIBarButtonItem alloc] initWithTitle:@"Close " style:UIBarButtonItemStyleDone target:self
//                                    action:@selector(actionDismiss)];
////    close.image = [UIImage imageNamed:ASSETS_CLOSE];
//    self.navigationItem.rightBarButtonItem = close;

	[self.view addGestureRecognizer:[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(dismissKeyboard)]];
    self.tableView.separatorInset = UIEdgeInsetsZero;

    UIPanGestureRecognizer *pan = [UIPanGestureRecognizer new];
    [self.view addGestureRecognizer:pan];

    if ([PFUser currentUser] != nil)
    {
        [self profileLoad];
    }
}

- (void)viewDidAppear:(BOOL)animated
{
	[super viewDidAppear:animated];

}

- (void)dismissKeyboard
{
	[self.view endEditing:YES];
}

- (void)profileLoad
{
	PFUser *user = [PFUser currentUser];
    [user fetchIfNeededInBackgroundWithBlock:^(PFObject *object, NSError *error)
    {
        self.nameTextField.placeholder =  [NSString stringWithFormat:@"%@", object[PF_USER_FULLNAME]];
        self.userNameString = object[PF_USER_FULLNAME];
    }];

}

#pragma mark - User actions

- (IBAction)actionLogout:(id)sender
{
	UIActionSheet *action = [[UIActionSheet alloc] initWithTitle:nil delegate:self cancelButtonTitle:@"Cancel" destructiveButtonTitle:nil
											   otherButtonTitles:@"Logout", nil];
    [action showInView:self.view];
}


//Not used
- (IBAction) actionDelete
{
//PFCloud *cloud = [PFCloud callFunction:@"DeleteAll" withParameters:0];
#warning FETCHING OTHER CLASSES TOO????
    PFQuery *query = [PFQuery queryWithClassName:PF_CHAT_CLASS_NAME];
    [query findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
        if (!error) {
        [objects.firstObject deleteInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
            if (error) {
                [ProgressHUD showError:@"Your not Neo"];
                return;
            } else {
                for (PFObject *object in objects) {
                    [object deleteInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
                        if (!error && object == objects.lastObject) {
                            [self dismissViewControllerAnimated:1 completion:0];
                            [ProgressHUD showSuccess:@"Deleted All Chats"];
                            [query clearCachedResult];
                        }
                    }];
                }
            }
            }];
        } else {
            [ProgressHUD showError:@"Network Error"];
        }
    }];
}

- (void)actionDismiss
{
    [self dismissViewControllerAnimated:1 completion:0];
}

#pragma mark - UIActionSheetDelegate

- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex
{
	if (buttonIndex != actionSheet.cancelButtonIndex)
	{
        if (actionSheet == self.changeNameActionSheet)
        {
            [self changeUsername];
        }
        else
        {
            [PFUser logOut];
            fieldName.text = @"";
            ParsePushUserResign();
            [self.navigationController showDetailViewController:[MasterLoginRegisterView new] sender:self];
    //        [self dismissViewControllerAnimated:1 completion:^{
    //            PostNotification(NOTIFICATION_USER_LOGGED_OUT);
    //        }];
            [self.navigationController popToRootViewControllerAnimated:YES];
        }
    }
}

- (IBAction)switchVibrate:(UISwitch *)sender
{
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    if (sender.isOn) {
         [userDefaults setBool:YES forKey:PF_KEY_SHOULDVIBRATE];
    } else {
        [userDefaults setBool:NO forKey:PF_KEY_SHOULDVIBRATE];
    }
    [userDefaults synchronize];
}

- (IBAction)TOS
{
    UIViewController *tos = [[UIViewController alloc] init];
    UIWebView *webView = [[UIWebView alloc] initWithFrame:tos.view.frame];
    [webView loadRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:@"http://volliemessenger.com/terms-of-use/"]]];
    webView.backgroundColor = [UIColor whiteColor];
    [tos.view addSubview:webView];
    tos.title = @"Terms Of Service";
    [self.navigationController pushViewController:tos animated:1];
}

- (IBAction)PP
{
    UIViewController *pp = [[UIViewController alloc] init];
    UIWebView *webView = [[UIWebView alloc] initWithFrame:pp.view.frame];
    [webView loadRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:@"http://volliemessenger.com/privacy-policy/"]]];
    webView.backgroundColor = [UIColor whiteColor];
    [pp.view addSubview:webView];
    pp.title = @"Privacy Policy";
    [self.navigationController pushViewController:pp animated:1];
}


-(void)changeUsername
{
    if ([self.nameTextField.text isEqualToString:@""] == NO)
    {
        [ProgressHUD show:@"Please wait..."];
        
        PFUser *user = [PFUser currentUser];
        user[PF_USER_FULLNAME] = self.nameTextField.text;
        user[PF_USER_FULLNAME_LOWER] = [self.nameTextField.text lowercaseString];
        
        [user saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error)
         {
             if (error == nil)
             {
//                 [self.navigationController popViewControllerAnimated:0];
                 [ProgressHUD showSuccess:@"Saved."];
             }
             else [ProgressHUD showError:@"Network error."];
         }];
    }
    else [ProgressHUD showError:@"Name field must be set."];
}


//- (IBAction)actionSave:(id)sender
//{
////	[self dismissKeyboard];
//    [self.navigationController popViewControllerAnimated:0];
//    return;
//
//	if ([fieldName.text isEqualToString:@""] == NO)
//	{
//		[ProgressHUD show:@"Please wait..."];
//
//		PFUser *user = [PFUser currentUser];
//		user[PF_USER_FULLNAME] = fieldName.text;
//		user[PF_USER_FULLNAME_LOWER] = [fieldName.text lowercaseString];
//
//		[user saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error)
//		{
//			if (error == nil)
//			{
//                [self.navigationController popViewControllerAnimated:0];
//                [ProgressHUD showSuccess:@"Saved."];
//			}
//			else [ProgressHUD showError:@"Network error."];
//		}];
//	}
//	else [ProgressHUD showError:@"Name field must be set."];
//}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
	return 4;
}


- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if (section == 2) return 2;
    else return 1;
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.section == 0)
    {
        if (indexPath.row == 0) return self.nameCell;
//        if (indexPath.row == 1) return _cellPhoneNumber;
    }
    if (indexPath.section == 1) return cellVibrate;

    if (indexPath.section == 2)
    {
        if (indexPath.row == 0) return _cellTOS;
        if (indexPath.row == 1) return _cellPP;
    }
    if (indexPath.section == 3) return cellButton;
	return nil;
}

@end
