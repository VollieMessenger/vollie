//
//  SelectChatroomView.m
//  Volley
//
//  Created by benjaminhallock@gmail.com on 1/12/15.
//  Copyright (c) 2015 KZ. All rights reserved.
//

#import "AlbumView.h"

#import <Parse/Parse.h>

#import "AppConstant.h"

#import "ProgressHUD.h"

#import "UIColor+JSQMessages.h"

#import "AppDelegate.h"

#import "utilities.h"

#import "messages.h"

#import "JSQMessagesKeyboardController.h"

#import "pushnotification.h"

#import "NSDate+TimeAgo.h"

#import "CustomChatView.h"

#import "MessagesCellDot.h"

@interface AlbumView () < UITextViewDelegate, UITableViewDataSource, UITableViewDelegate >

@property UITapGestureRecognizer *tap;

@property IBOutlet UITableView *tableView;

@property IBOutlet UIButton *composeButton;

@property NSMutableArray *messages;

@property NSMutableArray *messagesSorted;

@property NSMutableArray *messagesObjectIds;

@property PFObject *selectedRoom;

@property PFObject *selectedSet;

@property PFObject *selectedMessage;

@property NSString *selectedText;//For next view title;

@property NSMutableArray *arrayOfReusableCells;

@property BOOL didViewJustLoad;

@property NSMutableArray *savedPhotoObjects;

@property int randomNumber;

@property BOOL justCreatedChatroom;

@property BOOL didSendPictures;
@property BOOL firstLoop;

@property int countDownToPhotoRefresh;

@end

@implementation AlbumView

@synthesize tap;

-(void)viewWillAppear:(BOOL)animated
{
    self.navigationController.navigationBarHidden = 0;
    if (_didSendPictures) [self.navigationController popViewControllerAnimated:0];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:1];
    if (self.didViewJustLoad)
    {
        self.didViewJustLoad = NO;
    }
}

- (void)loadAlbumFavorites
// LOAD MESSAGES FROM INBOX INSTEAD.
{
    if ([PFUser currentUser])
    {
        self.tableView.userInteractionEnabled = NO;

        PFQuery *query = [PFQuery queryWithClassName:PF_FAVORITES_CLASS_NAME];
        [query whereKey:PF_FAVORITES_ALBUM equalTo:self.album];
        [query orderByDescending:@"createdAt"];
        [query includeKey:PF_FAVORITES_SET];
        [query setCachePolicy:kPFCachePolicyCacheThenNetwork];
        [query findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
            if (!error)
            {
                NSMutableArray *newObjects = [NSMutableArray new];
                int new = 0;
                for (PFObject *object in objects)
                {
                    if (![self.messagesObjectIds containsObject:object.objectId])
                    {
                        self.firstLoop ? [self.messages addObject:object] : [self.messages insertObject:object atIndex:new];
                        [newObjects addObject:object];
                        [self.messagesObjectIds addObject:object.objectId];
                        new +=1;
                    }
                }
                
                NSSortDescriptor * sorting = [[NSSortDescriptor alloc] initWithKey:PF_SET_UPDATED ascending:YES];
                
                self.messagesSorted = [[self.messages sortedArrayUsingDescriptors:[NSArray arrayWithObjects:sorting, nil]] mutableCopy];
                
//                for (PFObject * favorite in self.messagesSorted) {
//                    PFObject *set = [favorite valueForKey:PF_FAVORITES_SET];
//                    NSLog(@"fired %@",set);
//                }
                
//                self.messagesSorted = [NSMutableArray arrayWithArray:[self.messages sortedArrayUsingComparator:^NSComparisonResult(id a, id b) {
//                    PFObject *fav1 = a;
//                    PFObject *fav2 = b;
//                    PFObject *set1 = [fav1 valueForKey:PF_FAVORITES_SET];
//                    PFObject *set2 = [fav2 valueForKey:PF_FAVORITES_SET];
//
//                    NSDate *firstDate;
//                    NSDate *secondDate;
//                    NSLog(@"fired %@",set2);
//                    if (fav1.createdAt < set1[PF_SET_UPDATED]) {
//                        firstDate = set1[PF_SET_UPDATED];
//                    } else {
//                        firstDate = set1.createdAt;
//                    }
//
//                    if (fav2.createdAt < set2[PF_SET_UPDATED]) {
//                        secondDate = set2[PF_SET_UPDATED];
//                    } else {
//                        secondDate = set1.createdAt;
//                    }
//
//                    return [secondDate compare:firstDate];
//                }]];

                //If createdAt is greater than set UpdatedAction, order as such.}

#warning INSERTING ROWS TWICE, MUST CLEAR TABLE BEFOR EACH TIME.

                NSMutableArray *indexPaths = [NSMutableArray new];
                
                for (PFObject *album in newObjects)
                {
                    [indexPaths addObject:[NSIndexPath indexPathForRow:[self.messagesSorted indexOfObject:album] inSection:0]];
                }

                [self.tableView beginUpdates];
                [self.tableView insertRowsAtIndexPaths:indexPaths withRowAnimation:UITableViewRowAnimationAutomatic];
                [self.tableView endUpdates];
                
                self.tableView.userInteractionEnabled = YES;

                [self updateEmptyView];
                
            }
            else
            {
                if ([query hasCachedResult] && self.navigationController.visibleViewController == self)
                {
                    [ProgressHUD showError:@"Network error."];
                }
            }
            self.firstLoop = NO;
//            PostNotification(NOTIFICATION_REFRESH_FAVORITES);
        }];
    }
}

-(void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    [self.tableView setEditing:0 animated:1];

    PFObject *favorite = [self.messages objectAtIndex:indexPath.row];
    [favorite deleteInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
        if (!error)
        {
            NSIndexPath *indexPath = [NSIndexPath indexPathForRow:[self.messages indexOfObject:favorite] inSection:0];

            PFQuery *query = [PFQuery queryWithClassName:PF_FAVORITES_CLASS_NAME];
            [query whereKey:PF_FAVORITES_ALBUM equalTo:self.album];
            [query clearCachedResult];

            [self.messagesSorted removeObject:favorite];
            [self.messages removeObject:favorite];
            //THis will help it not come back from the dead.
           // [self.messagesObjectIds removeObject:favorite.objectId];

            [self.tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationLeft];

            if (self.messagesSorted.count == 0)
            {
                PFQuery *query2 = [PFQuery queryWithClassName:PF_ALBUMS_CLASS_NAME];
                [query2 whereKey:PF_ALBUMS_USER equalTo:[PFUser currentUser]];
                [query2 clearCachedResult];

                // RELOAD TABLEVIEW OF FAVORITES, AND INBOX BECAUSE WHY NOT
                PostNotification(NOTIFICATION_REFRESH_ALBUMS);

                [self.album removeObjectForKey:PF_ALBUMS_SET];
                [self.album saveInBackground];
            }

            [self updateEmptyView];
        }
    }];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    MessagesCellDot *cell = [tableView dequeueReusableCellWithIdentifier:@"MessagesCell"];
    if (!cell) cell = [[MessagesCellDot alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"MessagesCell"];
    
    [self.arrayOfReusableCells addObject:cell];

    [cell format];

    cell.selectionStyle = UITableViewCellSelectionStyleNone;

    cell.labelDescription.text = @"";
    cell.labelLastMessage.text = @"";

    cell.labelInitials.hidden = YES;

    PFObject *favorite = [self.messagesSorted objectAtIndex:indexPath.row];
    
    PFObject *set = [favorite valueForKey:PF_FAVORITES_SET];

    NSArray *arrayOfColors = [AppConstant arrayOfColors];

    UIColor *selectedColor;

    NSNumber *setNumber = [set valueForKey:PF_SET_ROOMNUMBER];

    //SetNumber is base 0, plus one for count
    if ([setNumber intValue] + 1 > (arrayOfColors.count)){
        selectedColor = [arrayOfColors objectAtIndex:(([setNumber intValue] + 1) % arrayOfColors.count)];
    } else {
        selectedColor = [arrayOfColors objectAtIndex:[setNumber intValue]];
    }

    cell.labelDescription.textColor = selectedColor;
    cell.labelInitials.backgroundColor = selectedColor;

    cell.labelLastMessage.text = [set.updatedAt dateTimeUntilNow];

    PFUser *user = [set valueForKey:PF_SET_USER];

    [user fetchIfNeededInBackgroundWithBlock:^(PFObject *object, NSError *error) {
        if (!error){
            if ([user.objectId isEqual:[PFUser currentUser].objectId]){
                cell.labelDescription.text = @"Me";
            } else {
                cell.labelDescription.text = [user valueForKey:PF_USER_FULLNAME];
            }

        NSString *nam = [user valueForKey:PF_USER_FULLNAME];
        NSMutableArray *array = [NSMutableArray arrayWithArray:[nam componentsSeparatedByString:@" "]];
        [array removeObject:@" "];
        NSString *first = array.firstObject;
        NSString *last = array.lastObject;
        first = [first stringByPaddingToLength:1 withString:nam startingAtIndex:0];
        last = [last stringByPaddingToLength:1 withString:nam startingAtIndex:0];
        nam = [first stringByAppendingString:last];
        cell.labelInitials.text = nam;
        }
    }];
    PFObject *picture = set[PF_SET_LASTPICTURE];

    if (picture) {
    [picture fetchIfNeededInBackgroundWithBlock:^(PFObject *object, NSError *error) {
        if (!error)
        {
            PFFile *file = [picture valueForKey:PF_PICTURES_THUMBNAIL];
//            cell.imageUser.file = file;
//            [cell.imageUser loadInBackground];

            [file getDataInBackgroundWithBlock:^(NSData *data, NSError *error) {
                if (!error) {
                    cell.imageUser.image = [UIImage imageWithData:data];
                    cell.labelInitials.hidden = NO;
                }
            }];
        }
    }];
    }

    return cell;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.messagesSorted.count;
//    return 1;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (self.messagesSorted.count){
        [tableView deselectRowAtIndexPath:indexPath animated:1];
        
        MessagesCellDot *cell = [tableView cellForRowAtIndexPath:indexPath];

        PFObject *favorite = [self.messagesSorted objectAtIndex:indexPath.row];
        PFObject *set = [favorite objectForKey:PF_FAVORITES_SET];

        NSArray *arrayOfColors = [AppConstant arrayOfColors];
        UIColor *selectedColor;
        NSNumber *setNumber = [set objectForKey:PF_SET_ROOMNUMBER];

        if ([setNumber intValue] + 1 > (arrayOfColors.count)){
            selectedColor = [arrayOfColors objectAtIndex:(( [setNumber intValue] + 1) % arrayOfColors.count)];
        } else {
            selectedColor = [arrayOfColors objectAtIndex:[setNumber intValue]];
        }

        CustomChatView *chat = [[CustomChatView alloc] initWithSetId:set.objectId andColor:selectedColor];
        chat.navigationController.navigationBar.barTintColor = [UIColor volleyFlatPeach];
        chat.room = [set objectForKey:PF_SET_ROOM];
        chat.isFavoritesSets = YES;
        chat.album = self.album;
        chat.senderId = [[PFUser currentUser].objectId copy];
        chat.senderDisplayName = [[[PFUser currentUser] valueForKey:PF_USER_FULLNAME] copy];

        NSString *title = @"";

        if ([cell.labelDescription.text isEqualToString:@"Me"])
        {
            title = cell.labelDescription.text;
        }
        else if (cell.labelDescription.text.length)
        {
            title = [cell.labelDescription.text stringByAppendingString:@"'s Pictures"];
        }

        chat.title = title;

        CATransition* transition = [CATransition animation];
        transition.duration = 0.3;
        transition.type = kCATransitionPush;
        transition.subtype = kCATransitionFromRight;
        transition.timingFunction = UIViewAnimationCurveEaseInOut;
        transition.fillMode = kCAFillModeForwards;
        [self.navigationController.view.layer addAnimation:transition forKey:kCATransition];

        [self.navigationController pushViewController:chat animated:YES];
    }
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    [textField resignFirstResponder];
    return YES;
}


- (void)longPress:(UILongPressGestureRecognizer *)longPressss
{
    CGPoint point = [longPressss locationInView:self.tableView];

    UITableViewCell *cell = [self.tableView cellForRowAtIndexPath:[self.tableView indexPathForRowAtPoint:point]];
    if (cell)
    {
        [self.tableView setEditing:1 animated:1];
        tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(didTap:)];
        tap.delegate = self;
        [self.tableView addGestureRecognizer:tap];
    }
}

- (void)didTap:(UITapGestureRecognizer *)tapppppp
{
    CGPoint point = [tapppppp locationInView:self.tableView];

    if (point.x > 50 && tap) {
        [self.tableView setEditing:0 animated:1];
        [self.tableView removeGestureRecognizer:tap];
        tap = nil;
    }
}

- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldReceiveTouch:(UITouch *)touch
{
    //This is called ALWAYS because of longPress???
    CGPoint point = [touch locationInView:self.view];

    if (self.tableView.editing) {
        if (point.x < 50)
        {
            //Let the button work
            return NO;
        } else {
            return YES;
        }
    } else {
        return NO;
    }
}

- (void)viewDidLoad
{
    self.firstLoop = YES;
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(loadAlbumFavorites) name:NOTIFICATION_REFRESH_FAVORITES object:0];

    [self.tableView registerNib:[UINib nibWithNibName:@"MessagesCellDot" bundle:0] forCellReuseIdentifier:@"MessagesCell"];

    UILongPressGestureRecognizer *longpress = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(longPress:)];
    [self.view addGestureRecognizer:longpress];

    _composeButton.backgroundColor = [UIColor whiteColor];

    _composeButton.imageView.tintColor = [UIColor volleyFamousGreen];
    _composeButton.imageView.image = [_composeButton.imageView.image imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
    _composeButton.titleLabel.textColor = [UIColor volleyFamousGreen];
    _composeButton.tintColor = [UIColor volleyFamousGreen];

    [super viewDidLoad];

    self.navigationController.navigationBarHidden = 0;
    
    self.view.backgroundColor = [UIColor whiteColor];

    self.messages = [NSMutableArray new];
    self.messagesObjectIds = [NSMutableArray new];

    [self loadAlbumFavorites];

    /*
    UIBarButtonItem *backButton = [[UIBarButtonItem alloc]
                                   initWithTitle: @"Back"
                                   style: UIBarButtonItemStyleBordered
                                   target: nil action: nil];
    [self.navigationItem setBackBarButtonItem: backButton];
     */

    self.didViewJustLoad = YES;


    self.arrayOfReusableCells = [NSMutableArray new];
}

- (BOOL)textViewShouldBeginEditing:(UITextView *)textView
{
    [self.view addGestureRecognizer:tap];
    return YES;
}

- (void)textViewDidEndEditing:(UITextView *)textView
{
    [self.view removeGestureRecognizer:tap];
}

-(void)textViewDidChangeSelection:(UITextView *)textView {
    if ([textView.text containsString:@"\n"]) {
        [textView deleteBackward];
        [textView resignFirstResponder];
    }
}


-(void)actionClose
{
    [self dismissViewControllerAnimated:0 completion:0];
}

- (void)updateEmptyView
{
    if (self.messagesSorted.count == 0)
    {
        UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(0, 70, self.view.frame.size.width, 70)];
        label.text = @"No favorites";
        label.textAlignment = NSTextAlignmentCenter;
        label.textColor = [UIColor lightGrayColor];
        [self.view addSubview:label];
    }
    else
    {
        for (UILabel *label in self.view.subviews)
        {
            if ([label isKindOfClass:[UILabel class]] && [label.text isEqualToString:@"No favorites"])
            {
                [label removeFromSuperview];
            }
        }
    }
}

@end
