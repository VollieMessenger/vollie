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

@end

@implementation SelectRoomVC

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view.

    self.tableView.backgroundColor = [UIColor clearColor];
    self.title = @"Send to...";
    self.messages = [NSMutableArray new];
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

#pragma mark - "TableView Stuff"

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    ChatRoomCell *cell = [tableView dequeueReusableCellWithIdentifier:@"cell"];
    PFObject *room = [self.messages objectAtIndex:indexPath.row];
    [cell setNeedsUpdateConstraints];
    [cell updateConstraintsIfNeeded];
//    cell.lastImageView.layer.cornerRadius = 10;
//    cell.lastImageView.layer.masksToBounds = YES;

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

    
//
    PFObject *picture = room[PF_MESSAGES_LASTPICTURE];
//
    if (picture)
    {
        PFFile *file = [picture valueForKey:PF_PICTURES_THUMBNAIL];
        cell.imageView.file = file;
        [cell.imageView loadInBackground];

    }
//    {
//        PFFile *file = [picture valueForKey:PF_PICTURES_THUMBNAIL];
//        NSString *tempString = file.url;
//        NSURL *tempURL = [NSURL URLWithString:tempString];
//        NSData *tempData = [NSData dataWithContentsOfURL:tempURL];
//        UIImage *thumbnailImage = [UIImage imageWithData:tempData];
//        cell.lastImageView.image = thumbnailImage;
////        NSLog(@"%@", file);
//    }
    return cell;
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{

    return self.messages.count;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    //make it send messages here
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
//    [tableView reloadData];
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
