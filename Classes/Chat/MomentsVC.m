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
#import "ParseVolliePackage.h"
#import "AFDropdownNotification.h"
#import "FullWidthChatView.h"
#import "FullWidthCell.h"
#import "DynamicCardCell.h"
#import "CardObject.h"
#import "CardsViewHelper.h"
#import "LoadMoreCell.h"

//for testing the fav cells
#import "FivePicsFavCell.h"

@interface MomentsVC () <UITableViewDataSource, UITableViewDelegate, RefreshMessagesDelegate, ManageChatDelegate, AFDropdownNotificationDelegate>
@property (strong, nonatomic) IBOutlet UITableView *tableView;

@property (strong, nonatomic) IBOutlet UIImageView *vollieIconImageView;

@property (weak, nonatomic) IBOutlet UIButton *nextVollieButton;

@property BOOL isLoading;
@property BOOL shouldScrollDown;

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

@property NSMutableArray *kyleSetsArray;
@property NSMutableArray *kyleCardsArray;
@property NSArray *kyleChatArray;
@property int numberToSearchThrough;
@property CardsViewHelper *helperTool;
@property NSMutableArray *finishedCardsArray;

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
    self.shouldScrollDown = YES;
    
    
    //new loading stuff:
    self.kyleSetsArray = [NSMutableArray new];
    self.kyleCardsArray = [NSMutableArray new];
    self.kyleChatArray = [NSArray new];
    self.numberToSearchThrough = 0;
    self.helperTool = [CardsViewHelper new];
    self.sortedCardsArray = [NSMutableArray new];
    self.finishedCardsArray = [NSMutableArray new];

//    [self loadMessages];
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
//    [self loadMessages];
    [self newParseLoad];
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
//    VollieCardData *card = self.vollieCardDataArray[(indexPath.row/2)];
    
    if (indexPath.row != 0)
    {
        CardObject *card = self.finishedCardsArray[indexPath.row - 1];
        
        //    [card.viewController clearUnreadDot];
        card.unreadStatus = false;
        DynamicCardCell *cell = [tableView cellForRowAtIndexPath:indexPath];
        cell.unreadMessagesLabel.hidden = YES;
        
        NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
        [formatter setDateFormat:@"YYYY-MM-dd HH:mm"];
        
        //    CustomChatView *deepChatView = [[CustomChatView alloc] initWithSet:card.set andUserChatRoom:self.room withOrangeBubbles:NO];
        
        CustomChatView *chatt = [[CustomChatView alloc] initWithSetId:card.setID andColor:[UIColor volleyFamousGreen] andPictures:card.photosArray andComments:card.messagesArray andActualSet:card.set];
        //    chatt.room = self.room;
        
        chatt.titleLabel.text = card.title;
        
        NSString *title;
        
        [chatt setTitle:title];
        chatt.room = self.room;
        [self.navigationController pushViewController:chatt animated:1];
    }
    else
    {
        [self getDataForSetOfCards];
    }
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
//    if (self.shouldShowTempCard == NO)
//    {
//        return self.vollieCardDataArray.count * 2 - 1;
//    }
//    else
//    {
////        return 1;
//        return  self.vollieCardDataArray.count * 2;
//    }
    if (self.finishedCardsArray.count)
    {
//        return 7;
        return self.finishedCardsArray.count + 1;
    }
    else
    {
        return 0;
    }
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
//    if (indexPath.item % 2 == 1)
//    {
//        return 0;
//        //this is the spacerCell
//    }
//    else
//    {
//        return 325;
//    }
    if (indexPath.row != 0)
    {
        return 325;
    }
    else
    {
        return 80;
    }
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.row != 0)
    {
        CardObject *card = [self.finishedCardsArray objectAtIndex:indexPath.row - 1];
        CardCellView *vc = card.chatVC;
        //        VollieCardData *card = [self.sortedCardsArray objectAtIndex:(indexPath.row/2)];
        //        CardCellView *vc = card.viewController;
        vc.room = self.room;
        vc.view.backgroundColor = [UIColor whiteColor];
        [self.vollieVCcardArray addObject:vc];
        [self.tableView registerNib:[UINib nibWithNibName:@"DynamicCardCell" bundle:0] forCellReuseIdentifier:@"DynamicCardCell"];
        DynamicCardCell *cell = [tableView dequeueReusableCellWithIdentifier:@"DynamicCardCell"];
        //        [cell formatCell];
        [cell formatCellWithCardObject:card];
        //        [cell fillPicsWithVollieCardData:card];
        [self fillUIView:cell.viewForChatVC withCardVC:card.chatVC];
        return cell;
    }
    else
    {
        [self.tableView registerNib:[UINib nibWithNibName:@"LoadMoreCell" bundle:0] forCellReuseIdentifier:@"LoadMoreCell"];
        LoadMoreCell *cell = [tableView dequeueReusableCellWithIdentifier:@"LoadMoreCell"];
        return cell;
    }
}



-(void)scrollToBottom
{
    [ProgressHUD dismiss];
    if (self.shouldScrollDown)
    {
        NSLog(@"Scrolling to the bottom");
        [self.tableView reloadData];
         [self.tableView scrollRectToVisible:CGRectMake(0, self.tableView.contentSize.height - self.tableView.bounds.size.height, self.tableView.bounds.size.width, self.tableView.bounds.size.height) animated:NO];
    }
    else
    {
        CGFloat oldTableViewOffset = self.tableView.contentOffset.y;
//        How : float verticalContentOffset  = tableView.contentOffset.y;
        

        NSLog(@"Trying not to scroll to bottom");
        [self.tableView reloadData];
        // Put your scroll position to where it was before
//        CGFloat newTableViewHeight = self.tableView.contentSize.height;
        self.tableView.contentOffset = CGPointMake(0, oldTableViewOffset);
        self.shouldScrollDown = YES;
    }
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

-(void)newParseLoad
{
    [CardObject retrieveResultsWithSearchTerm:self.room withCompletion:^(NSArray *results)
    {
        [self clearPushNotesCounter];
        NSLog(@"%lu is the number of found chat objects!", results.count);
//        NSLog(@"%@ is the first result!", results.firstObject);
        if (results.count != self.kyleChatArray.count)
        {
//            self.kyleCardsArray = [NSMutableArray new];
            self.kyleChatArray = results;
            [self createCards];
        }
    }];
}

-(void)createCards
{
    self.setsIDsArray = [NSMutableArray new];
    self.kyleCardsArray = [NSMutableArray new];
    self.kyleSetsArray = [NSMutableArray new];
    [ProgressHUD show:@"Loading" Interaction:NO];
    for (PFObject* chatObject in self.kyleChatArray)
    {
        [self NEWERcheckForVollieCardWith:chatObject];
    }
    NSLog(@"%lu cards", self.kyleCardsArray.count);
    [self getDataForSetOfCards];
}

-(void)NEWERcheckForVollieCardWith:(PFObject*)chatObject
{
    PFObject *set = [chatObject objectForKey:@"setId"];
    if (![self.setsIDsArray containsObject:set.objectId])
    {
        CardObject *card = [[CardObject alloc] initWithChatObject:chatObject];
        [self.kyleCardsArray addObject:card];
        [self.setsIDsArray addObject:set.objectId];
    }
    else
    {
        for (CardObject *card in self.kyleCardsArray)
        {
            if ([card.setID isEqualToString:set.objectId])
            {
                [card modifyCardWith:chatObject];
            }
        }
    }
}

//-(void)reverseArrayWith:(NSMutableArray*)array
//{
//    NSArray *reversedArray = [[array reverseObjectEnumerator] allObjects];
//    self.finishedCardsArray = [NSMutableArray arrayWithArray:reversedArray];
//}

-(void)sortFinishedCards
{
    NSSortDescriptor *sortDescriptor = [NSSortDescriptor sortDescriptorWithKey:@"numberFromDateToSortWith" ascending:YES];
    NSArray *sortedCards = [self.finishedCardsArray sortedArrayUsingDescriptors:@[sortDescriptor]];
    self.finishedCardsArray = [NSMutableArray arrayWithArray:sortedCards];
}

-(void)sortCards
{
    NSSortDescriptor *sortDescriptor = [NSSortDescriptor sortDescriptorWithKey:@"numberFromDateToSortWith" ascending:YES];
    NSArray *sortedCards = [self.kyleCardsArray sortedArrayUsingDescriptors:@[sortDescriptor]];
    self.sortedCardsArray = sortedCards;
    NSArray* reversedArray = [[sortedCards reverseObjectEnumerator] allObjects];
    self.sortedCardsArray = reversedArray;

//    self.sortedCardsArray = [self.sortedCardsArray reverseObjectEnumerator];
//    [self.sortedCardsArray reverseObjectEnumerator];
}

-(void)getDataForSetOfCards
{
    [self sortCards];
//    int numberOfCardsWithPicsLoaded = 0;
    int numberOfCardsToLoad;
    __block int numberOfCardsWithPicsLoaded = 0; //  x lives in block storage
    
    if (self.kyleCardsArray.count >= 7)
    {
        if (self.kyleCardsArray.count - self.numberToSearchThrough > 6)
        {
            numberOfCardsToLoad = 7;
//            NSLog(@"set number of cards to load as 7");
        }
        else
        {
            numberOfCardsToLoad = (int)self.kyleCardsArray.count - self.numberToSearchThrough;
//            NSLog(@"set number of cards to load as %i", numberOfCardsToLoad);
            
        }
    }
    else
    {
        if (self.numberToSearchThrough != self.kyleCardsArray.count)
        {
            numberOfCardsToLoad = (int)self.kyleCardsArray.count;
        }
        else
        {
            numberOfCardsToLoad = 0;
            [self scrollToBottom];
        }
    }
    
    NSLog(@"%i cards going to load", numberOfCardsToLoad);
//    if (numberOfCardsToLoad == self.numberToSearchThrough)
//    {
//        //this means it's loading from ViewDidAppear after adding content to an additional card
//        NSLog(@"TEST TEST TEST");
//        [self scrollToBottom];
//    }
    
    __block int numberOfCardsWithMessagesStatusLoaded = 0;
    for (int i = 0; i < numberOfCardsToLoad; i++)
    {
        CardObject *card = self.sortedCardsArray[self.numberToSearchThrough];
        [card createVCForCard];
        [card checkForUnreadUsers:^(BOOL finished)
        {
            if (finished)
            {
                numberOfCardsWithMessagesStatusLoaded++;
//                NSLog(@"finished checking for unread users for card %i", i);
                if(numberOfCardsWithPicsLoaded == numberOfCardsToLoad && numberOfCardsWithMessagesStatusLoaded == numberOfCardsToLoad)
                {
//                    NSLog(@"YOU CAN RETURN NOW");
                    [self scrollToBottom];
//                    [self.tableView]
                }
            }
        }];
//        NSLog(@"Getting data for %@",card.title);
        
//        [self.helperTool getPicsWith:card];
        [card getPicsForCardwithPics:^(BOOL pics)
        {
            if (pics)
            {
//                NSLog(@"downloaded pics finished for card %i", i);
                numberOfCardsWithPicsLoaded++;
//                NSLog(@"x is %i", x);
                if(numberOfCardsWithPicsLoaded == numberOfCardsToLoad && numberOfCardsWithMessagesStatusLoaded == numberOfCardsToLoad)
                {
//                    NSLog(@"YOU CAN RETURN NOW");
                    [self scrollToBottom];
                }
            }
        }];
        [self.finishedCardsArray addObject:card];
        [self sortFinishedCards];
        self.numberToSearchThrough ++;
    }
}

-(void)loadMessages
{
//    [self createQuery];
    [self newParseLoad];
}

-(void)reloadCardsAfterUpload
{
    NSLog(@"Sent message to reload cards");
    [self loadMessages];
    [self performSelector:@selector(dismissTopNotification) withObject:self afterDelay:0.8f];
//    [self dismissTopNotification];
//    [self.notification dismissWithGravityAnimation:NO];
}

//-(void)createQuery
//{
////    JSQMessage *message_last = [self.messages lastObject];
////    PFObject *picture_last = [self.pictureObjects lastObject];
//
//    NSLog(@"Created PFQuery for Cards");
//    PFQuery *query = [PFQuery queryWithClassName:PF_CHAT_CLASS_NAME];
//    [query whereKey:PF_CHAT_ROOM equalTo:self.room];
//    [query includeKey:PF_CHAT_USER];
//    [query includeKey:PF_CHAT_SETID];
//    [query setLimit:1000];
//    [query orderByDescending:@"createdAt"];
//
//    [self getMessagesWithPFQuery:query];
//}

//-(void)getMessagesWithPFQuery:(PFQuery *)query
//{
//    NSLog(@"Fetching messages");
//    [query findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error)
//     {
//         if(!error)
//         {
//             NSLog(@"Found %li messages", objects.count);
//             NSLog(@"Organizing messages");
//             [self clearPushNotesCounter];
//             
//             if (self.objectIdsArray.count == objects.count)
//             {
//                 NSLog(@"Searched and found %li messages. Before we had %li messages", self.objectIdsArray.count, objects.count);
////                 self.shouldNotScrollDown = true;
////                 NSLog(@"IT SEARCHED AND BROUGHT UP THE SAME AMOUNT OF MESSAGES");
//                 self.shouldScrollDown = NO;
//             }
//             
////             NSLog(@"%@", [objects.firstObject objectForKey:@"setId"]);
//             
//             self.setsIDsArray = [NSMutableArray new];
//             self.vollieCardDataArray = [NSMutableArray new];
//             self.objectIdsArray = [NSMutableArray new];
//             self.vollieVCcardArray = [NSMutableArray new];
//             self.sortedCardsArray = [NSArray new];
//             
//             for (PFObject *object in [objects reverseObjectEnumerator])
//             {
//                 [self checkForObjectIdWith:object];
//             }
//             [self scrollToBottom];
//         }
//         else
//         {
//             NSLog(@"%@",error);
//             [ProgressHUD showError:@"network connection error"];
//         }
//     }];
//}

-(void)clearPushNotesCounter
{
//    NSLog(@"checking this room for push notification count: %@ ", self.messageItComesFrom);
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

//-(void)checkForObjectIdWith:(PFObject *)object
//{
//    if (![self.objectIdsArray containsObject:object.objectId])
//    {
////        NSLog(@"%@", object[@"updatedAction"]);
////        NSLog(@"Found an object that wasn't accounted for before");
//        [self.objectIdsArray addObject:object.objectId];
//        [self checkForVollieCardWith:object];
//    }
//    else
//    {
////        NSLog(@"this message is already somewhere");
//    }
//}
//
//-(void)checkForVollieCardWith:(PFObject *)object
//{
//    PFObject *set = [object objectForKey:@"setId"];
//    if (set)
//    {
//        if ([self.setsIDsArray containsObject:set.objectId])
//        {
//            //find the correct vollie card
//            for (VollieCardData *card in self.vollieCardDataArray)
//            {   //THIS can be refactored to containsObject...
//                if ([card.set isEqualToString:set.objectId])
//                {
//                    [card modifyCardWith:object];
//                    NSSortDescriptor *sortDescriptor = [NSSortDescriptor sortDescriptorWithKey:@"numberFromDateToSortWith" ascending:YES];
//                    NSArray *sortedCards = [self.vollieCardDataArray sortedArrayUsingDescriptors:@[sortDescriptor]];
//                    self.sortedCardsArray = sortedCards;
//
//                    if (self.sortedCardsArray.count == self.vollieCardDataArray.count)
//                    {
//                        //test to see if it is the right count after the sort
//                    }
//                    self.vollieCardDataArray = [NSMutableArray arrayWithArray:self.sortedCardsArray];
//
////                    [self scrollToBottom];
//                }
//            }
//        }
//        else
//        {
////            NSLog(@"Creating Vollie Card");
//            
//            VollieCardData *card = [[VollieCardData alloc] initWithPFObject:object andSet:set];
//            card.actualSet = set;
//            card.unreadStatus = false;
//            [self.vollieCardDataArray addObject:card];
//            [self.setsIDsArray addObject:set.objectId];
//            
//            //DO THIS SOON:
////            PFRelation *unreadUsers = [set relationForKey:@"unreadUsers"];
////            [unreadUsers.query findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error)
////             {
////                 if (!error)
////                 {
////    //                 self..image = [UIImage imageNamed:@"1readMesseageIcon"];
////                     for (PFUser *user in objects)
////                     {
////                         if ([user.objectId isEqualToString:[PFUser currentUser].objectId])
////                         {
////                             NSLog(@"There is an updated card in this room you haven't read");
////                             card.unreadStatus = true;
//////                             [self.tableView reloadData];
//////                             [self scrollToBottom];
////    //                         self.unreadNotificationDot.image = [UIImage imageNamed:@"1unreadMesseageIcon"];
////                         }
////                         //            NSLog(@"%@", user.objectId);
////                     }
////                 }
////             }];
//            
//            //create vollie card
////            [self scrollToBottom];
//        }
//    }
//}

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
