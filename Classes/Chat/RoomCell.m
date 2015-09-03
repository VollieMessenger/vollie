//
//  RoomCell.m
//  Volley
//
//  Created by Kyle Bendelow on 8/4/15.
//  Copyright (c) 2015 KZ. All rights reserved.
//

#import "RoomCell.h"
#import "AppConstant.h"
#import "NSDate+TimeAgo.h"

@implementation RoomCell
@synthesize imageView;

-(void)formatCellWith:(PFObject *)room
{
    self.imageView.layer.cornerRadius = 10;
    self.imageView.layer.masksToBounds = YES;
    [self.imageView setImage:nil];
    [self.chatRoomLabel setText:nil];
    [self.lastMessageLabel setText:nil];
    
    self.room = room;
    
    [self fillInTextFields];
    [self checkUnreadStatus];
    [self fillInPicture];
}

-(void)fillInTextFields
{
//    PFObject *info = room[PF_MESSAGES_ROOM];
    
    
    //fills in text labels
    if (self.room[PF_MESSAGES_NICKNAME])
    {
        self.chatRoomLabel.text = self.room[PF_MESSAGES_NICKNAME];
    }
    else
    {
        NSString *description = self.room[PF_MESSAGES_DESCRIPTION];
        if (description.length)
        {
            self.chatRoomLabel.text = description;
        }
    }
    self.lastMessageLabel.text = self.room[PF_MESSAGES_LASTMESSAGE];
    NSDate *date = self.room[PF_MESSAGES_UPDATEDACTION];
    NSString *ago = [date dateTimeUntilNow];
    self.dateLabel.text = ago;
}

-(void)checkUnreadStatus
{
    //unread messages dot
    int counter = [self.room[PF_MESSAGES_COUNTER] intValue];
    if (counter > 0)
    {
        self.unreadStatusDot.image = [UIImage imageNamed:ASSETS_UNREAD];
    }
    else
    {
        self.unreadStatusDot.image = [UIImage imageNamed:ASSETS_READ];
    }
}

-(void)fillInPicture
{
    PFObject *pictureObject = [self.room valueForKey:PF_MESSAGES_LASTPICTURE];
    NSLog(@"%@",self.room);
    if (pictureObject)
    {
        PFFile *file = [pictureObject valueForKey:PF_PICTURES_THUMBNAIL];
        //                [cell.imageUser loadInBackground];
        [file getDataInBackgroundWithBlock:^(NSData *data, NSError *error) {
            if (!error)
            {
                self.imageView.image = [UIImage imageWithData:data];
            }
            else
            {
                NSLog(@"there was an error getting the picture");
            }
        }];
    } else {
        [self.imageView setImage:nil];
    }
}

- (void)awakeFromNib {
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
