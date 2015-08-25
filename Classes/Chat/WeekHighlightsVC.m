//
//  WeekHighlightsVC.m
//  Volley
//
//  Created by Kyle Bendelow on 8/6/15.
//  Copyright (c) 2015 KZ. All rights reserved.
//

#import "WeekHighlightsVC.h"
#import "WeekCell.h"
#import "AppConstant.h"
#import "AppDelegate.h"
#import "MainInboxVC.h"
#import "NSDate+TimeAgo.h"

@interface WeekHighlightsVC () <UITableViewDelegate, UITableViewDataSource>
@property (weak, nonatomic) IBOutlet UITableView *tableView;

//@property NSMutableArray *rooms;
@property NSMutableArray *sets;
@property NSMutableArray *weeks;
@property NSMutableArray *hightlightsArray;

@end

@implementation WeekHighlightsVC

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.title = @"Highlights";
//    self.rooms = [NSMutableArray new];
    self.sets = [NSMutableArray new];
    self.weeks = [NSMutableArray new];
}

-(void)viewDidAppear:(BOOL)animated
{
    
}

-(void)basicSetUpOFUI
{
    self.tableView.backgroundColor = [UIColor clearColor];
}


#pragma mark "Parse Methods"

-(void)loadRoomsFromMainInbox
{
    //maybe i should make this public and have it load after loadinbox finishes in maininbox
    NavigationController *navInbox = [(AppDelegate *)[[UIApplication sharedApplication] delegate] navInbox];
    MainInboxVC *inbox = (MainInboxVC*)navInbox.viewControllers.firstObject;
    NSMutableArray *messagesArray = [NSMutableArray new];
    messagesArray = inbox.messages;
    for (PFObject *message in messagesArray)
    {
        //i would like to have this be a regular for loop
        //and do a counter. An alert would come up saying "loading"
        // and when the counter hits zero the tableview reloads and the alert goes away
        PFObject *room = [message objectForKey:@"room"];
        [self loadSetsFrom:room];
    }
}

-(void)loadSetsFrom:(PFObject *)room
{
    PFQuery *query = [PFQuery queryWithClassName:@"Sets"];
    [query whereKey:@"room" equalTo:room];
    [query includeKey:@"lastPicture"];
    [query includeKey:@"createdAt"];
    [query orderByDescending:@"createdAt"];
    [query findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error)
    {
        if(!error)
        {
            for (PFObject *set in objects)
            {
                if ([set objectForKey:@"numberOfResponses"])
                {
                    [self.sets addObject:set];
                    [self createHighlightWithSet:set];
                    // do i organize here?
                }
                //this is where if counter was zero i'd make it hide the alert
            }
//            NSLog(@"%li sets are now in the Highlights View Controller", self.sets.count);
        }
    }];
}

-(void)createHighlightWithSet:(PFObject*)set
{
    NSDate *now = [NSDate date];
    NSDate *setDate = [set valueForKey:@"createdAt"];
    double deltaSeconds = fabs([setDate timeIntervalSinceDate:now]);
    double minutes = deltaSeconds / 60;
    double hours = minutes / 60;
    double days = hours / 24;
    double weeks = days / 7;
    NSLog(@"%fl days since set was created", days);
    int weeksInt = (int)weeks;
    NSLog(@"%i number of weeks", weeksInt);
}

#pragma mark "TableView Stuff"

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    WeekCell *cell = [tableView dequeueReusableCellWithIdentifier:@"cellid"];
    cell.backgroundColor = [UIColor clearColor];
    [cell formatCell];
    
    
    
    
    
    
    
    
    return cell;
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return 3;
}



@end
