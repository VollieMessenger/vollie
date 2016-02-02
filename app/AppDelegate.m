
#import <Parse/Parse.h>

#import <ParseUI/ParseUI.h>

#import <ParseCrashReporting/ParseCrashReporting.h>

#import "ProgressHUD.h"

#import "AppConstant.h"

#import "utilities.h"

#import "UIColor+JSQMessages.h"

#import "AppDelegate.h"

#import "ChatroomUsersView.h"

#import "CreateChatroomView.h"

#import "CustomChatView.h"

#import "MessagesView.h"

#import "ProfileView.h"

#import "CustomCameraView.h"

#import "NavigationController.h"

#import "MainInboxVC.h"

#import "WeekHighlightsVC.h"

#import "WelcomeView.h"

#import "RegisterView.h"

#import "LoginView.h"

#import "ChatView.h"

#import "MomentsVC.h"

#import "MasterScrollView.h"

#import "MasterLoginRegisterView.h"

#import <QuartzCore/QuartzCore.h>

#import "JCNotificationCenter.h"
#import "JCNotificationBannerPresenterSmokeStyle.h"
#import "JCNotificationBannerPresenterIOS7Style.h"
#import "JCNotificationBannerPresenter.h"

@implementation AppDelegate

@synthesize scrollView, vc;

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
//    [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleLightContent];
//    [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleDefault];


    //Must come before appidkey, RUN SCRIPT IN BUILD PHASE
    [ParseCrashReporting enable];

    [Parse setApplicationId:@"1RAToTZOshvcDzr2ahHAhPqTzabpc8WjLK9V2ymz"
                  clientKey:@"82SkbouTNf1ROMadLZEbBOkcKJzRHS6cDjn9Clfu"];

    [PFAnalytics trackAppOpenedWithLaunchOptions:launchOptions];

    [PFUser enableAutomaticUser];

    //Only for pinning data offline
//    [Parse enableLocalDatastore];

//    PFACL *defaultACL = [PFACL new];
    // If you would like all objects to be private by default, remove this line.
//    [defaultACL setPublicReadAccess:true];
//    [PFACL setDefaultACL:defaultACL withAccessForCurrentUser:true];

    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(didSendMail:) name:NOTIFICATION_APP_MAIL_SEND object:0];

    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(setCameraBack) name:NOTIFICATION_CAMERA_POPUP object:0];


	if ([application respondsToSelector:@selector(registerUserNotificationSettings:)])
	{
		UIUserNotificationType userNotificationTypes = (UIUserNotificationTypeAlert | UIUserNotificationTypeBadge | UIUserNotificationTypeSound);
		UIUserNotificationSettings *settings = [UIUserNotificationSettings settingsForTypes:userNotificationTypes categories:nil];
		[application registerUserNotificationSettings:settings];
		[application registerForRemoteNotifications];
	}
//    [PFImageView class];

/*
#warning REMOVE THIS WHEN SHIPPING, TESTING CRASH
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(5.0 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            [NSException raise:NSGenericException format:@"Everything is ok. This is just a test crash."];
    });
*/
    [self checkForFirstRun];
    [self setUpScrollViewAndVCs];

    // Parse push notification
    NSDictionary *notificationPayload = launchOptions[UIApplicationLaunchOptionsRemoteNotificationKey];
    [self checkForPushNotificationWith:notificationPayload];
    
    
	return YES;
}

-(void)checkForFirstRun
{
    
    NSUserDefaults *userDefualts = [NSUserDefaults standardUserDefaults];
    
    if (![userDefualts boolForKey:@"firstRun"])
    {
        [userDefualts setBool:1 forKey:@"firstRun"];
        if (![userDefualts boolForKey:@"logout"]) {
#warning LOGING OUT USER INCASE OLD VERSION.
            [userDefualts setBool:YES forKey:@"logout"];
            [PFUser logOut];
        }
        [userDefualts setBool:NO forKey:PF_KEY_SHOULDVIBRATE];
        [userDefualts synchronize];
    }
}

-(void)setUpScrollViewAndVCs
{
    //sets up the actual view controller that contains the scrollview
    self.window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
    self.window.backgroundColor = [UIColor volleyFamousGreen];
    vc = [[UIViewController alloc] init];
    vc.view.frame = self.window.bounds;
    
    //sets up scrollView
    scrollView = [[MasterScrollView alloc] init];
    scrollView.frame = self.window.bounds;
    [vc.view addSubview:scrollView];
    scrollView.bounces = NO;
    scrollView.pagingEnabled = YES;
    scrollView.scrollEnabled = YES;
    scrollView.directionalLockEnabled = YES;
    scrollView.showsHorizontalScrollIndicator = NO;
    scrollView.contentSize = CGSizeMake(3 * vc.view.frame.size.width, vc.view.frame.size.height);
    //centers scrollView to middle:
    [scrollView setContentOffset:CGPointMake(vc.view.frame.size.width, 0) animated:0];
    
    //sets up reference to storyboard
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Storyboard" bundle:nil];
    
    //set up camera on left of scrollview
    CustomCameraView *camera = [[CustomCameraView alloc] initWithPopUp:NO];
    self.navCamera = [[NavigationController alloc] initWithRootViewController:camera];
    camera.scrollView = scrollView;
    _navCamera.view.frame = CGRectMake(0, 0, vc.view.frame.size.width, vc.view.frame.size.height);
    [_navCamera didMoveToParentViewController:vc];
    [scrollView addSubview:_navCamera.view];
    
    //set up main inbox for middle of scrollview
    MainInboxVC *mainInbox = (MainInboxVC *)[storyboard instantiateViewControllerWithIdentifier:@"MainInboxVC"];
    self.navInbox = [[NavigationController alloc] initWithRootViewController:mainInbox];
    mainInbox.scrollView = scrollView;
    _navInbox.view.frame = CGRectMake(vc.view.frame.size.width, 0, vc.view.frame.size.width, vc.view.frame.size.height);
    [_navInbox didMoveToParentViewController:vc];
    [scrollView addSubview:_navInbox.view];
    
    //set up highlights page for right on scrollview
    WeekHighlightsVC *weekHighlights = (WeekHighlightsVC *)[storyboard instantiateViewControllerWithIdentifier:@"WeekHighlightsVC"];
    self.navFavorites = [[NavigationController alloc] initWithRootViewController:weekHighlights];
//    self.navFavorites.navigationBar.barTintColor = [UIColor volleyFamousOrange];
    self.navFavorites.navigationBar.barTintColor = [UIColor whiteColor];

    weekHighlights.scrollView = scrollView;
    _navFavorites.view.frame = CGRectMake(vc.view.frame.size.width * 2, 0, vc.view.frame.size.width, vc.view.frame.size.height);
    [_navFavorites didMoveToParentViewController:vc];
    [scrollView addSubview:_navFavorites.view];
    
    self.window.rootViewController = vc;
    [self.window makeKeyAndVisible];
}

-(void)checkForPushNotificationWith:(NSDictionary*)notificationPayload
{
    if (notificationPayload)
    {
        // Create a pointer to the Photo object
        NSString *roomId = [notificationPayload objectForKey:@"r"];
        PFObject *room = [PFObject objectWithoutDataWithClassName:PF_CHATROOMS_CLASS_NAME
                                                         objectId:roomId];
        // Fetch photo object
        [room fetchIfNeededInBackgroundWithBlock:^(PFObject *object, NSError *error) {
            // Show photo view controller
            if (!error && [PFUser currentUser])
            {
                UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Storyboard" bundle:nil];
                MomentsVC *cardViewController = (MomentsVC *)[storyboard instantiateViewControllerWithIdentifier:@"CardVC"];
                cardViewController.room = room;
                //                cardViewController
                //#warning SEND TO MESSAGES VIEW (NOT ARCHIVE);
                [scrollView openView:cardViewController];
            }
        }];
    }
}



// these 2 methods move the camera back into the scrollview after it has been presented over NewVollieVC
- (void)setCameraBack
{
    [self performSelector:@selector(setCameraBack2) withObject:self afterDelay:0.5f];
}

- (void)setCameraBack2
{
    _navCamera.view.frame = CGRectMake(0, 0, vc.view.frame.size.width, vc.view.frame.size.height);
    scrollView.contentSize = CGSizeMake(2 * vc.view.frame.size.width, vc.view.frame.size.height);
    [scrollView addSubview:_navCamera.view];
}

- (void)didSendMail:(NSNotification *)notification
{
    NSDictionary *dict = notification.userInfo;
    NSString *string = [dict valueForKey:@"string"];
    NSArray *people = [dict valueForKey:@"people"];

    MFMessageComposeViewController *controller = [[MFMessageComposeViewController alloc] init];
    if([MFMessageComposeViewController canSendText])
    {
        controller.body = string;
        controller.recipients = [NSArray arrayWithArray:people];
        controller.messageComposeDelegate = self;
       [self.vc presentViewController:controller animated:1 completion:0];
    }
}

- (void)messageComposeViewController:(MFMessageComposeViewController *)controller didFinishWithResult:(MessageComposeResult)result
{
    switch (result) {
        case MessageComposeResultCancelled:
            NSLog(@"Cancelled");
            break;
        case MessageComposeResultFailed:
            NSLog(@"Text Failed");
            break;
        case MessageComposeResultSent:
            NSLog(@"Text Sent");
            break;
        default:
            break;
    }
    [self.vc dismissViewControllerAnimated:1 completion:0];
}


- (void)applicationWillResignActive:(UIApplication *)application
{
	
}

- (void)applicationDidEnterBackground:(UIApplication *)application
{
    PFInstallation *currentInstallation = [PFInstallation currentInstallation];
    if (currentInstallation.badge != 0) {
        currentInstallation.badge = 0;
        [currentInstallation saveInBackground];
    }
}

- (void)applicationWillEnterForeground:(UIApplication *)application
{
    
}

- (void)applicationDidBecomeActive:(UIApplication *)application
{
        PFInstallation *currentInstallation = [PFInstallation currentInstallation];
        if (currentInstallation.badge != 0) {
            currentInstallation.badge = 0;
            [currentInstallation saveEventually];
        }
}

- (void)applicationWillTerminate:(UIApplication *)application
{
	
}

#pragma mark - Push notification methods

- (void)application:(UIApplication *)application didRegisterForRemoteNotificationsWithDeviceToken:(NSData *)deviceToken
{
	PFInstallation *currentInstallation = [PFInstallation currentInstallation];
	[currentInstallation setDeviceTokenFromData:deviceToken];
        currentInstallation.channels = @[@"global"];
	[currentInstallation saveInBackground];
}

- (void)application:(UIApplication *)application didFailToRegisterForRemoteNotificationsWithError:(NSError *)error
{
	NSLog(@"didFailToRegisterForRemoteNotificationsWithError %@", error);
}

- (void)application:(UIApplication *)application didReceiveRemoteNotification:(NSDictionary *)userInfo fetchCompletionHandler:(void (^)(UIBackgroundFetchResult))completionHandler
{
    NSLog(@"notification");
    BOOL didJustOpenFromBackground = NO;

    //Tracking Push Notifications open and stuff
    if (application.applicationState == UIApplicationStateInactive) {
        didJustOpenFromBackground = YES;
        [PFAnalytics trackAppOpenedWithRemoteNotificationPayload:userInfo];
    }

//IF APPLICATION IS ACTIVE>
    NSLog(@"%@", userInfo); // ADD CHATROOM ID IN THIS TO CREATE NEW CHATROOM AND OPEN IT IN BACKGROUND.
//        [PFPush handlePush:userInfo]; // SEND AN ALERT IN APP
    

    NSString *alertText = [[userInfo objectForKey:@"aps"] objectForKey:@"alert"];

    if ([userInfo objectForKey:@"r"])
    {
        NSString *roomId = [userInfo objectForKey:@"r"];
        PFObject *room = [PFObject objectWithoutDataWithClassName:PF_CHATROOMS_CLASS_NAME
                                                            objectId:roomId];
        PFQuery *query2 = [PFQuery queryWithClassName:PF_MESSAGES_CLASS_NAME];
        [query2 whereKey:PF_MESSAGES_USER equalTo:[PFUser currentUser]];
        //      [query includeKey:PF_MESSAGES_LASTUSER];
        [query2 whereKey:PF_MESSAGES_ROOM equalTo:room];
        [query2 findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error)
        {
            if (!error && objects.count)
            {
                PFObject *messageRoom = objects[0];
                PFObject *customChatRoom = [messageRoom objectForKey:PF_MESSAGES_ROOM];
                PFObject *lastPicture = [messageRoom objectForKey:@"lastPicture"];
                [lastPicture fetch];
                PFObject *set = [lastPicture objectForKey:@"setId"];
                NSLog(@"%@ this is the set", set);
                
                if ([scrollView checkIfOnCard:roomId didComeFromBackground:didJustOpenFromBackground andSetId:set.objectId])
                {
                    //SAME CHATROOOM
                    PostNotification(NOTIFICATION_REFRESH_CHATROOM);
//                    CustomChatView *chatView = scro
                }
                else
                {
                    
                    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Storyboard" bundle:nil];
                    MomentsVC *cardViewController = (MomentsVC *)[storyboard instantiateViewControllerWithIdentifier:@"CardVC"];
                    cardViewController.messageItComesFrom = messageRoom;
                    if ([messageRoom objectForKey:PF_ALBUMS_NICKNAME])
                    {
                        cardViewController.name = [messageRoom objectForKey:PF_ALBUMS_NICKNAME];
                    }
                    else
                    {
                        cardViewController.name = [messageRoom objectForKey:PF_MESSAGES_DESCRIPTION];
                    }
                    cardViewController.room = customChatRoom;
                    
                    if (application.applicationState == UIApplicationStateActive && !didJustOpenFromBackground)
                    {
                        NSString* title = @"NEW MESSAGE!";
                        NSUserDefaults *userDefualts = [NSUserDefaults standardUserDefaults];
                        
                        if ([userDefualts boolForKey:PF_KEY_SHOULDVIBRATE])
                        {
                            [JSQSystemSoundPlayer jsq_playMessageReceivedAlert];
                        }
                        else
                        {
                            [JSQSystemSoundPlayer jsq_playMessageReceivedSound];
                        }
                        
                        [JCNotificationCenter sharedCenter].presenter = [JCNotificationBannerPresenterIOS7Style new];
                        if (scrollView.contentOffset.x)
                        {
                            NSLog(@"IN APP NOTIFICATION");
                            [JCNotificationCenter enqueueNotificationWithTitle:title
                                                                       message:alertText
                                                                    tapHandler:^
                            {

                                //Dismiss Modal Views
                                PostNotification(NOTIFICATION_CLICKED_PUSH);
//                                [lastPicture fetch];
//                                PFObject *set = [lastPicture objectForKey:@"setId"];
                                CustomChatView *deepChatView = [[CustomChatView alloc] initWithSet:set andUserChatRoom:messageRoom withOrangeBubbles:NO];
                                [scrollView openView:deepChatView];
                            }];
                            completionHandler(UIBackgroundFetchResultNewData);
                        }
                    }
                    else
                    {
                        NSLog(@"I was opened from a push note");
                        PFObject *set = [lastPicture objectForKey:@"setId"];
                        CustomChatView *deepChatView = [[CustomChatView alloc] initWithSet:set andUserChatRoom:messageRoom withOrangeBubbles:NO];
                        [scrollView openView:deepChatView];
                        completionHandler(UIBackgroundFetchResultNoData);
                    }
                }
            }
            
        }];
        
        
        
//        if ([scrollView checkIfCurrentChatIsEqualToRoom:roomId didComeFromBackground:didJustOpenFromBackground])
//        {
//            //SAME CHATROOOM
//            PostNotification(NOTIFICATION_REFRESH_CHATROOM);
//        }
//        else
//        {
//
//        PFQuery *query = [PFQuery queryWithClassName:PF_MESSAGES_CLASS_NAME];
//        [query whereKey:PF_MESSAGES_USER equalTo:[PFUser currentUser]];
//        //      [query includeKey:PF_MESSAGES_LASTUSER];
//        [query whereKey:PF_MESSAGES_ROOM equalTo:room];
//        [query findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error)
//        {
//            if (!error && objects.count)
//            {
//                PFObject *messageRoom = objects[0];
//                PFObject *customChatRoom = [messageRoom objectForKey:PF_MESSAGES_ROOM];
//                PFObject *lastPicture = [messageRoom objectForKey:@"lastPicture"];
//                [lastPicture fetch];
//                PFObject *set = [lastPicture objectForKey:@"setId"];
//                NSLog(@"%@ this is the set", set);
////                 [lastPicture fetchinbac];
//////
////                 PFObject *set = [lastPicture objectForKey:@"setId"];
////                 PFObject *room = [lastPicture objectForKey:@"room"];
////                 CustomChatView *deepChatView = [[CustomChatView alloc] initWithSet:set andUserChatRoom:room];
////                 [self.navigationController pushViewController:vc animated:YES];
////
//                 
//                 
//                 UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Storyboard" bundle:nil];
//                 MomentsVC *cardViewController = (MomentsVC *)[storyboard instantiateViewControllerWithIdentifier:@"CardVC"];
//                 cardViewController.messageItComesFrom = messageRoom;
//                 if ([messageRoom objectForKey:PF_ALBUMS_NICKNAME])
//                 {
//                     cardViewController.name = [messageRoom objectForKey:PF_ALBUMS_NICKNAME];
//                 }
//                 else
//                 {
//                     cardViewController.name = [messageRoom objectForKey:PF_MESSAGES_DESCRIPTION];
//                 }
//                 cardViewController.room = customChatRoom;
//                 
//                 if (application.applicationState == UIApplicationStateActive && !didJustOpenFromBackground)
//                 {
//                     NSString* title = @"NEW MESSAGE!";
//                     
//                     NSUserDefaults *userDefualts = [NSUserDefaults standardUserDefaults];
//                     
//                     if ([userDefualts boolForKey:PF_KEY_SHOULDVIBRATE]){
//                         [JSQSystemSoundPlayer jsq_playMessageReceivedAlert];
//                     }
//                     else
//                     {
//                         [JSQSystemSoundPlayer jsq_playMessageReceivedSound];
//                     }
//                     
//                     [JCNotificationCenter sharedCenter].presenter = [JCNotificationBannerPresenterIOS7Style new];
//                     
//                     if (scrollView.contentOffset.x)
//                     {
//                         //says if you aren't looking at camera
//                         NSLog(@"IN APP NOTIFICATION");
//                         
//                         [JCNotificationCenter enqueueNotificationWithTitle:title
//                                                                    message:alertText
//                                                                 tapHandler:^{
//                                                                     
//                                                                     //Dismiss Modal Views
//                                                                     PostNotification(NOTIFICATION_CLICKED_PUSH);
//                                                                     
//                                                                          [lastPicture fetch];
//                                                    
//                                                                          PFObject *set = [lastPicture objectForKey:@"setId"];
////                                                                          PFObject *room = [lastPicture objectForKey:@"room"];
//                                                                          CustomChatView *deepChatView = [[CustomChatView alloc] initWithSet:set andUserChatRoom:messageRoom withOrangeBubbles:NO];
////                                                                     deepChatView.room = room;
////                                                                        deepChatView.room = customChatRoom;
////                                                                          [self.navigationController pushViewController:vc animated:YES];
//                                                                     
//                                                                     [scrollView openView:deepChatView];
//                                                                 }];
//                     }
//                     else
//                     {
//                         //this is if the notification happens while you're looking at the camera
////                         [scrollView openView:cardViewController];
////                         [JCNotificationCenter enqueueNotificationWithTitle:title
////                                                                    message:alertText
////                                                                 tapHandler:^{
////                                                                     
////                                                                     //Dismiss Modal Views
////                                                                     PostNotification(NOTIFICATION_CLICKED_PUSH);
////                                                                     
////                                                                     [scrollView openView:cardViewController];
////                                                                 }];
//                     }
//                     completionHandler(UIBackgroundFetchResultNewData);
//                 }
//                 else
//                 {
//                     NSLog(@"I was opened from a push note");
//                     PFObject *set = [lastPicture objectForKey:@"setId"];
//                     CustomChatView *deepChatView = [[CustomChatView alloc] initWithSet:set andUserChatRoom:messageRoom withOrangeBubbles:NO];
//                     [scrollView openView:deepChatView];
//                     completionHandler(UIBackgroundFetchResultNoData);
//                 }
//             }
//         }];
//        }
    //Need to download new message if it exists.
        PostNotification(NOTIFICATION_REFRESH_INBOX);
        // Show photo view controller
        //Irrelevant but acceptable
    }
    
}

@end
