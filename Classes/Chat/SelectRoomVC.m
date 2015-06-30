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
#import "utilities.h"
#import "AppDelegate.h"
//#import "messages.h"


@interface SelectRoomVC () <UITableViewDataSource, UITableViewDelegate>

@property (strong, nonatomic) IBOutlet UITableView *tableView;

@property NSMutableArray *messages;
@property NSMutableArray *savedPhotoObjects;
@property NSMutableArray *savedImageFiles;
@property NSMutableArray *objectsForParse;

@property PFObject *selectedRoom;
@property PFObject *selectedSet;
//@property PFObject *selectedMessage;

@property int countDownToPhotoRefresh;
@property BOOL isThePicturesReadyToSend;

@property int counterForLastPhotoTaken;

@end

@implementation SelectRoomVC

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view.
//    NSLog(@"%li photos", self.photosToSend.count);
//    NSLog(@"%@ is the text i'm gonna send", self.textToSend);

    self.tableView.backgroundColor = [UIColor clearColor];
    self.title = @"Send to...";
    self.messages = [NSMutableArray new];
    self.savedPhotoObjects = [NSMutableArray new];
    self.savedImageFiles = [NSMutableArray new];
    self.objectsForParse = [NSMutableArray new];
    [self loadData];
    self.counterForLastPhotoTaken = (int)self.photosToSend.count;
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

             [self.selectedSet setValue:self.selectedRoom forKey:PF_SET_ROOM];
             [self.selectedSet setValue:[PFUser currentUser] forKey:PF_SET_USER];
             [self.selectedSet saveInBackground];
//             NSLog(@"%@ is teh selected set", self.selectedSet);

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
    self.counterForLastPhotoTaken = (int)self.photosToSend.count;

    for (id imageOrFile in self.photosToSend)
    {
        if ([imageOrFile isKindOfClass:[UIImage class]])
        {
            self.counterForLastPhotoTaken--;
            UIImage *image = imageOrFile;
            PFFile *imageFile = [PFFile fileWithName:@"image.png"
                                                data:UIImageJPEGRepresentation(image, .5)];
            PFObject *picture = [self basicParseObjectSetupWith:imageOrFile and:image];
            [picture setObject:imageFile forKey:PF_PICTURES_PICTURE];

            [self.savedPhotoObjects addObject:picture];
            [self.savedImageFiles addObject:imageFile];
            [self saveParseObjectInBackgroundWith:picture];
            [self lastPhotoCheckerAndSetterWith:picture];

        }
        else if ([imageOrFile isKindOfClass:[NSDictionary class]])
        {
            self.counterForLastPhotoTaken--;
            NSDictionary *dic = imageOrFile;
            NSString *path = dic.allKeys.firstObject;
            UIImage *image = dic.allValues.firstObject;
            PFFile *videoFile = [PFFile fileWithName:@"video.mov" contentsAtPath:path];
            PFObject *video = [self basicParseObjectSetupWith:imageOrFile and:image];
            [video setValue:@YES forKey:PF_PICTURES_IS_VIDEO];

            [video setValue:[NSDate dateWithTimeIntervalSinceNow:[self.photosToSend indexOfObject:dic]]forKey:PF_PICTURES_UPDATEDACTION];

            [self.savedPhotoObjects addObject:video];
            [self.savedImageFiles addObject:videoFile];

            [self saveParseObjectInBackgroundWith:video];
            [self lastPhotoCheckerAndSetterWith:video];
        }
    }
    [self checkForTextAndSendIt];
}

-(void)checkForTextAndSendIt
{
    if (![self.textToSend isEqualToString:@""] && ![self.textToSend isEqualToString:@"Type Message Here..."])
    {
        PFObject *object = [PFObject objectWithClassName:PF_CHAT_CLASS_NAME];
        object[PF_CHAT_USER] = [PFUser currentUser];
        object[PF_CHAT_ROOM] = self.selectedRoom;
        object[PF_CHAT_TEXT] = self.textToSend;
        object[PF_CHAT_SETID] = self.selectedSet;
        [object setValue:[NSDate date] forKey:PF_PICTURES_UPDATEDACTION];
        [self saveParseObjectInBackgroundWith:object];
    }
}

-(void)lastPhotoCheckerAndSetterWith:(PFObject*)object
{
    if (self.counterForLastPhotoTaken == 0)
    {
        [self.selectedSet setValue:object forKey:PF_SET_LASTPICTURE];
        [self.selectedSet saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error)
        {
            if (!error)
            {
                NSLog(@"updated last picture for set");
            }
        }];
        [self.selectedRoom setValue:object forKey:@"lastPicture"];
        [self.selectedRoom saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error)
         {
             if (!error)
             {
                 NSLog(@"updated last picture for set");
             }
         }];
    }
}

-(void)saveParseObjectInBackgroundWith:(PFObject*)object
{
//    NSLog(@"I'M SAVING THIS: %@", object);
    [object saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
        if (!error)
        {

        }
    }];
}

-(PFObject*)basicParseObjectSetupWith:(id)imageOrFile and:(UIImage *)image
{
    PFObject *object = [PFObject objectWithClassName:PF_PICTURES_CLASS_NAME];
    [object setValue:[PFUser currentUser] forKey:PF_PICTURES_USER];
    [object setValue:@YES forKey:PF_CHAT_ISUPLOADED];
    [object setValue:[NSDate dateWithTimeIntervalSinceNow:[self.photosToSend indexOfObject:object]]forKey:PF_PICTURES_UPDATEDACTION];
    [object setValue:self.selectedSet forKey:PF_PICTURES_SETID];
    [object setValue:self.selectedRoom forKey:PF_PICTURES_CHATROOM];
    UIImage *thumbnail = ResizeImage(image, image.size.width, image.size.height);
    PFFile *file = [PFFile fileWithName:@"thumbnail.png" data:UIImageJPEGRepresentation(thumbnail, .2)];
    [object setValue:[NSDate dateWithTimeIntervalSinceNow:[self.photosToSend indexOfObject:image]]forKey:PF_PICTURES_UPDATEDACTION];
    [object setObject:file forKey:PF_PICTURES_THUMBNAIL];

    return object;
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
