//
//  MainInboxVC.m
//  Volley
//
//  Created by Kyle Bendelow on 8/4/15.
//  Copyright (c) 2015 KZ. All rights reserved.
//

#import "MainInboxVC.h"
#import "AppConstant.h"
#import "AppDelegate.h"
#import <Parse/Parse.h>
#import "messages.h"
#import "NSDate+TimeAgo.h"
#import "ProgressHUD.h"
#import "RoomCell.h"
#import "MomentsVC.h"
#import "MasterLoginRegisterView.h"
#import "CustomCameraView.h"
#import "ParseVolliePackage.h"
#import "NewVollieVC.h"
#import "ProfileView.h"
#import "InviteContactsCell.h"
#import "CreateChatroomView.h"
#import "WeekHighlightsVC.h"

@interface MainInboxVC () <UITableViewDelegate, UITableViewDataSource, RefreshMessagesDelegate, PushToCardDelegate, UIScrollViewDelegate, UIGestureRecognizerDelegate>

//visual properties
@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (weak, nonatomic) IBOutlet UIImageView *imageViewInButton;
@property (weak, nonatomic) IBOutlet UIImageView *imageViewInButtonRight;

//random properties
@property BOOL isCurrentlyLoadingMessages;
@property BOOL firstTimeLoading;

//refresh control
@property  UIRefreshControl *refreshControl;
@property UIView *refreshLoadingView;
@property UIView *refreshColorView;
@property UIImageView *compassSpinner;
@property UIImageView *compassBackground;
@property BOOL isRefreshIconsOverlap;
@property BOOL isRefreshAnimating;
@property BOOL isRefreshingUp;
@property BOOL isRefreshingDown;

//for the touch and hold to rename and delete
@property PFObject *messageToRenameDelete;
@property UILongPressGestureRecognizer *longPress;
@property UITapGestureRecognizer *tap;

//@property MomentsVC *cardViewVC;

//arrays
//@property NSMutableArray *messagesObjectIds;
//@property NSMutableArray *savedDates;
//@property NSMutableDictionary *savedMessagesForDate;


@end

@implementation MainInboxVC

- (void)viewDidLoad
{
    [super viewDidLoad];
    [self setUpUserInterface];
    [self basicSetUpAfterLoad];
    self.firstTimeLoading = YES;
//    [self refreshMessages];
}

-(void)viewWillAppear:(BOOL)animated
{
    [self setNavBarColor];
    self.scrollView.scrollEnabled = YES;
}

-(void)viewDidAppear:(BOOL)animated
{
    [self refreshMessages];
//    NSLog(@"%@", self.scrollView);
}

-(void)viewWillDisappear:(BOOL)animated
{
    self.scrollView.scrollEnabled = NO;
}

#pragma mark "User Interface and Interaction"

-(void)basicSetUpAfterLoad
{
    self.isCurrentlyLoadingMessages = false;
    [self setupRefreshControl];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(refreshMessages) name:NOTIFICATION_USER_LOGGED_OUT object:0];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(refreshMessages) name:NOTIFICATION_USER_LOGGED_IN object:0];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(enableScrollview:) name:NOTIFICATION_ENABLESCROLLVIEW object:0];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(disableScrollView:) name:NOTIFICATION_DISABLESCROLLVIEW object:0];
}

-(void)setUpUserInterface
{
    UIImageView *imageViewVolley = [[UIImageView alloc] init];
    imageViewVolley.image = [UIImage imageNamed:@"volley"];
    
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Storyboard" bundle:nil];
    self.cardViewVC = (MomentsVC *)[storyboard instantiateViewControllerWithIdentifier:@"CardVC"];

    self.navigationItem.titleView = imageViewVolley;
    self.navigationItem.titleView.alpha = 1;
    //    self.navigationItem.titleView.frame = CGRectMake(0, 0, self.view.frame.size.width, (53 - ([number intValue] * [number intValue])));
    self.navigationItem.titleView.frame = CGRectMake(0, 0, 250, 44);
    self.title = @"";
    self.view.backgroundColor = [UIColor whiteColor];
    UIBarButtonItem *favoritesButton = [[UIBarButtonItem alloc] initWithTitle:@"Fav"
                                                             style:UIBarButtonItemStyleBordered target:self action:@selector(swipeRightToFavorites:)];
//    favoritesButton.image = [UIImage imageNamed:@"settings"];
    favoritesButton.image = [UIImage imageNamed:ASSETS_STAR_ON];
    self.navigationItem.rightBarButtonItem = favoritesButton;
    UIBarButtonItem *cameraButton =[[UIBarButtonItem alloc] initWithTitle:@"Cam" style:UIBarButtonItemStyleBordered target:self action:@selector(swipeLeftToCamera:)];
    cameraButton.image = [UIImage imageNamed:ASSETS_NEW_CAMERA];
    self.navigationItem.leftBarButtonItem = cameraButton;
    [self setNavBarColor];
    
    self.imageViewInButton.layer.cornerRadius = 10;
    self.imageViewInButton.layer.masksToBounds = YES;
    self.imageViewInButtonRight.layer.cornerRadius = 10;
    self.imageViewInButtonRight.layer.masksToBounds = YES;
    self.imageViewInButtonRight.hidden = YES;
    
    self.longPress = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(longPress:)];
    [self.view addGestureRecognizer:self.longPress];
}

-(void)setNavBarColor
{
    [self.navigationController.navigationBar setTintColor:[UIColor colorWithWhite:.98 alpha:1]];
    [self.navigationController.navigationBar setBarTintColor:[UIColor volleyFamousGreen]];
    [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleLightContent animated:1];
    self.navigationController.navigationBar.titleTextAttributes =  @{
                                                                     NSForegroundColorAttributeName: [UIColor whiteColor],
                                                                     NSFontAttributeName: [UIFont fontWithName:@"Helvetica Neue" size:20.0f],
                                                                     NSShadowAttributeName:[NSShadow new]
                                                                     };
}

-(void) swipeRightToFavorites:(UIBarButtonItem *)button
{
    [self.scrollView setContentOffset:CGPointMake(self.view.frame.size.width * 2, 0) animated:1];
}

- (void)swipeLeftToCamera:(UIBarButtonItem *)button
{
    [self.scrollView setContentOffset:CGPointMake(0, 0) animated:YES];
}

- (IBAction)onNewMessageButtonTapped:(id)sender
{
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Storyboard" bundle:nil];
    NewVollieVC *vc = (NewVollieVC *)[storyboard instantiateViewControllerWithIdentifier:@"NewVollieVC"];
    [[NSNotificationCenter defaultCenter] postNotificationName:@"clearText" object:nil];
    ParseVolliePackage *package = [ParseVolliePackage new];
    package.refreshDelegate = self;
    vc.package = package;
    
    [self.navigationController pushViewController:vc animated:YES];
}
#pragma mark "Parse Stuff"

-(void)loadInbox
{
    if ([PFUser currentUser] && self.isCurrentlyLoadingMessages == NO)
    {
//        NavigationController *navFavorites = [(AppDelegate *)[[UIApplication sharedApplication] delegate] navFavorites];
//        WeekHighlightsVC *vc = (WeekHighlightsVC*)navFavorites.viewControllers.firstObject;
        self.isCurrentlyLoadingMessages = YES;
        
        //should change this to RoomObject.h
        PFQuery *query = [PFQuery queryWithClassName:PF_MESSAGES_CLASS_NAME];
        [query whereKey:PF_MESSAGES_USER equalTo:[PFUser currentUser]];
        //      [query includeKey:PF_MESSAGES_LASTUSER];
        [query includeKey:PF_MESSAGES_ROOM];
        [query includeKey:PF_MESSAGES_USER]; // doesn't need to be here
        [query includeKey:PF_MESSAGES_LASTPICTURE];
        [query includeKey:PF_MESSAGES_LASTPICTUREUSER];
        [query whereKey:PF_MESSAGES_HIDE_UNTIL_NEXT equalTo:@NO];
        [query orderByDescending:PF_MESSAGES_UPDATEDACTION];
        [query setCachePolicy:kPFCachePolicyCacheThenNetwork];
        [query findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error)
         {
             if (!error)
             {
                 [self clearMessageArrays];
                 for (PFObject *message in objects)
                 {
                     if ([[message valueForKey:PF_MESSAGES_LASTMESSAGE] isEqualToString:@""] && ![message valueForKey:PF_MESSAGES_LASTPICTURE])
                     {
                         //this hides messages that have neither a message or picture yet
                         //i'd like to make this cleaner and actually delete it off of parse, but this works for now
                     }
                     else
                     {
                         [self.messages addObject:message];
                     }
                 }
                 [self.tableView reloadData];
                 self.isCurrentlyLoadingMessages = NO;
                 if (self.firstTimeLoading)
                 {
                     NavigationController *navFavorites = [(AppDelegate *)[[UIApplication sharedApplication] delegate] navFavorites];
                     WeekHighlightsVC *vc = (WeekHighlightsVC*)navFavorites.viewControllers.firstObject;
                     [vc loadRoomsFromMainInbox];
                     self.firstTimeLoading = NO;
                 }
             }
             else
             {
                 if ([query hasCachedResult])
                 {
                     if (self.navigationController.visibleViewController == self)
                     {
                         [self.refreshControl endRefreshing];
                         [ProgressHUD showError:@"Network error."];
                     }
                 }
             }
             [self.tableView reloadData];
             [self.refreshControl endRefreshing];
         }];
        
    }
}

- (void)clearMessageArrays
{
    //let's see if we really need this
    self.messages = [NSMutableArray new];
//    self.savedDates = [NSMutableArray new];
//    self.savedMessagesForDate = [NSMutableDictionary new];
//    self.messagesObjectIds = [NSMutableArray new];
}

#pragma mark "TableView Stuff"

- (UITableViewCellEditingStyle)tableView:(UITableView *)aTableView editingStyleForRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Detemine if it's in editing mode
    if (self.tableView.editing)
    {
        return UITableViewCellEditingStyleDelete;
    }
    
    return UITableViewCellEditingStyleNone;
}


-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
//    if (self.messages.count)
//    {
        return self.messages.count + 1;
//    }
//    else
//    {
//        return 0;
//    }
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.row < self.messages.count)
    {
        RoomCell *cell = [tableView dequeueReusableCellWithIdentifier:@"cellID" forIndexPath:indexPath];
        PFObject *room = self.messages[indexPath.row];
        [cell formatCellWith:room];
        return cell;
    }
    else
    {
        [self.tableView registerNib:[UINib nibWithNibName:@"InviteContactsCell" bundle:0] forCellReuseIdentifier:@"InviteContactsCell"];
        InviteContactsCell *cell = [tableView dequeueReusableCellWithIdentifier:@"InviteContactsCell"];
        return cell;
    }
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:1];
    if (indexPath.row < self.messages.count)
    {
        RoomCell *cell = (RoomCell*)[tableView cellForRowAtIndexPath:indexPath];
        
        PFObject *room = self.messages[indexPath.row];
        PFObject *customChatRoom = [room objectForKey:PF_MESSAGES_ROOM];
        
        UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Storyboard" bundle:nil];
        MomentsVC *cardViewController = (MomentsVC *)[storyboard instantiateViewControllerWithIdentifier:@"CardVC"];
        cardViewController.name = cell.chatRoomLabel.text;
        cardViewController.room = customChatRoom;
        cardViewController.messageItComesFrom = room;
        [self.navigationController pushViewController:cardViewController animated:YES];
    }
    else
    {
        CreateChatroomView * view = [[CreateChatroomView alloc]init];
        view.title = @"ahhhhh";
        view.isTherePicturesToSend = NO;
        view.invite = YES;
        [self.navigationController pushViewController:view animated:YES];
        return;
    }
}


#pragma mark "Longtouch to edit/delete"
- (void)longPress:(UILongPressGestureRecognizer *)longPressss
{
    CGPoint point = [longPressss locationInView:self.tableView];
    
    UITableViewCell *cell = [self.tableView cellForRowAtIndexPath:[self.tableView indexPathForRowAtPoint:point]];
    if (cell)
    {
        //do we need if?
        [self.tableView setEditing:1 animated:1];
        self.tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(didTap:)];
        self.tap.delegate = self;
        [self.tableView addGestureRecognizer:self.tap];
    }
}

- (void)didTap:(UITapGestureRecognizer *)tapppppp
{
    CGPoint point = [tapppppp locationInView:self.tableView];
    
    if (point.x > 50 && self.tap)
    {
        [self.tableView setEditing:0 animated:1];
        [self.tableView removeGestureRecognizer:self.tap];
        self.tap = nil;
    }
}

- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldReceiveTouch:(UITouch *)touch
{
    //This is called ALWAYS because of longPress???
    CGPoint point = [touch locationInView:self.view];
    
    if (self.tableView.editing)
    {
        if (point.x < 50)
        {
            //Let the button work
            return NO;
        }
        else
        {
            return YES;
        }
    }
    else
    {
        return NO;
    }
}

- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
    return YES;
}

-(NSArray *)tableView:(UITableView *)tableView editActionsForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewRowAction *button = [UITableViewRowAction rowActionWithStyle:UITableViewRowActionStyleDefault title:@"Delete" handler:^(UITableViewRowAction *action, NSIndexPath *indexPath)
    {
        [self.tableView setEditing:0 animated:1];
        PFObject *message = [self.messages objectAtIndex:indexPath.row];
        [message setValue:@YES forKey:PF_MESSAGES_HIDE_UNTIL_NEXT];
        [message saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
            if (!error)
            {
                //Remove all traces of messages
                [self.messages removeObject:message];
                
                //Animation
                [self.tableView beginUpdates];
                [self.tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationAutomatic];
                [self.tableView endUpdates];
            }
        }];
    }];
    button.backgroundColor = [UIColor redColor];
    
    UITableViewRowAction *button2 = [UITableViewRowAction rowActionWithStyle:UITableViewRowActionStyleDefault title:@"Rename" handler:^(UITableViewRowAction *action, NSIndexPath *indexPath)
    {
        [self.tableView setEditing:0 animated:1];
        self.messageToRenameDelete = [self.messages objectAtIndex:indexPath.row];
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Rename..." message:0 delegate:self cancelButtonTitle:@"Cancel" otherButtonTitles:@"Rename", nil];
        alert.alertViewStyle = UIAlertViewStylePlainTextInput;
        if (self.messageToRenameDelete[PF_MESSAGES_NICKNAME])
        {
            [alert textFieldAtIndex:0].text = [self.messageToRenameDelete valueForKey:PF_ALBUMS_NICKNAME];
        }
        [alert show];
        
    }];
    
    button2.backgroundColor = [UIColor colorWithRed:.75f green:.75f blue:.75f alpha:1]; //arbitrary color
    return @[button, button2]; //array with all the buttons you want. 1,2,3, etc...
}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    
    if (buttonIndex != alertView.cancelButtonIndex && [alertView textFieldAtIndex:0].hasText)
    {
        NSLog(@"you clicked rename");
//        NSString *string = [alertView textFieldAtIndex:0].text;
        [self.messageToRenameDelete setValue:[alertView textFieldAtIndex:0].text forKey:PF_MESSAGES_NICKNAME];
        [self.messageToRenameDelete saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error)
        {
            if (succeeded)
            {
                [self.tableView setEditing:0 animated:1];
                [self.tableView reloadData];
                [ProgressHUD showSuccess:@"Renamed"];
            }
            else
            {
                [ProgressHUD showError:@"Connectivity Issues"];
            }
        }];

    }
}

#pragma mark "Crazy Other Methods"

- (void)refreshMessages
{
    if ([[[PFUser currentUser] valueForKey:PF_USER_ISVERIFIED] isEqualToNumber:@YES])
    {
        [self loadInbox];
    }
    else
    {
        //Error when app starts and no user logged in, when user registers, the inbox is gone. Might user super VC to present this MasterView.
        [self.navigationController showDetailViewController:[MasterLoginRegisterView new] sender:self];
        [self.scrollView setContentOffset:CGPointMake(self.view.frame.size.width, 0) animated:1];
        [self clearMessageArrays];
    }
}

-(void)pushToCard
{
//    self.scrollView.scrollEnabled = NO;
    [self reloadAfterMessageSuccessfullySent];
}

-(void)reloadAfterMessageSuccessfullySent
{
    //needs to send user to new vollie page
    NSLog(@"refreshed messages");
//    [self refreshMessages];
    [self performSelector:@selector(loadInbox) withObject:nil afterDelay:1.0];
//    NSLog(@"About to Push to Card 0");
//    if (!self.isCurrentlyLoadingMessages)
//    {
//        [self performSelector:@selector(goToCardViewWithMessage) withObject:self afterDelay:2.0f];
//    }
//    else
//    {
//        [self performSelector:@selector(delayedGoToCardWithMessage) withObject:self afterDelay:1.0f];
//        [self.tableView reloadData];
//    }
    [self.cardViewVC reloadCardsAfterUpload];
}

//-(void)delayedGoToCardWithMessage
//{
//    [self performSelector:@selector(goToCardViewWithMessage) withObject:self afterDelay:2.0f];
//}

-(void)newGoToCardViewWith:(PFObject*)userChatRoom and:(PFObject*)room
{
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Storyboard" bundle:nil];
    self.cardViewVC = (MomentsVC *)[storyboard instantiateViewControllerWithIdentifier:@"CardVC"];
    self.cardViewVC.room = room;
    self.cardViewVC.messageItComesFrom = userChatRoom;
    self.cardViewVC.shouldShowTempCard = YES;
    [self.navigationController pushViewController:self.cardViewVC animated:NO];
}

-(void)goToCardViewWithMessage
{
//    self.scrollView.scrollEnabled = YES;
    PFObject *message = [self.messages objectAtIndex:0];
    PFObject *room = [message objectForKey:PF_MESSAGES_ROOM];
//    RoomCell *cell = (RoomCell*)[self.tableView cellForRowAtIndexPath:0];

//    NSString *nameString = cell.room
//    selectedRoom = room.objectId;
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Storyboard" bundle:nil];
    MomentsVC *cardViewController = (MomentsVC *)[storyboard instantiateViewControllerWithIdentifier:@"CardVC"];
    ////    cardViewController.name = cell.labelDescription.text;
    cardViewController.room = room;
//    cardViewController.name = cell.chatRoomLabel.text;
//    NSLog(@"%@", cell.chatRoomLabel.text);
    cardViewController.messageItComesFrom = message;
//    self.scrollView.scrollEnabled = YES;
    [self.navigationController pushViewController:cardViewController animated:YES];
}

- (void)enableScrollview:(NSNotification *)notification
{
    self.scrollView.scrollEnabled = YES;
}

- (void)disableScrollView:(NSNotification *)notification
{
    self.scrollView.scrollEnabled = NO;
}

//-(void)goToSettingsVC:(id)id
//{
////    NavigationController *nav = [[NavigationController alloc] initWithRootViewController: [[ProfileView alloc] initWithStyle:UITableViewStyleGrouped]];
//    
//    ProfileView *vc = [[ProfileView alloc] initWithStyle:UITableViewStyleGrouped];
//    [self.navigationController pushViewController:vc animated:YES];
////    [self showDetailViewController:nav sender:self];
//}

-(void)goToMostRecentChatRoom
{
//    NSLog(@"test success");
    self.scrollView.scrollEnabled = NO;
    [self refreshMessages];
    [self performSelector:@selector(goToCardViewWithMessage) withObject:self afterDelay:1.0f];
}

#pragma mark "Refresh Control"
- (void)setupRefreshControl
{
    // Programmatically inserting a UIRefreshControl
    self.refreshControl = [[UIRefreshControl alloc] init];
    
    // Setup the loading view, which will hold the moving graphics
    self.refreshLoadingView = [[UIView alloc] initWithFrame:self.refreshControl.bounds];
    self.refreshLoadingView.backgroundColor = [UIColor clearColor];
    
    // Setup the color view, which will display the rainbowed background
    self.refreshColorView = [[UIView alloc] initWithFrame:self.refreshControl.bounds];
    self.refreshColorView.backgroundColor = [UIColor clearColor];
    self.refreshColorView.alpha = .8;
    
    // Create the graphic image views
    self.compassBackground = [[UIImageView alloc] initWithImage:[UIImage imageNamed:ASSETS_NEW_BLANKV]];
    self.compassSpinner = [[UIImageView alloc] initWithImage:[UIImage imageNamed:ASSETS_NEW_BLANKV]];
    
    // Add the graphics to the loading view
    [self.refreshLoadingView addSubview:self.compassBackground];
    [self.refreshLoadingView addSubview:self.compassSpinner];
    
    // Clip so the graphics don't stick out
    self.refreshLoadingView.clipsToBounds = YES;
    
    // Hide the original spinner icon
    self.refreshControl.tintColor = [UIColor clearColor];
    
    // Add the loading and colors views to our refresh control
    [self.refreshControl addSubview:self.refreshColorView];
    [self.refreshControl addSubview:self.refreshLoadingView];
    
    // Initalize flags
    self.isRefreshIconsOverlap = NO;
    self.isRefreshAnimating = NO;
    
    // When activated, invoke our refresh function
    [self.refreshControl addTarget:self action:@selector(refreshMessages) forControlEvents:UIControlEventValueChanged];
    [self.tableView addSubview:_refreshControl];
}

- (void)animateRefreshView
{
    // Background color to loop through for our color view
    //    NSArray *colorArray = @[[UIColor redColor],[UIColor blueColor],[UIColor purpleColor],[UIColor cyanColor],[UIColor orangeColor],[UIColor magentaColor]];
    
    NSArray *colorArray = [UIColor arrayOfColorsCore];
    static int colorIndex = 0;
    
    //    colorArray = [AppConstant arrayOfColors];
    
    // Flag that we are animating
    self.isRefreshAnimating = YES;
    //    self.labelNoMessages.hidden = YES;
    
    [UIView animateWithDuration:0.3
                          delay:0
                        options:UIViewAnimationOptionCurveLinear
                     animations:^{
                         // Rotate the spinner by M_PI_2 = PI/2 = 90 degrees
                         [self.compassSpinner setTransform:CGAffineTransformRotate(self.compassSpinner.transform, M_PI * 2)];
                         
                         // Change the background color
                         self.refreshColorView.backgroundColor = [colorArray objectAtIndex:colorIndex];
                         colorIndex = (colorIndex + 1) % colorArray.count;
                     }
                     completion:^(BOOL finished) {
                         // If still refreshing, keep spinning, else reset
                         if (self.refreshControl.isRefreshing)
                         {
                             [self animateRefreshView];
                         }
                         else
                         {
                             [self resetAnimation];
                         }
                     }];
}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    // Get the current size of the refresh controller
    CGRect refreshBounds = self.refreshControl.bounds;
    
    // Distance the table has been pulled >= 0
    CGFloat pullDistance = MAX(0.0, -self.refreshControl.frame.origin.y);
    
    // Half the width of the table
    CGFloat midX = self.tableView.frame.size.width / 2.0;
    
    dispatch_async(dispatch_get_main_queue(), ^
{
   if (pullDistance > 60.0f && !_isRefreshingUp)
   {
       self.isRefreshingUp = YES;
       [UIView animateWithDuration:.3f animations:^{
//                               self.labelNoMessages.hidden = YES;
           self.tableView.backgroundColor = [UIColor volleyFlatOrange];
       }];
   }
   else if (pullDistance < 60.0f && !_isRefreshingDown)
   {
       _isRefreshingDown = YES;
       [UIView animateWithDuration:.2f animations:^{
           self.tableView.backgroundColor = [UIColor whiteColor];
//                               self.labelNoMessages.hidden = NO;
       }];
   }
});
    
    if (pullDistance  < 5 && _isRefreshingUp == YES && _isRefreshingDown == YES)
    {
        _isRefreshingDown = NO;
        _isRefreshingUp = NO;
    }
    
    
    // Calculate the width and height of our graphics
    CGFloat compassHeight = self.compassBackground.bounds.size.height;
    CGFloat compassHeightHalf = compassHeight / 2.0;
    
    CGFloat compassWidth = self.compassBackground.bounds.size.width;
    CGFloat compassWidthHalf = compassWidth / 2.0;
    
    CGFloat spinnerHeight = self.compassSpinner.bounds.size.height;
    CGFloat spinnerHeightHalf = spinnerHeight / 2.0;
    
    CGFloat spinnerWidth = self.compassSpinner.bounds.size.width;
    CGFloat spinnerWidthHalf = spinnerWidth / 2.0;
    
    // Calculate the pull ratio, between 0.0-1.0
    CGFloat pullRatio = MIN( MAX(pullDistance, 0.0), 100.0) / 100.0;
    
    // Set the Y coord of the graphics, based on pull distance
    CGFloat compassY = pullDistance / 2.0 - compassHeightHalf;
    CGFloat spinnerY = pullDistance / 2.0 - spinnerHeightHalf;
    
    // Calculate the X coord of the graphics, adjust based on pull ratio
    CGFloat compassX = (midX + compassWidthHalf) - (compassWidth * pullRatio);
    CGFloat spinnerX = (midX - spinnerWidth - spinnerWidthHalf) + (spinnerWidth * pullRatio);
    
    // When the compass and spinner overlap, keep them together
    if (fabsf(compassX - spinnerX) < 1.0)
    {
        self.isRefreshIconsOverlap = YES;
    }
    
    // If the graphics have overlapped or we are refreshing, keep them together
    //Changed to && from ||
    if (self.isRefreshIconsOverlap || self.refreshControl.isRefreshing)
    {
        compassX = midX - compassWidthHalf;
        spinnerX = midX - spinnerWidthHalf;
    }
    
    // Set the graphic's frames
    CGRect compassFrame = self.compassBackground.frame;
    compassFrame.origin.x = compassX;
    compassFrame.origin.y = compassY;
    
    CGRect spinnerFrame = self.compassSpinner.frame;
    spinnerFrame.origin.x = spinnerX;
    spinnerFrame.origin.y = spinnerY;
    
    self.compassBackground.frame = compassFrame;
    self.compassSpinner.frame = spinnerFrame;
    
    // Set the encompassing view's frames
    refreshBounds.size.height = pullDistance;
    
    self.refreshColorView.frame = refreshBounds;
    self.refreshLoadingView.frame = refreshBounds;
    
    // If we're refreshing and the animation is not playing, then play the animation
    if (self.refreshControl.isRefreshing && !self.isRefreshAnimating)
    {
        [self animateRefreshView];
        self.isRefreshIconsOverlap = NO;
    }
    
}

- (void)resetAnimation
{
    // Reset our flags and background color
    self.isRefreshAnimating = NO;
    self.isRefreshIconsOverlap = NO;
    self.refreshColorView.backgroundColor = [UIColor clearColor];
    //    self.labelNoMessages.hidden = NO;
}

@end
