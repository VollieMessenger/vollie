//
//  CardVC.m
//  Volley
//
//  Created by Kyle on 6/10/15.
//  Copyright (c) 2015 KZ. All rights reserved.
//

#import "MomentsVC.h"
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
#import "VollieCardData.h"
#import "CellForCard.h"
#import "ChatColView.h"

@interface MomentsVC () <UITableViewDataSource, UITableViewDelegate>
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
@property NSMutableArray *vollieCardDataArray;
@property NSMutableArray *objectIdsArray;
@property NSMutableArray *vollieVCcardArray;
@property (strong, nonatomic) IBOutlet UICollectionView *messagesCollectionView;

@property int isLoadingEarlierCount;

@end

@implementation MomentsVC

- (void)viewDidLoad
{
    [super viewDidLoad];

    self.isLoading = NO;
    self.title = self.name;
//    self.testLabel.text = ;

    self.messages = [NSMutableArray new];
    self.colorForSetID = [NSMutableDictionary new];
    self.setsIDsArray = [NSMutableArray new];
    self.vollieCardDataArray = [NSMutableArray new];
    self.objectIdsArray = [NSMutableArray new];
    self.vollieVCcardArray = [NSMutableArray new];

    [self loadMessages];
}

-(void)viewDidAppear:(BOOL)animated
{
    [self loadMessages];
}

#pragma mark - TableView
-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.vollieCardDataArray.count;
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    VollieCardData *card = [self.vollieCardDataArray objectAtIndex:indexPath.row];
    CellForCard *cell = [tableView dequeueReusableCellWithIdentifier:@"cellid"];
//    cell = [[CardCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"cellid"];
//    cell.testLabel.text = [NSString stringWithFormat:@"set %li", indexPath.row];
//    cell.picLabel.text = [NSString stringWithFormat:@"%li pics", card.photosArray.count];
//    cell.messageLabel.text = [NSString stringWithFormat:@"%li messages", card.messagesArray.count];
//    cell.card = card;

//    CustomChatView *vc = [[CustomChatView alloc] initWithSetId:card.set andColor:[UIColor redColor] andPictures:card.photosArray andComments:card.messagesArray];
////    chatt.senderId = [self.senderId copy];
////    chatt.senderDisplayName = [self.senderDisplayName copy];
//    vc.room = self.room;
    CardCellView *vc = card.viewController;
    vc.room = self.room;
    [self.vollieVCcardArray addObject:vc];

//    superTest *cv = [self.storyboard instantiateViewControllerWithIdentifier:@"testID"];
    vc.view.frame = cell.cardOutline.bounds;
    cell.cardOutline.layer.cornerRadius = 45;
    cell.cardOutline.layer.borderColor = [UIColor volleyFamousGreen].CGColor;
    cell.cardOutline.layer.borderWidth = 1;
    cell.cardOutline.layer.masksToBounds = YES;
//    NSLog(@"%f is cell height", cell.cardOutline.bounds.size.height);
//    NSLog(@"%f is VC height", vc.card.bounds.size.height);
    [self addChildViewController:vc];
    [cell.cardOutline addSubview:vc.view];
    [vc didMoveToParentViewController:self];

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
//         for (PFObject *object in [objects reverseObjectEnumerator])
//         {
//             [self checkForObjectIdWith:object];
//         }
         for (PFObject *object in objects)
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
//        NSLog(@"this message is already somewhere");
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
            for (VollieCardData *card in self.vollieCardDataArray)
            {
                if ([card.set isEqualToString:set.objectId])
                {
//                    for (CustomChatView *vc in self.vollieVCcardArray)
//                    {
//                        if([vc.setIDforCardCheck isEqualToString:set.objectId])
//                        {
//                            [self.vollieVCcardArray removeObject:vc];
//                        }
//                    }
                    [card modifyCardWith:object];
                    [self createCardVCwithVollieCardData:card];
                }
            }
        }
        else
        {
//            NSLog(@"%@", object.objectId);
            VollieCardData *card = [[VollieCardData alloc] initWithPFObject:object];
            [self.vollieCardDataArray addObject:card];
            [self.setsIDsArray addObject:set.objectId];
            //create vollie card
            [self createCardVCwithVollieCardData:card];
        }
    }
}

-(void)createCardVCwithVollieCardData:(VollieCardData*)cardData
{
//    CustomChatView *vc = [[CustomChatView alloc] initWithSetId:cardData.set andColor:[UIColor volleyFamousGreen] andPictures:cardData.photosArray andComments:cardData.messagesArray];
//    //    chatt.senderId = [self.senderId copy];
//    //    chatt.senderDisplayName = [self.senderDisplayName copy];
//    vc.room = self.room;
//    [self.vollieVCcardArray addObject:vc];
    [self.tableView reloadData];
}

@end
