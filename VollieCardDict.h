//
//  VollieCardDict.h
//  Volley
//
//  Created by Kyle on 6/12/15.
//  Copyright (c) 2015 KZ. All rights reserved.
//

#import <Foundation/Foundation.h>
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

@interface VollieCardDict : NSMutableDictionary

@property NSString *setID;
@property NSMutableArray *photosArray;
@property NSMutableArray *messagesArray;

-(instancetype)initWithPFObject:(PFObject*)PFObject;

@end
