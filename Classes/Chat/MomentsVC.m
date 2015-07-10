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
#import "NewVollieVC.h"
#import "ManageChatVC.h"
#import "OnePicCell.h"

@interface MomentsVC () <UITableViewDataSource, UITableViewDelegate>
@property (strong, nonatomic) IBOutlet UITableView *tableView;

@property (strong, nonatomic) IBOutlet UIImageView *vollieIconImageView;

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
    [self basicSetUpForUI];

    self.messages = [NSMutableArray new];
    self.colorForSetID = [NSMutableDictionary new];
    self.setsIDsArray = [NSMutableArray new];
    self.vollieCardDataArray = [NSMutableArray new];
    self.objectIdsArray = [NSMutableArray new];
    self.vollieVCcardArray = [NSMutableArray new];

    [self loadMessages];
}

-(void)basicSetUpForUI
{
    self.title = self.name;
    self.tableView.backgroundColor = [UIColor clearColor];
    self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    // gets rid of line ^^
    self.automaticallyAdjustsScrollViewInsets = NO;
    self.vollieIconImageView.layer.cornerRadius = 10;
    self.vollieIconImageView.layer.masksToBounds = YES;
    UIBarButtonItem *barButton = [[UIBarButtonItem alloc] initWithTitle:@"More" style:UIBarButtonItemStyleBordered target:self action:@selector(goToManageChatVC)];
    barButton.image = [UIImage imageNamed:ASSETS_TYPING];
    self.navigationItem.rightBarButtonItem = barButton;
}

-(void)goToManageChatVC
{
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Storyboard" bundle:nil];
    ManageChatVC *manageChatVC = (ManageChatVC *)[storyboard instantiateViewControllerWithIdentifier:@"ManageChatVC"];
    manageChatVC.messageButReallyRoom = self.messageItComesFrom;
    manageChatVC.room = self.room;
    [self.navigationController pushViewController:manageChatVC animated:YES];
}

-(void)viewDidAppear:(BOOL)animated
{
    [self loadMessages];
}

#pragma mark - TableView

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    VollieCardData *card = self.vollieCardDataArray[indexPath.row];

    CustomChatView *chatt = [[CustomChatView alloc] initWithSetId:card.set andColor:[UIColor volleyFamousGreen]     andPictures:card.photosArray andComments:card.messagesArray];
//    chatt.senderId = [self.senderId copy];
//    chatt.senderDisplayName = [self.senderDisplayName copy];
    chatt.room = self.room;

    NSString *title;

    [chatt setTitle:title];

    CATransition* transition = [CATransition animation];
    transition.duration = 0.3;
    transition.type = kCATransitionPush;
    transition.subtype = kCATransitionFromRight;
    transition.timingFunction = UIViewAnimationCurveEaseInOut;
    transition.fillMode = kCAFillModeForwards;
    [self.navigationController.view.layer addAnimation:transition forKey:kCATransition];
    [self.navigationController pushViewController:chatt animated:1];
}
-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.vollieCardDataArray.count;
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    VollieCardData *data = self.vollieCardDataArray[indexPath.item];
    if (data.photosArray.count)
    {
        switch (data.photosArray.count)
        {
            case 1:
                return 160;
                break;
            case 2:
                return 260;
            case 3:
                return 350;
            case 4:
                return 450;
            case 5:
                return 530;
            default:
                return 160;
                break;
        }
    }
    else
    {
        return 115;
    }

}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    VollieCardData *card = [self.vollieCardDataArray objectAtIndex:indexPath.row];

    if (card.photosArray.count == 1)
    {
        OnePicCell *cell = [tableView dequeueReusableCellWithIdentifier:@"OnePicCell"];
        [cell fillPicsWithVollieCardData:card];
        [cell formatCell];
        return cell;
    }
    else
    {
    CellForCard *cell = [tableView dequeueReusableCellWithIdentifier:@"cellid"];
    cell.cardOutline.backgroundColor = [UIColor clearColor];
    cell.backgroundColor = [UIColor clearColor];
    CardCellView *vc = card.viewController;
    vc.room = self.room;
    vc.view.backgroundColor =[UIColor whiteColor];
    [self.vollieVCcardArray addObject:vc];

//    superTest *cv = [self.storyboard instantiateViewControllerWithIdentifier:@"testID"];
    vc.view.frame = cell.cardOutline.bounds;
    cell.cardOutline.layer.cornerRadius = 10;
    cell.cardOutline.layer.borderColor = [UIColor colorWithWhite:0.829 alpha:1.000].CGColor;
    cell.cardOutline.layer.borderWidth = 1;
    cell.cardOutline.layer.masksToBounds = YES;
//    NSLog(@"%f is cell height", cell.cardOutline.bounds.size.height);
//    NSLog(@"%f is VC height", vc.card.bounds.size.height);
    [self addChildViewController:vc];
    [cell.cardOutline addSubview:vc.view];
    [vc didMoveToParentViewController:self];
    return cell;
    }
}

-(void)scrollToBottomAndReload
{
    [self.tableView reloadData];
    NSIndexPath* ip = [NSIndexPath indexPathForRow:[self.tableView numberOfRowsInSection:0] - 1 inSection:0];
    [self.tableView scrollToRowAtIndexPath:ip atScrollPosition:UITableViewScrollPositionTop animated:NO];
}

#pragma mark - ParseLoad

-(void)loadMessages
{
//    if (self.isLoading == NO)
//    {
//        self.isLoading = YES;
        [self createQuery];
//    }
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
         if(!error)
         {
             [self clearPushNotesCounter];
             for (PFObject *object in [objects reverseObjectEnumerator])
             {
                 [self checkForObjectIdWith:object];
             }
         }
         else
         {
             NSLog(@"%@",error);
         }
     }];
}

-(void)clearPushNotesCounter
{
    NSNumber *number = [self.messageItComesFrom valueForKey:PF_MESSAGES_COUNTER];
    if (number)
    {
        if ([number intValue] > 0)
        {
            ClearMessageCounter(self.messageItComesFrom);
        }
    }
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
                    [card modifyCardWith:object];
                    [self scrollToBottomAndReload];
                }
            }
        }
        else
        {
            VollieCardData *card = [[VollieCardData alloc] initWithPFObject:object];
            [self.vollieCardDataArray addObject:card];
            [self.setsIDsArray addObject:set.objectId];
            //create vollie card
            [self scrollToBottomAndReload];
        }
    }
}

-(void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
//newVollieToGroup
    if([[segue identifier] isEqualToString:@"newVollieToGroup"])
    {
        NSLog(@"New Vollie is going to Room");
    }
    NewVollieVC *vc = [segue destinationViewController];
    vc.whichRoom = self.room;
}

@end
