//
//  CardVC.h
//  Volley
//
//  Created by Kyle on 6/10/15.
//  Copyright (c) 2015 KZ. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "JSQMessages.h"

#import "KLCPopup.h"

#import <Parse/Parse.h>

@interface MomentsVC : UIViewController

@property PFObject *room;
@property NSString *name;
@property PFObject *messageItComesFrom;

-(void)reloadCardsAfterUpload;

@end
