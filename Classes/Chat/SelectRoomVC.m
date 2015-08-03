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
#import "pushnotification.h"
#import "messages.h"
#import "CreateChatroomView.h"
//#import "ParseVolliePackage.h"

@interface SelectRoomVC () <UITableViewDataSource, UITableViewDelegate, UINavigationBarDelegate>

@property (strong, nonatomic) IBOutlet UITableView *tableView;
@property (strong, nonatomic) IBOutlet UIButton *sendButton;

@property NSMutableArray *messages;
@property NSMutableArray *savedPhotoObjects;
@property NSMutableArray *savedImageFiles;
@property NSMutableArray *objectsForParse;
@property NSMutableArray *cellsArray;

@property PFObject *selectedRoom;
@property PFObject *selectedSet;
//@property PFObject *selectedMessage;

@property int countDownToPhotoRefresh;
@property BOOL isThePicturesReadyToSend;

@property int counterForLastPhotoTaken;
@property (weak, nonatomic) IBOutlet UIImageView *vollieIconOnNewButton;

@end

@implementation SelectRoomVC

- (void)viewDidLoad
{
    [super viewDidLoad];

    self.tableView.backgroundColor = [UIColor clearColor];
    self.title = @"Send to...";
    self.messages = [NSMutableArray new];
    self.savedPhotoObjects = [NSMutableArray new];
    self.savedImageFiles = [NSMutableArray new];
    self.objectsForParse = [NSMutableArray new];
    self.cellsArray = [NSMutableArray new];
    [self loadData];
    self.counterForLastPhotoTaken = (int)self.photosToSend.count;

    self.sendButton.hidden = YES;
    self.sendButton.backgroundColor = [UIColor volleyFamousOrange];
    [self.sendButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    self.sendButton.titleLabel.font = [UIFont fontWithName:@"ArialRoundedMTBold" size:17.0];
    
    self.vollieIconOnNewButton.layer.cornerRadius = 10;
    self.vollieIconOnNewButton.layer.masksToBounds = YES;

//    [self.inputToolbar.contentView.rightBarButtonItem setTitleColor:[UIColor volleyFamousOrange] forState:UIControlStateNormal];
}

- (void)loadData
{
    if ([PFUser currentUser])
    {
        NavigationController *nav  = [(AppDelegate *)[[UIApplication sharedApplication] delegate] navInbox];
        // LOAD MESSAGES FROM INBOX INSTEAD.
        MessagesView *view = nav.viewControllers.firstObject;
        self.messages = view.messages;
        NSLog(@"%li messages coming in", view.messages.count);
    }
}

#pragma mark "ParseStuff"
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
             [self.selectedSet setValue:self.selectedRoom forKey:PF_SET_ROOM];
             [self.selectedSet setValue:[PFUser currentUser] forKey:PF_SET_USER];

             if (self.photosToSend.count)
             {
//                 [self createParseObjectsWithPhotosArray];
//                 ParseVolliePackage *volliePackage = [ParseVolliePackage new];

                 [self.package sendPhotosWithPhotosArray:self.photosToSend
                                                andText:self.textToSend
                                                andRoom:self.selectedRoom
                                                 andSet:self.selectedSet];

                 [self.navigationController popToViewController:[self.navigationController.viewControllers objectAtIndex:0] animated:YES];
             }
             else
             {
//                 ParseVolliePackage *volliePackage = [ParseVolliePackage new];
                 [self.package checkForTextAndSendItWithText:self.textToSend
                                                      andRoom:self.selectedRoom
                                                       andSet:self.selectedSet];

                 [self.navigationController popToViewController:[self.navigationController.viewControllers objectAtIndex:0] animated:YES];
             }
         }
         else
         {
             [ProgressHUD showError:@"Network Error"];
         }
     }];
}

#pragma mark - "TableView Stuff"

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    ChatRoomCell *cell = [tableView dequeueReusableCellWithIdentifier:@"cell"];
    PFObject *room = [self.messages objectAtIndex:indexPath.row];
    [cell setNeedsUpdateConstraints];
    [cell updateConstraintsIfNeeded];
//    cell.selectedImageView.backgroundColor = [UIColor colorWithWhite:0.702 alpha:1.000];
//    cell.selectedImageView.layer.cornerRadius = 10;
//    cell.selectedImageView.layer.masksToBounds = YES;
    cell.selectedImageView.image = [UIImage imageNamed:@"check-mark-unselected-gray"];
//    cell.selectedImageView.layer.borderColor = [UIColor volleyFamousOrange].CGColor;
//    cell.selectedImageView.layer.borderWidth = 1;

    [self.cellsArray addObject:cell];

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
        cell.imageView.layer.cornerRadius = 10;
        cell.imageView.layer.masksToBounds = YES;
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
    for (ChatRoomCell *cell in self.cellsArray)
    {
//        cell.selectedImageView.backgroundColor = [UIColor clearColor];
        cell.selectedImageView.image = [UIImage imageNamed:@"check-mark-unselected-gray"];
    }

//    self.sendButton.hidden = NO;

    if (self.sendButton.isHidden) {
        self.sendButton.hidden = NO;
        self.sendButton.alpha = 0;
        [UIView animateWithDuration:.3f animations:^{
            self.sendButton.alpha = 1;
        }];
    }

    ChatRoomCell *cell = [tableView cellForRowAtIndexPath:indexPath];
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
//    cell.selectedImageView.backgroundColor = [UIColor volleyFamousOrange];
    cell.selectedImageView.image = [UIImage imageNamed:@"checkmark"];

    PFObject *room = [self.messages objectAtIndex:indexPath.row];
    self.selectedRoom = [room objectForKey:PF_MESSAGES_ROOM];
}

- (IBAction)createRoom:(id)sender {
    CreateChatroomView * view = [[CreateChatroomView alloc]init];
    view.title = @"ahhhhh";
    view.isTherePicturesToSend = self.savedPhotoObjects.count;
    view.invite = NO;
    view.sendingMessage = self.textToSend;
    view.package = self.package;
    [self.navigationController pushViewController:view animated:YES];
}

@end
