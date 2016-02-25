//
//  CardObject.m
//  Volley
//
//  Created by Kyle Bendelow on 2/23/16.
//  Copyright © 2016 KZ. All rights reserved.
//

#import "CardObject.h"
#import "AppConstant.h"
#import "messages.h"

@implementation CardObject

- (instancetype)initWithChatObject:(PFObject *)object;
{
    self = [super init];
    if (self)
    {
        self.set = [object objectForKey:@"setId"];
        self.setID = self.set.objectId;
        if ([self.set objectForKey:@"title"])
        {
            self.title = [self.set objectForKey:@"title"];
        }
        self.dateUpdated = self.set.updatedAt;
        self.photosArray = [NSMutableArray new];
        self.messagesArray = [NSMutableArray new];
        self.numberOfTextMessages = 0;
        [self checkIfIsPictureOrMessageWith:object];
//        NSLog(@"CREATED CARD");
    }
    return self;
}

-(void)modifyCardWith:(PFObject *)object
{
//    NSLog(@"MODIFIED CARD");
    [self checkIfIsPictureOrMessageWith:object];
}

-(void)checkIfIsPictureOrMessageWith:(PFObject *)object
{
    if ([object objectForKey:PF_PICTURES_THUMBNAIL])
    {
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

                self.photosArray = [[NSMutableArray alloc] initWithArray:sortedArray];
            }
            
            NSDate *date = object[PF_PICTURES_UPDATEDACTION];

            self.dateUpdated = date;
            self.numberFromDateToSortWith = [NSNumber numberWithDouble:[date timeIntervalSinceReferenceDate]];
            
//            [self createCardVCwithSetID:set.objectId andPictures:self.photosArray andComments:self.messagesArray];
        }
    }
    else
    {
        [self addMessageToOurArrayWith:object];
    }
}

-(void)addMessageToOurArrayWith:(PFObject*)object
{
    PFUser *user = object[PF_CHAT_USER];
    NSDate *date = object[PF_PICTURES_UPDATEDACTION];
    PFObject *set = object[PF_CHAT_SETID];
    
    if (!date) date = [NSDate date];
    
    if (![object[PF_CHAT_TEXT] isEqualToString:@"emptyCard"])
    {
        JSQMessage *message = [[JSQMessage alloc] initWithSenderId:user.objectId
                                                 senderDisplayName:user[PF_USER_FULLNAME]
                                                             setId:set.objectId
                                                              date:date
                                                              text:object[PF_CHAT_TEXT]];
        
        [self.messagesArray addObject:message];
        self.numberOfTextMessages++;
    }
    
    self.dateUpdated = date;
    self.numberFromDateToSortWith = [NSNumber numberWithDouble:[date timeIntervalSinceReferenceDate]];
//    [self createCardVCwithSetID:set.objectId andPictures:self.photosArray andComments:self.messagesArray];
}

-(void)createVCForCard
{
    CardCellView *vc = [[CardCellView alloc] initWithSetId:self.setID andColor:[UIColor volleyFamousGreen] andPictures:self.photosArray andComments:self.messagesArray];
    self.chatVC = vc;
}

+ (void)retrieveResultsWithSearchTerm:(PFObject *)chatRoom withCompletion:(void (^)(NSArray *results))complete
{
    NSLog(@"Created PFQuery for Cards");
    PFQuery *query = [PFQuery queryWithClassName:PF_CHAT_CLASS_NAME];
    [query whereKey:PF_CHAT_ROOM equalTo:chatRoom];
    [query includeKey:PF_CHAT_USER];
    [query includeKey:PF_CHAT_SETID];
    [query setLimit:1000];
    [query orderByDescending:@"createdAt"];

    [query findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error)
    {
        if (!error)
        {
            complete(objects);
        }
        else
        {
            NSLog(@"%@", error);
        }
    }];
}

- (void)getPicsForCardwithPics:(void (^)(BOOL pics))complete
{
    long tempcount = self.photosArray.count;
    int count = (int)tempcount;
    
    if (count == 0)
    {
        NSLog(@"no images");
        self.imageOne = [UIImage imageNamed:@"Vollie-icon"];
        self.imageTwo = [UIImage imageNamed:@"Vollie-icon"];
        complete (YES);
    }
    else if (count == 1)
    {
        PFObject *tempPhoto = self.photosArray[0];
        PFFile *thumbnail = [tempPhoto objectForKey:@"thumbnail"];
        [thumbnail getDataInBackgroundWithBlock:^(NSData *data, NSError *error)
         {
             if (!error)
             {
                 NSLog(@"downloaded 1 pic");
                 self.imageOne = [UIImage imageWithData:data];
                 self.imageTwo = [UIImage imageNamed:@"Vollie-icon"];
                 complete (YES);
             }
         }];
    }
    else
    {
        PFObject *firstPhoto = self.photosArray[count-2];
        PFFile *firstThumbnailData = [firstPhoto objectForKey:@"thumbnail"];
        [firstThumbnailData getDataInBackgroundWithBlock:^(NSData *data, NSError *error)
         {
             if (!error)
             {
                 self.imageOne = [UIImage imageWithData:data];
             }
         }];
        PFObject *secondPhoto = self.photosArray[count-1];
        PFFile *secondPhotoFile = [secondPhoto objectForKey:@"thumbnail"];
        [secondPhotoFile getDataInBackgroundWithBlock:^(NSData *data, NSError *error)
         {
             if (!error)
             {
                 NSLog(@"downloaded 2 pics");
                 self.imageTwo = [UIImage imageWithData:data];
                 complete (YES);
             }
         }];
    }
}

- (void)checkForUnreadUsers:(void (^)(BOOL finished))complete
{
    PFRelation *unreadUsers = [self.set relationForKey:@"unreadUsers"];
    [unreadUsers.query findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error)
     {
         if (!error)
         {
             for (PFUser *user in objects)
             {
                 if ([user.objectId isEqualToString:[PFUser currentUser].objectId])
                 {
                     NSLog(@"There is an updated card in this room you haven't read");
                     self.unreadStatus = true;
                 }
             }
             complete (YES);
         }
     }];

}

@end
