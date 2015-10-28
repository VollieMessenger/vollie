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
#import "ExplainationCell.h"

@interface WeekHighlightsVC () <UITableViewDelegate, UITableViewDataSource, UIScrollViewDelegate, UIGestureRecognizerDelegate>
@property (weak, nonatomic) IBOutlet UITableView *tableView;

//@property NSMutableArray *rooms;
@property NSMutableArray *sets;
@property NSMutableArray *weeks;
@property NSMutableArray *hightlightsArray;
@property NSArray *sortedHighlightsArray;

//refresh control
@property UIRefreshControl *refreshControl;
@property UIView *refreshLoadingView;
@property UIView *refreshColorView;
@property UIImageView *compassSpinner;
@property UIImageView *compassBackground;
@property BOOL isRefreshIconsOverlap;
@property BOOL isRefreshAnimating;
@property BOOL isRefreshingUp;
@property BOOL isRefreshingDown;

@end

@implementation WeekHighlightsVC

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.title = @"Flashbacks";
//    self.rooms = [NSMutableArray new];
//    self.sets = [NSMutableArray new];
//    self.weeks = [NSMutableArray new];
//    self.hightlightsArray = [NSMutableArray new];
    
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
//    self.tableView.backgroundColor = [UIColor clearColor];
    
    UIBarButtonItem *settingsButton = [[UIBarButtonItem alloc] initWithTitle:@"settings"
                                                                        style:UIBarButtonItemStyleBordered target:self action:@selector(goToSettingsVC)];
    settingsButton.image = [UIImage imageNamed:@"settings"];
    self.navigationItem.rightBarButtonItem = settingsButton;
    UIBarButtonItem *inboxButton = [[UIBarButtonItem alloc] initWithTitle:@"inbox"
                                                                       style:UIBarButtonItemStyleBordered target:self action:@selector(goBackToInboxVC)];
    inboxButton.image = [UIImage imageNamed:ASSETS_INBOX_FLIP];
    self.navigationItem.leftBarButtonItem = inboxButton;
    
    [self setupRefreshControl];
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
    self.sets = [NSMutableArray new];
    self.weeks = [NSMutableArray new];
    self.hightlightsArray = [NSMutableArray new];
    messagesArray = inbox.messages;
//    for (PFObject *message in messagesArray)
//    {
//        //i would like to have this be a regular for loop
//        //and do a counter. An alert would come up saying "loading"
//        // and when the counter hits zero the tableview reloads and the alert goes away
////        PFObject *room = [message objectForKey:@"room"];
//        [self loadSetsFrom:message];
//    }
//
    for (int x = 0; x < messagesArray.count; x++)
    {
        PFObject *message = messagesArray[x];
        [self loadSetsFrom:message];
        
        if (x == messagesArray.count - 1)
        {
            [self.refreshControl endRefreshing];
            [self performSelector:@selector(delayedReloadOfView) withObject:@1 afterDelay:2];
        }
    }
//    self.
}

-(void)delayedReloadOfView
{
//    [self.refreshControl endRefreshing];
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
//            [self performSelector:@selector(delayedReloadOfView) withObject:@1 afterDelay:2];
            for (PFObject *set in objects)
            {
                if ([set objectForKey:@"numberOfResponses"] && [set objectForKey:@"lastPicture"])
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
    if (indexPath.row < self.sortedHighlightsArray.count)
    {
        WeekCell *cell = [tableView dequeueReusableCellWithIdentifier:@"cellid"];
        HighlightData *highlight = self.sortedHighlightsArray[indexPath.row];
        [cell formatCell];
        [cell fillPicsWithTop5PicsFromHighlight:highlight];
        if (highlight.howManyWeeksAgo != 0)
        {
            if (highlight.howManyWeeksAgo != 1)
            {
                cell.weekLabel.text = [NSString stringWithFormat:@"%i Weeks Ago", highlight.howManyWeeksAgo];
            }
            else
            {
                cell.weekLabel.text = [NSString stringWithFormat:@"%i Week Ago", highlight.howManyWeeksAgo];
            }
        }
        else
        {
            cell.weekLabel.text = @"This Week";
        }
        return cell;
    }
    else
    {
        [self.tableView registerNib:[UINib nibWithNibName:@"ExplainationCell" bundle:0] forCellReuseIdentifier:@"ExplainationCell"];
        ExplainationCell *cell = [tableView dequeueReusableCellWithIdentifier:@"ExplainationCell"];
//        ThreePicCell *cell = [tableView dequeueReusableCellWithIdentifier:@"ThreePicCell"];
        return cell;
    }
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.row == self.sortedHighlightsArray.count)
    {
        return 100;
    }
    else
    {
        return 187;
    }
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.sortedHighlightsArray.count + 1;
//    return 1;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:1];
}

#pragma mark "Refresh Swipe Down"
- (void)setupRefreshControl
{
    // Programmatically inserting a UIRefreshControl
    self.refreshControl = [[UIRefreshControl alloc] init];
    
    // Setup the loading view, which will hold the moving graphics
    self.refreshLoadingView = [[UIView alloc] initWithFrame:self.refreshControl.bounds];
    self.refreshLoadingView.backgroundColor = [UIColor clearColor];
    
    // Setup the color view, which will display the rainbowed background
    self.refreshColorView = [[UIView alloc] initWithFrame:self.refreshControl.bounds];
    self.refreshColorView.backgroundColor = [UIColor clearColor];
    self.refreshColorView.alpha = .8;
    
    // Create the graphic image views
    self.compassBackground = [[UIImageView alloc] initWithImage:[UIImage imageNamed:ASSETS_NEW_BLANKV]];
    self.compassSpinner = [[UIImageView alloc] initWithImage:[UIImage imageNamed:ASSETS_NEW_BLANKV]];
    
    // Add the graphics to the loading view
    [self.refreshLoadingView addSubview:self.compassBackground];
    [self.refreshLoadingView addSubview:self.compassSpinner];
    
    // Clip so the graphics don't stick out
    self.refreshLoadingView.clipsToBounds = YES;
    
    // Hide the original spinner icon
    self.refreshControl.tintColor = [UIColor clearColor];
    
    // Add the loading and colors views to our refresh control
    [self.refreshControl addSubview:self.refreshColorView];
    [self.refreshControl addSubview:self.refreshLoadingView];
    
    // Initalize flags
    self.isRefreshIconsOverlap = NO;
    self.isRefreshAnimating = NO;
    
    // When activated, invoke our refresh function
    [self.refreshControl addTarget:self action:@selector(loadRoomsFromMainInbox) forControlEvents:UIControlEventValueChanged];
    [self.tableView addSubview:_refreshControl];
}

- (void)animateRefreshView
{
    // Background color to loop through for our color view
    //    NSArray *colorArray = @[[UIColor redColor],[UIColor blueColor],[UIColor purpleColor],[UIColor cyanColor],[UIColor orangeColor],[UIColor magentaColor]];
    
    NSArray *colorArray = [UIColor arrayOfColorsCore];
    static int colorIndex = 0;
    
    //    colorArray = [AppConstant arrayOfColors];
    
    // Flag that we are animating
    self.isRefreshAnimating = YES;
    //    self.labelNoMessages.hidden = YES;
    
    [UIView animateWithDuration:0.3
                          delay:0
                        options:UIViewAnimationOptionCurveLinear
                     animations:^{
                         // Rotate the spinner by M_PI_2 = PI/2 = 90 degrees
                         [self.compassSpinner setTransform:CGAffineTransformRotate(self.compassSpinner.transform, M_PI * 2)];
                         
                         // Change the background color
                         self.refreshColorView.backgroundColor = [colorArray objectAtIndex:colorIndex];
                         colorIndex = (colorIndex + 1) % colorArray.count;
                     }
                     completion:^(BOOL finished) {
                         // If still refreshing, keep spinning, else reset
                         if (self.refreshControl.isRefreshing)
                         {
                             [self animateRefreshView];
                         }
                         else
                         {
                             [self resetAnimation];
                         }
                     }];
}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    // Get the current size of the refresh controller
    CGRect refreshBounds = self.refreshControl.bounds;
    
    // Distance the table has been pulled >= 0
    CGFloat pullDistance = MAX(0.0, -self.refreshControl.frame.origin.y);
    
    // Half the width of the table
    CGFloat midX = self.tableView.frame.size.width / 2.0;
    
    dispatch_async(dispatch_get_main_queue(), ^
    {
        if (pullDistance > 60.0f && !_isRefreshingUp)
        {
            self.isRefreshingUp = YES;
            [UIView animateWithDuration:.3f animations:^{
                //                               self.labelNoMessages.hidden = YES;
                self.tableView.backgroundColor = [UIColor volleyFlatOrange];
            }];
        }
        else if (pullDistance < 60.0f && !_isRefreshingDown)
        {
            _isRefreshingDown = YES;
            [UIView animateWithDuration:.2f animations:^{
                self.tableView.backgroundColor = [UIColor whiteColor];
                //                               self.labelNoMessages.hidden = NO;
            }];
        }
    });
    
    if (pullDistance  < 5 && _isRefreshingUp == YES && _isRefreshingDown == YES)
    {
        _isRefreshingDown = NO;
        _isRefreshingUp = NO;
    }
    
    // Calculate the width and height of our graphics
    CGFloat compassHeight = self.compassBackground.bounds.size.height;
    CGFloat compassHeightHalf = compassHeight / 2.0;
    
    CGFloat compassWidth = self.compassBackground.bounds.size.width;
    CGFloat compassWidthHalf = compassWidth / 2.0;
    
    CGFloat spinnerHeight = self.compassSpinner.bounds.size.height;
    CGFloat spinnerHeightHalf = spinnerHeight / 2.0;
    
    CGFloat spinnerWidth = self.compassSpinner.bounds.size.width;
    CGFloat spinnerWidthHalf = spinnerWidth / 2.0;
    
    // Calculate the pull ratio, between 0.0-1.0
    CGFloat pullRatio = MIN( MAX(pullDistance, 0.0), 100.0) / 100.0;
    
    // Set the Y coord of the graphics, based on pull distance
    CGFloat compassY = pullDistance / 2.0 - compassHeightHalf;
    CGFloat spinnerY = pullDistance / 2.0 - spinnerHeightHalf;
    
    // Calculate the X coord of the graphics, adjust based on pull ratio
    CGFloat compassX = (midX + compassWidthHalf) - (compassWidth * pullRatio);
    CGFloat spinnerX = (midX - spinnerWidth - spinnerWidthHalf) + (spinnerWidth * pullRatio);
    
    // When the compass and spinner overlap, keep them together
    if (fabsf(compassX - spinnerX) < 1.0)
    {
        self.isRefreshIconsOverlap = YES;
    }
    
    // If the graphics have overlapped or we are refreshing, keep them together
    //Changed to && from ||
    if (self.isRefreshIconsOverlap || self.refreshControl.isRefreshing)
    {
        compassX = midX - compassWidthHalf;
        spinnerX = midX - spinnerWidthHalf;
    }
    
    // Set the graphic's frames
    CGRect compassFrame = self.compassBackground.frame;
    compassFrame.origin.x = compassX;
    compassFrame.origin.y = compassY;
    
    CGRect spinnerFrame = self.compassSpinner.frame;
    spinnerFrame.origin.x = spinnerX;
    spinnerFrame.origin.y = spinnerY;
    
    self.compassBackground.frame = compassFrame;
    self.compassSpinner.frame = spinnerFrame;
    
    // Set the encompassing view's frames
    refreshBounds.size.height = pullDistance;
    
    self.refreshColorView.frame = refreshBounds;
    self.refreshLoadingView.frame = refreshBounds;
    
    // If we're refreshing and the animation is not playing, then play the animation
    if (self.refreshControl.isRefreshing && !self.isRefreshAnimating)
    {
        [self animateRefreshView];
        self.isRefreshIconsOverlap = NO;
    }
    
}

- (void)resetAnimation
{
    // Reset our flags and background color
    self.isRefreshAnimating = NO;
    self.isRefreshIconsOverlap = NO;
    self.refreshColorView.backgroundColor = [UIColor clearColor];
    //    self.labelNoMessages.hidden = NO;
}




@end
