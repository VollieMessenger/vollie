//
//  CardVC.m
//  Volley
//
//  Created by Kyle on 6/10/15.
//  Copyright (c) 2015 KZ. All rights reserved.
//

#import "CardVC.h"
#import <Parse/Parse.h>
#import <ParseUI/ParseUI.h>
#import "ProgressHUD.h"
#import "NSDate+TimeAgo.h"
#import "AppConstant.h"
//#import "camera.h"
#import "utilities.h"
#import "messages.h"
#import "pushnotification.h"
#import "UIColor+JSQMessages.h"
#import "CustomCameraView.h"
#import "CustomChatView.h"
#import "CustomCollectionViewCell.h"
#import "ChatView.h"
#import "ChatroomUsersView.h"
#import "AppDelegate.h"
#import <MediaPlayer/MediaPlayer.h>

@interface CardVC ()
@property (strong, nonatomic) IBOutlet UILabel *nameLabel;
@property (strong, nonatomic) IBOutlet UILabel *testLabel;

@property BOOL isLoading;

@end

@implementation CardVC

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.nameLabel.text = self.name;
    self.title = self.name;
//    self.testLabel.text = ;


}

#pragma mark - Navigation

-(void)loadMessages
{
    if (self.isLoading == NO)
    {
        PFQuery *query = [PFQuery queryWithClassName:PF_CHAT_CLASS_NAME];
        [query whereKey:PF_CHAT_ROOM equalTo:self.room];
//        JSQMessage *message_last = [messages lastObject];
//        PFObject *picture_last = [pictureObjects lastObject];
    }
}


@end
