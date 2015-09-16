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
#import "HighlightData.h"
#import "AllWeekPhotosVC.h"
#import "ProfileView.h"

@interface WeekHighlightsVC () <UITableViewDelegate, UITableViewDataSource>
@property (weak, nonatomic) IBOutlet UITableView *tableView;

//@property NSMutableArray *rooms;
@property NSMutableArray *sets;
@property NSMutableArray *weeks;
@property NSMutableArray *hightlightsArray;
@property NSArray *sortedHighlightsArray;

@end

@implementation WeekHighlightsVC

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.title = @"Highlights";
//    self.rooms = [NSMutableArray new];
    self.sets = [NSMutableArray new];
    self.weeks = [NSMutableArray new];
    self.hightlightsArray = [NSMutableArray new];
    
    [self basicSetUpOFUI];
}

-(void)viewDidAppear:(BOOL)animated
{
    self.scrollView.scrollEnabled = YES;
}



-(void)viewWillDisappear:(BOOL)animated
{
    self.scrollView.scrollEnabled = NO;
}

-(void)basicSetUpOFUI
{
    self.tableView.backgroundColor = [UIColor clearColor];
    
    UIBarButtonItem *settingsButton = [[UIBarButtonItem alloc] initWithTitle:@"settings"
                                                                        style:UIBarButtonItemStyleBordered target:self action:@selector(goToSettingsVC)];
    settingsButton.image = [UIImage imageNamed:@"settings"];
    self.navigationItem.rightBarButtonItem = settingsButton;
    UIBarButtonItem *inboxButton = [[UIBarButtonItem alloc] initWithTitle:@"inbox"
                                                                       style:UIBarButtonItemStyleBordered target:self action:@selector(goBackToInboxVC)];
    inboxButton.image = [UIImage imageNamed:ASSETS_INBOX_FLIP];
    self.navigationItem.leftBarButtonItem = inboxButton;
}

-(void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    AllWeekPhotosVC *vc = [segue destinationViewController];
    NSIndexPath *indexpath = [self.tableView indexPathForSelectedRow];
    HighlightData *highlight = self.sortedHighlightsArray[indexpath.row];
    vc.highlight = highlight;
}

-(void)goToSettingsVC
{
    ProfileView *vc = [[ProfileView alloc] initWithStyle:UITableViewStyleGrouped];
    [self.navigationController pushViewController:vc animated:YES];
}

-(void)goBackToInboxVC
{
    //why isn't this working!!!
    
    [self.scrollView setContentOffset:CGPointMake(self.view.frame.size.width, 0) animated:1];
//    [self.scrollView setContentOffset:CGPointMake(0, 0) animated:YES];
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
//        PFObject *room = [message objectForKey:@"room"];
        [self loadSetsFrom:message];
    }
}

-(void)delayedReloadOfView
{
    [self.tableView reloadData];
}

-(void)loadSetsFrom:(PFObject *)message
{
    PFObject *room = [message objectForKey:@"room"];
    PFQuery *query = [PFQuery queryWithClassName:@"Sets"];
    [query whereKey:@"room" equalTo:room];
    [query includeKey:@"lastPicture"];
    [query includeKey:@"createdAt"];
//    [query whereKey:@"isUploaded" equalTo:@1];
//    [query includeKey:@"numberOfResponses"];
    [query orderByDescending:@"numberOfResponses"];
    [query findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error)
    {
        if(!error)
        {
            [self performSelector:@selector(delayedReloadOfView) withObject:@1 afterDelay:2];
            for (PFObject *set in objects)
            {
                if ([set objectForKey:@"numberOfResponses"])
                {
//                    NSLog(@"%i responses", [[set objectForKey:@"numberOfResponses"]intValue]);
//                    [self.sets addObject:set];
                    [self createHighlightWithSet:set andMessage:message];
                    // do i organize here?
                }
                //this is where if counter was zero i'd make it hide the alert
//                [self.tableView reloadData];
            }
        }
    }];
}

-(void)createHighlightWithSet:(PFObject*)set andMessage:(PFObject*)message
{
    NSDate *now = [NSDate date];
//    NSDate *setDate = [set valueForKey:@"createdAt"];
    NSDate *setDate = set.createdAt;
    double deltaSeconds = fabs([setDate timeIntervalSinceDate:now]);
    double minutes = deltaSeconds / 60;
    double hours = minutes / 60;
    double days = hours / 24;
    double weeks = days / 7;
    
//    double weeks = deltaSeconds / (60 * 60 * 24 * 7);
//    NSLog(@"%fl days since set was created", days);
    int weeksInt = (int)weeks;
    NSNumber *weeksNumber = [NSNumber numberWithInt:weeksInt];
    
    if ([self.weeks containsObject:weeksNumber])
    {
        for (HighlightData *data in self.hightlightsArray)
        {
//            NSLog(@"%i weeks ago compared to %i", data.howManyWeeksAgo, weeksInt);
            if (data.howManyWeeksAgo == weeksInt)
            {
                [data modifyHighLightWithSet:set andUserChatroom:message];
//                [self.tableView reloadData];
//                NSLog(@"modified something with week %i", weeksInt);
            }
        }
    }
    else
    {
        [self.weeks addObject:[NSNumber numberWithInt:weeksInt]];
        HighlightData *data = [[HighlightData alloc] initWithPFObject:set andAmountOfWeeks:weeksInt andUserChatroom:message];
//        data.userChatroom = message;
        [self.hightlightsArray addObject:data];
        NSSortDescriptor *sortDescriptor;
        sortDescriptor = [[NSSortDescriptor alloc] initWithKey:@"weeksNumberToSortWith"
                                                     ascending:YES];
        NSArray *sortDescriptors = [NSArray arrayWithObject:sortDescriptor];
        self.sortedHighlightsArray = [self.hightlightsArray sortedArrayUsingDescriptors:sortDescriptors];
        
//        NSLog(@"i created a highlight object for week %i", weeksInt);
//        NSLog(@"%li highlights in the highlight array", self.hightlightsArray.count);
    }
}



#pragma mark "TableView Stuff"

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    WeekCell *cell = [tableView dequeueReusableCellWithIdentifier:@"cellid"];
    HighlightData *highlight = self.sortedHighlightsArray[indexPath.row];
//    HighlightData *highlight = self.sortedHighlightsArray[0];

    cell.backgroundColor = [UIColor clearColor];
    [cell formatCell];
    [cell fillPicsWithTop5PicsFromHighlight:highlight];
//    if (indexPath.row != 0)
    if (highlight.howManyWeeksAgo != 0)
    {
        if (indexPath.row != 1)
        {
            cell.weekLabel.text = [NSString stringWithFormat:@"%i Weeks Ago", highlight.howManyWeeksAgo];
        }
        else
        {
            cell.weekLabel.text = [NSString stringWithFormat:@"%i Week Ago", highlight.howManyWeeksAgo];
        }
    }
    return cell;
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.sortedHighlightsArray.count;
//    return 1;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:1];
}



@end
