//
//  UserData.h
//  Volley
//
//  Created by Kyle Bendelow on 5/16/16.
//  Copyright © 2016 KZ. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <Parse/Parse.h>


@interface UserData : NSObject

-(instancetype)initWithPFObject:(PFObject *)object;
-(void)modifyCardWith:(PFObject *)object;

@property NSString *userID;
@property NSString *userName;
@property int numberOfMessages;
@property int numberOfChatRooms;
@property PFUser *user;
@property NSMutableArray *chatRoomsArray;
@property NSMutableArray *messagesArray;

@end
