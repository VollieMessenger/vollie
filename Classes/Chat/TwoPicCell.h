//
//  TwoPicCell.h
//  Volley
//
//  Created by Kyle on 7/13/15.
//  Copyright (c) 2015 KZ. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <Parse/Parse.h>
#import <ParseUI/ParseUI.h>
#import "VollieCardData.h"

@interface TwoPicCell : UITableViewCell

@property (strong, nonatomic) IBOutlet PFImageView *imageViewOne;
@property (strong, nonatomic) IBOutlet PFImageView *imageViewTwo;
@property (strong, nonatomic) IBOutlet UIView *cardView;

-(void)fillPicsWithVollieCardData:(VollieCardData*)vollieCardData;
-(void)formatCell;
@property (strong, nonatomic) IBOutlet UIView *viewForChatVC;

@property NSMutableArray *imageViewArray;

@end
