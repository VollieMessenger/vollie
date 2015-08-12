//
//  MainInboxVC.m
//  Volley
//
//  Created by Kyle Bendelow on 8/4/15.
//  Copyright (c) 2015 KZ. All rights reserved.
//

#import "MainInboxVC.h"
#import "AppConstant.h"
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



@interface MainInboxVC () <UITableViewDelegate, UITableViewDataSource, RefreshMessagesDelegate, PushToCardDelegate, UIScrollViewDelegate>

//visual properties
@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (weak, nonatomic) IBOutlet UIImageView *imageViewInButton;
@property (weak, nonatomic) IBOutlet UIImageView *imageViewInButtonRight;

//random properties
@property BOOL isCurrentlyLoadingMessages;

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
    [self refreshMessages];
}

-(void)viewWillAppear:(BOOL)animated
{
    [self setNavBarColor];
    self.scrollView.scrollEnabled = YES;
}

-(void)viewDidAppear:(BOOL)animated
{
    [self refreshMessages];
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

    self.navigationItem.titleView = imageViewVolley;
    self.navigationItem.titleView.alpha = 1;
    //    self.navigationItem.titleView.frame = CGRectMake(0, 0, self.view.frame.size.width, (53 - ([number intValue] * [number intValue])));
    self.navigationItem.titleView.frame = CGRectMake(0, 0, 250, 44);
    self.title = @"";
    self.view.backgroundColor = [UIColor whiteColor];
    UIBarButtonItem *favoritesButton = [[UIBarButtonItem alloc] initWithTitle:@"Fav"
                                                             style:UIBarButtonItemStyleBordered target:self action:@selector(goToSettingsVC:)];
    favoritesButton.image = [UIImage imageNamed:@"settings"];
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
    
    
}

-(void)setNavBarColor
{
    [self.navigationController.navigationBar setTintColor:[UIColor colorWithWhite:.98 alpha:1]];
    [self.navigationController.navigationBar setBarTintColor:[UIColor volleyFamousGreen]];
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
                         
//                             NSDate *date = [message valueForKey:PF_MESSAGES_UPDATEDACTION];
//                             date = [self dateAtBeginningOfDayForDate:date];
//
//                             if (![self.savedDates containsObject:date])
//                             {
//                                 [self.savedDates addObject:date];
//                                 NSMutableArray *array = [NSMutableArray arrayWithObject:message];
//                                 NSDictionary *dict = [NSDictionary dictionaryWithObject:array forKey:date];
//                                 [self.savedMessagesForDate addEntriesFromDictionary:dict];
//                             }
//                             else
//                             {
//                                 [(NSMutableArray *)[self.savedMessagesForDate objectForKey:date] addObject:message];
//                             }
                     }
                 }
                 [self.tableView reloadData];
                 self.isCurrentlyLoadingMessages = NO;
//                 [self updateEmptyView];
                 //do we need that^^
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


-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.messages.count;
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    RoomCell *cell = [tableView dequeueReusableCellWithIdentifier:@"cellID" forIndexPath:indexPath];
    PFObject *room = self.messages[indexPath.row];
    [cell formatCellWith:room];
    return cell;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:1];
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

- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
    return YES;
    //Required for edit actions
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
        
        // [[(AppDelegate *)[[UIApplication sharedApplication] delegate] vc] showDetailViewController:[MasterLoginRegisterView new] sender:self];
        
        [self.navigationController showDetailViewController:[MasterLoginRegisterView new] sender:self];
        [self.scrollView setContentOffset:CGPointMake(self.view.frame.size.width, 0) animated:1];
        [self clearMessageArrays];
    }
}

-(void)pushToCard
{
    [self reloadAfterMessageSuccessfullySent];
}

-(void)reloadAfterMessageSuccessfullySent
{
    //needs to send user to new vollie page
    NSLog(@"About to Push to Card 0");
    [self performSelector:@selector(goToCardViewWithMessage) withObject:self afterDelay:1.0f];
    //    [self perfor]
}

-(void)goToCardViewWithMessage
{
    PFObject *message = [self.messages objectAtIndex:0];
    PFObject *room = [message objectForKey:PF_MESSAGES_ROOM];
//    selectedRoom = room.objectId;
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Storyboard" bundle:nil];
    MomentsVC *cardViewController = (MomentsVC *)[storyboard instantiateViewControllerWithIdentifier:@"CardVC"];
    ////    cardViewController.name = cell.labelDescription.text;
    cardViewController.room = room;
    cardViewController.messageItComesFrom = message;
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

-(void)goToSettingsVC:(id)id
{
//    NavigationController *nav = [[NavigationController alloc] initWithRootViewController: [[ProfileView alloc] initWithStyle:UITableViewStyleGrouped]];
    
    ProfileView *vc = [[ProfileView alloc] initWithStyle:UITableViewStyleGrouped];
    [self.navigationController pushViewController:vc animated:YES];
//    [self showDetailViewController:nav sender:self];
}

-(void)goToMostRecentChatRoom
{
//    NSLog(@"test success");
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
                         if (self.refreshControl.isRefreshing) {
                             [self animateRefreshView];
                         }else{
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
