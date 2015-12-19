//
//  MainInboxVC.h
//  Volley
//
//  Created by Kyle Bendelow on 8/4/15.
//  Copyright (c) 2015 KZ. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MasterScrollView.h"
#import <Parse/Parse.h>
#import "MomentsVC.h"
#import "InboxModal.h"

@interface MainInboxVC : UIViewController

@property (strong, nonatomic) MasterScrollView *scrollView;
@property NSMutableArray *messages;
@property MomentsVC *cardViewVC;
@property BOOL shouldShowTempCard;
@property InboxModal *inboxModalTool;


//-(void)goToMostRecentChatRoom;
-(void)newGoToCardViewWith:(PFObject*)userChatRoom and:(PFObject*)room andNotification:(BOOL)notificationShow;
-(void)loadInbox;
-(void)setUpTopNotification;
-(void)hideTopNotification;

@end

