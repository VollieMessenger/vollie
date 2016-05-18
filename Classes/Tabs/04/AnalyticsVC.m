//
//  AnalyticsVC.m
//  Volley
//
//  Created by Kyle Bendelow on 5/16/16.
//  Copyright © 2016 KZ. All rights reserved.
//

#import "AnalyticsVC.h"
#import <Parse/Parse.h>
#import "UserData.h"

@interface AnalyticsVC () <UITableViewDelegate, UITableViewDataSource>
@property (weak, nonatomic) IBOutlet UILabel *messagesSentLabel;
@property (weak, nonatomic) IBOutlet UILabel *picturesSentLabel;
@property (weak, nonatomic) IBOutlet UILabel *chatRoomsActiveLabel;
@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (weak, nonatomic) IBOutlet UILabel *usersActiveLabel;
@property (weak, nonatomic) IBOutlet UILabel *usersTotalLabel;

//@property NSMutableArray *parseObjectsArray;
@property NSMutableArray *messagesArray;
@property NSMutableArray *picturesArray;
@property NSMutableArray *userArray;
@property NSMutableArray *userIDArray;
@property NSMutableArray *chatRoomArray;
@property NSMutableArray *userNameArray;
@property NSMutableArray *userDataObjectsArray;

@end

@implementation AnalyticsVC

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.tableView.backgroundColor = [UIColor clearColor];
    [self basicSetup];
    [self fetchDataFromParse];
}

-(void)basicSetup
{
    self.messagesArray = [NSMutableArray new];
    self.picturesArray = [NSMutableArray new];
    self.userArray = [NSMutableArray new];
    self.userIDArray = [NSMutableArray new];
    self.chatRoomArray = [NSMutableArray new];
    self.userNameArray = [NSMutableArray new];
    self.userDataObjectsArray = [NSMutableArray new];
}

-(void)fetchDataFromParse
{
    PFQuery *query = [PFQuery queryWithClassName:@"Chat"];
//    query where
    [query orderByDescending:@"createdAt"];
    [query findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error)
    {
        NSLog(@"%li items found", objects.count);
        for (PFObject *object in objects)
        {
            [self checkToSeeIfObjectIsWithin24HoursWith:object];
        }
        self.messagesSentLabel.text = [NSString stringWithFormat:@"%li Messages Sent", self.messagesArray.count];
        self.picturesSentLabel.text = [NSString stringWithFormat:@"%li Pictures Sent", self.picturesArray.count];
        self.chatRoomsActiveLabel.text = [NSString stringWithFormat:@"%li Chatrooms Active", self.chatRoomArray.count];
        self.usersActiveLabel.text = [NSString stringWithFormat:@"%li Users Active", self.userArray.count];
        [self beginUserDownloads];
    }];
    
    PFQuery *userQuery = [PFUser query];
    [userQuery findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error)
    {
        NSLog(@"%li users", objects.count);
        self.usersTotalLabel.text = [NSString stringWithFormat:@"Users Total: %li", objects.count];
//        self.usersTotalLabel.text = @"EKLSF";
    }];
}

-(void)checkToSeeIfObjectIsWithin24HoursWith:(PFObject *)object
{
    NSDate *now = [NSDate date];
    NSDate *date = object.createdAt;
    double deltaSeconds = fabs([date timeIntervalSinceDate:now]);
    double minutes = deltaSeconds / 60;
    double hours = minutes / 60;
    double days = hours / 24;
    if (days < 1)
    {
//        [self.messagesArray addObject:object];
        [self checkToSeeIfPictureOrMessageWith:object];
        [self checkToSeeIfNewChatroomWithParseObject:object];
        [self checkToSeeIfNewUserWithParseObject:object];
    }
}

-(void)checkToSeeIfPictureOrMessageWith:(PFObject *)object
{
    if ([object objectForKey:@"isUploaded"])
    {
        [self.picturesArray addObject:object];
    }
    else
    {
        [self.messagesArray addObject:object];
    }
}

-(void)checkToSeeIfNewChatroomWithParseObject:(PFObject*)object
{
    PFObject *chatRoom = [object objectForKey:@"room"];
    if (![self.chatRoomArray containsObject:chatRoom.objectId])
    {
        [self.chatRoomArray addObject:chatRoom.objectId];
    }
}

-(void)checkToSeeIfNewUserWithParseObject:(PFObject*)object
{
    PFUser *user = [object objectForKey:@"user"];
    NSString *userID = user.objectId;
    if (![self.userIDArray containsObject:userID])
    {
        [self.userIDArray addObject:userID];
        [self.userArray addObject:user];
        UserData *userDataObject = [[UserData alloc] initWithPFObject:object];
        [self.userDataObjectsArray addObject:userDataObject];
    }
    else
    {
        for (UserData *userObject in self.userDataObjectsArray)
        {
            if ([userObject.userID isEqualToString:userID])
            {
                [userObject modifyCardWith:object];
            }
        }
    }
}

-(void)beginUserDownloads
{
    int numberOfUsersToDownload = (int)self.userArray.count;
    for (UserData *userData in self.userDataObjectsArray)
    {
        PFUser *user = userData.user;
        [user fetchInBackgroundWithBlock:^(PFObject *object, NSError *error) {
            [self.userNameArray addObject:[user objectForKey:@"fullname"]];
            userData.userName = [user objectForKey:@"fullname"];
            if (self.userNameArray.count == numberOfUsersToDownload)
            {
//                [self.tableView reloadData];
                [self reorganizeUsersAndReloadData];
            }
        }];
    }
}

-(void)reorganizeUsersAndReloadData
{
    NSSortDescriptor *sortDescriptor = [NSSortDescriptor sortDescriptorWithKey:@"numberOfMessages" ascending:YES];
    NSArray *organizedArray = [self.userDataObjectsArray sortedArrayUsingDescriptors:@[sortDescriptor]];
    
    
    self.userDataObjectsArray = [NSMutableArray arrayWithArray:organizedArray];
    [self.tableView reloadData];
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [UITableViewCell new];
    cell.backgroundColor = [UIColor clearColor];
    if (self.userNameArray.count)
    {
        UserData *data = self.userDataObjectsArray[indexPath.row];
//        NSString *userName = self.userNameArray[indexPath.row];
        NSString *stringToShow = [NSString stringWithFormat:@"%@: %li", data.userName, data.messagesArray.count];
        cell.textLabel.text = stringToShow;
    }
//    NSString *userName = self.userNameArray[indexPath.row];
//    cell.textLabel.text = @"test";
    return cell;
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.userNameArray.count;
}

@end
