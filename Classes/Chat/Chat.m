//
//  RoomObject.m
//  Volley
//
//  Created by Kyle Bendelow on 8/4/15.
//  Copyright (c) 2015 KZ. All rights reserved.
//

#import "Chat.h"
#import "AppConstant.h"

@implementation Chat

-(NSArray *)getParseInformation
{
    
    NSMutableArray *objectsToReturn;
    PFQuery *query = [PFQuery queryWithClassName:PF_MESSAGES_CLASS_NAME];
    [query whereKey:PF_MESSAGES_USER equalTo:[PFUser currentUser]];
    //      [query includeKey:PF_MESSAGES_LASTUSER];
    [query includeKey:PF_MESSAGES_ROOM];
    [query includeKey:PF_MESSAGES_USER]; // doesn't need to be here
    [query includeKey:PF_MESSAGES_LASTPICTURE];
    [query includeKey:PF_MESSAGES_LASTPICTUREUSER];
    [query whereKey:PF_MESSAGES_HIDE_UNTIL_NEXT equalTo:@NO];
    [query orderByDescending:PF_MESSAGES_UPDATEDACTION];
    [query setCachePolicy:kPFCachePolicyCacheThenNetwork];
    [query findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error)
     {
         if (!error)
         {
             for (PFObject *message in objects)
             {
                 
                 if ([[message valueForKey:PF_MESSAGES_LASTMESSAGE] isEqualToString:@""] && ![message valueForKey:PF_MESSAGES_LASTPICTURE])
                 {
                     //this hides messages that have neither a message or picture yet
                     //i'd like to make this cleaner and actually delete it off of parse, but this works for now
                 }
                 else
                 {
                     [objectsToReturn addObject:message];
                     
                     //                             NSDate *date = [message valueForKey:PF_MESSAGES_UPDATEDACTION];
                     //                             date = [self dateAtBeginningOfDayForDate:date];
                     //
                     //                             if (![self.savedDates containsObject:date])
                     //                             {
                     //                                 [self.savedDates addObject:date];
                     //                                 NSMutableArray *array = [NSMutableArray arrayWithObject:message];
                     //                                 NSDictionary *dict = [NSDictionary dictionaryWithObject:array forKey:date];
                     //                                 [self.savedMessagesForDate addEntriesFromDictionary:dict];
                     //                             }
                     //                             else
                     //                             {
                     //                                 [(NSMutableArray *)[self.savedMessagesForDate objectForKey:date] addObject:message];
                     //                             }
                 }
             }
         }
     }];
    
    return nil;
}


@end
