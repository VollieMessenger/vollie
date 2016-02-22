//
//  DynamicCardCell.h
//  Volley
//
//  Created by Kyle Bendelow on 2/12/16.
//  Copyright © 2016 KZ. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <Parse/Parse.h>
#import <ParseUI/ParseUI.h>
#import "VollieCardData.h"
#import "JSQMessages.h"

@interface DynamicCardCell : UITableViewCell
@property (strong, nonatomic) IBOutlet PFImageView *imageViewOne;
@property (strong, nonatomic) IBOutlet PFImageView *imageViewTwo;
@property (strong, nonatomic) IBOutlet UIView *cardView;

-(void)fillPicsWithVollieCardData:(VollieCardData*)vollieCardData;
-(void)formatCell;
@property (strong, nonatomic) IBOutlet UIView *viewForChatVC;
@property (weak, nonatomic) IBOutlet UIImageView *notificationDot;
@property (weak, nonatomic) IBOutlet UILabel *titleLabel;

@property NSMutableArray *imageViewArray;
@property (weak, nonatomic) IBOutlet UILabel *unreadMessagesLabel;
@property (weak, nonatomic) IBOutlet UIImageView *imageIfNoMessages;

@end
