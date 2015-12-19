//
//  InboxModal.h
//  Volley
//
//  Created by Kyle Bendelow on 12/16/15.
//  Copyright © 2015 KZ. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <Parse/Parse.h>
#import "MomentsVC.h"


@interface InboxModal : UIViewController

-(PFQuery*)createQueryForUserChatRooms;
-(PFQuery*)createQueryForSharedChatRoom;
-(void)inviteContacts;
-(void)formatNavigationBar:(UINavigationBar*)bar;
-(MomentsVC *)createMomentsVCWith:(PFObject *)room andCustomChatRoom:(PFObject*)customChatRoom;

@property UINavigationController *nav;


@end
