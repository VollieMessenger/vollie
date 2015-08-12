//
//  RoomCell.h
//  Volley
//
//  Created by Kyle Bendelow on 8/4/15.
//  Copyright (c) 2015 KZ. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <Parse/Parse.h>
#import <ParseUI/ParseUI.h>

@interface RoomCell : UITableViewCell

-(void)formatCellWith:(PFObject*)room;

@property (weak, nonatomic) IBOutlet UIImageView *unreadStatusDot;
@property (weak, nonatomic) IBOutlet UILabel *chatRoomLabel;
@property (weak, nonatomic) IBOutlet UILabel *lastMessageLabel;
@property (weak, nonatomic) IBOutlet UILabel *dateLabel;
@property (weak, nonatomic) IBOutlet PFImageView *imageView;
@property PFObject *room;

@end
