//
//  SelectChatroomView.h
//  Volley
//
//  Created by benjaminhallock@gmail.com on 1/12/15.
//  Copyright (c) 2015 KZ. All rights reserved.
//

#import <UIKit/UIKit.h>

#import <Parse/Parse.h>

#import "CreateChatroomView.h"

#import "MasterScrollView.h"

@interface DidFavoriteView : UIViewController

@property PFObject *set;

@property PFObject *album;

@property BOOL isMovingAlbum;

@end
