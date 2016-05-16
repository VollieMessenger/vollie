//
//  UserData.m
//  Volley
//
//  Created by Kyle Bendelow on 5/16/16.
//  Copyright © 2016 KZ. All rights reserved.
//

#import "UserData.h"

@implementation UserData

-(instancetype)initWithPFObject:(PFObject *)object
{
    PFUser *user = [object objectForKey:@"user"];
    self.user = user;
    self.userID = user.objectId;
    self.chatRoomsArray = [NSMutableArray new];
    self.messagesArray = [NSMutableArray new];
    [self.messagesArray addObject:object];
    self.numberOfMessages = 1;
    
    [self addRoomIDtoArrayWith:object];
    
    return self;
}

-(void)modifyCardWith:(PFObject *)object
{
    [self.messagesArray addObject:object];
    [self addRoomIDtoArrayWith:object];
}

-(void)addRoomIDtoArrayWith:(PFObject *)object
{
    PFObject *room = [object objectForKey:@"room"];
    if (![self.chatRoomsArray containsObject:room.objectId])
    {
        [self.chatRoomsArray addObject:room.objectId];
    }
}



@end
