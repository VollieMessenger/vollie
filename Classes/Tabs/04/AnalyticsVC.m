//
//  AnalyticsVC.m
//  Volley
//
//  Created by Kyle Bendelow on 5/16/16.
//  Copyright © 2016 KZ. All rights reserved.
//

#import "AnalyticsVC.h"
#import <Parse/Parse.h>

@interface AnalyticsVC () <UITableViewDelegate, UITableViewDataSource>
@property (weak, nonatomic) IBOutlet UILabel *messagesSentLabel;
@property (weak, nonatomic) IBOutlet UILabel *chatRoomsActiveLabel;
@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (weak, nonatomic) IBOutlet UILabel *usersActiveLabel;

@property NSMutableArray *messagesArray;
@property NSMutableArray *userArray;
@property NSMutableArray *userIDArray;
@property NSMutableArray *chatRoomArray;
@property NSMutableArray *userNameArray;

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
    self.userArray = [NSMutableArray new];
    self.userIDArray = [NSMutableArray new];
    self.chatRoomArray = [NSMutableArray new];
    self.userNameArray = [NSMutableArray new];
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
        self.chatRoomsActiveLabel.text = [NSString stringWithFormat:@"%li Chatrooms Active", self.chatRoomArray.count];
        self.usersActiveLabel.text = [NSString stringWithFormat:@"%li Users Active", self.userArray.count];
        [self beginUserDownloads];
        
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
        [self checkToSeeIfNewChatroomWithParseObject:object];
        [self checkToSeeIfNewUserWithParseObject:object];
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
        NSLog(@"%@", user);
    }
}

-(void)beginUserDownloads
{
    int numberOfUsersToDownload = (int)self.userArray.count;
    __block int numberOfUsersDownloaded = 0; //  x lives in block storage
    for (PFUser *user in self.userArray)
    {
        [user fetchInBackgroundWithBlock:^(PFObject *object, NSError *error) {
            NSLog(@"%@", user);
            [self.userNameArray addObject:[user objectForKey:@"fullname"]];
            if (self.userNameArray.count == numberOfUsersToDownload)
            {
                [self.tableView reloadData];
            }
        }];
    }
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [UITableViewCell new];
    cell.backgroundColor = [UIColor clearColor];
    if (self.userNameArray.count)
    {
        NSString *userName = self.userNameArray[indexPath.row];
        cell.textLabel.text = userName;
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
