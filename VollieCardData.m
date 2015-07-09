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

-(instancetype)initWithPFObject:(PFObject *)object
{
    self = [super self];
    if(self)
    {
//        NSLog(@"%@", object);
        PFObject *set = [object objectForKey:@"setId"];
        self.set = set.objectId;
//        NSLog(@"%@ is my my SetID", self.set);

        self.photosArray = [NSMutableArray new];
        self.messagesArray = [NSMutableArray new];

        [self checkIfIsPictureOrMessageWith:object];
    }
    return self;
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
            PFObject *set = object[PF_CHAT_SETID];
            [self createCardVCwithSetID:set.objectId andPictures:self.photosArray andComments:self.messagesArray];
        }
    }
    else
    {// IS A COMMENT
        [self addMessageToOurArrayWith:object];
    }
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
    [self createCardVCwithSetID:set.objectId andPictures:self.photosArray andComments:self.messagesArray];
}

-(void)createCardVCwithSetID:(NSString*)setID andPictures:(NSMutableArray*)picsArray andComments:(NSMutableArray *)commentsArray
{
//    if (!picsArray.count)
//    {
//        UIImage *image = [UIImage imageNamed:@"Vollie-icon"];
//        [picsArray addObject:image];
//    }
    CardCellView *vc = [[CardCellView alloc] initWithSetId:setID andColor:[UIColor volleyFamousGreen] andPictures:picsArray andComments:commentsArray];
    self.viewController = vc;
    //    chatt.senderId = [self.senderId copy];
    //    chatt.senderDisplayName = [self.senderDisplayName copy];
//    vc.room = self.room;
//    [self.vollieVCcardArray addObject:vc];
//    [self.tableView reloadData];
}

@end
