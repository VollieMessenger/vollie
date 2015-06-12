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
#import "VollieCard.h"
#import "CardCell.h"

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
@property NSMutableArray *objectIdsArray;

@property int isLoadingEarlierCount;

@end

@implementation CardVC

- (void)viewDidLoad
{
    [super viewDidLoad];

    self.isLoading = NO;
    self.title = self.name;
//    self.testLabel.text = ;

    self.messages = [NSMutableArray new];
    self.colorForSetID = [NSMutableDictionary new];
    self.setsIDsArray = [NSMutableArray new];
    self.vollieCardArray = [NSMutableArray new];
    self.objectIdsArray = [NSMutableArray new];

    [self loadMessages];

}

#pragma mark - TableView
-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.vollieCardArray.count;
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    VollieCard *card = [self.vollieCardArray objectAtIndex:indexPath.row];
    CardCell *cell = [tableView dequeueReusableCellWithIdentifier:@"cellid"];
    cell.testLabel.text = [NSString stringWithFormat:@"set %li", indexPath.row];
    cell.picLabel.text = [NSString stringWithFormat:@"%li pics", card.photosArray.count];
    cell.messageLabel.text = [NSString stringWithFormat:@"%li messages", card.messagesArray.count];
//    PFObject *object = [self.setsIDsArray objectAtIndex:indexPath.row];
//    cell.textLabel.text = [NSString stringWithFormat:@"%@", object];
    return cell;

//    http://stackoverflow.com/questions/17398058/is-it-possible-to-add-uitableview-within-a-uitableviewcell
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
//    JSQMessage *message_last = [self.messages lastObject];
//    PFObject *picture_last = [self.pictureObjects lastObject];

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
             [self checkForObjectIdWith:object];
         }
     }];
}

-(void)checkForObjectIdWith:(PFObject *)object
{
    if (![self.objectIdsArray containsObject:object.objectId])
    {
        [self.objectIdsArray addObject:object.objectId];
        [self checkForVollieCardWith:object];
    }
    else
    {
        NSLog(@"this message is already somewhere");
    }
}

-(void)checkForVollieCardWith:(PFObject *)object
{
    PFObject *set = [object objectForKey:@"setId"];
    if (set)
    {
        if ([self.setsIDsArray containsObject:set.objectId])
        {
            //find the correct vollie card
            for (VollieCard *card in self.vollieCardArray)
            {
                if ([card.set isEqualToString:set.objectId])
                {
                    [card modifyCardWith:object];
                    [self.tableView reloadData];
                }
            }
        }
        else
        {
            NSLog(@"%@", object.objectId);
            VollieCard *card = [[VollieCard alloc] initWithPFObject:object];
            [self.vollieCardArray addObject:card];
            [self.setsIDsArray addObject:set.objectId];
            [self.tableView reloadData];
            //create vollie card
        }
    }
}
@end
