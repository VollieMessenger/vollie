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
@property BOOL shouldShowLoadMoreButton;

@property int isLoadingEarlierCount;

@property LoadMoreCell *masterLoadMoreCell;

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
//    self.shou
    
    
    //new loading stuff:
    self.kyleSetsArray = [NSMutableArray new];
    self.kyleCardsArray = [NSMutableArray new];
    self.kyleChatArray = [NSArray new];
    self.numberToSearchThrough = 0;
    self.helperTool = [CardsViewHelper new];
    self.sortedCardsArray = [NSMutableArray new];
    self.finishedCardsArray = [NSMutableArray new];
    self.shouldShowLoadMoreButton = NO;

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
//    self.navigationItem.rightBarButtonItem = nil;
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
    
    if (self.shouldShowLoadMoreButton)
    {
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
            
//            NSString *title;
            
            [chatt setTitle:self.name];
            chatt.room = self.room;
            [self.navigationController pushViewController:chatt animated:1];
        }
        else
        {
////            LoadMoreCell *cell = 
//            cell.titleLabel.hidden = YES;
//            cell.spinner.hidden = NO;
//            [cell.spinner startAnimating];
            self.masterLoadMoreCell.titleLabel.hidden = YES;
            self.masterLoadMoreCell.spinner.hidden = NO;
            [self.masterLoadMoreCell.spinner startAnimating];
            [self getDataForSetOfCards];
        }
    }
    else
    {
        CardObject *card = self.finishedCardsArray[indexPath.row];
        
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
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if (self.finishedCardsArray.count)
    {
//        return 7;
        if(self.shouldShowLoadMoreButton)
        {
            return self.finishedCardsArray.count + 1;
        }
        else
        {
            return self.finishedCardsArray.count;
        }
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
    if (self.shouldShowLoadMoreButton)
    {
        if (indexPath.row == 0)
        {
            return 75;
        }
        else
        {
            return 325;
        }
    }
    else
    {
        return 325;
    }
    
    
//    if (indexPath.row != 0)
//    {
//        return 325;
//    }
//    else
//    {
//        return 80;
//    }
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    
//    CardObject *card = [CardObject new];
    if (self.shouldShowLoadMoreButton)
    {
        if (indexPath.row == 0)
        {
            [self.tableView registerNib:[UINib nibWithNibName:@"LoadMoreCell" bundle:0] forCellReuseIdentifier:@"LoadMoreCell"];
            LoadMoreCell *cell = [tableView dequeueReusableCellWithIdentifier:@"LoadMoreCell"];
            self.masterLoadMoreCell = cell;
            return cell;
        }
        else
        {
            CardObject *card = [self.finishedCardsArray objectAtIndex:indexPath.row - 1];
            CardCellView *vc = card.chatVC;
            vc.room = self.room;
            vc.view.backgroundColor = [UIColor whiteColor];
            [self.vollieVCcardArray addObject:vc];
            [self.tableView registerNib:[UINib nibWithNibName:@"DynamicCardCell" bundle:0] forCellReuseIdentifier:@"DynamicCardCell"];
            DynamicCardCell *cell = [tableView dequeueReusableCellWithIdentifier:@"DynamicCardCell"];
            //        [cell formatCell];
            [cell formatCellWithCardObject:card];
            //        [cell fillPicsWithVollieCardData:card];
            [self fillUIView:cell.viewForChatVC withCardVC:card.chatVC];
            return cell;        }
    }
    else
    {
        CardObject *card = [self.finishedCardsArray objectAtIndex:indexPath.row];
//        card = [self.finishedCardsArray objectAtIndex:indexPath.row];
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
//        CGFloat oldTableViewOffset = self.tableView.contentOffset.y;
//        How : float verticalContentOffset  = tableView.contentOffset.y;
        NSLog(@"%@ is content size", NSStringFromCGSize(self.tableView.contentSize));
        
        CGFloat whereToScrollTo = self.tableView.contentSize.height;
        
        //2275

        NSLog(@"Trying not to scroll to bottom");
        [self.tableView reloadData];
        CGFloat newHeight = self.tableView.contentSize.height;
        
        // Put your scroll position to where it was before
//        CGFloat newTableViewHeight = self.tableView.contentSize.height;
        self.tableView.contentOffset = CGPointMake(0, (newHeight-whereToScrollTo));
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
//            self.finishedCardsArray = [NSMutableArray new];
            self.numberToSearchThrough = 0;
            [self createCards];
        }
    }];
}

-(void)createCards
{
    self.setsIDsArray = [NSMutableArray new];
    self.kyleCardsArray = [NSMutableArray new];
    self.kyleSetsArray = [NSMutableArray new];
    self.sortedCardsArray = [NSMutableArray new];
    self.finishedCardsArray = [NSMutableArray new];
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

-(void)stopAnimationOfTopCell
{
    self.masterLoadMoreCell.titleLabel.hidden = NO;
    self.masterLoadMoreCell.spinner.hidden = YES;
//    self.masterLoadMoreCell 
}

-(void)getDataForSetOfCards
{
    [self sortCards];
//    int numberOfCardsWithPicsLoaded = 0;
    int numberOfCardsToLoad;
    __block int numberOfCardsWithPicsLoaded = 0; //  x lives in block storage
    
    if (self.numberToSearchThrough == 0)
    {
        NSLog(@"initial load of cards");
        self.shouldScrollDown = YES;
    }
    else
    {
        self.shouldScrollDown = NO;
        NSLog(@"not initial load of cardS");
    }
    
    if (self.kyleCardsArray.count >= 7)
    {
        if (self.kyleCardsArray.count - self.numberToSearchThrough > 6)
        {
            numberOfCardsToLoad = 7;
            NSLog(@"loading %i cards", numberOfCardsToLoad);
            if (self.kyleCardsArray.count - self.numberToSearchThrough == 7)
            {
                self.shouldShowLoadMoreButton = NO;
            }
            else
            {
                self.shouldShowLoadMoreButton = YES;                
            }
        }
        else
        {
            numberOfCardsToLoad = (int)self.kyleCardsArray.count - self.numberToSearchThrough;
            NSLog(@"loading remaining %i cards", numberOfCardsToLoad);
            self.shouldShowLoadMoreButton = NO;
            
        }
    }
    else
    {
        if (self.numberToSearchThrough != self.kyleCardsArray.count)
        {
            numberOfCardsToLoad = (int)self.kyleCardsArray.count;
            NSLog(@"only had %lu cards", self.kyleCardsArray.count);
            self.shouldShowLoadMoreButton = NO;
        }
        else
        {
            numberOfCardsToLoad = 0;
            [self scrollToBottom];
        }
    }
    
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
                    [self stopAnimationOfTopCell];
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
                    [self stopAnimationOfTopCell];
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
//    [self loadMessages];
    [self newParseLoad];
    [self performSelector:@selector(dismissTopNotification) withObject:self afterDelay:0.8f];
//    [self dismissTopNotification];
//    [self.notification dismissWithGravityAnimation:NO];
}
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
