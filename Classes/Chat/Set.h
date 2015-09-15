//
//  Set.h
//  Volley
//
//  Created by Kyle Bendelow on 8/26/15.
//  Copyright (c) 2015 KZ. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <Parse/Parse.h>

@interface Set : NSObject

@property int numberOfResponses;
@property PFObject *set;
@property PFObject *userChatroom;

@end
