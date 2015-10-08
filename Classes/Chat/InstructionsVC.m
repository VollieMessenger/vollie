//
//  InstructionsVC.m
//  Volley
//
//  Created by Kyle Bendelow on 10/5/15.
//  Copyright © 2015 KZ. All rights reserved.
//

#import "InstructionsVC.h"
//#import "InstructionsPageVC.h"
//#import "MasterScrollView.h"
#import "RegisterView.h"
#import "LoginView.h"
#import "WelcomeView.h"
#import "AppConstant.h"

#import "PageOne.h"
#import "PageTwo.h"
#import "PageThree.h"
#import "PageFour.h"

@interface InstructionsVC ()
@property NavigationController *firstNav;
@property NavigationController *navRegister;
@property NavigationController *navLogin;
@property NavigationController *fourthNav;
@property UIScrollView *scrollView;

@end

@implementation InstructionsVC
@synthesize firstNav, navRegister, navLogin, scrollView, fourthNav;

- (void)viewDidLoad
{
    //    [IQKeyboardManager sharedManager].enableAutoToolbar = YES;
    
    [super viewDidLoad];
    scrollView = [[UIScrollView alloc] init];
    scrollView.frame = self.view.frame;
    [self.view addSubview:scrollView];
    //we already say this stuff in the app delegate
    //commenting it out just in case
    scrollView.bounces = NO;
    scrollView.pagingEnabled = 1;
    scrollView.directionalLockEnabled = YES;
    scrollView.showsHorizontalScrollIndicator = 0;
    scrollView.scrollEnabled = 1;
    
    PageOne *pageOne = [PageOne new];
    pageOne.scrollView = scrollView;
    
    PageTwo *pageTwo = [PageTwo new];
    pageTwo.scrollView = scrollView;
    
    PageThree *pageThree = [PageThree new];
    pageThree.scrollView = scrollView;
    
    PageFour *pageFour = [PageFour new];
    pageFour.scrollView = scrollView;
    pageFour.parentVC = self;
    
    
    
//    WelcomeView *welcome = [WelcomeView new];
//    welcome.scrollView = scrollView;
//    LoginView *login = [[LoginView alloc] init];
//    RegisterView *registerView = [[RegisterView alloc] init];
//    
    firstNav = [[NavigationController alloc] initWithRootViewController:pageTwo];
    navRegister = [[NavigationController alloc] initWithRootViewController:pageOne];
    navLogin = [[NavigationController alloc] initWithRootViewController:pageThree];
    fourthNav = [[NavigationController alloc] initWithRootViewController:pageFour];

    
    firstNav.view.frame = CGRectMake(self.view.frame.size.width,
                                       0,
                                       self.view.frame.size.width,
                                       self.view.frame.size.height);
    
    navLogin.view.frame = CGRectMake(self.view.frame.size.width * 2,
                                     0,
                                     self.view.frame.size.width,
                                     self.view.frame.size.height);
    
    
    navRegister.view.frame = CGRectMake(0,
                                        0,
                                        self.view.frame.size.width,
                                        self.view.frame.size.height);
    
    fourthNav.view.frame = CGRectMake(self.view.frame.size.width * 3,
                                     0,
                                     self.view.frame.size.width,
                                     self.view.frame.size.height);
    
    [scrollView addSubview:navRegister.view];
    [scrollView addSubview:navLogin.view];
    [scrollView addSubview:firstNav.view];
    [scrollView addSubview:fourthNav.view];
    
    [navLogin didMoveToParentViewController:self];
    [navRegister didMoveToParentViewController:self];
    [firstNav didMoveToParentViewController:self];
    [fourthNav didMoveToParentViewController:self];
    
    scrollView.contentSize = CGSizeMake(4 * self.view.frame.size.width,
                                        self.view.frame.size.height);
    
//    [scrollView setContentOffset:CGPointMake(self.view.frame.size.width, 0) animated:1];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(dismiss2) name:NOTIFICATION_USER_LOGGED_IN object:0];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(setToCenter) name:NOTIFICATION_SLIDE_MIDDLE_WELCOME object:0];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(disableScroll) name:NOTIFICATION_DISABLE_SCROLL_WELCOME object:0];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(enableScroll) name:NOTIFICATION_ENABLE_SCROLL_WELCOME object:0];
}

-(void) disableScroll
{
    scrollView.scrollEnabled = NO;
}

-(void) enableScroll
{
    scrollView.scrollEnabled = YES;
}

-(void) setToCenter
{
    [scrollView setContentOffset:CGPointMake(self.view.frame.size.width, 0) animated:1];
}

-(void)dismiss2
{
    //    [IQKeyboardManager sharedManager].enableAutoToolbar = NO;
    [self dismissViewControllerAnimated:1 completion:0];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}
@end






//
//- (void)viewDidLoad
//{
//    [super viewDidLoad];
//    
//    self.scrollView.bounces = NO;
//    self.scrollView.pagingEnabled = YES;
//    self.scrollView.scrollEnabled = YES;
//    self.scrollView.directionalLockEnabled = YES;
//    self.scrollView.showsHorizontalScrollIndicator = NO;
//    self.scrollView.contentSize = CGSizeMake(4 * self.view.frame.size.width, self.view.frame.size.height);
//    
//    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Storyboard" bundle:nil];
//    InstructionsPageVC *pageOneVC = (InstructionsPageVC *)[storyboard instantiateViewControllerWithIdentifier:@"InstructionsPageVC"];
//    pageOneVC.imageView.image = [UIImage imageNamed:@"contacts icon"];
//    pageOneVC.scrollView = self.scrollView;
//    pageOneVC.leftButtonHidden = YES;
//    pageOneVC.centerButtonHidden = YES;
//    
////    InstructionsPageVC *pageTwoVC = (InstructionsPageVC *)[storyboard instantiateViewControllerWithIdentifier:@"InstructionsPageVC"];
////    pageTwoVC.scrollView = self.scrollView;
////    pageTwoVC.centerButtonHidden = YES;
////    
////    InstructionsPageVC *pageThreeVC = (InstructionsPageVC *)[storyboard instantiateViewControllerWithIdentifier:@"InstructionsPageVC"];
////    pageThreeVC.scrollView = self.scrollView;
////    pageThreeVC.centerButtonHidden = YES;
////    
////    InstructionsPageVC *pageFourVC = (InstructionsPageVC *)[storyboard instantiateViewControllerWithIdentifier:@"InstructionsPageVC"];
////    pageFourVC.scrollView = self.scrollView;
////    pageFourVC.rightButtonHidden = YES;
//    
//    pageOneVC.view.frame = CGRectMake(0,0, self.scrollView.frame.size.width, self.scrollView.frame.size.height);
////    pageTwoVC.view.frame = CGRectMake(self.view.frame.size.width, 0, self.scrollView.frame.size.width, self.scrollView.frame.size.height);
////    pageThreeVC.view.frame = CGRectMake(self.view.frame.size.width * 2, 0, self.scrollView.frame.size.width, self.scrollView.frame.size.height);
////    pageFourVC.view.frame = CGRectMake(self.view.frame.size.width * 3, 0, self.scrollView.frame.size.width, self.scrollView.frame.size.height);
//
//    [pageOneVC didMoveToParentViewController:self];
////    [pageTwoVC didMoveToParentViewController:self];
////    [pageThreeVC didMoveToParentViewController:self];
////    [pageFourVC didMoveToParentViewController:self];
//    
//    [self.scrollView addSubview:pageOneVC.view];
////    [self.scrollView addSubview:pageTwoVC.view];
////    [self.scrollView addSubview:pageThreeVC.view];
////    [self.scrollView addSubview:pageFourVC.view];
//
//}
