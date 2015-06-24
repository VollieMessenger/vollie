//
//  ChatRoomCell.h
//  Volley
//
//  Created by Kyle on 6/24/15.
//  Copyright (c) 2015 KZ. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <Parse/Parse.h>

@interface ChatRoomCell : UITableViewCell
@property (strong, nonatomic) IBOutlet UILabel *roomNameLabel;
@property (strong, nonatomic) IBOutlet UIImageView *lastImageView;

@end
