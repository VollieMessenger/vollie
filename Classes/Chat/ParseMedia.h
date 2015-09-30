//
//  ParseMedia.h
//  Volley
//
//  Created by Kyle Bendelow on 8/27/15.
//  Copyright (c) 2015 KZ. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <Parse/Parse.h>

@interface ParseMedia : NSObject

@property PFObject *set;
@property PFObject *userChatroom;
@property PFFile *mediaForCell;
@property PFFile *thumbNail;
@property NSDate *createdAt;

-(instancetype)initWithPFObject:(PFObject *)object;

@end
