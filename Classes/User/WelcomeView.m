
#import <Parse/Parse.h>
#import "ProgressHUD.h"
#import "WelcomeView.h"

#import "AppConstant.h"
#import "pushnotification.h"
#import "utilities.h"

@implementation WelcomeView

- (void)viewDidLoad
{
	[super viewDidLoad];
	self.title = @"Welcome";

	UIBarButtonItem *backButton = [[UIBarButtonItem alloc] initWithTitle:@"Back" style:UIBarButtonItemStylePlain target:nil action:nil];
	[self.navigationItem setBackBarButtonItem:backButton];
}

-(void)viewWillAppear:(BOOL)animated {
       self.navigationController.navigationBarHidden= 1;
}

-(void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:1];
}

#pragma mark - User actions

- (IBAction)actionRegister:(id)sender
{
    [self.scrollView setContentOffset:CGPointMake(0, 0) animated:1];
}

- (IBAction)actionLogin:(id)sender
{
    [self.scrollView setContentOffset:CGPointMake(self.view.frame.size.width * 2, 0) animated:1];
}
- (void)userLoggedIn:(PFUser *)user
{
	[ProgressHUD showSuccess:[NSString stringWithFormat:@"Welcome back %@!", user[PF_USER_FULLNAME]]];
	[self dismissViewControllerAnimated:YES completion:nil];
}

@end
