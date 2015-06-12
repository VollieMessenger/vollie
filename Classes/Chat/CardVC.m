//
//  CardVC.m
//  Volley
//
//  Created by Kyle on 6/10/15.
//  Copyright (c) 2015 KZ. All rights reserved.
//

#import "CardVC.h"
#import <Parse/Parse.h>
#import <ParseUI/ParseUI.h>
#import "ProgressHUD.h"
#import "NSDate+TimeAgo.h"
#import "AppConstant.h"
//#import "camera.h"
#import "utilities.h"
#import "messages.h"
#import "pushnotification.h"
#import "UIColor+JSQMessages.h"
#import "CustomCameraView.h"
#import "CustomChatView.h"
#import "CustomCollectionViewCell.h"
#import "ChatView.h"
#import "ChatroomUsersView.h"
#import "AppDelegate.h"
#import <MediaPlayer/MediaPlayer.h>
#import "VollieCardDict.h"

@interface CardVC () <UITableViewDataSource, UITableViewDelegate>
@property (strong, nonatomic) IBOutlet UITableView *tableView;

@property BOOL isLoading;

@property NSMutableArray *messages;
@property NSMutableArray *pictureObjects;
@property NSMutableArray *pictureObjectIDs;
@property NSMutableArray *messageObjects;
@property NSDictionary *messageToSetIDs;
@property NSMutableArray *messageObjectIDs;
@property NSMutableDictionary *colorForSetID;
@property NSMutableArray *unassignedCommentArray;
@property NSMutableArray *unassignedCommentArrayIDs;
@property NSMutableArray *setsArray;
@property NSMutableArray *setsIDsArray;
@property NSMutableArray *vollieCardArray;

@property int isLoadingEarlierCount;

@end

@implementation CardVC

- (void)viewDidLoad
{
    [super viewDidLoad];

    self.isLoading = NO;
    self.title = self.name;
//    self.testLabel.text = ;

    self.messages = [[NSMutableArray alloc] init];
    self.pictureObjects = [NSMutableArray new];
    self.pictureObjectIDs = [NSMutableArray new];
    self.messageObjects = [NSMutableArray new];
    self.messageToSetIDs = [NSDictionary new];
    self.messageObjectIDs = [NSMutableArray new];
    self.colorForSetID = [NSMutableDictionary new];
    self.unassignedCommentArray = [NSMutableArray new];
    self.unassignedCommentArrayIDs = [NSMutableArray new];
    self.setsArray = [NSMutableArray new];
    self.setsIDsArray = [NSMutableArray new];
    self.vollieCardArray = [NSMutableArray new];

    [self loadMessages];
}

#pragma mark - TableView
-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.setsIDsArray.count;
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"cellid"];
    PFObject *object = [self.setsIDsArray objectAtIndex:indexPath.row];
    cell.textLabel.text = [NSString stringWithFormat:@"%@", object];
    return cell;
}

#pragma mark - ParseLoad

-(void)loadMessages
{
    if (self.isLoading == NO)
    {
        self.isLoading = YES;
        [self createQuery];
    }
}

-(void)createQuery
{
    JSQMessage *message_last = [self.messages lastObject];
    PFObject *picture_last = [self.pictureObjects lastObject];

    PFQuery *query = [PFQuery queryWithClassName:PF_CHAT_CLASS_NAME];
    [query whereKey:PF_CHAT_ROOM equalTo:self.room];
    [query includeKey:PF_CHAT_USER];
    [query includeKey:PF_CHAT_SETID];
    [query orderByDescending:PF_PICTURES_UPDATEDACTION];

//    if (message_last && picture_last)
//    {
//        if (message_last.date > picture_last.createdAt)
//        {
//            [query whereKey:PF_CHAT_CREATEDAT greaterThan:message_last.date];
//        }
//        else
//        {
//            [query whereKey:PF_CHAT_CREATEDAT greaterThan:picture_last.createdAt];
//        }
//    }

    [self getMessagesWithPFQuery:query];
}

-(void)getMessagesWithPFQuery:(PFQuery *)query
{
    [query findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error)
     {
         if(error == nil);
         for (PFObject *object in [objects reverseObjectEnumerator])
         {
//             NSLog(@"%@", [object objectForKey:@"setId"]);
             [self checkIfIsPictureOrMessageWith:object];
         }
     }];
}

-(void)assignToCorrectSet
{

}

-(void)checkIfIsPictureOrMessageWith:(PFObject *)object
{
    if ([object objectForKey:PF_PICTURES_THUMBNAIL])
    {// IS A PICTURE, ADD TO PICTURES
        if ([object valueForKey:PF_CHAT_ISUPLOADED])
        {
            if ([self.pictureObjectIDs containsObject:object.objectId])
            {
                [self.pictureObjectIDs addObject:object.objectId];
                [self.pictureObjects addObject:object];
            }
        }
    }
    else
    {// IS A COMMENT
        if (![self.messageObjectIDs containsObject:object.objectId])
        {
            [self parseThroughMessageDataWithObject:object];
        }
    }
}

-(void)parseThroughMessageDataWithObject:(PFObject*)object
{
    PFUser *user = object[PF_CHAT_USER];
    NSDate *date = object[PF_PICTURES_UPDATEDACTION];
    PFObject *set = object[PF_CHAT_SETID];
    if (!set)
    {
        // if it doesn't exist, set one?
        NSLog(@"found a message without a set");
    }
    else
    {
        if ([self.setsIDsArray containsObject:set])
        {
            //"this one already had a set"
        }
        else
        {
            [self.setsIDsArray addObject:set];
            NSLog(@"%li sets", self.setsIDsArray.count);
//            NSLog(@"ADDED A SET");
        }
    }
    if (!date) date = [NSDate date];
    JSQMessage *message = [[JSQMessage alloc] initWithSenderId:user.objectId
                                             senderDisplayName:user[PF_USER_FULLNAME]
                                                         setId:set.objectId
                                                          date:date
                                                          text:object[PF_CHAT_TEXT]];
    [self.messages addObject:message];
    [self.messageObjectIDs addObject:object.objectId];
//    NSLog(@"added a message to messages, we now have %li", self.messages.count);
    [self.tableView reloadData];
}



@end
