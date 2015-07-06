/////////////////////////////////////////////////////////////////////////////////////////////////////

#import <Parse/Parse.h>

#import "ProgressHUD.h"

#import "AppConstant.h"

#import "messages.h"

#import "pushnotification.h"

#import "utilities.h"

//#import "IQKeyboardManager.h"

//#import "camera.h"

#import "MomentsVC.h"

#import "ProfileView.h"

#import "utilities.h"

#import "AlbumView.h"

#import "MasterLoginRegisterView.h"

#import "MasterScrollView.h"

#import "MessagesView.h"

#import "MessagesCell.h"

#import "ChatView.h"

#import "CustomCameraView.h"

#import "UIColor+JSQMessages.h"

#import "CustomCollectionViewCell.h"

#import "CustomChatView.h"

#import "CreateChatroomView.h"

#import "NSDate+TimeAgo.h"

#import <sys/utsname.h> // Device name.

#import "AppDelegate.h"

#import "InviteCell.h"

#import "NewVollieVC.h"

@interface MessagesView () <UIInputViewAudioFeedback>

{
    UITapGestureRecognizer *tap;

    UILongPressGestureRecognizer *longPress;

    NSMutableArray *savedPhotoObjects; /// NOT USED

    NSMutableDictionary *colorsForRoom;

    NSMutableArray *savedDates;

    NSMutableDictionary *savedMessagesForDate;

    NSMutableArray *customChatPictures;

    NSMutableArray *customChatMessages;

    NSMutableArray *arrayOfAvailableColors;

    UIColor *customColor;

    NSString *customSetId;

    NSString *customChatTitle;
    
    NSString *selectedRoom;

    PFObject *commentObject; //comment send by delegate

    PFObject *albumToDelete;

    PFObject *messageToRenameDelete;

    BOOL didViewJustLoad;

    NSIndexPath *indexForDelete;
}

@property BOOL isRefreshingUp;

@property BOOL isRefreshingDown;

@property NSMutableArray *messagesObjectIds;

@property IBOutlet UILabel *labelNoMessages;

@property (strong, nonatomic) UIImageView *imageView;

@property (strong, nonatomic) UIImageView *imageView2;

@property IBOutlet UIView *viewHeader;

@property UISearchBar *searchBar;

@property IBOutlet UITextField *searchTextField;

@property IBOutlet UIButton *searchCloseButton;

@property NSMutableArray *searchMessages;

@property BOOL isSearching;

@property (strong, nonatomic) IBOutlet UIButton *composeButton;

@property (strong, nonatomic) IBOutlet UIButton *albumButton;

@property BOOL isRefreshIconsOverlap;

@property BOOL isLoadingChatView;

@property BOOL isRefreshAnimating;

@property UIView *refreshLoadingView;

@property UIImageView *compassSpinner;

@property UIView *refreshColorView;

@property UIImageView *compassBackground;

@property  UIRefreshControl *refreshControl;

@property (strong, nonatomic) IBOutlet UITableView *tableView;

@property (strong, nonatomic) IBOutlet UIView *viewEmpty;

@property IBOutlet UIButton *cameraButton; // Not USED.

@property int x;

@property IBOutlet UIButton *cameraButton2;

@property BOOL isLoadingMessages;

@end

@implementation MessagesView

@synthesize viewEmpty, messages, viewHeader, searchBar, imageView, imageView2, messagesObjectIds;

- (id)initWithArchive:(BOOL)isArchive
{
    self = [super init];

    if (self)
    {
        self.isArchive = isArchive;
    }

    return self;
}

- (IBAction)didSelectCompose:(id)sender
{
    if (_isArchive)
    {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"New Album" message:0 delegate:self cancelButtonTitle:@"Cancel" otherButtonTitles:@"Save", nil];
        alert.alertViewStyle = UIAlertViewStylePlainTextInput;
        [alert textFieldAtIndex:0].placeholder = @"Name...";
        [alert show];
    }
    else
    {
        UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Storyboard" bundle:nil];
        NewVollieVC *vc = (NewVollieVC *)[storyboard instantiateViewControllerWithIdentifier:@"NewVollieVC"];
//        [self presentViewController:vc animated:YES completion:nil];
        [self.navigationController pushViewController:vc animated:YES];

//        CreateChatroomView *chat = [CreateChatroomView new];
//        chat.isTherePicturesToSend = NO;
//        [self showViewController:chat sender:0];

    }
}

#pragma mark - NOTIFICATION

- (void)enableScrollview:(NSNotification *)notification
{
    self.scrollView.scrollEnabled = YES;
}

- (void)disableScrollView:(NSNotification *)notification
{
    self.scrollView.scrollEnabled = NO;
}

- (void)openChatNotification:(NSNotification *)notification
{
    NSDictionary *dict = notification.userInfo;
#warning FRAGILE
    ChatView *chat = [dict valueForKey:@"view"];
    [self openView:chat];
}

- (void)openView:(UIViewController *)view2
{
    [self.scrollView setContentOffset:CGPointMake([UIScreen mainScreen].bounds.size.width, 0) animated:0];

    if ([self.navigationController.viewControllers.lastObject isKindOfClass:[CustomChatView class]])
    {
        CustomChatView *customChat = self.navigationController.viewControllers.lastObject;
        ChatView *chat2 = [self.navigationController.viewControllers objectAtIndex:self.navigationController.viewControllers.count - 2];

        if (chat2.room_ == customChat.room)
        {
            [self.navigationController popViewControllerAnimated:1];
            return;
        }
        else
        {
            [self.navigationController popToRootViewControllerAnimated:0];
        }
    }
    else if ([self.navigationController.viewControllers.lastObject isKindOfClass:[ChatView class]])
    {
        [self.navigationController popViewControllerAnimated:0];
    }
    /// IF CUSTOM CHAT ROOM IS SAME AS ROOM BEFORE, POP THE STACK ONCE.
    [self.navigationController pushViewController:view2 animated:0];
}

- (void)longPress:(UILongPressGestureRecognizer *)longPressss
{
    CGPoint point = [longPressss locationInView:self.tableView];

    UITableViewCell *cell = [self.tableView cellForRowAtIndexPath:[self.tableView indexPathForRowAtPoint:point]];
    if (cell)
    {
        [self.tableView setEditing:1 animated:1];
        tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(didTap:)];
        tap.delegate = self;
        [self.tableView addGestureRecognizer:tap];
    }
}

- (void)didTap:(UITapGestureRecognizer *)tapppppp
{
    CGPoint point = [tapppppp locationInView:self.tableView];

    if (point.x > 50 && tap) {
        [self.tableView setEditing:0 animated:1];
        [self.tableView removeGestureRecognizer:tap];
        tap = nil;
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

- (void)viewDidLoad
{
//    [IQKeyboardManager sharedManager].enableAutoToolbar = NO;
    [[UIDevice currentDevice] playInputClick];

//    self..enableInputClicksWhenVisible = YES;
    if (_isArchive)
    {
//        self.labelNoMessages.text = @"This is Albums, you can favorite any set of photos from any conversation into an album.";
    }
    else
    {
//        self.labelNoMessages.text = @"This is the inbox where messages will appear once you take a picture and start a conversation.";
    }

    [super viewDidLoad];
    self.viewEmpty.hidden = YES;
    didViewJustLoad = YES;

    longPress = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(longPress:)];
    [self.view addGestureRecognizer:longPress];

    if (_isArchive)
    {
        self.albumButton.titleLabel.textColor = [UIColor volleyFlatOrange];
        [self.view addSubview:self.albumButton];
    }
    else
    {
        _composeButton.tintColor = [UIColor volleyFamousGreen];
        _composeButton.imageView.tintColor = [UIColor volleyFamousGreen];
        _composeButton.titleLabel.text = @"NEW MESSAGE";
        [_composeButton setImage:[[UIImage imageNamed:@"Compose"] imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate] forState:UIControlStateNormal];
        [self.view addSubview:self.composeButton];
    }

    if (!_isArchive) {
        UIImageView *imageViewVolley = [[UIImageView alloc] init];
        imageViewVolley.image = [UIImage imageNamed:@"volley"];

        //    NSNumber *number = [self deviceModelName];
        //    number = [NSNumber numberWithFloat:(number.floatValue / 7.0f)];

        self.navigationItem.titleView = imageViewVolley;
        self.navigationItem.titleView.alpha = 1;
        //    self.navigationItem.titleView.frame = CGRectMake(0, 0, self.view.frame.size.width, (53 - ([number intValue] * [number intValue])));
        self.navigationItem.titleView.frame = CGRectMake(0, 0, 250, 44);
    }

    _searchCloseButton.hidden = YES;
    [self clearAll];
    [self setupRefreshControl];
    [self setUpNavBar];

    UIView *spacerView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 10, 10)];
    [_searchTextField setLeftViewMode:UITextFieldViewModeAlways];
    [_searchTextField setLeftView:spacerView];


    if (_isArchive)
    {
        [self.tableView registerNib:[UINib nibWithNibName:@"MessagesCellDot" bundle:0] forCellReuseIdentifier:@"MessagesCell"];
    }
    else
    {
        [self.tableView registerNib:[UINib nibWithNibName:@"MessagesCell" bundle:0] forCellReuseIdentifier:@"MessagesCell"];
        [self.tableView registerNib:[UINib nibWithNibName:@"InviteCell" bundle:0] forCellReuseIdentifier:@"InviteCell"];
    }

    self.tableView.backgroundColor = [UIColor whiteColor];

#warning REFRESHES BOTH ARCHIVE AND INBOX
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(refreshMessages) name:NOTIFICATION_USER_LOGGED_OUT object:0];

    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(refreshMessages) name:NOTIFICATION_USER_LOGGED_IN object:0];

    if (!_isArchive)
    {
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(refreshMessages) name:NOTIFICATION_REFRESH_INBOX object:0];

        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(reloadDataTableView) name:NOTIFICATION_RELOAD_INBOX object:0];

        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(openChatNotification:) name:NOTIFICATION_OPEN_CHAT_VIEW object:0];

        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(enableScrollview:) name:NOTIFICATION_ENABLESCROLLVIEW object:0];

        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(disableScrollView:) name:NOTIFICATION_DISABLESCROLLVIEW object:0];
    }
    else
    {
        
//        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(refreshMessages) name:NOTIFICATION_REFRESH_ALBUMS object:0];
    }

    [self refreshMessages];
}

-(void)reloadDataTableView
{
    [self.tableView reloadData];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    if (didViewJustLoad)
    {
//        [self animate];
    }

    //Needed to scroll tableview to hide searchbar.
    self.edgesForExtendedLayout = UIRectEdgeNone;

    //Deleted && !_isArchive
    if (self.navigationController.visibleViewController == self)
    {
        self.scrollView.scrollEnabled = YES;
    } else {
        self.scrollView.scrollEnabled = NO;
    }

    if (didViewJustLoad) [searchBar resignFirstResponder];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    
    [[UIApplication sharedApplication] setStatusBarHidden:NO
                                            withAnimation:UIStatusBarAnimationFade];
//    [self loadFavorites];

    didViewJustLoad = NO;
}

- (void) animate
{
    imageView = [[UIImageView alloc] initWithFrame:CGRectMake(self.view.frame.size.width, 0, self.view.frame.size.width, self.view.frame.size.height)];
    imageView.image = [UIImage imageNamed:@"launch image volley"];
    imageView2 = [[UIImageView alloc] initWithFrame:CGRectMake(self.view.frame.size.width, 0, self.view.frame.size.width, self.view.frame.size.height)];
    imageView2.image = [UIImage imageNamed:@"launch image volleyALPHA"];

    imageView2.contentMode = UIViewContentModeScaleToFill;
    imageView.contentMode = UIViewContentModeScaleToFill;

    imageView.layer.shouldRasterize = YES;
    imageView.layer.rasterizationScale = [UIScreen mainScreen].scale;

    imageView2.layer.shouldRasterize = YES;
    imageView2.layer.rasterizationScale = [UIScreen mainScreen].scale;

    [self.scrollView addSubview:imageView2];
    [self.scrollView addSubview:imageView];

    __weak MessagesView *weakSelf = self;
    [UIView animateWithDuration:0.6f delay:0.3f options:UIViewAnimationOptionCurveEaseInOut  animations:^{
        imageView2.frame = CGRectMake(self.view.frame.size.width * 2, 0, self.view.frame.size.width, self.view.frame.size.height);
    } completion:^(BOOL finished) {
        if (finished) [weakSelf animate2];
    }];
}

-(void) animate2
{
    __weak MessagesView *weakSelf = self;
    [UIView animateWithDuration:.4f delay:0 options:UIViewAnimationOptionCurveEaseInOut animations:^{
        if ([PFUser currentUser]) {
            imageView.frame = imageView.frame;
            imageView.frame = CGRectMake(self.view.frame.size.width/5.5 + self.view.frame.size.width, -self.view.frame.size.height/4, self.view.frame.size.width/1.5, self.view.frame.size.height/1.5);
        } else {
            imageView.alpha = 1;
            imageView.alpha = 0;
        }
    } completion:^(BOOL finished) {
        if (finished) [weakSelf animate3];
    }];
}

-(void) animate3
{
    [imageView removeFromSuperview];
    [imageView2 removeFromSuperview];
    imageView = [UIImageView new];
    imageView2 = [UIImageView new];

    //    [UIView animateKeyframesWithDuration:0.3f delay:1.0f options:0 animations:^{
    //        self.navigationItem.titleView.alpha = 1;
    //    } completion:0];
}

- (void) clearAll
{
    messages = [[NSMutableArray alloc] init];
    savedDates = [NSMutableArray new];
    savedMessagesForDate = [NSMutableDictionary new];
    messagesObjectIds = [NSMutableArray new];
    colorsForRoom = [NSMutableDictionary new];
    arrayOfAvailableColors = [NSMutableArray arrayWithArray: [AppConstant arrayOfColors]];
}

-(void)viewWillDisappear:(BOOL)animated
{
    self.scrollView.scrollEnabled = NO;
}


- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(10, 0, self.view.frame.size.width, 22)];
    label.textColor = [UIColor lightGrayColor];
    label.textAlignment = NSTextAlignmentLeft;
//    label.font = [UIFont fontWithName:@"Helvetica Bold" size:15];
    label.font = [UIFont fontWithName:@"ArialRoundedMTBold" size:15.0];
    label.backgroundColor = [UIColor whiteColor];
    //    label.backgroundColor = [UIColor volleyFlatPeach];
    //    if (section == 0) {
    //        UIView *view = [[UIView alloc] init];
    //        view.frame = CGRectZero;
    //        view.backgroundColor = [UIColor whiteColor];
    //        return view;
    //    }
    if (savedDates.count) {

        if (savedDates.count - 1 > section) {
            NSDate *date = [savedDates objectAtIndex:section];
            //        NSDateFormatter *dateFormat = [[NSDateFormatter alloc] init];
            //        [dateFormat setDateFormat:@"MMMM dd"];
            //        NSString *dateString = [dateFormat stringFromDate:date];
            NSDateFormatter *dateFormate = [[NSDateFormatter alloc] init];
            [dateFormate setDateFormat:@"MMMM dd"];
            NSString *dateString = [dateFormate stringFromDate:date];
            dateString = [@"  " stringByAppendingString:dateString];
            if ([date isEqualToDate:[self dateAtBeginningOfDayForDate:[NSDate date]]]) {
                label.text = @"   Today";
            } else {
                label.text = dateString;
            }
        }
    }
    if (_isArchive) {
        label.font = [UIFont fontWithName:@"Helvetica Bold" size:14];
        label.text = @"   MY ALBUMS";
    }
    return label;
}

#pragma mark - Backend methods

//Grab all messages with MY NAME ON IT.
//Add loading booleen back in.

- (void)loadInbox
{
    if ([PFUser currentUser] && _isLoadingMessages == NO)
    {
        _isLoadingMessages = YES;

        PFQuery *query = [PFQuery queryWithClassName:PF_MESSAGES_CLASS_NAME];

        [query whereKey:PF_MESSAGES_USER equalTo:[PFUser currentUser]];
//      [query includeKey:PF_MESSAGES_LASTUSER];
        [query includeKey:PF_MESSAGES_ROOM];
        [query includeKey:PF_MESSAGES_USER];
        [query includeKey:PF_MESSAGES_LASTPICTURE];
        [query includeKey:PF_MESSAGES_LASTPICTUREUSER];
        [query whereKey:PF_MESSAGES_HIDE_UNTIL_NEXT equalTo:@NO];

        //      PFObject *message = messages.lastObject;
        //    if (message) [query whereKey:PF_MESSAGES_UPDATEDACTION greaterThan:message.updatedAt];

        //Clear the cache if there is a delete.
        //        [query clearCachedResult];

        [query orderByDescending:PF_MESSAGES_UPDATEDACTION];

        [query setCachePolicy:kPFCachePolicyCacheThenNetwork];

        [query findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error)
         {
             if (!error)
             {
                 [self clearAll];

                 for (PFObject *message in objects)
                 {
                     if (![messagesObjectIds containsObject:message.objectId])
                     {
/*
 #define		PF_MESSAGES_CLASS_NAME				@"Messages"				//	Class name
 #define		PF_MESSAGES_HIDE_UNTIL_NEXT			@"shouldHideUntilNext"	//	Class name
 #define		PF_MESSAGES_USER					@"user"					//	Pointer to User
 #define		PF_MESSAGES_USER_DONOTDISTURB		@"userPush"					//	Pointer to
 #define		PF_MESSAGES_ROOM					@"room"				   //	Pointer to Room
 #define		PF_MESSAGES_DESCRIPTION				@"description"			//	String
 #define		PF_MESSAGES_LASTUSER				@"lastUser"				//	Pointer lastuser
 #define		PF_MESSAGES_LASTMESSAGE				@"lastMessage"			//	String
 #define		PF_MESSAGES_LASTPICTURE				@"lastPicture"			//	Chat pointer
 #define		PF_MESSAGES_LASTPICTUREUSER			@"lastPictureUser"	//	PFuser
 #define		PF_MESSAGES_COUNTER					@"counter"				//	Number
 #define		PF_MESSAGES_UPDATEDACTION			@"updatedAction"		//	Date
 #define		PF_MESSAGES_NICKNAME                @"nickname"             //	Date
 */

                         if ([[message valueForKey:PF_MESSAGES_LASTMESSAGE] isEqualToString:@""] && ![message valueForKey:PF_MESSAGES_LASTPICTURE])
                         {
                             //this hides messages that have neither a message or picture yet
                             //i'd like to make this cleaner and actually delete it off of parse, but this works for now
                         }
                         else
                         {
                             [messages addObject:message];
                             NSDate *date = [message valueForKey:PF_MESSAGES_UPDATEDACTION];
                             date = [self dateAtBeginningOfDayForDate:date];

                             if (![savedDates containsObject:date])
                             {
                                 [savedDates addObject:date];
                                 NSMutableArray *array = [NSMutableArray arrayWithObject:message];
                                 NSDictionary *dict = [NSDictionary dictionaryWithObject:array forKey:date];
                                 [savedMessagesForDate addEntriesFromDictionary:dict];
                             }
                             else
                             {
                                 [(NSMutableArray *)[savedMessagesForDate objectForKey:date] addObject:message];
                             }
                         }
                     }
                 }
                 
                 [self.tableView reloadData];
                 _isLoadingMessages = NO;
                 //Scroll search bar up a notch.
                 [self updateEmptyView];
             }
             else
             {
                 if ([query hasCachedResult]) {
                     if (self.navigationController.visibleViewController == self) {
                         [self.refreshControl endRefreshing];
                         [ProgressHUD showError:@"Network error."];
                     }
                 }
             }
             [_refreshControl endRefreshing];
         }];
    }
}


// FOR EACH FAVORIATE ID, LOAD LATEST PICTURE, FOR EACH PICTURE, LOAD LATEST CHAT.
- (void)loadFavorites
{
    [messagesObjectIds removeAllObjects];
    [messages removeAllObjects];
    PFQuery *query = [PFQuery queryWithClassName:PF_ALBUMS_CLASS_NAME];
    [query whereKey:PF_ALBUMS_USER equalTo:[PFUser currentUser]];
    [query includeKey:PF_ALBUMS_SET];
    [query includeKey:PF_ALBUMS_USER];
    [query orderByAscending:PF_ALBUMS_NICKNAME];
    [query setCachePolicy:kPFCachePolicyCacheThenNetwork];
    [query findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
        if (!error)
        {
            for (PFObject *object in objects)
            {

             if (![messagesObjectIds containsObject:object.objectId])
                {
                    [messages addObject:object];
                    [messagesObjectIds addObject:object.objectId];
                }
//                else
//                {
//                    PFObject *oldMesssage = [messages objectAtIndex:[messagesObjectIds indexOfObject:object.objectId]];
//                    if (oldMesssage.updatedAt < object.updatedAt)
//                    {
//                        [self.messages removeObject:oldMesssage];
//                        [messagesObjectIds removeObject:oldMesssage.objectId];
//                        [self.messages addObject:object];
//                        [messagesObjectIds addObject:object.objectId];
//                    }
//                }
             }

            /*
            NSMutableArray *indexpaths = [NSMutableArray new];

            for (PFObject *message in objects)
            {
                NSIndexPath *indexpath = [NSIndexPath indexPathForRow:[self.messages indexOfObject:message] inSection:0];
                [indexpaths addObject:indexpath];
            }
            */

            [self.tableView reloadData];
            [self updateEmptyView];
            [_refreshControl endRefreshing];
        }
        else
        {
            if ([query hasCachedResult] && self.navigationController.visibleViewController == self)
                {
                    [_refreshControl endRefreshing];
                    [ProgressHUD showError:@"Network error"];
            }
        }
    }];
}

- (NSDate *)dateAtBeginningOfDayForDate:(NSDate *)inputDate
{
    //Convert to my time zone
    NSTimeZone *tz = [NSTimeZone defaultTimeZone];
    NSInteger seconds = [tz secondsFromGMTForDate:inputDate];
    NSDate *date = [NSDate dateWithTimeInterval: seconds sinceDate:inputDate];
    // Use the user's current calendar and time zone
    NSCalendar *calendar = [NSCalendar currentCalendar];
    NSTimeZone *timeZone = [NSTimeZone systemTimeZone];
    [calendar setTimeZone:timeZone];

    // Selectively convert the date components (year, month, day) of the input date
    NSDateComponents *dateComps = [calendar components:NSYearCalendarUnit | NSMonthCalendarUnit | NSDayCalendarUnit fromDate:date];

    // Set the time components manually
    [dateComps setHour:0];
    [dateComps setMinute:0];
    [dateComps setSecond:0];
    // Convert back
    NSDate *beginningOfDay = [calendar dateFromComponents:dateComps];
    return beginningOfDay;
}

-(void)actionSettings
{
    NavigationController *nav = [[NavigationController alloc] initWithRootViewController: [[ProfileView alloc] initWithStyle:UITableViewStyleGrouped]];

       [self showDetailViewController:nav sender:self];
}

-(void)setUpNavBar
{
    if (self.isArchive)
    {
        self.title = @"Favorites";

        self.cameraButton2.hidden = YES;

        self.view.backgroundColor = [UIColor whiteColor];
        self.tableView.backgroundColor = [UIColor clearColor];

        UIBarButtonItem *item = [[UIBarButtonItem alloc] initWithTitle:@"Settings"
                                                                 style:UIBarButtonItemStylePlain target:self action:@selector(actionSettings)];
        item.image = [UIImage imageNamed:ASSETS_NEW_SETTINGS];
        self.navigationItem.rightBarButtonItem = item;

        UIBarButtonItem *settings =[[UIBarButtonItem alloc] initWithTitle:@"Back" style:UIBarButtonItemStyleDone target:self action:@selector(actionBack:)];
        settings.image = [UIImage imageNamed:ASSETS_INBOX_FLIP];
        self.navigationItem.leftBarButtonItem = settings;

    } else {

        self.title = @"";

        self.view.backgroundColor = [UIColor whiteColor];

        UIBarButtonItem *item = [[UIBarButtonItem alloc] initWithTitle:@"Fav"
                                                                 style:UIBarButtonItemStyleBordered target:self action:@selector(actionFavorties:)];
        item.image = [UIImage imageNamed:ASSETS_STAR_ON];
        self.navigationItem.rightBarButtonItem = item;

        UIBarButtonItem *settings =[[UIBarButtonItem alloc] initWithTitle:@"   " style:UIBarButtonItemStyleBordered target:self action:@selector(actionBack:)];
        settings.image = [UIImage imageNamed:ASSETS_NEW_CAMERA];
        self.navigationItem.leftBarButtonItem = settings;
    }
}

-(void) actionFavorties:(UIBarButtonItem *)button
{
    [self.scrollView setContentOffset:CGPointMake(self.view.frame.size.width * 2, 0) animated:1];
}

- (IBAction) actionBack:(UIBarButtonItem *)button
{
    if (_isArchive) {
        [self.scrollView setContentOffset:CGPointMake(self.view.frame.size.width, 0) animated:1];
    } else {
        [self.scrollView setContentOffset:CGPointMake(0, 0) animated:YES];
    }
}

- (IBAction)actionSettings:(UIButton *)button
{
    [UIView animateWithDuration:.3 animations:^{
        button.transform = CGAffineTransformMakeScale(0.3,0.3);
        button.transform = CGAffineTransformMakeScale(1,1);
    }];
}

- (void) changeBackgroundColor
{
    UIColor *randomColor = [[UIColor arrayOfColorsCore] objectAtIndex:arc4random_uniform((int)[UIColor arrayOfColorsCore].count)];
    [UIView animateWithDuration:.3 animations:^{
        self.view.backgroundColor = randomColor;
    }];
}

//REFRESH CONTROL
- (void)refreshMessages
{
    if ([[[PFUser currentUser] valueForKey:PF_USER_ISVERIFIED] isEqualToNumber:@YES])
    {
        if (self.isArchive)
        {
            [self loadFavorites];
        }
        else
        {
            [self loadInbox];
        }

    } else {
        if (_isArchive) {

            //Error when app starts and no user logged in, when user registers, the inbox is gone. Might user super VC to present this MasterView.

            // [[(AppDelegate *)[[UIApplication sharedApplication] delegate] vc] showDetailViewController:[MasterLoginRegisterView new] sender:self];

            [self.navigationController showDetailViewController:[MasterLoginRegisterView new] sender:self];
            [self.scrollView setContentOffset:CGPointMake(self.view.frame.size.width, 0) animated:1];
            [self actionCleanup];
        }
    }
}

#pragma mark - Helper methods

//IF NO MESSAGES, SHOW VIEW.
- (void)updateEmptyView
{
    viewEmpty.hidden = (messages.count > 0) ? YES: NO;

    if (!viewEmpty.isHidden)
    {
        self.tableView.separatorColor = [UIColor clearColor];
    } else {
        if (!_isArchive)
        {
            if (self.messages.count > 5)
            {
                self.tableView.tableHeaderView = viewHeader;
//                [self.tableView scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:0] atScrollPosition:UITableViewScrollPositionTop animated:1];
            }

            //            [self.tableView scrollRectToVisible:CGRectMake(0, 44, 0, 0) animated:1];
            //            [self.tableView setContentOffset:CGPointMake(0, 44) animated:0];
        } else {
            [self.tableView setTableHeaderView:0];
        }
        self.tableView.separatorColor = [UIColor colorWithRed:.8f green:.8f blue:.8f alpha:.9f];
    }
}

#pragma mark - User actions


//PART OF CAMERA BUTTON.
- (IBAction)buttonRelease:(UIButton*)button {
    // Do something else
    [UIView animateWithDuration:.3f animations:^{
        button.transform = CGAffineTransformMakeScale(3,3);
    }];
}

//WHEN YOU LOGOUT AND STUFF.
- (void)actionCleanup
{
    [messages removeAllObjects];
    [messagesObjectIds removeAllObjects];
    [savedDates removeAllObjects];
    [savedMessagesForDate removeAllObjects];

    //Clear the cache of videos.
        NSArray* tmpDirectory = [[NSFileManager defaultManager] contentsOfDirectoryAtPath:NSTemporaryDirectory() error:NULL];
        for (NSString *file in tmpDirectory) {
            [[NSFileManager defaultManager] removeItemAtPath:[NSString stringWithFormat:@"%@%@", NSTemporaryDirectory(), file] error:NULL];
        }

    [self.tableView reloadData];
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    if (self.isArchive) {
        return 1;
    }

    if (_isSearching) {
        return 1;
    }

    return savedDates.count +1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if (_isSearching)
    {
        return _searchMessages.count;
    }
    if(messages.count != 0)
    {
        self.labelNoMessages.text = @"";
    }
    if (self.isArchive)
    {
        return messages.count;
    } else {
        NSInteger sectionsAmount = [tableView numberOfSections];
        if (section == sectionsAmount - 1) {
            return 1;
        }else{
        NSDate *dateRepresentingThisDay = [savedDates objectAtIndex:section];
        NSArray *eventsOnThisDay = [savedMessagesForDate objectForKey:dateRepresentingThisDay];

        return [eventsOnThisDay count];
        }
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    MessagesCellDot *cell2;
    MessagesCell *cell;
    InviteCell *cell3;
    if (_isArchive)
    {
        cell2 = [tableView dequeueReusableCellWithIdentifier:@"MessagesCell" forIndexPath:indexPath];
        if (!cell2) cell2 = [[MessagesCellDot alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"MessagesCell"];
        [cell2 format];
        cell2.labelInitials.hidden = YES;
    }
    else
    {
        NSInteger sectionsAmount = [tableView numberOfSections];
        NSInteger rowsAmount = [tableView numberOfRowsInSection:[indexPath section]];
        if ([indexPath section] == sectionsAmount - 1 && [indexPath row] == rowsAmount - 1) {
            cell3 = [tableView dequeueReusableCellWithIdentifier:@"InviteCell" forIndexPath:indexPath];
            cell3.invite.backgroundColor = [UIColor volleyFamousGreen];
            cell3.invite.textColor = [UIColor whiteColor];
            
            return cell3;
        } else {
            cell = [tableView dequeueReusableCellWithIdentifier:@"MessagesCell" forIndexPath:indexPath];
            if (!cell) cell = [[MessagesCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"MessagesCell"];
            [cell format];
            cell.labelInitials.hidden = YES;
        }
    }

    if (self.isArchive) // LOADING PICTURES, THEN CHAT MESSAGES FOR PICTURES.
    {
        cell2.labelDescription.text = @"";
        cell2.labelLastMessage.text = @"";
        PFObject *album = [messages objectAtIndex:indexPath.row];
        cell2.labelDescription.text = album[PF_ALBUMS_NICKNAME];
        cell2.imageUser.backgroundColor = [UIColor volleyFlatOrange];
        cell2.labelDescription.textColor = [UIColor volleyLabelGrey];
        cell2.labelInitials.backgroundColor = [UIColor volleyFlatOrange];

//Need to get the new album if a favorite has been added or deleted.
//        if (![album valueForKey:PF_ALBUMS_SET])
//        {
//            [album fetch];
//        }

        if ([album valueForKey:PF_ALBUMS_SET])
        {
            PFObject *set =[album valueForKey:PF_ALBUMS_SET];
            PFUser *user = [set objectForKey:PF_SET_USER];
            cell2.labelLastMessage.text = [set.updatedAt dateTimeUntilNow];

            if (user){
                [user fetchIfNeededInBackgroundWithBlock:^(PFObject *object, NSError *error){
                    if (!error){
                        NSString *nam = [object valueForKey:PF_USER_FULLNAME];
                        NSMutableArray *array = [NSMutableArray arrayWithArray:[nam componentsSeparatedByString:@" "]];
                        [array removeObject:@" "];
                        NSString *first = array.firstObject;
                        NSString *last = array.lastObject;
                        first = [first stringByPaddingToLength:1 withString:nam startingAtIndex:0];
                        last = [last stringByPaddingToLength:1 withString:nam startingAtIndex:0];
                        nam = [first stringByAppendingString:last];
                        cell2.labelInitials.text = nam;
                    }
                }];
            }

            PFObject *picture = [set valueForKey:PF_SET_LASTPICTURE];
            if (picture){
                [picture fetchIfNeededInBackgroundWithBlock:^(PFObject *object, NSError *error) {
                    if (!error) {
                        PFFile *file = [picture valueForKey:PF_PICTURES_THUMBNAIL];
                        cell2.imageUser.file = file;
                        [cell2.imageUser loadInBackground:^(UIImage *image, NSError *error) {
                            if (!error) {
                                cell.labelInitials.hidden = NO;
                            }
                        }];
                    }
                }];
            } else {
                cell.imageUser.image = [UIImage imageNamed:@"Blank V"];
            }
        }

        return cell2;

    } else { // NOT ARCHIVE

        if (savedDates.count)
        {
            PFObject *message;

            if (_isSearching && _searchMessages.count)
            {
                message = [_searchMessages objectAtIndex:indexPath.row];
            }
            else
            {
                NSDate *dateRepresentingThisDay = [savedDates objectAtIndex:indexPath.section];
                NSArray *eventsOnThisDay = [savedMessagesForDate objectForKey:dateRepresentingThisDay];
                message = [eventsOnThisDay objectAtIndex:indexPath.row];
            }

            PFObject *pictureObject = [message valueForKey:PF_MESSAGES_LASTPICTURE];

            if (pictureObject)
            {
                PFUser *user = [message valueForKey:PF_MESSAGES_LASTPICTUREUSER];
                NSString *name = [user valueForKey:PF_USER_FULLNAME];

                    if (name && name.length)
                    {
                        NSMutableArray *array = [NSMutableArray arrayWithArray:[name componentsSeparatedByString:@" "]];
                        [array removeObject:@" "];
                        NSString *first = array.firstObject;
                        NSString *last = array.lastObject;
                        if (first.length && last.length)
                        {
                            first = [first stringByPaddingToLength:1 withString:name startingAtIndex:0];
                            last = [last stringByPaddingToLength:1 withString:name startingAtIndex:0];
                            name = [first stringByAppendingString:last];
                            cell.labelInitials.text = name;
        #warning INITIALS ARE HIDDEN
        //                    cell.labelInitials.hidden = NO;
                        }
                    }
                
                PFObject * room = [message objectForKey:PF_MESSAGES_ROOM];
                if ([room.objectId isEqualToString:selectedRoom])
                {
                    ClearMessageCounter(message);
                    selectedRoom = @"";
                }
                
                PFFile *file = [pictureObject valueForKey:PF_PICTURES_THUMBNAIL];
                cell.imageUser.file = file;
//                [cell.imageUser loadInBackground];
                [file getDataInBackgroundWithBlock:^(NSData *data, NSError *error) {
                    if (!error) {
                        cell.imageUser.image = [UIImage imageWithData:data];
                    }
                }];
            }
            else
            {
                cell.imageUser.image = [UIImage imageNamed:@"Blank V"];
            }

            cell.tableBackgroundColor = [UIColor volleyFamousGreen];

            [cell bindData:message];
        }
    }
    return cell;
}

- (UIColor *)convertColorStringToColorWorkAround:(NSString *)string
{
    NSArray * colorParts = [string componentsSeparatedByString: @" "];
    CGFloat red = [[colorParts objectAtIndex:0] floatValue];
    CGFloat green = [[colorParts objectAtIndex:1] floatValue];
    CGFloat blue = [[colorParts objectAtIndex:2] floatValue];
    CGFloat alpha = [[colorParts objectAtIndex:3] floatValue];

    UIColor * newColor = [UIColor colorWithRed:red green:green blue:blue alpha:alpha];

    return newColor;
}

/*
 - (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
 {
 //Required for edit actions
 }
 */
 
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
    return YES;
    //Required for edit actions
}

-(NSArray *)tableView:(UITableView *)tableView editActionsForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewRowAction *button = [UITableViewRowAction rowActionWithStyle:UITableViewRowActionStyleDefault title:@"Delete" handler:^(UITableViewRowAction *action, NSIndexPath *indexPath) {

        [self.tableView setEditing:0 animated:1];

        if (_isArchive)
        {
            //Okay because there's no sections in archive.
            albumToDelete = [self.messages objectAtIndex:indexPath.row];

            dispatch_async(dispatch_get_main_queue(), ^{
                UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Delete Album" message:@"All the favorites inside the album will be lost" delegate:self cancelButtonTitle:@"Cancel" otherButtonTitles:@"Delete", nil];
                [alert show];
            });

        }
        else
        { // NOT ARCHIVE
            NSDate *dateRepresentingThisDay = [savedDates objectAtIndex:indexPath.section];

            NSMutableArray *eventsOnThisDay = [savedMessagesForDate objectForKey:dateRepresentingThisDay];

            PFObject  *message = [eventsOnThisDay objectAtIndex:indexPath.row];

            [message setValue:@YES forKey:PF_MESSAGES_HIDE_UNTIL_NEXT];

            [message saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
                if (!error) {
                    //Remove all traces of messages
                    [[savedMessagesForDate objectForKey:dateRepresentingThisDay] removeObject:message];
                    [messagesObjectIds removeObject:message.objectId];
                    [self.messages removeObject:message];

                    //Animation
                    [self.tableView beginUpdates];
                    [self.tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationAutomatic];
                    [self.tableView endUpdates];

                    //
                    [self updateEmptyView];
                }
            }];
        }

    }];
    button.backgroundColor = [UIColor redColor]; //arbitrary color

    UITableViewRowAction *button2 = [UITableViewRowAction rowActionWithStyle:UITableViewRowActionStyleDefault title:@"Rename" handler:^(UITableViewRowAction *action, NSIndexPath *indexPath) {

        [self.tableView setEditing:0 animated:1];

        //SAME FOR BOTH ARCHIVE AND INBOX
        if (_isArchive)
        {
            messageToRenameDelete = [messages objectAtIndex:indexPath.row];
        }
        else
        {
            NSDate *dateRepresentingThisDay = [savedDates objectAtIndex:indexPath.section];
            NSArray *eventsOnThisDay = [savedMessagesForDate objectForKey:dateRepresentingThisDay];
            messageToRenameDelete = [eventsOnThisDay objectAtIndex:indexPath.row];
        }

        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Rename..." message:0 delegate:self cancelButtonTitle:@"Cancel" otherButtonTitles:@"Rename", nil];

        alert.alertViewStyle = UIAlertViewStylePlainTextInput;

        if (messageToRenameDelete[PF_MESSAGES_NICKNAME])
        {
            [alert textFieldAtIndex:0].text = [messageToRenameDelete valueForKey:PF_ALBUMS_NICKNAME];
        }

        [alert show];

    }];

    button2.backgroundColor = [UIColor colorWithRed:.75f green:.75f blue:.75f alpha:1]; //arbitrary color

    return @[button, button2]; //array with all the buttons you want. 1,2,3, etc...
}

#pragma mark - ALERTVIEW

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{

    if (buttonIndex != alertView.cancelButtonIndex && [alertView.title isEqualToString:@"New Album"] && [alertView textFieldAtIndex:0].hasText)
    {
        PFObject *album = [PFObject objectWithClassName:PF_ALBUMS_CLASS_NAME];
        [album setValue:[[alertView textFieldAtIndex:0].text capitalizedString] forKey:PF_ALBUMS_NICKNAME];
        [album setValue:[PFUser currentUser] forKey:PF_ALBUMS_USER];

        [album saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error)
        {
            if (succeeded)
            {
                [self.messages addObject:album];
                [messagesObjectIds addObject:album.objectId];

                NSIndexPath *indexpath = [NSIndexPath indexPathForRow:self.messages.count - 1 inSection:0];
                [self.tableView insertRowsAtIndexPaths:@[indexpath] withRowAnimation:UITableViewRowAnimationAutomatic];

                //Clear the favorites cache.
                PFQuery *query = [PFQuery queryWithClassName:PF_ALBUMS_CLASS_NAME];
                [query clearCachedResult];

                [self updateEmptyView];
                [self.tableView setEditing:0 animated:1];
            }
            else
            {
            }
        }];
    }

    if ([alertView.title isEqualToString:@"Delete Album"] && buttonIndex != alertView.cancelButtonIndex)
    {
        __block NSIndexPath *indexPath = [NSIndexPath indexPathForRow:[self.messages indexOfObject:albumToDelete] inSection:0];

        [self.messages removeObject:albumToDelete];

//        This will ensure it does not come back from the dead.
//        [messagesObjectIds removeObject:albumToDelete.objectId];

        [albumToDelete deleteInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
            if (succeeded)
            {
                [self.tableView setEditing:0 animated:1];

                //Delete all the favorites in the album
                PFQuery *query = [PFQuery queryWithClassName:PF_FAVORITES_CLASS_NAME];
                [query whereKey:PF_FAVORITES_ALBUM equalTo:albumToDelete];
                [query findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
                    if (!error) {
                        [PFObject deleteAllInBackground:objects];
                    }
                }];

                PFQuery *query2 = [PFQuery queryWithClassName:PF_ALBUMS_CLASS_NAME];
                [query2 clearCachedResult];

                [self.tableView beginUpdates];
                [self.tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationLeft];
                [self.tableView endUpdates];

                [self updateEmptyView];
            } else {
            }
        }];

    }
    else if ([alertView.title isEqualToString:@"Rename..."] && buttonIndex != alertView.cancelButtonIndex)
    {

        if ([alertView textFieldAtIndex:0].hasText) {

            NSString *string = [alertView textFieldAtIndex:0].text;

            if (string.length) {
                [messageToRenameDelete setValue:[alertView textFieldAtIndex:0].text forKey:PF_MESSAGES_NICKNAME];
            } else {
                [messageToRenameDelete setValue:@"" forKey:PF_MESSAGES_NICKNAME];
            }

            [messageToRenameDelete saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
                if (succeeded)
                {
                    [self.tableView setEditing:0 animated:1];
                    [self.tableView reloadData];
                } else {
                }
            }];

        } else {

            [ProgressHUD showError:@"Cancelled"];
            [alertView dismissWithClickedButtonIndex:0 animated:1];
        }
    }
}

#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:1];

    if (!self.isArchive)
    { //NOT ARCHIVE
        MessagesCell *cell = [tableView cellForRowAtIndexPath:indexPath];

        PFObject *message;
        if (_isSearching && _searchMessages.count)
        {
            message = [_searchMessages objectAtIndex:indexPath.row];
        }
        else
        {
            if (savedDates.count)
            {
                NSInteger sectionsAmount = [tableView numberOfSections];
                if ([indexPath section] == sectionsAmount - 1)
                {
                    CreateChatroomView * view = [[CreateChatroomView alloc]init];
                    NSString *name = [message valueForKey:PF_USER_FULLNAME];
                    view.title = @"ahhhhh";
                    view.isTherePicturesToSend = NO;
                    view.invite = YES;
                    [self.navigationController pushViewController:view animated:YES];
                    return;
                }
                NSDate *dateRepresentingThisDay = [savedDates objectAtIndex:indexPath.section];
                NSArray *eventsOnThisDay = [savedMessagesForDate objectForKey:dateRepresentingThisDay];
                message = [eventsOnThisDay objectAtIndex:indexPath.row];
            }
        }

        if (message)
        {
            PFObject *room = [message objectForKey:PF_MESSAGES_ROOM];
            selectedRoom = room.objectId;
            ChatView *chatView = [[ChatView alloc] initWith:room
                                                       name:cell.labelDescription.text];
            
            chatView.message_ = message;
                
            chatView.title = cell.labelDescription.text;

            CATransition* transition = [CATransition animation];
            transition.duration = 0.3;
            transition.type = kCATransitionPush;
            transition.subtype = kCATransitionFromRight;
            transition.timingFunction = UIViewAnimationCurveEaseInOut;
            transition.fillMode = kCAFillModeForwards;
            [self.navigationController.view.layer addAnimation:transition forKey:kCATransition];
            UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Storyboard" bundle:nil];
            MomentsVC *cardViewController = (MomentsVC *)[storyboard instantiateViewControllerWithIdentifier:@"CardVC"];
//            cardViewController = [[CardVC alloc] initWith:room name:cell.labelDescription.text];
            cardViewController.name = cell.labelDescription.text;
            cardViewController.room = room;
            [self.navigationController pushViewController:cardViewController animated:YES];

        }
    }
    else
    {
        // IS ARCHIVE
        if (messages.count)
        {
            MessagesCellDot *cell = [tableView cellForRowAtIndexPath:indexPath];
                cell.userInteractionEnabled = NO;
            PFObject *album = [messages objectAtIndex:indexPath.row];
            AlbumView *albumView = [[AlbumView alloc]init];
            albumView.title = cell.labelDescription.text;
            albumView.album = album;

                CATransition* transition = [CATransition animation];
                transition.duration = 0.3;
                transition.type = kCATransitionPush;
                transition.subtype = kCATransitionFromRight;
                transition.timingFunction = UIViewAnimationCurveEaseInOut;
                transition.fillMode = kCAFillModeForwards;
                [self.navigationController.view.layer addAnimation:transition forKey:kCATransition];
                cell.userInteractionEnabled = YES;
            [self.navigationController pushViewController:albumView animated:1];
        }
    }
}

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

-(void)viewDidDisappear:(BOOL)animated {
    [self.tableView setEditing:0 animated:1];
    [searchBar setText:0];
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
            _isRefreshingUp = YES;
            [UIView animateWithDuration:.3f animations:^{
                if (_isArchive)
                {
                    self.labelNoMessages.hidden = YES;
                    self.tableView.backgroundColor = [UIColor volleyFamousGreen];
                }
                else
                {
                    self.labelNoMessages.hidden = YES;
                    self.tableView.backgroundColor = [UIColor volleyFlatOrange];
                }
            }];
        }
        else if (pullDistance < 60.0f && !_isRefreshingDown)
        {
            _isRefreshingDown = YES;
            [UIView animateWithDuration:.2f animations:^{
                self.tableView.backgroundColor = [UIColor whiteColor];
                self.labelNoMessages.hidden = NO;
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

- (NSNumber *)deviceModelName {

    struct utsname systemInfo;
    uname(&systemInfo);

    NSString *machineName = [NSString stringWithCString:systemInfo.machine encoding:NSUTF8StringEncoding];

    //MARK: More official list is at
    //http://theiphonewiki.com/wiki/Models
    //MARK: You may just return machineName. Following is for convenience

    NSDictionary *commonNamesDictionary =
    @{
      @"i386":   @14, //@"iPhone Simulator",
      @"x86_64": @14, //@"iPad Simulator",

      @"iPhone1,1": @20,  // @"iPhone",
      @"iPhone1,2": @20,  // @"iPhone 3G",
      @"iPhone2,1": @20,  // @"iPhone 3GS",
      @"iPhone3,1": @16,  // @"iPhone 4",
      @"iPhone3,2": @16,  // @"iPhone 4(Rev A)",
      @"iPhone3,3": @16,  // @"iPhone 4(CDMA)",
      @"iPhone4,1": @15,  // @"iPhone 4S",
      @"iPhone5,1": @14,  // @"iPhone 5(GSM)",
      @"iPhone5,2": @14,  // @"iPhone 5(GSM+CDMA)",
      @"iPhone5,3": @10,  // @"iPhone 5c(GSM)",
      @"iPhone5,4": @10,  // @"iPhone 5c(GSM+CDMA)",
      @"iPhone6,1": @9,  // @"iPhone 5s(GSM)",
      @"iPhone6,2": @9,  // @"iPhone 5s(GSM+CDMA)",
      @"iPhone7,1": @9,  // @"iPhone 6+ (GSM+CDMA)",
      @"iPhone7,2": @9,  // @"iPhone 6 (GSM+CDMA)",

      @"iPad1,1":  @"iPad",
      @"iPad2,1":  @"iPad 2(WiFi)",
      @"iPad2,2":  @"iPad 2(GSM)",
      @"iPad2,3":  @"iPad 2(CDMA)",
      @"iPad2,4":  @"iPad 2(WiFi Rev A)",
      @"iPad2,5":  @"iPad Mini 1G (WiFi)",
      @"iPad2,6":  @"iPad Mini 1G (GSM)",
      @"iPad2,7":  @"iPad Mini 1G (GSM+CDMA)",
      @"iPad3,1":  @"iPad 3(WiFi)",
      @"iPad3,2":  @"iPad 3(GSM+CDMA)",
      @"iPad3,3":  @"iPad 3(GSM)",
      @"iPad3,4":  @"iPad 4(WiFi)",
      @"iPad3,5":  @"iPad 4(GSM)",
      @"iPad3,6":  @"iPad 4(GSM+CDMA)",

      @"iPad4,1":  @"iPad Air(WiFi)",
      @"iPad4,2":  @"iPad Air(GSM)",
      @"iPad4,3":  @"iPad Air(GSM+CDMA)",

      @"iPad4,4":  @"iPad Mini 2G (WiFi)",
      @"iPad4,5":  @"iPad Mini 2G (GSM)",
      @"iPad4,6":  @"iPad Mini 2G (GSM+CDMA)",

      @"iPod1,1":  @"iPod 1st Gen",
      @"iPod2,1":  @"iPod 2nd Gen",
      @"iPod3,1":  @"iPod 3rd Gen",
      @"iPod4,1":  @"iPod 4th Gen",
      @"iPod5,1":  @"iPod 5th Gen",

      };

    NSNumber *deviceName = commonNamesDictionary[machineName];

    if (deviceName == nil) {
        deviceName = @4.0;
    }

    return deviceName;
}


#pragma mark - UISearchBarDelegate

- (void)searchMessages:(NSString *)search_lower
{

    for (PFObject *message in self.messages)
    {
        if ([[[message valueForKey:PF_MESSAGES_DESCRIPTION] lowercaseString] containsString:search_lower]) {
            [self.searchMessages addObject:message];

        }
        else if (message[PF_MESSAGES_NICKNAME])
        {
            if ([[[message valueForKey:PF_MESSAGES_NICKNAME] lowercaseString]  containsString:search_lower]) [self.searchMessages addObject:message];
        }
    }

    [self.tableView reloadData];
    return;

    /*
     PFQuery *query = [PFQuery queryWithClassName:PF_USER_CLASS_NAME];
     [query whereKey:PF_USER_OBJECTID notEqualTo:[PFUser currentUser].objectId];
     [query whereKey:PF_USER_FULLNAME_LOWER containsString:search_lower];
     [query orderByAscending:PF_USER_FULLNAME];
     [query setLimit:1000];
     [query setCachePolicy:kPFCachePolicyCacheElseNetwork];
     [query findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error)
     {
     if (error == nil)
     {
     [self.tableView reloadData];
     }
     else [ProgressHUD showError:@"Network error."];
     }];
     */
}


-(IBAction)textFieldDidChange:(UITextField *)textField
{
    if ([textField.text length] > 0)
    {
        [_searchMessages removeAllObjects];
        _isSearching = YES;
        [self searchMessages:[textField.text lowercaseString]];
    }
    else {
        _isSearching = NO;
        [self.tableView reloadData];
    }
}

- (void)textFieldDidBeginEditing:(UITextField *)textField
{
    textField.text =@"";
    self.searchMessages = [NSMutableArray new];
    _isSearching = YES;
    _searchCloseButton.hidden = NO;
    //    [searchBar setShowsCancelButton:YES animated:YES];
}

- (void)textFieldDidEndEditing:(UITextField *)textField
{
    //    [searchBar_ setShowsCancelButton:NO animated:YES];
    _isSearching = NO;
    _searchCloseButton.hidden = YES;
    [textField resignFirstResponder];
    textField.text = @"";
    [self.tableView reloadData];
}

-(IBAction)closeSearch:(id)sender {
    [_searchTextField resignFirstResponder];
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    [textField resignFirstResponder];
    return YES;
}

- (void)searchBarCancelButtonClicked:(UISearchBar *)searchBar
{
    [self searchBarCancelled];
}

- (void)searchBarSearchButtonClicked:(UISearchBar *)searchBar_
{
    [searchBar_ resignFirstResponder];
}

- (void)searchBarCancelled
{
    searchBar.text = @"Search...";
    [searchBar resignFirstResponder];
    [self.tableView reloadData];
}


@end
