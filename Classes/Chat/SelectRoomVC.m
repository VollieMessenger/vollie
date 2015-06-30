//
//  SelectRoomVC.m
//  Volley
//
//  Created by Kyle on 6/24/15.
//  Copyright (c) 2015 KZ. All rights reserved.
//

#import "SelectRoomVC.h"
#import "ChatRoomCell.h"
#import <Parse/Parse.h>
#import "AppConstant.h"
#import "ProgressHUD.h"
#import "AppDelegate.h"
//#import "messages.h"


@interface SelectRoomVC () <UITableViewDataSource, UITableViewDelegate>

@property (strong, nonatomic) IBOutlet UITableView *tableView;

@property NSMutableArray *messages;
@property NSMutableArray *savedPhotoObjects;
@property NSMutableArray *objectsForParse;

@property PFObject *selectedRoom;
@property PFObject *selectedSet;
@property PFObject *selectedMessage;

@property int countDownToPhotoRefresh;
@property BOOL isThePicturesReadyToSend;


@end

@implementation SelectRoomVC

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    NSLog(@"%li", self.photosToSend.count);
    NSLog(@"%@", self.textToSend);

    self.tableView.backgroundColor = [UIColor clearColor];
    self.title = @"Send to...";
    self.messages = [NSMutableArray new];
    self.savedPhotoObjects = [NSMutableArray new];
    self.objectsForParse = [NSMutableArray new];
    [self loadData];
}

- (void)loadData
{
    if ([PFUser currentUser])
    {
        NavigationController *nav  = [(AppDelegate *)[[UIApplication sharedApplication] delegate] navInbox];
        // LOAD MESSAGES FROM INBOX INSTEAD.
        MessagesView *view = nav.viewControllers.firstObject;
        self.messages = view.messages;
    }
}

-(void)beginSendingVolliePackage
{
    [self.selectedRoom fetchInBackgroundWithBlock:^(PFObject *object, NSError *error)
     {
         if (!error)
         {
//             [ProgressHUD show:@"Sending..." Interaction:NO];
             int numberOfSets = [[object valueForKey:PF_CHATROOMS_ROOMNUMBER] intValue];
//             NSLog(@"%i is the number of sets", numberOfSets);
             self.selectedSet = [PFObject objectWithClassName:PF_SET_CLASS_NAME];
             if (numberOfSets == 0)
             {
                 [self.selectedSet setValue:@(0) forKey:PF_SET_ROOMNUMBER];
                 //i mean when would this happen? If we're creatin a new room? meh....
             }
             else
             {
                 [self.selectedSet setValue:@(numberOfSets) forKey:PF_SET_ROOMNUMBER];
//                 NSLog(@"%@ set roomnumber", [self.selectedSet objectForKey:PF_SET_ROOMNUMBER]);
             }

             [self.selectedRoom setValue:@(numberOfSets + 1) forKey:PF_CHATROOMS_ROOMNUMBER];
//             NSLog(@"%@ set chatrooms roomnumber", [self.selectedRoom objectForKey:PF_SET_ROOMNUMBER]);

             [self.selectedRoom saveInBackground];

             [self.selectedSet setValue:_selectedRoom forKey:PF_SET_ROOM];
             [self.selectedSet setValue:[PFUser currentUser] forKey:PF_SET_USER];
             [self.selectedSet saveInBackground];
             NSLog(@"%@ is teh selected set", self.selectedSet);

             [self createParseObjectsWithPhotosArray];

//             [self savePicturesinRoom:self.selectedRoom];
         }
         else
         {
             [ProgressHUD showError:@"Network Error"];
         }
     }];
}

-(void)createParseObjectsWithPhotosArray
{
    for (id imageOrFile in self.photosToSend)
    {
        if ([imageOrFile isKindOfClass:[UIImage class]])
        {
            PFObject *picture = [self basicParseObjectSetupWith:imageOrFile];
//            NSLog(@"%@", picture);
        }
        else if ([imageOrFile isKindOfClass:[NSDictionary class]])
        {
            PFObject *video = [self basicParseObjectSetupWith:imageOrFile];
        }
    }
}

-(PFObject*)basicParseObjectSetupWith:(id)imageOrFile
{
    PFObject *object = [PFObject objectWithClassName:PF_PICTURES_CLASS_NAME];
    [object setValue:[PFUser currentUser] forKey:PF_PICTURES_USER];
    [object setValue:@YES forKey:PF_CHAT_ISUPLOADED];
    [object setValue:[NSDate dateWithTimeIntervalSinceNow:[self.photosToSend indexOfObject:object]]forKey:PF_PICTURES_UPDATEDACTION];
//    [object setValue:self.selectedSet forKey:PF_PICTURES_SETID];
    NSLog(@"%@ should be the selected set", self.selectedSet);
    NSLog(@"%@", object);
    return object;
}

-(void)savePicturesinRoom:(PFObject *)room
{
//    self.countDownToPhotoRefresh = (int)self.savedPhotoObjects.count;

//    while (_isThePicturesReadyToSend == NO)
//    {
//        [self savePicturesinRoom:room];
//        return;
//    }

    for (PFObject *picture in self.photosToSend)
    {
//
//        NSLog(@"%li in the photosToSend forin loop", self.photosToSend.count);
//
//        [picture setValue:self.selectedRoom forKey:PF_PICTURES_CHATROOM];
//        NSLog(@"%@", [picture objectForKey:PF_PICTURES_CHATROOM]);

//        [self savePictureInBGwithObject:picture andFile:imageOrVideo];
    }
}

-(void)savePictureInBGwithObject:(PFObject *)picture andFile:(PFFile *)imageOrVideo
{
    NSLog(@"at least i went");
    [picture saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error)
     {
         if (succeeded)
         {
             [picture setValue:imageOrVideo forKey:PF_PICTURES_PICTURE];
             [picture saveInBackground];

             _countDownToPhotoRefresh--;

             if (_countDownToPhotoRefresh == 0)
             {
//                 [ProgressHUD showSuccess:@"Saved" Interaction:1];

//                 PFObject *lastPicture = self.savedPhotoObjects.lastObject;

//                 SendPushNotification(self.selectedRoom, @"New Picture!");
//                 UpdateMessageCounter(self.selectedRoom, @"New Picture!", lastPicture);

//                 PostNotification(NOTIFICATION_REFRESH_INBOX);
//                 PostNotification(NOTIFICATION_CLEAR_CAMERA_STUFF);
//
//                 [[NSNotificationCenter defaultCenter] postNotificationName:NOTIFICATION_OPEN_CHAT_VIEW object:chatView userInfo:@{@"view": chatView}];

//                 self.buttonSend.userInteractionEnabled = YES;

//                 _didSendPictures = YES;
             }
         }
//         else
//         {
//             if (self.navigationController.visibleViewController == self && picture == self.savedPhotoObjects.lastObject && _countDownToPhotoRefresh == 0)
//             {
//                 [ProgressHUD showError:@"Network error."];
//             }
//         }
     }];
}

#pragma mark - "TableView Stuff"

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    ChatRoomCell *cell = [tableView dequeueReusableCellWithIdentifier:@"cell"];
    PFObject *room = [self.messages objectAtIndex:indexPath.row];
    [cell setNeedsUpdateConstraints];
    [cell updateConstraintsIfNeeded];

    if (room[PF_MESSAGES_NICKNAME])
    {
        cell.roomNameLabel.text = room[PF_MESSAGES_NICKNAME];
    }
    else
    {
        NSString *description = room[PF_MESSAGES_DESCRIPTION];
        cell.roomNameLabel.text = description;
    }
    if(room[PF_MESSAGES_LASTMESSAGE])
    {
        cell.lastTextLabel.text = room[PF_MESSAGES_LASTMESSAGE];
    }
    PFObject *picture = room[PF_MESSAGES_LASTPICTURE];
    if (picture)
    {
        PFFile *file = [picture valueForKey:PF_PICTURES_THUMBNAIL];
        cell.imageView.file = file;
        [cell.imageView loadInBackground];

    }
    return cell;
}

- (IBAction)onSendButtonPushed:(id)sender
{
    if (self.selectedRoom)
    {
        [self beginSendingVolliePackage];
    }
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{

    return self.messages.count;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    ChatRoomCell *cell = [tableView cellForRowAtIndexPath:indexPath];
    cell.backgroundColor = [UIColor volleyFamousOrange];
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    PFObject *room = [self.messages objectAtIndex:indexPath.row];
    self.selectedRoom = [room objectForKey:PF_MESSAGES_ROOM];
}


/*
 PFObject *message = [self.messages objectAtIndex:indexPath.row];

 NSString *comment = [message valueForKey:PF_MESSAGES_LASTMESSAGE];
 if ([comment isEqualToString:@""]) {
 comment = @"No comments available";
 }
 cell.labelLastMessage.text = comment;

 UIColor *green = [UIColor volleyFamousGreen];
 cell.labelDescription.textColor = green;
 //    cell.imageUser.layer.borderColor = [UIColor volleyBorderGrey].CGColor;

 if (message == self.selectedMessage)
 {
 cell.imageUser.layer.borderColor = [UIColor whiteColor].CGColor;
 cell.labelInitials.backgroundColor = [UIColor volleyFamousGreen];
 cell.backgroundColor = [UIColor volleyFamousOrange];
 cell.labelDescription.textColor = [UIColor whiteColor];
 cell.labelLastMessage.textColor = [UIColor whiteColor];
 }
 else
 {
 cell.backgroundColor = [UIColor whiteColor];
 cell.labelDescription.textColor = [UIColor blackColor];
 cell.labelLastMessage.textColor = [UIColor lightGrayColor];
 //        cell.imageUser.layer.borderColor = [UIColor volleyBorderGrey].CGColor;
 }

 if (message[PF_MESSAGES_NICKNAME])
 {
 cell.labelDescription.text = message[PF_MESSAGES_NICKNAME];
 }
 else
 {
 NSString *description = message[PF_MESSAGES_DESCRIPTION];

 if (description.length)
 {
 cell.labelDescription.text = description;
 }
 }

 PFObject *picture = [message valueForKey:PF_MESSAGES_LASTPICTURE];

 if (picture)
 {
 PFFile *file = [picture valueForKey:PF_PICTURES_THUMBNAIL];
 cell.imageUser.file = file;
 [cell.imageUser loadInBackground];

 PFUser *user = [message valueForKey:PF_MESSAGES_LASTPICTUREUSER];
 NSString *name = [user valueForKey:PF_USER_FULLNAME];
 NSMutableArray *array = [NSMutableArray arrayWithArray:[name componentsSeparatedByString:@" "]];
 [array removeObject:@" "];

 if (array.count == 2)
 {
 NSString *first = array.firstObject;
 NSString *last = array.lastObject;
 first = [first stringByPaddingToLength:1 withString:name startingAtIndex:0];
 last = [last stringByPaddingToLength:1 withString:name startingAtIndex:0];
 name = [first stringByAppendingString:last];
 cell.labelInitials.text = name;
 cell.labelInitials.hidden = NO;
 }
 }

 return cell;

 */

@end
