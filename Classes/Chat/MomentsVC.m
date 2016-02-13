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
#import "ChatColView.h"
#import "NewVollieVC.h"
#import "ManageChatVC.h"
#import "OnePicCell.h"
#import "OnePicCellNew.h"
#import "TwoPicCell.h"
#import "ThreePicCell.h"
#import "FourPicCell.h"
#import "FivePicCell.h"
#import "LoadingCell.h"
#import "ParseVolliePackage.h"
#import "AFDropdownNotification.h"
#import "FullWidthChatView.h"
#import "FullWidthCell.h"
#import "DynamicCardCell.h"



//for testing the fav cells
#import "FivePicsFavCell.h"

@interface MomentsVC () <UITableViewDataSource, UITableViewDelegate, RefreshMessagesDelegate, ManageChatDelegate, AFDropdownNotificationDelegate>
@property (strong, nonatomic) IBOutlet UITableView *tableView;

@property (strong, nonatomic) IBOutlet UIImageView *vollieIconImageView;

@property (weak, nonatomic) IBOutlet UIButton *nextVollieButton;

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

@property (nonatomic, strong) AFDropdownNotification *notification;


@property NSArray *sortedCardsArray;

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
    self.sortedCardsArray = [NSArray new];

    [self loadMessages];
}

-(void)basicSetUpForUI
{
    NSLog(@"Set Up MomentsVC UI");
    self.title = self.name;
    self.tableView.backgroundColor = [UIColor clearColor];
    self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    // gets rid of line ^^
    self.automaticallyAdjustsScrollViewInsets = NO;
    self.vollieIconImageView.layer.cornerRadius = 10;
    self.vollieIconImageView.layer.masksToBounds = YES;
    UIBarButtonItem *barButton = [[UIBarButtonItem alloc] initWithTitle:@"" style:UIBarButtonItemStylePlain target:self action:@selector(goToManageChatVC)];
    barButton.image = [UIImage imageNamed:ASSETS_TYPING];
    self.navigationItem.rightBarButtonItem = barButton;
    
    [self setUpTopNotification];
}

-(void)setUpTopNotification
{
    NSLog(@"Initialized Top Notification");
    self.notification = [[AFDropdownNotification alloc] init];
    self.notification.notificationDelegate = self;
    self.notification.titleText = @"Sending Vollie!";
    self.notification.subtitleText = @"We are uploading your Vollie now. Your new Vollie will appear at the bottom of the thread!";
    self.notification.image = [UIImage imageNamed:@"Vollie-icon"];
    self.notification.dismissOnTap = YES;
    if (self.shouldShowTempCard)
    {
        self.nextVollieButton.userInteractionEnabled = NO;
        NSLog(@"showing notificaiton");
        [self.notification presentInView:self.view withGravityAnimation:NO];
        self.shouldShowTempCard = NO;
    }
}

-(void)goToManageChatVC
{
    NSLog(@"Going to Chatroom Settings");
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Storyboard" bundle:nil];
    ManageChatVC *manageChatVC = (ManageChatVC *)[storyboard instantiateViewControllerWithIdentifier:@"ManageChatVC"];
    manageChatVC.delegate = self;
    manageChatVC.messageButReallyRoom = self.messageItComesFrom;
    manageChatVC.room = self.room;
    [self.navigationController pushViewController:manageChatVC animated:YES];
}

-(void)viewDidAppear:(BOOL)animated
{
    [self loadMessages];
}

-(void)viewWillAppear:(BOOL)animated
{
    [self.navigationController.navigationBar setTintColor:[UIColor colorWithWhite:.98 alpha:1]];
    [self.navigationController.navigationBar setBarTintColor:[UIColor volleyFamousGreen]];
    [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleLightContent animated:1];
    self.navigationController.navigationBar.titleTextAttributes =
    @{
        NSForegroundColorAttributeName: [UIColor colorWithWhite:.98 alpha:1],
        NSFontAttributeName: [UIFont fontWithName:@"Helvetica Neue" size:20.0f],
        NSShadowAttributeName:[NSShadow new]
    };
}

#pragma mark - TableView

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    VollieCardData *card = self.vollieCardDataArray[(indexPath.row/2)];
    [card.viewController clearUnreadDot];

    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    [formatter setDateFormat:@"YYYY-MM-dd HH:mm"];
//    NSLog(@"date is %@",[formatter stringFromDate:card.dateUpdated]);
//    VollieCardData *card = self.sortedCardsArray[(indexPath.row/2)];

//    CustomChatView *chatt = [[CustomChatView alloc] initWithSet:card.actualSet andUserChatRoom:self.room];
    CustomChatView *chatt = [[CustomChatView alloc] initWithSetId:card.set andColor:[UIColor volleyFamousGreen] andPictures:card.photosArray andComments:card.messagesArray andActualSet:card.actualSet];
//    chatt.senderId = [self.senderId copy];
//    chatt.senderDisplayName = [self.senderDisplayName copy];
//    CustomChatView *chatt = [[CustomChatView alloc] initWithSet:card.set andUserChatRoom:chatRoom];
    chatt.room = self.room;

    NSString *title;

    [chatt setTitle:title];
//
//    CATransition* transition = [CATransition animation];
//    transition.duration = 0.3;
//    transition.type = kCATransitionPush;
//    transition.subtype = kCATransitionFromRight;
//    transition.timingFunction = UIViewAnimationCurveEaseInOut;
//    transition.fillMode = kCAFillModeForwards;
//    [self.navigationController.view.layer addAnimation:transition forKey:kCATransition];
//    
    
//    if (card.photosArray.count)
//    {
        NSLog(@"Going to CustomChatView because there are pictures");
//        CustomChatView *chatt = [[CustomChatView alloc] initWithSetId:card.set andColor:[UIColor volleyFamousGreen] andPictures:card.photosArray andComments:card.messagesArray andActualSet:card.actualSet];
        //    chatt.senderId = [self.senderId copy];
        //    chatt.senderDisplayName = [self.senderDisplayName copy];
        //    CustomChatView *chatt = [[CustomChatView alloc] initWithSet:card.set andUserChatRoom:chatRoom];
        chatt.room = self.room;
        [self.navigationController pushViewController:chatt animated:1];
//    }
//    else
//    {
//        NSLog(@"Going to a chatroom with no pictures");
//        FullWidthChatView *chatt = [[FullWidthChatView alloc] initWithSetId:card.set andColor:[UIColor volleyFamousGreen] andPictures:card.photosArray andComments:card.messagesArray andActualSet:card.actualSet];
//        chatt.room = self.room;
//        [self.navigationController pushViewController:chatt animated:1];
//    }
}
-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
//    return self.vollieCardDataArray.count;

    if (self.shouldShowTempCard == NO)
    {
        return self.vollieCardDataArray.count * 2 - 1;
    }
    else
    {
//        return 1;
        return  self.vollieCardDataArray.count * 2;
    }
//    return self.sortedCardsArray.count * 2 - 1;
//     return [[self.cards valueForKeyPath:@"cards"] count] * 2 - 1
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.item % 2 == 1)
    {
        return 15;
        //this is the spacerCell
    }
    else
    {
        return 280;
    }
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.row % 2 == 1)
    {
        UITableViewCell * spacerCell = [tableView dequeueReusableCellWithIdentifier:@"fakeCellID"];

        if (spacerCell == nil)
        {
            //this is our spacer cell
            spacerCell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault
                                           reuseIdentifier:@"fakeCellID"];
            spacerCell.backgroundColor = [UIColor clearColor];
            [spacerCell.contentView setAlpha:0];
            [spacerCell setUserInteractionEnabled:NO];
        }
        return spacerCell;
    }
    if (indexPath.row == self.vollieCardDataArray.count * 2)
    {
        //this is going to be for temp card
        UITableViewCell * spacerCell = [tableView dequeueReusableCellWithIdentifier:@"fakeCellID"];
        if (spacerCell == nil)
        {
            //this is our spacer cell
            spacerCell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault
                                                reuseIdentifier:@"fakeCellID"];
            spacerCell.backgroundColor = [UIColor blueColor];
//            [spacerCell.contentView setAlpha:1];
            [spacerCell setUserInteractionEnabled:NO];
        }
        return spacerCell;
    }
    else
    {
        VollieCardData *card = [self.vollieCardDataArray objectAtIndex:(indexPath.row/2)];
//        VollieCardData *card = [self.sortedCardsArray objectAtIndex:(indexPath.row/2)];
        CardCellView *vc = card.viewController;
        vc.room = self.room;
        vc.view.backgroundColor = [UIColor whiteColor];
        [self.vollieVCcardArray addObject:vc];
        [self.tableView registerNib:[UINib nibWithNibName:@"DynamicCardCell" bundle:0] forCellReuseIdentifier:@"DynamicCardCell"];
        DynamicCardCell *cell = [tableView dequeueReusableCellWithIdentifier:@"DynamicCardCell"];
        [cell formatCell];
        [cell fillPicsWithVollieCardData:card];
        [self fillUIView:cell.viewForChatVC withCardVC:card.viewController];
        return cell;
    }
}

-(void)scrollToBottomAndReload
{
//    NSLog(@"scrolled tos the bottom of the cards");
    [self.tableView reloadData];
    NSIndexPath* ip = [NSIndexPath indexPathForRow:[self.tableView numberOfRowsInSection:0] - 1 inSection:0];
    [self.tableView scrollToRowAtIndexPath:ip atScrollPosition:UITableViewScrollPositionTop animated:NO];
}

-(void)scrollToBottom
{
    [self.tableView reloadData];
    [self.tableView scrollRectToVisible:CGRectMake(0, self.tableView.contentSize.height - self.tableView.bounds.size.height, self.tableView.bounds.size.width, self.tableView.bounds.size.height) animated:NO];
}

-(void)fillUIView:(UIView*)view withCardVC:(CardCellView *)vc
{
    vc.view.frame = view.bounds;
    //        cell.viewForChatVC.layer.cornerRadius = 10;
    [self addChildViewController:vc];
    [view addSubview:vc.view];
    [vc didMoveToParentViewController:self];
}

#pragma mark - ParseLoad

-(void)loadMessages
{
    [self createQuery];
}

-(void)reloadCardsAfterUpload
{
    NSLog(@"Sent message to reload cards");
    [self loadMessages];
    [self performSelector:@selector(dismissTopNotification) withObject:self afterDelay:0.8f];
//    [self dismissTopNotification];
//    [self.notification dismissWithGravityAnimation:NO];
}

-(void)createQuery
{
//    JSQMessage *message_last = [self.messages lastObject];
//    PFObject *picture_last = [self.pictureObjects lastObject];

    NSLog(@"Created PFQuery for Cards");
    PFQuery *query = [PFQuery queryWithClassName:PF_CHAT_CLASS_NAME];
    [query whereKey:PF_CHAT_ROOM equalTo:self.room];
    [query includeKey:PF_CHAT_USER];
    [query includeKey:PF_CHAT_SETID];
    [query orderByDescending:@"createdAt"];

    [self getMessagesWithPFQuery:query];
}

-(void)getMessagesWithPFQuery:(PFQuery *)query
{
    NSLog(@"Fetching messages");
    [query findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error)
     {
         if(!error)
         {
             NSLog(@"Organizing messages");
             [self clearPushNotesCounter];
             for (PFObject *object in [objects reverseObjectEnumerator])
             {
                 [self checkForObjectIdWith:object];
             }
         }
         else
         {
             NSLog(@"%@",error);
             [ProgressHUD showError:@"network connection error"];
         }
     }];
}

-(void)clearPushNotesCounter
{
    NSLog(@"checking this room for push notification count: %@ ", self.messageItComesFrom);
    NSNumber *number = [self.messageItComesFrom valueForKey:PF_MESSAGES_COUNTER];
    if (number)
    {
        if ([number intValue] > 0)
        {
            NSLog(@"Clearing Push Notification Count");
            ClearMessageCounter(self.messageItComesFrom);
        }
    }
}

-(void)checkForObjectIdWith:(PFObject *)object
{
    if (![self.objectIdsArray containsObject:object.objectId])
    {
//        NSLog(@"%@", object[@"updatedAction"]);
        NSLog(@"Found an object that wasn't accounted for before");
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
            {   //THIS can be refactored to containsObject...
                if ([card.set isEqualToString:set.objectId])
                {
                    [card modifyCardWith:object];
                    NSSortDescriptor *sortDescriptor = [NSSortDescriptor sortDescriptorWithKey:@"numberFromDateToSortWith" ascending:YES];
                    NSArray *sortedCards = [self.vollieCardDataArray sortedArrayUsingDescriptors:@[sortDescriptor]];
                    self.sortedCardsArray = sortedCards;

                    if (self.sortedCardsArray.count == self.vollieCardDataArray.count)
                    {
                        //test to see if it is the right count after the sort
                    }
                    self.vollieCardDataArray = [NSMutableArray arrayWithArray:self.sortedCardsArray];

//                    [self scrollToBottomAndReload];
                    [self scrollToBottom];
                }
            }
        }
        else
        {
            NSLog(@"Creating Vollie Card");
            VollieCardData *card = [[VollieCardData alloc] initWithPFObject:object andSet:set];
            card.actualSet = set;
            [self.vollieCardDataArray addObject:card];
            [self.setsIDsArray addObject:set.objectId];
            //create vollie card
//            [self scrollToBottomAndReload];
            [self scrollToBottom];
        }
    }
}

-(void)reloadAfterMessageSuccessfullySent
{
    [self loadMessages];
    
    [self performSelector:@selector(dismissTopNotification) withObject:self afterDelay:1];
    NSLog(@"Loading messages and dismissing top notification");
}

-(void)dismissTopNotification
{
    self.nextVollieButton.userInteractionEnabled = YES;
    [self.notification dismissWithGravityAnimation:YES];
    [self loadMessages];
}

-(void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
//newVollieToGroup
    if([[segue identifier] isEqualToString:@"newVollieToGroup"])
    {
//        NSLog(@"New Vollie is going to Room");
    }
    NewVollieVC *vc = [segue destinationViewController];
    vc.whichRoom = self.room;
    vc.whichMessagesRoom = self.messageItComesFrom;
    ParseVolliePackage *package = [ParseVolliePackage new];
    package.refreshDelegate = self;
    vc.package = package;
}

-(void)titleChange:(NSString *)title
{
    NSLog(@"Changed MomentsVC title bar to %@", title);
    self.title = title;
    [self.view setNeedsDisplay];
}

@end
