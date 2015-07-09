//
//  ChatRoomCell.h
//  Volley
//
//  Created by Kyle on 6/24/15.
//  Copyright (c) 2015 KZ. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <Parse/Parse.h>
#import <ParseUI/ParseUI.h>

@interface ChatRoomCell : UITableViewCell
@property (strong, nonatomic) IBOutlet PFImageView *imageView;
@property (strong, nonatomic) IBOutlet UILabel *lastTextLabel;
@property (strong, nonatomic) IBOutlet UILabel *roomNameLabel;
//@property (strong, nonatomic) IBOutlet UIImageView *lastImageView;
@property (strong, nonatomic) IBOutlet UIImageView *selectedImageView;

@end
