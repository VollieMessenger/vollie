//
//  FullChatVC.h
//  Volley
//
//  Created by Kyle on 7/20/15.
//  Copyright (c) 2015 KZ. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <Parse/Parse.h>
#import "JSQMessages.h"
#import "VollieCardData.h"

@interface FullChatVC : UIViewController

@property PFObject *room;
@property NSString *name;
@property VollieCardData *card;

-(id)initWithCard:(VollieCardData *)card;

@end
