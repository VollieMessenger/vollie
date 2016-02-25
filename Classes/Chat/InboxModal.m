//
//  InboxModal.m
//  Volley
//
//  Created by Kyle Bendelow on 12/16/15.
//  Copyright © 2015 KZ. All rights reserved.
//

#import "InboxModal.h"
#import "CreateChatroomView.h"
#import "AppConstant.h"
#import "UIColor+JSQMessages.h"
#import "AppDelegate.h"
#import "CustomChatView.h"
#import "WeekHighlightsVC.h"

@interface InboxModal ()

@end

@implementation InboxModal

-(PFQuery*)createQueryForUserChatRooms
{
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
    return query;
}

-(PFQuery*)createQueryForSharedChatRoom
{
    PFQuery *query2 = [PFQuery queryWithClassName:PF_MESSAGES_CLASS_NAME];
    [query2 whereKey:@"objectId" equalTo:@"LKOjl2KHk4"];
    //      [query includeKey:PF_MESSAGES_LASTUSER];
    [query2 includeKey:PF_MESSAGES_ROOM];
    [query2 includeKey:PF_MESSAGES_USER]; // doesn't need to be here
    [query2 includeKey:PF_MESSAGES_LASTPICTURE];
    [query2 includeKey:PF_MESSAGES_LASTPICTUREUSER];
    //        [query2 whereKey:PF_MESSAGES_HIDE_UNTIL_NEXT equalTo:@NO];
    [query2 orderByDescending:PF_MESSAGES_UPDATEDACTION];
    [query2 setCachePolicy:kPFCachePolicyCacheThenNetwork];
    return query2;
}

-(void)inviteContacts
{
    CreateChatroomView * view = [[CreateChatroomView alloc]init];
    view.title = @"ahhhhh";
    view.isTherePicturesToSend = NO;
    view.invite = YES;
    [self.nav pushViewController:view animated:YES];
    return;
}

-(void)formatNavigationBar:(UINavigationBar *)bar
{
    [bar setTintColor:[UIColor colorWithWhite:.98 alpha:1]];
    [bar setBarTintColor:[UIColor volleyFamousGreen]];
    [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleLightContent animated:1];
    bar.titleTextAttributes =  @{
                                 NSForegroundColorAttributeName: [UIColor whiteColor],
                                 NSFontAttributeName: [UIFont fontWithName:@"Helvetica Neue" size:20.0f],
                                 NSShadowAttributeName:[NSShadow new]
                                 };
}

-(MomentsVC*)createMomentsVCWith:(PFObject *)room andCustomChatRoom:(PFObject *)customChatRoom
{
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Storyboard" bundle:nil];
    MomentsVC *cardViewController = (MomentsVC *)[storyboard instantiateViewControllerWithIdentifier:@"CardVC"];
    cardViewController.room = customChatRoom;
    cardViewController.messageItComesFrom = room;
    
    
    return cardViewController;
}

-(void)checkIfCustomChatViewIsVisible
{
    UINavigationController* flashbacksNavController = [(AppDelegate *)[[UIApplication sharedApplication] delegate] navFavorites];
    if ([flashbacksNavController.viewControllers.lastObject isKindOfClass:[CustomChatView class]])
    {
        [self.scrollView setContentOffset:CGPointMake(self.view.frame.size.width * 2, 0) animated:0];
        self.scrollView.scrollEnabled = NO;
    }
}

- (void)viewDidLoad
{
    // this isn't firing
    [super viewDidLoad];
    NSLog(@"Set up the inbox modal tool");
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
