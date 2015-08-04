//
//  MainInboxVC.m
//  Volley
//
//  Created by Kyle Bendelow on 8/4/15.
//  Copyright (c) 2015 KZ. All rights reserved.
//

#import "MainInboxVC.h"
#import "AppConstant.h"
#import <Parse/Parse.h>
#import "messages.h"
#import "NSDate+TimeAgo.h"
#import "ProgressHUD.h"
#import "RoomCell.h"

@interface MainInboxVC () <UITableViewDelegate, UITableViewDataSource>

@property (weak, nonatomic) IBOutlet UITableView *tableView;

@property  UIRefreshControl *refreshControl;

@property NSMutableArray *messagesObjectIds;
@property NSMutableArray *savedDates;
@property NSMutableDictionary *savedMessagesForDate;








@property BOOL isCurrentlyLoadingMessages;

@end

@implementation MainInboxVC

- (void)viewDidLoad
{
    [super viewDidLoad];
    [self setUpUserInterface];
    [self loadInbox];
}

#pragma mark "User Interface and Interaction"

-(void)basicSetUpOfProperties
{
    self.isCurrentlyLoadingMessages = false;
}

-(void)setUpUserInterface
{
    UIImageView *imageViewVolley = [[UIImageView alloc] init];
    imageViewVolley.image = [UIImage imageNamed:@"volley"];

    self.navigationItem.titleView = imageViewVolley;
    self.navigationItem.titleView.alpha = 1;
    //    self.navigationItem.titleView.frame = CGRectMake(0, 0, self.view.frame.size.width, (53 - ([number intValue] * [number intValue])));
    self.navigationItem.titleView.frame = CGRectMake(0, 0, 250, 44);
    self.title = @"";
    self.view.backgroundColor = [UIColor whiteColor];
    UIBarButtonItem *favoritesButton = [[UIBarButtonItem alloc] initWithTitle:@"Fav"
                                                             style:UIBarButtonItemStyleBordered target:self action:@selector(swipeRightToFavorites:)];
    favoritesButton.image = [UIImage imageNamed:ASSETS_STAR_ON];
    self.navigationItem.rightBarButtonItem = favoritesButton;
    UIBarButtonItem *cameraButton =[[UIBarButtonItem alloc] initWithTitle:@"Cam" style:UIBarButtonItemStyleBordered target:self action:@selector(swipeLeftToCamera:)];
    cameraButton.image = [UIImage imageNamed:ASSETS_NEW_CAMERA];
    self.navigationItem.leftBarButtonItem = cameraButton;
}

-(void) swipeRightToFavorites:(UIBarButtonItem *)button
{
    [self.scrollView setContentOffset:CGPointMake(self.view.frame.size.width * 2, 0) animated:1];
}

- (void)swipeLeftToCamera:(UIBarButtonItem *)button
{
    [self.scrollView setContentOffset:CGPointMake(0, 0) animated:YES];
}

#pragma mark "Parse Stuff"

-(void)loadInbox
{
    if ([PFUser currentUser] && self.isCurrentlyLoadingMessages == NO)
    {
        self.isCurrentlyLoadingMessages = YES;
        
        //should change this to RoomObject.h
        PFQuery *query = [PFQuery queryWithClassName:PF_MESSAGES_CLASS_NAME];
        [query whereKey:PF_MESSAGES_USER equalTo:[PFUser currentUser]];
        //      [query includeKey:PF_MESSAGES_LASTUSER];
        [query includeKey:PF_MESSAGES_ROOM];
        [query includeKey:PF_MESSAGES_USER];
        [query includeKey:PF_MESSAGES_LASTPICTURE];
        [query includeKey:PF_MESSAGES_LASTPICTUREUSER];
        [query whereKey:PF_MESSAGES_HIDE_UNTIL_NEXT equalTo:@NO];
        [query orderByDescending:PF_MESSAGES_UPDATEDACTION];
        [query setCachePolicy:kPFCachePolicyCacheThenNetwork];
        [query findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error)
         {
             if (!error)
             {
                 [self clearMessageArrays];
                 for (PFObject *message in objects)
                 {
                     if (![self.messagesObjectIds containsObject:message.objectId])
                     {
                         if ([[message valueForKey:PF_MESSAGES_LASTMESSAGE] isEqualToString:@""] && ![message valueForKey:PF_MESSAGES_LASTPICTURE])
                         {
                             //this hides messages that have neither a message or picture yet
                             //i'd like to make this cleaner and actually delete it off of parse, but this works for now
                         }
                         else
                         {
                             [self.messages addObject:message];
                             NSDate *date = [message valueForKey:PF_MESSAGES_UPDATEDACTION];
                             date = [self dateAtBeginningOfDayForDate:date];

                             if (![self.savedDates containsObject:date])
                             {
                                 [self.savedDates addObject:date];
                                 NSMutableArray *array = [NSMutableArray arrayWithObject:message];
                                 NSDictionary *dict = [NSDictionary dictionaryWithObject:array forKey:date];
                                 [self.savedMessagesForDate addEntriesFromDictionary:dict];
                             }
                             else
                             {
                                 [(NSMutableArray *)[self.savedMessagesForDate objectForKey:date] addObject:message];
                             }
                         }
                     }
                 }
                 [self.tableView reloadData];
                 self.isCurrentlyLoadingMessages = NO;
//                 [self updateEmptyView];
                 //do we need that^^
             }
             else
             {
                 if ([query hasCachedResult])
                 {
                     if (self.navigationController.visibleViewController == self)
                     {
//                         [self.refreshControl endRefreshing];
                         [ProgressHUD showError:@"Network error."];
                     }
                 }
             }
//             [_refreshControl endRefreshing];
         }];
        
    }
}

- (void)clearMessageArrays
{
    //let's see if we really need this
    self.messages = [NSMutableArray new];
    self.savedDates = [NSMutableArray new];
    self.savedMessagesForDate = [NSMutableDictionary new];
    self.messagesObjectIds = [NSMutableArray new];
//    colorsForRoom = [NSMutableDictionary new];
//    arrayOfAvailableColors = [NSMutableArray arrayWithArray: [AppConstant arrayOfColors]];
}



#pragma mark "TableView Stuff"

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    RoomCell *cell = [tableView dequeueReusableCellWithIdentifier:@"cellID" forIndexPath:indexPath];
//    if(!cell)
//    {
//        cell = [[MessagesCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"cellID"];
//   
//    }
//    [cell format];
//    cell.textLabel.text = @"test";
    
    PFObject *message = self.messages[indexPath.row];
    
    
    return cell;
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.messages.count;
}


#pragma mark "Crazy Other Methods"

- (NSDate *)dateAtBeginningOfDayForDate:(NSDate *)inputDate
{
    //Convert to my time zone
    NSTimeZone *tz = [NSTimeZone defaultTimeZone];
    NSInteger seconds = [tz secondsFromGMTForDate:inputDate];
    NSDate *date = [NSDate dateWithTimeInterval: seconds sinceDate:inputDate];
    // Use the user's current calendar and time zone
    NSCalendar *calendar = [NSCalendar currentCalendar];
    NSTimeZone *timeZone = [NSTimeZone systemTimeZone];
    [calendar setTimeZone:timeZone];
    
    // Selectively convert the date components (year, month, day) of the input date
    NSDateComponents *dateComps = [calendar components:NSYearCalendarUnit | NSMonthCalendarUnit | NSDayCalendarUnit fromDate:date];
    
    // Set the time components manually
    [dateComps setHour:0];
    [dateComps setMinute:0];
    [dateComps setSecond:0];
    // Convert back
    NSDate *beginningOfDay = [calendar dateFromComponents:dateComps];
    return beginningOfDay;
}


@end
