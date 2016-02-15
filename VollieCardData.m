//
//  VollieCardDict.m
//  Volley
//
//  Created by Kyle on 6/12/15.
//  Copyright (c) 2015 KZ. All rights reserved.
//

#import "VollieCardData.h"

@implementation VollieCardData

//this subclass contains the methods to create and modify cards

-(instancetype)initWithPFObject:(PFObject *)object andSet:(PFObject *)setObject
{
    self = [super self];
    if(self)
    {
//        NSLog(@"%@", object);
        
        if ([setObject objectForKey:@"title"])
        {
            self.titleForCard = [setObject objectForKey:@"title"];
        }
        
        self.actualSet = object;
        PFObject *set = [object objectForKey:@"setId"];
        self.set = set.objectId;
        self.dateUpdated = object.createdAt;
        NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
        [formatter setDateFormat:@"YYYY-MM-dd HH:mm"];

        self.photosArray = [NSMutableArray new];
        self.messagesArray = [NSMutableArray new];

        [self checkIfIsPictureOrMessageWith:object];
    }
    return self;
}

-(void)setDateUpdatedWithObject:(PFObject*)object
{
    NSDate *date = object.createdAt;
    self.numberFromDateToSortWith = [NSNumber numberWithDouble:[date timeIntervalSinceReferenceDate]];
}

-(void)setUnreadDotWithSet:(PFObject*)set
{
//    NSString *currentUserString = [PFUser currentUser].objectId;
    // we haven't brough in the set yet
    //if we do a findobjectinbasckgroundwithblock and try to do a query where relation doesn't include me
    
//    PFRelation *unreadUsers = [set relationForKey:@"unreadUsers"];
//    [unreadUsers.query findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error)
//    {
//        for (PFUser *user in objects)
//        {
//            if ([user.objectId isEqualToString:currentUserString])
//            {
//                NSLog(@"you're in this set");
//                self.unreadStatus = true;
//            }
////            NSLog(@"%@", user.objectId);
//        }
//    }];
    
    
    
//    PFQuery *setQuery = [PFQuery queryWithClassName:@"Sets"];
//    [setQuery getObjectInBackgroundWithId:self.set.objectId block:^(PFObject *fullSet, NSError *error)
//     {
//         if(!error)
//         {
//             self.set = fullSet;
//             PFObject *room = [fullSet objectForKey:@"room"];
//             NSLog(@"room info is %@", room);
//             self.room = room;
//         }
//     }];
//    [unreadUsers removeObject:[PFUser currentUser]];
//    NSString *userId = [PFUser currentUser].objectId;
//    for (PFUser *user in unreadUsers)
//    {
//        NSLog(@"%@", user.objectId);
//    }
}

-(void)modifyCardWith:(PFObject *)object
{
    [self checkIfIsPictureOrMessageWith:object];
}

-(void)checkIfIsPictureOrMessageWith:(PFObject *)object
{
    if ([object objectForKey:PF_PICTURES_THUMBNAIL])
    {// IS A PICTURE, ADD TO PICTURES
        if ([object valueForKey:PF_CHAT_ISUPLOADED])
        {
            [self.photosArray addObject:object];
            
            if (object[@"photoNumber"])
            {
                NSSortDescriptor *sortDescriptor;
                sortDescriptor = [[NSSortDescriptor alloc] initWithKey:@"photoNumber"
                                                             ascending:YES];
                NSArray *sortDescriptors = [NSArray arrayWithObject:sortDescriptor];
                NSArray *sortedArray = [self.photosArray sortedArrayUsingDescriptors:sortDescriptors];
//                NSArray* reversed = [[sortedArray reverseObjectEnumerator] allObjects];
//                sortedArray = reversed;

                
//                NSLog(@"%@", sortedArray);
                
//                for (PFObject *object in sortedArray)
//                {
//                    NSLog(@"%@", object[@"photoNumber"]);
//                }
                
//                self.photosArray = [NSMutableArray new];
//                for (PFObject *object2 in sortedArray)
//                {
//                    [self.photosArray addObject:object2];
//                }
                self.photosArray = [[NSMutableArray alloc] initWithArray:sortedArray];
//                self.photosArray = sortedArray;
            }
            
//            self.dateUpdated = object.createdAt;
            PFObject *set = object[PF_CHAT_SETID];
            NSDate *date = object[PF_PICTURES_UPDATEDACTION];
//            self.numberFromDateToSortWith = object[@"photoNumber"];
            self.dateUpdated = date;
            self.numberFromDateToSortWith = [NSNumber numberWithDouble:[date timeIntervalSinceReferenceDate]];

            [self createCardVCwithSetID:set.objectId andPictures:self.photosArray andComments:self.messagesArray];
        }
    }
    else
    {// IS A COMMENT
        [self addMessageToOurArrayWith:object];
//        if (object.createdAt > self.dateUpdated)
//        {
//            NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
//            [formatter setDateFormat:@"YYYY-MM-dd HH:mm"];
////            NSDate *todaysDate;
//            NSLog(@"Initialized date is %@",[formatter stringFromDate:self.dateUpdated]);
//            self.dateUpdated = object.createdAt;
//            NSLog(@"changed date is %@",[formatter stringFromDate:self.dateUpdated]);
//            self.numberFromDateToSortWith = [NSNumber numberWithDouble:[object.createdAt timeIntervalSinceReferenceDate]];
//            NSLog(@"%@", self.numberFromDateToSortWith);
//        }
    }
}

-(void)setDateForVollieCardData
{
    //kyle note: refactor this later
    //do this later
}

-(void)addMessageToOurArrayWith:(PFObject*)object
{
    PFUser *user = object[PF_CHAT_USER];
    NSDate *date = object[PF_PICTURES_UPDATEDACTION];
    PFObject *set = object[PF_CHAT_SETID];

    if (!date) date = [NSDate date];
    JSQMessage *message = [[JSQMessage alloc] initWithSenderId:user.objectId
                                             senderDisplayName:user[PF_USER_FULLNAME]
                                                         setId:set.objectId
                                                          date:date
                                                          text:object[PF_CHAT_TEXT]];

    [self.messagesArray addObject:message];
    
    self.dateUpdated = date;
    self.numberFromDateToSortWith = [NSNumber numberWithDouble:[date timeIntervalSinceReferenceDate]];
    [self createCardVCwithSetID:set.objectId andPictures:self.photosArray andComments:self.messagesArray];
}

-(void)createCardVCwithSetID:(NSString*)setID andPictures:(NSMutableArray*)picsArray andComments:(NSMutableArray *)commentsArray
{
    CardCellView *vc = [[CardCellView alloc] initWithSetId:setID andColor:[UIColor volleyFamousGreen] andPictures:picsArray andComments:commentsArray];
    self.viewController = vc;
    

    //
}

@end
